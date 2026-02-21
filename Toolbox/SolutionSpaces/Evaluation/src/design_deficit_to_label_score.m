function [label,score] = design_deficit_to_label_score(measureDeficit,varargin)
%DESIGN_DEFICIT_TO_LABEL_SCORE Get the label and score for designs given deficit
%   DESIGN_DEFICIT_TO_LABEL_SCORE uses the given measure deficits of design 
%   samples to label them as either fulfilling the given requirements or not. It
%   can also produce a quantitative value to represent how much said measures 
%   are within their supposed limits, named the score.
%
%   LABEL = DESIGN_DEFICIT_TO_LABEL_SCORE(MEASUREDEFICIT) gets the deficits of 
%   the measures of design samples in MEASUREDEFICIT and labels them in LABEL as 
%   fulfilling the requirements ('true') if all deficits are negative, or not 
%   ('false') if at least one deficit is positive.
%
%   [LABEL,SCORE] = DESIGN_DEFICIT_TO_LABEL_SCORE(...) also returns a SCORE for 
%   each design. Said score is a negative value for designs that meet the 
%   requirements, and positive value if one requirement is violated. In 
%   particular:
%       - For designs that meet the requirements, the score is computed as a 
%       a geometric mean of the deficits.
%       - For designs that do not meet at least one requirement, the score is
%       computed as the root square sum of all positive deficits (so all 
%       deficits of measures that violated the requirements).
%
%   [LABEL,SCORE] = DESIGN_DEFICIT_TO_LABEL_SCORE(MEASUREDEFICIT,DEFICITWEIGHT)
%   allows one to choose weights for each deficit, which determines how much
%   they are going to influence the score. By default, all deficits are given 
%   weight equal to 1.
%
%   User-defined score functions:
%   The optional parameters 'ScoreGoodFunction' and 'ScoreBadFunction' accept
%   function handles to override the default score computations. Each custom
%   function should have the signature
%       scores = my_score_fn(measureDeficitSubset, deficitWeight, varargin...)
%   where 'measureDeficitSubset' is an (nSample, nRequirement) array for the
%   samples being scored (only good or only bad samples are passed),
%   'deficitWeight' is the (1,nRequirement) weight vector, and any additional
%   options are passed from 'ScoreGoodOptions' or 'ScoreBadOptions'. The
%   function must return scores as an (nSample,1) numeric vector. If a
%   custom function is not provided, the default behaviors described above are
%   used.
%
%   Input:
%       - MEASUREDEFICIT : (nSample,nRequirement) double
%       - DEFICITWEIGHT : (1,nRequirement) double, optional
%       - VARARGIN : (1,1) struct with the following fields:
%           - 'ScoreGoodFunction' : function_handle, optional
%           - 'ScoreGoodOptions' : cell, optional
%           - 'ScoreBadFunction' : function_handle, optional
%           - 'ScoreBadOptions' : cell, optional
%   Output:
%       - LABEL : (nSample,1) logical
%       - SCORE : (nSample,1) double
%
%   See also DesignEvaluatorBottomUpMapping.

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

    % parse input
    parser = inputParser;
    parser.addOptional('DeficitWeight',[],@(x) isempty(x) || (isnumeric(x) && isvector(x)));
    parser.addParameter('ScoreGoodFunction',[],@(x) isempty(x) || isa(x,'function_handle') || isstring(x) || ischar(x));
    parser.addParameter('ScoreGoodOptions',{},@(x) isempty(x) || iscell(x));
    parser.addParameter('ScoreBadFunction',[],@(x) isempty(x) || isa(x,'function_handle') || isstring(x) || ischar(x));
    parser.addParameter('ScoreBadOptions',{},@(x) isempty(x) || iscell(x));
    parser.parse(varargin{:});
    options = parser.Results;

    % label based on worst-case (if any deficit is positive, design is bad)
    worstCase = max(measureDeficit,[],2);
    label = (worstCase<=0);
    
    if(nargout>1)
        if(isempty(options.DeficitWeight))
            options.DeficitWeight = 1;
        end

        % check inputs and vectorize
        nMeasure = size(measureDeficit,2);
        if(isscalar(options.DeficitWeight))
            options.DeficitWeight = options.DeficitWeight*ones(1,nMeasure);
        elseif(size(options.DeficitWeight,2)~=nMeasure)
            error('Deficit weight must be a scalar or a vector of the same length as the number of measures.');
        end

        % ignore -inf entries for score calculation (no limit)
        measureDeficit(measureDeficit==-inf) = nan;

        % see which limits were violated, if any
        violatedLimit = max(measureDeficit,0);
        score = nan(size(worstCase,1),1);
        
        % for bad designs, use the root square sum of violated limits
        if(any(~label))
            if(isempty(options.ScoreBadFunction))
                weightedDeficit = violatedLimit(~label,:).*options.DeficitWeight;
                score(~label) = sqrt(sum(weightedDeficit.^2,2));
            elseif((isstring(options.ScoreBadFunction) || ischar(options.ScoreBadFunction)) && any(strcmpi(options.ScoreBadFunction,{'worst-case','max'})))
                score(~label) = max(measureDeficit(~label,:).*options.DeficitWeight,[],2);
            elseif(isa(options.ScoreBadFunction,'function_handle'))
                score(~label) = options.ScoreBadFunction(violatedLimit(~label,:),options.DeficitWeight,options.ScoreBadOptions{:});
            else
                error('Invalid score function for bad designs.');
            end
        end
    
        % for good designs, use geometric mean of deficits
        if(any(label))
            if(isempty(options.ScoreGoodFunction))
                weightedDeficit = abs(measureDeficit(label,:)).^(options.DeficitWeight./sum(options.DeficitWeight));
                score(label) = -prod(weightedDeficit,2,'omitnan');
            elseif((isstring(options.ScoreGoodFunction) || ischar(options.ScoreGoodFunction)) && any(strcmpi(options.ScoreGoodFunction,{'worst-case','max'})))
                score(label) = max(measureDeficit(label,:).*options.DeficitWeight,[],2);
            elseif(isa(options.ScoreGoodFunction,'function_handle'))
                score(label) = options.ScoreGoodFunction(measureDeficit(label,:),options.DeficitWeight,options.ScoreGoodOptions{:});
            else
                error('Invalid score function for good designs.');
            end
        end
        
        % if any entry is nan, throw it to either extreme of min/max
        score(label & isnan(score)) = min(score);
        score(~label & isnan(score)) = max(score);
    end
end