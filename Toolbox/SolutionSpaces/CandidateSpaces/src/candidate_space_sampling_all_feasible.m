function [designSample,paddingSample] = candidate_space_sampling_all_feasible(candidateSpace,component,nSample,varargin)
%CANDIDATE_SPACE_SAMPLING_ALL_FEASIBLE Sampling inside candidate spaces
%   CANDIDATE_SPACE_SAMPLING_ALL_FEASIBLE produces design sample points that
%   are inside all of the candidates spaces; it does so by generating a sample
%   in the complete space and then checking which design points are 
%   simultaneously inside all of the candidate spaces. While not enough samples
%   have been generated, the process repeats.
%
%   DESIGNSAMPLE = CANDIDATE_SPACE_SAMPLING_ALL_FEASIBLE(CANDIDATESPACE,
%   COMPONENT,NSAMPLE) generates NSAMPLE design sample points that are inside 
%   the candidate spaces CANDIDATESPACE, with components COMPONENT, returning
%   said sample in DESIGNSAMPLE.
%
%   DESIGNSAMPLE = CANDIDATE_SPACE_SAMPLING_ALL_FEASIBLE(...NAME,VALUE,...) 
%   allows for the specification of additional options. These are:
%       - 'SamplingMethodFunction' : base sampling method to be used. Default:
%       @sampling_random.
%       - 'SamplingMethodOptions' : extra options for the base sampling method.
%       Default is empty.
%
%       - 'MaxNumberPaddingSamples' : maximum padding samples to return. If set,
%       padding memory is preallocated and capped to this size. Default: [].
%
%       - 'UseDesignSpaceForSampling' : when true, use
%       DesignSpaceLowerBound/DesignSpaceUpperBound instead of SamplingBox to
%       build the sampling box. Default: false.
%
%   [DESIGNSAMPLE,PADDINGSAMPLE] = CANDIDATE_SPACE_SAMPLING_ALL_FEASIBLE(...)
%   additionally returns extra samples generated PADDINGSAMPLE, which are not
%   inside at least one of the candidate spaces.
%
%   Input:
%       - CANDIDATESPACE : (1,nCandidateSpace) CandidateSpaceBase
%       - COMPONENT : (1,nComponent) cell
%       - NSAMPLE : inteter
%       - 'SamplingMethodFunction' : function_handle
%       - 'SamplingMethodOptions' : (1,nOption) cell
%
%   Output:
%       - DESIGNSAMPLE : (nSample,nDesignVariable) double
%       - PADDINGSAMPLE : (nSampleExtra,nDesignVariable) double
%
%   See also sso_component_stochastic, 
%   candidate_space_sampling_individual_feasible.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2023-2025.
%   Copyright 2023-2025 Eduardo Rodrigues Della Noce
%   SPDX-License-Identifier: Apache-2.0

