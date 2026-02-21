function [deficit,normalizationFactor] = design_measure_to_deficit(measure,varargin)
%DESIGN_MEASURE_TO_DEFICIT Deficit of design given measures and the requirements
%   DESIGN_MEASURE_TO_DEFICIT is used to compute the (performance/physical
%   feasibility) deficit of a design given its (performance/physical 
%   feasibility) measures previously computed and the limits imposed on the
%   system.
%   A normalization of the measures is done, and the deficit can is computed
%   in the following way:
%       - lower limit deficit: (lower limit - measure) / normalization factor
%       - upper limit deficit: (measure - upper limit) / normalization factor
%       - deficit : maximum between lower limit and upper limit deficit
%   In this way, measures that are within their given limits are given deficit 
%   values <0 and otherwise deficit values >0.
%   Weights may be applied to the deficits per measure as follows:
%       - positive deficit: multiplied by the corresponding weight;
%       - negative deficit: divided by the corresponding weight.
%
%   DEFICIT = DESIGN_MEASURE_TO_DEFICIT(MEASURE) receives the measures of design
%   sample points in MEASURE and returns the deficits of each measure in 
%   DEFICIT. All other inputs assume their default values, where lower limits 
%   are assumed to not apply, upper limits are assumed to be 0 and the 
%   normalization factor is computed on-thy-fly based on the given measures and
%   limits.
%
%   DEFICIT = DESIGN_MEASURE_TO_DEFICIT(MEASURE,LOWERLIMIT) allows for the 
%   specification of minimum values required for the measures in LOWERLIMIT.
%   Its default value is '-inf'. If any entry is set to 'nan', that entry will 
%   be assumed to be '-inf' as well.
%
%   DEFICIT = DESIGN_MEASURE_TO_DEFICIT(MEASURE,LOWERLIMIT,UPPERLIMIT) allows for  
%   the specification of maximum values required for the measures in UPPERLIMIT.
%   Its default value is '0'. If any entry is set to 'nan', that entry will 
%   be assumed to be '+inf'.
%
%   DEFICIT = DESIGN_MEASURE_TO_DEFICIT(MEASURE,LOWERLIMIT,UPPERLIMIT,
%   NORMALIZATIONFACTOR) also allows for the specification of the normalization
%   factors to be used in deficit computation in NORMALIZATIONFACTOR. Default
%   value is 'nan'. If any entry is set to 'nan', that entry will be computed
%   on-the-fly based on the given measures and limits.
%
%   DEFICIT = DESIGN_MEASURE_TO_DEFICIT(MEASURE,LOWERLIMIT,UPPERLIMIT,
%   NORMALIZATIONFACTOR,WEIGHT) also allows the specification of per-measure
%   weights through WEIGHT. A scalar applies to all measures.
%
%   DEFICIT = DESIGN_MEASURE_TO_DEFICIT(...,'WeightLowerLimit',WLL,
%   'WeightUpperLimit',WUL) optionally specifies distinct weights to apply to
%   lower- and upper-limit deficits, respectively. If omitted or empty, they
%   default to WEIGHT.
%
%   Inputs:
%       - MEASURE :  (nSample,nMeasure) double
%       - LOWERLIMIT : (1,nMeasure) double, optional
%       - UPPERLIMIT : (1,nMeasure) double, optional
%       - NORMALIZATIONFACTOR : (1,nMeasure) double, optional
%       - WEIGHT : (1,nMeasure) double, optional (default 1). Scalar allowed.
%       - 'WeightLowerLimit' : (1,nMeasure) double, optional (name-value).
%       - 'WeightUpperLimit' : (1,nMeasure) double, optional (name-value).
%
%   Output:
%       - DEFICIT : (nSample,nMeasure) double
%
%   See also design_measure_normalization_factor.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2022-2025.
%   Copyright 2022-2025 Eduardo Rodrigues Della Noce
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

    if(nargin<1 || isempty(measure))
        deficit = [];
        normalizationFactor = [];
        return;
    end

    parser = inputParser;
    parser.addOptional('LowerLimit',[]);
    parser.addOptional('UpperLimit',[]);
    parser.addOptional('NormalizationFactor',[]);
    parser.addOptional('Weight',[]);
    parser.addParameter('WeightLowerLimit',[]);
    parser.addParameter('WeightUpperLimit',[]);
    parser.parse(varargin{:});

    lowerLimit = parser.Results.LowerLimit;
    upperLimit = parser.Results.UpperLimit;
    normalizationFactor = parser.Results.NormalizationFactor;
    weightDefault = parser.Results.Weight;
    weightLowerLimit = parser.Results.WeightLowerLimit;
    weightUpperLimit = parser.Results.WeightUpperLimit;

    % default values
    if(isempty(lowerLimit))
        lowerLimit = -inf;
    end
    if(isempty(upperLimit))
        upperLimit = 0;
    end
    if(isempty(normalizationFactor))
        normalizationFactor = nan;
    end
    if(isempty(weightDefault))
        weightDefault = 1;
    end
    if(isempty(weightLowerLimit))
        weightLowerLimit = weightDefault;
    end
    if(isempty(weightUpperLimit))
        weightUpperLimit = weightDefault;
    end

    % change NaNs to respective no-limit equivalent
    lowerLimit(isnan(lowerLimit)) = -inf;
    upperLimit(isnan(upperLimit)) = +inf;

    % check inputs and vectorize
    nMeasure = size(measure,2);
    if(isscalar(lowerLimit))
        lowerLimit = lowerLimit*ones(1,nMeasure);
    elseif(size(lowerLimit,2)~=nMeasure)
        error('Lower limit must be a scalar or a vector of the same length as the number of measures.');
    end
    if(isscalar(upperLimit))
        upperLimit = upperLimit*ones(1,nMeasure);
    elseif(size(upperLimit,2)~=nMeasure)
        error('Upper limit must be a scalar or a vector of the same length as the number of measures.');
    end
    if(isscalar(normalizationFactor))
        normalizationFactor = normalizationFactor*ones(1,nMeasure);
    elseif(size(normalizationFactor,2)~=nMeasure)
        error('Normalization factor must be a scalar or a vector of the same length as the number of measures.');
    end
    if(isscalar(weightLowerLimit))
        weightLowerLimit = weightLowerLimit*ones(1,nMeasure);
    elseif(size(weightLowerLimit,2)~=nMeasure)
        error('Weight lower limit must be a scalar or a vector of the same length as the number of measures.');
    end
    if(isscalar(weightUpperLimit))
        weightUpperLimit = weightUpperLimit*ones(1,nMeasure);
    elseif(size(weightUpperLimit,2)~=nMeasure)
        error('Weight upper limit must be a scalar or a vector of the same length as the number of measures.');
    end

    % Find lower and upper scores, as well as normalization factor
    computeNormalization = (isinf(normalizationFactor) | isnan(normalizationFactor) | (normalizationFactor==0));
    if(any(computeNormalization))
        normalizationFactor(computeNormalization) = design_measure_normalization_factor(...
            measure(:,computeNormalization),...
            lowerLimit(computeNormalization),...
            upperLimit(computeNormalization));
    end

    % compute deficits for each limit
    lowerLimitDeficit = (lowerLimit - measure)./normalizationFactor;
    upperLimitDeficit = (measure - upperLimit)./normalizationFactor;

    % apply weights
    % - when deficit is negative, weight should divide the deficit
    % - when deficit is positive, weight should multiply the deficit
    % lower-limit weighted deficits
    isPositiveDeficit = (lowerLimitDeficit > 0);
    lowerWeightFactor = isPositiveDeficit.*weightLowerLimit + ...
        (~isPositiveDeficit).*(1./weightLowerLimit);
    weightedLowerLimitDeficit = lowerLimitDeficit .* lowerWeightFactor;

    % upper-limit weighted deficits
    isPositiveDeficit = (upperLimitDeficit > 0);
    upperWeightFactor = isPositiveDeficit.*weightUpperLimit + ...
        (~isPositiveDeficit).*(1./weightUpperLimit);
    weightedUpperLimitDeficit = upperLimitDeficit .* upperWeightFactor;

    % take worst-case for each 
    deficit = max(weightedLowerLimitDeficit,weightedUpperLimitDeficit);
end
