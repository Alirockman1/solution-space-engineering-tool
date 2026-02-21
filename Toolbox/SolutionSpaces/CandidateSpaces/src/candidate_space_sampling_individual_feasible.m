function [designSample,paddingSample] = candidate_space_sampling_individual_feasible(candidateSpace,componentIndex,nSample,varargin)
%CANDIDATE_SPACE_SAMPLING_INDIVIDUAL_FEASIBLE Sampling inside candidate spaces
%   CANDIDATE_SPACE_SAMPLING_INDIVIDUAL_FEASIBLE produces design sample points 
%   that are inside all of the candidates spaces; it does so by sequentially 
%   generating samples that are inside each candidate space individually, and 
%   then combining the results at the end. While not enough samples have been 
%   generated for each component separately, the process repeats for those 
%   components.
%
%   DESIGNSAMPLE = CANDIDATE_SPACE_SAMPLING_INDIVIDUAL_FEASIBLE(CANDIDATESPACE,
%   COMPONENTINDEX,NSAMPLE) generates NSAMPLE design sample points that are  
%   inside the candidate spaces CANDIDATESPACE, with components COMPONENTINDEX, 
%   returning said sample in DESIGNSAMPLE.
%
%   DESIGNSAMPLE = CANDIDATE_SPACE_SAMPLING_INDIVIDUAL_FEASIBLE(...NAME,VALUE,
%   ...) allows for the specification of additional options. These are:
%       - 'SamplingMethodFunction' : base sampling method to be used. Default:
%       @sampling_random.
%       - 'SamplingMethodOptions' : extra options for the base sampling method.
%       Default is empty.
%
%       - 'MaxNumPaddingSamples' : maximum padding samples to return. If set,
%       padding is preallocated and capped to this size. Default: [].
%
%       - 'UseDesignSpaceForSampling' : when true, use
%       DesignSpaceLowerBound/DesignSpaceUpperBound instead of SamplingBox to
%       build the sampling box. Default: false.
%
%   [DESIGNSAMPLE,PADDINGSAMPLE] = CANDIDATE_SPACE_SAMPLING_INDIVIDUAL_FEASIBLE
%   (...) additionally returns extra samples generated PADDINGSAMPLE, which are
%   not inside at least one of the candidate spaces.
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
%   See also sso_component_stochastic, candidate_space_sampling_all_feasible.

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

    nComponent = size(componentIndex,2);

    % create sampling box
    nDesignVariable = 0;
    for i=1:nComponent
        nDesignVariable = nDesignVariable + length(componentIndex{i});
    end
    samplingBox = nan(2,nDesignVariable);
    for i=1:nComponent
        if options.UseDesignSpaceForSampling
            samplingBox(:,componentIndex{i}) = [candidateSpace(i).DesignSpaceLowerBound; ...
                candidateSpace(i).DesignSpaceUpperBound];
        else
            samplingBox(:,componentIndex{i}) = candidateSpace(i).SamplingBox;
        end
    end

    % start generating samples
    designSample = nan(nSample,size(samplingBox,2));
    paddingSampleComponent = cell(1,nComponent);
    nPadComponent = nan(1,nComponent);
    for i=1:nComponent
        nDesignVariableComponent = length(componentIndex{i});

        designSampleComponent = nan(nSample,nDesignVariableComponent);

        % initialize padding storage
        isFixedPaddingCapacity = ~isempty(options.MaxNumberPaddingSamples);
        if isFixedPaddingCapacity
            paddingCapacity = options.MaxNumberPaddingSamples;
        else
            paddingCapacity = nSample;
        end
        paddingSampleComponent{i} = nan(paddingCapacity,nDesignVariableComponent);
        nStoredPadding = 0;

        samplingBoxComponent = samplingBox(:,componentIndex{i});
        nGeneratedDesignSample = 0;

        % generate samples for each candidate space separately
        while (nGeneratedDesignSample < nSample)
            currentSample = options.SamplingMethodFunction(samplingBoxComponent,nSample,options.SamplingMethodOptions{:});

            % see which designs are within current candidate spaces -> should be evaluated
            toBeEvaluated = candidateSpace(i).is_in_candidate_space(currentSample);
            nValid = sum(toBeEvaluated);

            % if we don't have enough, loop again;
            % if we do, get only those necessary and be done.
            if(nGeneratedDesignSample+nValid < nSample)
                if(nValid>0)
                    designSampleComponent(nGeneratedDesignSample+1:nGeneratedDesignSample+nValid,:) = currentSample(toBeEvaluated,:);
                    padChunk = currentSample(~toBeEvaluated,:);
                    if ~isempty(padChunk)
                        nPadNew = size(padChunk,1);
                        if isFixedPaddingCapacity
                            nWritable = min(nPadNew,max(0,paddingCapacity - nStoredPadding));
                            if nWritable>0
                                paddingSampleComponent{i}(nStoredPadding+1:nStoredPadding+nWritable,:) = padChunk(1:nWritable,:);
                                nStoredPadding = nStoredPadding + nWritable;
                            end
                        else
                            if nStoredPadding + nPadNew > paddingCapacity
                                newCapacity = max(paddingCapacity*2,nStoredPadding+nPadNew);
                                paddingSampleComponent{i}(paddingCapacity+1:newCapacity,:) = nan(newCapacity-paddingCapacity,nDesignVariableComponent);
                                paddingCapacity = newCapacity;
                            end
                            paddingSampleComponent{i}(nStoredPadding+1:nStoredPadding+nPadNew,:) = padChunk;
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
                    iStopConcatenation = nSample;
                end

                % add everything before that
                designSampleComponent(nGeneratedDesignSample+1:nSample,:) = currentSample(toBeEvaluated(1:iStopConcatenation),:);
                padChunk = currentSample(~toBeEvaluated(1:iStopConcatenation),:);
                if ~isempty(padChunk)
                    nPadNew = size(padChunk,1);
                    if isFixedPaddingCapacity
                        nWritable = min(nPadNew,max(0,paddingCapacity - nStoredPadding));
                        if nWritable>0
                            paddingSampleComponent{i}(nStoredPadding+1:nStoredPadding+nWritable,:) = padChunk(1:nWritable,:);
                            nStoredPadding = nStoredPadding + nWritable;
                        end
                    else
                        if nStoredPadding + nPadNew > paddingCapacity
                            newCapacity = max(paddingCapacity*2,nStoredPadding+nPadNew);
                            paddingSampleComponent{i}(paddingCapacity+1:newCapacity,:) = nan(newCapacity-paddingCapacity,nDesignVariableComponent);
                            paddingCapacity = newCapacity;
                        end
                        paddingSampleComponent{i}(nStoredPadding+1:nStoredPadding+nPadNew,:) = padChunk;
                        nStoredPadding = nStoredPadding + nPadNew;
                    end
                end

                nGeneratedDesignSample = nSample;
            end
        end
        
        designSample(:,componentIndex{i}) = designSampleComponent;
        if isFixedPaddingCapacity
            if nStoredPadding>0
                paddingSampleComponent{i} = paddingSampleComponent{i}(1:nStoredPadding,:);
            else
                paddingSampleComponent{i} = zeros(0,nDesignVariableComponent);
            end
        else
            paddingSampleComponent{i} = paddingSampleComponent{i}(1:nStoredPadding,:);
        end
        nPadComponent(i) = nStoredPadding;
    end
    
    nPaddingBiggest = max(nPadComponent);
    if ~isempty(options.MaxNumberPaddingSamples)
        nPaddingOutput = min(nPaddingBiggest,options.MaxNumberPaddingSamples);
    else
        nPaddingOutput = nPaddingBiggest;
    end
    if nPaddingOutput<=0
        paddingSample = zeros(0,size(samplingBox,2));
        return;
    end
    paddingSample = nan(nPaddingOutput,size(samplingBox,2));
    for i=1:nComponent
        samplingBoxComponent = samplingBox(:,componentIndex{i});
        
        % sample inside bounding box with traditional methods
        nKeep = min(size(paddingSampleComponent{i},1),nPaddingOutput);
        nMissing = nPaddingOutput - nKeep;
        if nMissing>0
            paddingAdditionalSample = options.SamplingMethodFunction(samplingBoxComponent,nMissing,options.SamplingMethodOptions{:});
        else
            paddingAdditionalSample = zeros(0,size(samplingBoxComponent,2));
        end
        if nKeep>0
            paddingSample(1:nKeep,componentIndex{i}) = paddingSampleComponent{i}(1:nKeep,:);
        end
        if nMissing>0
            paddingSample(nKeep+1:nPaddingOutput,componentIndex{i}) = paddingAdditionalSample;
        end
    end

    if(size(designSample,1)~=nSample)
        error('Failed to generate enough design samples');
    end
end