%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%   
%       http://www.apache.org/licenses/LICENSE-2.0
%   
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.

    parser = inputParser;
    parser.addParameter('SamplingMethodFunction',@sampling_random);
    parser.addParameter('SamplingMethodOptions',{});
    parser.addParameter('MaxNumberPaddingSamples',[],@(x)isnumeric(x)&&isscalar(x)&&x>=0&&mod(x,1)==0);
    parser.addParameter('UseDesignSpaceForSampling',false,@(x)islogical(x)||(isnumeric(x)&&isscalar(x)));
    parser.parse(varargin{:});
    options = parser.Results;

    nComponent = size(component,2);

    % create sampling box
    nDesignVariable = 0;
    for i=1:nComponent
        nDesignVariable = nDesignVariable + length(component{i});
    end
    samplingBox = nan(2,nDesignVariable);
    for i=1:nComponent
        if options.UseDesignSpaceForSampling
            samplingBox(:,component{i}) = [candidateSpace(i).DesignSpaceLowerBound; ...
                candidateSpace(i).DesignSpaceUpperBound];
        else
            samplingBox(:,component{i}) = candidateSpace(i).SamplingBox;
        end
    end

    % start generating samples
    designSample = nan(nSample,size(samplingBox,2));
    % initialize padding storage (fixed capacity when MaxNumberPaddingSamples is
    % provided; otherwise dynamic with doubling strategy)
    isFixedPaddingCapacity = ~isempty(options.MaxNumberPaddingSamples);
    if isFixedPaddingCapacity
        paddingCapacity = options.MaxNumberPaddingSamples;
    else
        paddingCapacity = nSample;
    end
    paddingSample = nan(paddingCapacity,size(samplingBox,2));
    nStoredPadding = 0;
    nGeneratedDesignSample = 0;
    while (nGeneratedDesignSample < nSample)
        % sample inside bounding box with traditional methods
        initialsample = options.SamplingMethodFunction(samplingBox,nSample,options.SamplingMethodOptions{:});
        
        % see which designs are within all candidate spaces -> should be evaluated
        isInsideCandidateSpace = false(nSample,nComponent);
        for i=1:nComponent
            isInsideCandidateSpace(:,i) = candidateSpace(i).is_in_candidate_space(initialsample(:,component{i}));
        end
        toBeEvaluated = all(isInsideCandidateSpace,2);
        nValid = sum(toBeEvaluated);

        % if we don't have enough, loop again; otherwise, fill remaining only
        if(nGeneratedDesignSample + nValid < nSample)
            if nValid>0
                designSample(nGeneratedDesignSample+1:nGeneratedDesignSample+nValid,:) = initialsample(toBeEvaluated,:);
                padChunk = initialsample(~toBeEvaluated,:);
                if ~isempty(padChunk)
                    nPadNew = size(padChunk,1);
                    if isFixedPaddingCapacity
                        nWritable = min(nPadNew,max(0,paddingCapacity - nStoredPadding));
                        if nWritable>0
                            paddingSample(nStoredPadding+1:nStoredPadding+nWritable,:) = padChunk(1:nWritable,:);
                            nStoredPadding = nStoredPadding + nWritable;
                        end
                    else
                        if nStoredPadding + nPadNew > paddingCapacity
                            newCapacity = max(paddingCapacity*2,nStoredPadding+nPadNew);
                            paddingSample(paddingCapacity+1:newCapacity,:) = nan(newCapacity-paddingCapacity,size(samplingBox,2));
                            paddingCapacity = newCapacity;
                        end
                        paddingSample(nStoredPadding+1:nStoredPadding+nPadNew,:) = padChunk;
                        nStoredPadding = nStoredPadding + nPadNew;
                    end
                end
                nGeneratedDesignSample = nGeneratedDesignSample + nValid;
            end
        else
            % find how many extras must be removed and the main index
            nExtraSample = nGeneratedDesignSample + nValid - nSample;
            if(nExtraSample>0)
                iExtra = find(toBeEvaluated,nExtraSample,'last');
                iStopConcatenation = iExtra(1)-1;
            else
                iStopConcatenation = length(toBeEvaluated);
            end
            % add everything before that
            designSample(nGeneratedDesignSample+1:nSample,:) = initialsample(toBeEvaluated(1:iStopConcatenation),:);
            padChunk = initialsample(~toBeEvaluated(1:iStopConcatenation),:);
            if ~isempty(padChunk)
                nPadNew = size(padChunk,1);
                if isFixedPaddingCapacity
                    nWritable = min(nPadNew,max(0,paddingCapacity - nStoredPadding));
                    if nWritable>0
                        paddingSample(nStoredPadding+1:nStoredPadding+nWritable,:) = padChunk(1:nWritable,:);
                        nStoredPadding = nStoredPadding + nWritable;
                    end
                else
                    if nStoredPadding + nPadNew > paddingCapacity
                        newCapacity = max(paddingCapacity*2,nStoredPadding+nPadNew);
                        paddingSample(paddingCapacity+1:newCapacity,:) = nan(newCapacity-paddingCapacity,size(samplingBox,2));
                        paddingCapacity = newCapacity;
                    end
                    paddingSample(nStoredPadding+1:nStoredPadding+nPadNew,:) = padChunk;
                    nStoredPadding = nStoredPadding + nPadNew;
                end
            end
            nGeneratedDesignSample = nSample;
        end
    end
    % trim padding storage
    paddingSample = paddingSample(1:nStoredPadding,:);

    if(size(designSample,1)~=nSample)
        error('Failed to generate enough design samples');
    end
end