function [removalCandidate,removalInformation] = component_trimming_method_corner_box_removal(designSampleComponent,iRemove,isKeep,varargin)
%COMPONENT_TRIMMING_METHOD_CORNER_BOX_REMOVAL Component SSO Trimming
%   COMPONENT_TRIMMING_METHOD_CORNER_BOX_REMOVAL uses the corner box removal
%   method to find the sample points for candidate removal during the trimming 
%   operation of the component SSO procedure.
%   In corner box removal, for a component of n-dimensiones, there will be 2^n 
%   trimming possibilities, and each one will be a combination where the sample 
%   points that have design variable values of less tahn / greater than the 
%   removal anchor are selected.
%
%   REMOVALCANDIDATE = COMPONENT_TRIMMING_METHOD_CORNER_BOX_REMOVAL(
%   DESIGNSAMPLECOMPONENT,IREMOVE) receives the design sample points 
%   of the component space in DESIGNSAMPLECOMPONENT and the index of the design
%   to be removed IREMOVE, and returns all trimming possibilities in 
%   REMOVALCANDIDATE. 
%
%   Input:
%       - DESIGNSAMPLECOMPONENT : (nSample,nComponentDesignVariable) double
%       - IREMOVE : integer
%
%   Output:
%       - REMOVALCANDIDATE : (nSample,nCandidate) logical
%
%   See also component_trimming_operation, component_trimming_leanness, 
%   component_trimming_method_planar_trimming.

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
    parser.addParameter('CornersToTest','all');
    parser.addParameter('TrimmingSlack',0.5);
    parser.addParameter('ConsiderOnlyKeepInSlack',true);
    parser.addParameter('NormalizeVariables',true,@islogical);
    parser.addParameter('Use3DOperations',false,@islogical);
    parser.parse(varargin{:});
    options = parser.Results;

    nSample = size(designSampleComponent,1);
    nDesignVariable = size(designSampleComponent,2);

    % create all combinations of (lesser than / greater than) for each design variable
    if(strcmpi(options.CornersToTest,'all'))
        combination = logical(round(fullfact(2*ones(nDesignVariable,1)) - 1));
    elseif(strcmpi(options.CornersToTest,'away'))
        center = mean(designSampleComponent(isKeep,:),1);
        combination = ((designSampleComponent(iRemove,:) - center)>=0);
    end

    % create sign matrix for each combination
    % removing everything greater --> -1
    % removing everything lesser --> 1
    signMatrix = (~combination) - (combination);

    anchorVector = designSampleComponent(iRemove,:); % (1,nDimension)

    lowerBound = min(designSampleComponent,[],1);
    upperBound = max(designSampleComponent,[],1);
    if(options.NormalizeVariables)
        normalizationFactor = upperBound - lowerBound;
    else
        normalizationFactor = ones(1,nDesignVariable);
    end

    % Pre-slack removal 
    nCombination = size(combination,1);
    anchorPerCombination = repmat(anchorVector,nCombination,1);

    if(options.Use3DOperations)
        signMatrix = reshape(signMatrix',1,nDesignVariable,nCombination);
        anchorPerCombination = reshape(anchorPerCombination',1,nDesignVariable,nCombination);
        normalizationFactor = repmat(normalizationFactor,1,1,nCombination);
    end

    [distanceMaximumPerCombination,iDimensionDistanceMaximumPerCombination] = corner_box_removal_compute_distance_maximum_per_combination(...
        designSampleComponent,...
        anchorPerCombination,...
        signMatrix,...
        normalizationFactor,...
        options.Use3DOperations);

    % Slack-adjusted anchors per combination
    if(options.TrimmingSlack<1)
        distanceAnchorToUpperBound = upperBound - anchorVector;
        distanceAnchorToLowerBound = anchorVector - lowerBound;
        slackToBound = distanceAnchorToUpperBound.*(signMatrix>0) + distanceAnchorToLowerBound.*(signMatrix<0);

        isKeepInSlack = (distanceMaximumPerCombination>=0); % not removed
        if(options.ConsiderOnlyKeepInSlack)
            isKeepInSlack = isKeepInSlack & isKeep;
        end

        if(options.Use3DOperations)
            isLimitingCurrentDimension = (iDimensionDistanceMaximumPerCombination==(1:nDesignVariable));
            isRelevantForSlack = isLimitingCurrentDimension & isKeepInSlack;

            currentDimensionAllowedSlack = distanceMaximumPerCombination.*normalizationFactor;
            currentDimensionAllowedSlack(~isRelevantForSlack) = inf;

            allowedSlack = min(currentDimensionAllowedSlack,[],1);
            allowedSlack = min(allowedSlack,slackToBound);
        else
            allowedSlack = nan(nCombination,nDesignVariable);
            for iDimension = 1:nDesignVariable
                isRelevantForSlack = isKeepInSlack & (iDimensionDistanceMaximumPerCombination==iDimension);
                currentDimensionAllowedSlack = distanceMaximumPerCombination;
                currentDimensionAllowedSlack(~isRelevantForSlack) = inf;
                allowedSlackDimension = min(currentDimensionAllowedSlack,[],1).*normalizationFactor(iDimension);
                allowedSlack(:,iDimension) = min(allowedSlackDimension,slackToBound(:,iDimension)');
            end
        end
        anchorPerCombination = anchorVector + (1-options.TrimmingSlack).*allowedSlack.*signMatrix;

        % Final removal with slack-adjusted anchors
        distanceMaximumPerCombination = corner_box_removal_compute_distance_maximum_per_combination(...
            designSampleComponent,...
            anchorPerCombination,...
            signMatrix,...
            normalizationFactor,...
            options.Use3DOperations);
    end

    if(options.Use3DOperations)
        removalCandidate = (reshape(distanceMaximumPerCombination,nSample,nCombination)<0);
        if(nargout>1)
            for i=1:nCombination
                removalInformation(i).Anchor = anchorPerCombination(1,:,i);
                removalInformation(i).CornerDirection = combination(i,:);
            end
        end
    else
        removalCandidate = (distanceMaximumPerCombination<0);
        if(nargout>1)
            for i=1:nCombination
                removalInformation(i).Anchor = anchorPerCombination(i,:);
                removalInformation(i).CornerDirection = combination(i,:);
            end
        end
    end
end

function [distanceMaximumPerCombination,iDimensionDistanceMaximumPerCombination] = corner_box_removal_compute_distance_maximum_per_combination(...
    designSampleComponent,...
    anchorVector,...
    signMatrix,...
    normalizationFactor,...
    use3DOperations)

    nSample = size(designSampleComponent,1);
    nDesignVariable = size(designSampleComponent,2);

    if(use3DOperations)
        distanceToAnchor = (designSampleComponent - anchorVector).*signMatrix./normalizationFactor;
        [distanceMaximumPerCombination,iDimensionDistanceMaximumPerCombination] = max(distanceToAnchor,[],2);
    else
        nCombination = size(anchorVector,1);

        distanceMaximumPerCombination = -inf(nSample,nCombination);
        iDimensionDistanceMaximumPerCombination = nan(nSample,nCombination);
        for iDimension = 1:nDesignVariable
            distanceDimension = ((designSampleComponent(:,iDimension) - anchorVector(:,iDimension)').*(signMatrix(:,iDimension)'))./normalizationFactor(iDimension); % (nSample,nCombination)
            isMaxDistance = (distanceDimension > distanceMaximumPerCombination);
            distanceMaximumPerCombination(isMaxDistance) = distanceDimension(isMaxDistance); % (nSample,nCombination)
            iDimensionDistanceMaximumPerCombination(isMaxDistance) = iDimension; % (nSample,nCombination)
        end
    end
end