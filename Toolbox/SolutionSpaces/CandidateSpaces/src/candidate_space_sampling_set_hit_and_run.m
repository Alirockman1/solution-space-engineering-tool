function [designSample,paddingSample] = candidate_space_sampling_set_hit_and_run(candidateSpace,componentIndex,nSample,varargin)
%CANDIDATE_SPACE_SAMPLING_SET_HIT_AND_RUN Markov Chain Monte Carlo Sampling

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
    parser.addParameter('UseDesignSpaceForSampling',false,@(x)islogical(x) && isscalar(x));
    parser.addParameter('NumberGeneratedCandidateSamples',10*nSample,@(x)isnumeric(x) && isscalar(x) && x > 0);
    parser.addParameter('RegionLimitLineSearchOptions',{},@(x)iscell(x));
    parser.addParameter('LineWalkSteps',3,@(x)isnumeric(x) && isscalar(x) && x > 0);
    parser.addParameter('SelectionCriterion','max-distance',@(x)any(strcmpi(x,{'random','max-distance'})));
    parser.addParameter('SelectionDistanceOptions',{},@(x)iscell(x));
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
    designSample = nan(nSample,nDesignVariable);
    paddingSampleComponent = cell(1,nComponent);

    for iComponent = 1:nComponent
        pointInside = candidateSpace(iComponent).DesignSampleDefinition(candidateSpace(iComponent).IsInsideDefinition,:);
        if(isempty(pointInside))
            error('candidate_space_sampling_set_hit_and_run:NoDesignSampleDefinition','No design sample definition found for component %d.',iComponent);
        end

        iCurrentPoint = randsample(size(pointInside,1),options.NumberGeneratedCandidateSamples,true);
        currentPoint = pointInside(iCurrentPoint,:);

        nDimension = size(currentPoint,2);
        candidateSpaceBox = samplingBox(:,componentIndex{iComponent});
        isInsideCandidateSpace = @(x)candidateSpace(iComponent).is_in_candidate_space(x);

        for iStep = 1:options.LineWalkSteps
            lineDirection = options.SamplingMethodFunction([-ones(1,nDimension);ones(1,nDimension)],options.NumberGeneratedCandidateSamples,options.SamplingMethodOptions{:});
            lineDirection = lineDirection ./ vecnorm(lineDirection,2,2);

            lineLimitPositive = find_candidate_space_boundary_newton(...
                candidateSpace(iComponent),...
                currentPoint,...
                lineDirection,...
                candidateSpaceBox,...
                options.RegionLimitLineSearchOptions{:});
            lineLimitNegative = find_candidate_space_boundary_newton(...
                candidateSpace(iComponent),...
                currentPoint,...
                -lineDirection,...
                candidateSpaceBox,...
                options.RegionLimitLineSearchOptions{:});

            % new point - anywhere in the line segment
            limitPointPositive = currentPoint + lineLimitPositive.*lineDirection;
            limitPointNegative = currentPoint + lineLimitNegative.*(-lineDirection);

            % make sure limits are inside designBox
            limitPointPositive = min(max(limitPointPositive,candidateSpaceBox(1,:)),candidateSpaceBox(2,:));
            limitPointNegative = min(max(limitPointNegative,candidateSpaceBox(1,:)),candidateSpaceBox(2,:));

            % uniformly distributed random step size [0,1]
            stepSize = rand(options.NumberGeneratedCandidateSamples,1);
            newPoint = limitPointNegative + stepSize.*(limitPointPositive - limitPointNegative);

            % update points if they are inside the candidate space
            isInRegionSampling = isInsideCandidateSpace(newPoint);
            currentPoint(isInRegionSampling,:) = newPoint(isInRegionSampling,:);
        end

        if(strcmpi(options.SelectionCriterion,'max-distance'))
            iDesignMaxDistance = design_select_max_distance(pointInside,currentPoint,nSample,options.SelectionDistanceOptions{:});
            designSample(:,componentIndex{iComponent}) = currentPoint(iDesignMaxDistance,:);
        else
            iDesignRandom = randsample(options.NumberGeneratedCandidateSamples,nSample,false);
            designSample(:,componentIndex{iComponent}) = currentPoint(iDesignRandom,:);
        end
    end

    paddingSample = [];
end


function lineLimit = find_candidate_space_boundary_newton(candidateSpace,currentPoint,lineDirection,candidateSpaceBox,maxIter)
    if(nargin < 5 || isempty(maxIter))
        maxIter = 5;
    end

    % first find distance to candidate space box
    distanceRelevant = currentPoint - candidateSpaceBox(1,:); % distance to lower left corner
    distanceToUpperRight = candidateSpaceBox(2,:) - currentPoint;
    distanceRelevant(lineDirection>0) = distanceToUpperRight(lineDirection>0);
    maxStepSize = min(distanceRelevant./abs(lineDirection),[],2);

    % compute score for both current point and limit point
    [~,scoreCurrent] = candidateSpace.is_in_candidate_space(currentPoint);

    stepSizePrevious = 0;
    lineLimit = maxStepSize;

    iIter = 1;
    while(iIter <= maxIter)
        scorePrevious = scoreCurrent;
        [~,scoreCurrent] = candidateSpace.is_in_candidate_space(currentPoint + lineLimit.*lineDirection);

        % estimate gradient of score
        gradientDenominator = lineLimit - stepSizePrevious;
        gradientDenominator(gradientDenominator == 0) = 1;
        gradientScore = (scoreCurrent - scorePrevious)./gradientDenominator;

        % update step size using newton's method
        stepSizePrevious = lineLimit;
        lineLimit = lineLimit - scoreCurrent./(gradientScore);
        lineLimit = min(max(lineLimit,0),maxStepSize);

        % update
        iIter = iIter + 1;
    end
end