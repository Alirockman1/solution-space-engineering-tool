function [plotData,evaluationData] = evaluate_selective_design_space_projection(systemEvaluation,designBox,designSpaceLowerBound,designSpaceUpperBound,desiredPairs,varargin)
%EVALUATE_SELECTIVE_DESIGN_SPACE_PROJECTION Evaluate designs in selective projection
%   EVALUATE_SELECTIVE_DESIGN_SPACE_PROJECTION evaluates design samples for
%   selective design space projection visualization. For each pair of design
%   variables specified in DESIREDPAIRS, the function samples designs where
%   the two selected variables vary across the entire design space while all
%   other variables are constrained to values within the solution space box.
%   This selective sampling strategy allows efficient visualization of
%   high-dimensional solution spaces through 2D projections.
%
%   [PLOTDATA,EVALUATIONDATA] = EVALUATE_SELECTIVE_DESIGN_SPACE_PROJECTION(
%   SYSTEMEVALUATION,DESIGNBOX,DESIGNSPACELOWERBOUND,DESIGNSPACEUPPERBOUND,
%   DESIREDPAIRS) evaluates designs using default sampling settings. The
%   function generates samples for each variable pair, evaluates them through
%   the system evaluation function, and returns data structures for plotting.
%
%   [PLOTDATA,EVALUATIONDATA] = EVALUATE_SELECTIVE_DESIGN_SPACE_PROJECTION(...,
%   VARARGIN) allows specification of additional options through name-value
%   pairs:
%       - 'SamplingMethod' : function handle for the sampling method. Default:
%       @sampling_random.
%       - 'SamplingOptions' : cell array of options passed to the sampling
%       method. Default: empty.
%       - 'NumberSamplesPerPlot' : number of samples to generate for each
%       variable pair plot. Default: 3000.
%       - 'MarkerColorsCriterion' : criterion for selecting which violated
%       requirement determines marker color when multiple requirements are
%       violated. Options: 'random' (random selection) or 'worst' (worst
%       deficit). Default: 'random'.
%       - 'PerformanceMeasureLowerLimit' : lower bounds for performance
%       measures (required for BottomUpMappingBase).
%       - 'PerformanceMeasureUpperLimit' : upper bounds for performance measures
%       (required for BottomUpMappingBase).
%       - 'PhysicalFeasibilityLowerLimit' : lower bounds for physical
%       feasibility. Default: -inf.
%       - 'PhysicalFeasibilityUpperLimit' : upper bounds for physical
%       feasibility. Default: 0.
%       - 'PerformanceActiveStatus' : logical array indicating which performance
%       requirements are active. Default: all true.
%       - 'PhysicalFeasibilityActiveStatus' : logical array indicating which
%       physical feasibility constraints are active. Default: all true.
%
%   Inputs:
%       - SYSTEMEVALUATION : BottomUpMappingBase OR DesignEvaluatorBase
%           -- system evaluation function or evaluator object
%       - DESIGNBOX : (2,nDesignVariable) double
%           -- solution space box bounds [lower; upper]
%       - DESIGNSPACELOWERBOUND : (1,nDesignVariable) double
%           -- lower bounds of the design space
%       - DESIGNSPACEUPPERBOUND : (1,nDesignVariable) double
%           -- upper bounds of the design space
%       - DESIREDPAIRS : (nPlot,2) integer
%           -- pairs of design variable indices to plot
%       - 'SamplingMethod' : function_handle
%           -- function handle for sampling method
%       - 'SamplingOptions' : (1,nOption) cell array
%           -- options for sampling method
%       - 'NumberSamplesPerPlot' : (1,1) integer
%           -- number of samples per variable pair
%       - 'MarkerColorsCriterion' : (1,1) char/string
%           -- criterion for selecting violated requirement color
%       - 'PerformanceMeasureLowerLimit' : (1,nPerformance) double
%           -- lower limits for performance measures
%       - 'PerformanceMeasureUpperLimit' : (1,nPerformance) double
%           -- upper limits for performance measures
%       - 'PhysicalFeasibilityLowerLimit' : (1,nPhysicalFeasibility) double
%           -- lower limits for physical feasibility
%       - 'PhysicalFeasibilityUpperLimit' : (1,nPhysicalFeasibility) double
%           -- upper limits for physical feasibility
%       - 'PerformanceActiveStatus' : (1,nPerformance) logical
%           -- active status for each performance requirement
%       - 'PhysicalFeasibilityActiveStatus' : (1,nPhysicalFeasibility) logical
%           -- active status for each physical feasibility constraint
%
%   Outputs:
%       - PLOTDATA : (1,nPlot) struct array
%           -- data structure for each plot containing:
%           -- DesignSample : (nSamplePerPlot,2) double - samples for the pair
%           -- RequirementViolated : (nSamplePerPlot,1) integer - requirement index
%           -- IsPhysicallyFeasible : (nSamplePerPlot,1) logical - feasibility
%           -- DesignSpaceLowerBound : (1,2) double - lower bounds for pair
%           -- DesignSpaceUpperBound : (1,2) double - upper bounds for pair
%           -- DesignBox : (2,2) double - solution box bounds for pair
%           -- DesignVariablePairIndex : (1,2) integer - indices of the pair
%           -- DesignSampleOtherVariables : (nSamplePerPlot,nOtherVar) double
%           -- PerformanceMeasure : (nSamplePerPlot,nPerformance) double
%           -- PhysicalFeasibilityMeasure : (nSamplePerPlot,nPhysicalFeasibility) double
%           -- PerformanceDeficit : (nSamplePerPlot,nPerformance) double
%           -- PhysicalFeasibilityDeficit : (nSamplePerPlot,nPhysicalFeasibility) double
%       - EVALUATIONDATA : struct
%           -- complete evaluation data containing:
%           -- DesignSample : (nTotalSample,nDesignVariable) double
%           -- PerformanceMeasure : (nTotalSample,nPerformance) double
%           -- PhysicalFeasibilityMeasure : (nTotalSample,nPhysicalFeasibility) double
%           -- PerformanceDeficit : (nTotalSample,nPerformance) double
%           -- PhysicalFeasibilityDeficit : (nTotalSample,nPhysicalFeasibility) double
%           -- EvaluatorOutput : class-defined output from evaluator
%           -- PerformanceActiveStatus : (1,nPerformance) logical
%           -- PhysicalFeasibilityActiveStatus : (1,nPhysicalFeasibility) logical
%           -- IsGoodPerformance : (nTotalSample,1) logical
%           -- IsPhysicallyFeasible : (nTotalSample,1) logical
%
%   See also plot_selective_design_space_projection,
%   plot_design_space_projection_axis, sampling_random, sampling_latin_hypercube.

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

    %% Parse Inputs
    p = inputParser;
    addOptional(p,'SamplingMethod',[],@(x) isempty(x) || isa(x,'function_handle'));
    addOptional(p,'SamplingOptions',{},@iscell);
    addOptional(p,'NumberSamplesPerPlot',[],@isnumeric);
    addOptional(p,'MarkerColorsCriterion',[],@(x) isempty(x) || ismember(x,{'random','worst'}));
    addParameter(p,'PerformanceMeasureLowerLimit',[],@isnumeric);
    addParameter(p,'PerformanceMeasureUpperLimit',[],@isnumeric);
    addParameter(p,'PhysicalFeasibilityLowerLimit',-inf,@isnumeric);
    addParameter(p,'PhysicalFeasibilityUpperLimit',0,@isnumeric);
    addParameter(p,'PerformanceActiveStatus',[],@(x) isempty(x) || islogical(x));
    addParameter(p,'PhysicalFeasibilityActiveStatus',[],@(x) isempty(x) || islogical(x));
    parse(p,varargin{:});
    options = p.Results;

    if(isempty(options.SamplingMethod))
        options.SamplingMethod = @sampling_random;
    end
    if(isempty(options.NumberSamplesPerPlot))
        options.NumberSamplesPerPlot = 3000;
    end
    if(isempty(options.MarkerColorsCriterion))
        options.MarkerColorsCriterion = 'random';
    end

    % Gather all evaluations necessary for all the plots
    nPlot = size(desiredPairs,1);
    nDesignVariable = size(designSpaceLowerBound,2);
    nPointTotal = nPlot*options.NumberSamplesPerPlot;
    designSample = nan(nPointTotal,nDesignVariable);

    %% Random Sampling for Relevant Scatter Plot
    for j=1:nPlot
        % Calculate row indices for this plot's samples
        startRow = (j-1)*options.NumberSamplesPerPlot + 1;
        endRow = j*options.NumberSamplesPerPlot;
        currentRow = startRow:endRow;
        
        currentAxes = [desiredPairs(j,1),desiredPairs(j,2)];
        otherAxes = ~ismember(1:nDesignVariable,currentAxes);
        
        scatterBound = nan(2, nDesignVariable);
        scatterBound(:,currentAxes) = [designSpaceLowerBound(currentAxes);designSpaceUpperBound(currentAxes)];
        scatterBound(:,otherAxes) = designBox(:,otherAxes);

        designSample(currentRow,:) = options.SamplingMethod(scatterBound, options.NumberSamplesPerPlot, options.SamplingOptions{:});
    end


    %% Evaluate Samples
    if(isa(systemEvaluation,'BottomUpMappingBase'))
        if(isempty(options.PerformanceMeasureLowerLimit) || isempty(options.PerformanceMeasureUpperLimit))
            error('Performance measure lower and upper limits must be specified for BottomUpMappingBase.');
        end

        [performanceMeasure,physicalFeasibilityMeasure,evaluationOutput] = systemEvaluation.response(designSample);
        performanceDeficit = design_measure_to_deficit(performanceMeasure,options.PerformanceMeasureLowerLimit,options.PerformanceMeasureUpperLimit);
        physicalFeasibilityDeficit = design_measure_to_deficit(physicalFeasibilityMeasure,options.PhysicalFeasibilityLowerLimit,options.PhysicalFeasibilityUpperLimit);
    elseif(isa(systemEvaluation,'DesignEvaluatorBase'))
        performanceMeasure = [];
        physicalFeasibilityMeasure = [];
        [performanceDeficit,physicalFeasibilityDeficit,evaluationOutput] = systemEvaluation.evaluate(designSample);

        if(isstruct(evaluationOutput) && isfield(evaluationOutput, 'PerformanceMeasure'))
            performanceMeasure = evaluationOutput.PerformanceMeasure;
        end
        if(isstruct(evaluationOutput) && isfield(evaluationOutput, 'PhysicalFeasibilityMeasure'))
            physicalFeasibilityMeasure = evaluationOutput.PhysicalFeasibilityMeasure;
        end
    else
        error('System evaluation must be a BottomUpMapping or DesignEvaluator.');
    end

    isActivePerformance = options.PerformanceActiveStatus;
    if(isempty(isActivePerformance))
        isActivePerformance = true(1,size(performanceDeficit,2));
    end
    if(isempty(performanceDeficit))
        isGoodPerformance = true(size(designSample,1),1);
    else
        performanceDeficitActive = performanceDeficit;
        performanceDeficitActive(:,~isActivePerformance) = 0;
        isGoodPerformance = all(performanceDeficitActive<=0,2);
    end

    isActivePhysicalFeasibility = options.PhysicalFeasibilityActiveStatus;
    if(isempty(isActivePhysicalFeasibility))
        isActivePhysicalFeasibility = true(1,size(physicalFeasibilityDeficit,2));
    end
    if(isempty(physicalFeasibilityDeficit))
        isPhysicallyFeasible = true(size(designSample,1),1);
    else
        physicalFeasibilityDeficitActive = physicalFeasibilityDeficit;
        physicalFeasibilityDeficitActive(:,~isActivePhysicalFeasibility) = 0;
        isPhysicallyFeasible = all(physicalFeasibilityDeficitActive<=0,2);
    end

    %% Tag Bad Designs w.r.t. which requirement it violates
    iRequirementViolated = zeros(nPointTotal,1);
    if(any(~isGoodPerformance))
        if(strcmpi(options.MarkerColorsCriterion,'random'))
            for i=1:nPointTotal
                if(~isGoodPerformance(i))
                    currentRequirementViolated = find(performanceDeficitActive(i,:)>0);
                    randomizedViolatedRequirement = currentRequirementViolated(randperm(length(currentRequirementViolated)));
                    iRequirementViolated(i) = randomizedViolatedRequirement(1);
                end
            end
        else % 'worst'
            [~,iWorstDeficit] = max(performanceDeficitActive(~isGoodPerformance,:),[],2);
            iRequirementViolated(~isGoodPerformance) = iWorstDeficit;
        end
    end

    plotData = struct(...
        'DesignSample',[],...
        'RequirementViolated',[],...
        'IsPhysicallyFeasible',[],...
        'DesignSpaceLowerBound',[],...
        'DesignSpaceUpperBound',[],...
        'DesignBox',[],...
        'DesignVariablePairIndex',[],...
        'DesignSampleOtherVariables',[],...
        'PerformanceMeasure',[],...
        'PhysicalFeasibilityMeasure',[],...
        'PerformanceDeficit',[],...
        'PhysicalFeasibilityDeficit',[]);
    for j=1:nPlot
        % Calculate row indices for this plot's samples
        startRow = (j-1)*options.NumberSamplesPerPlot + 1;
        endRow = j*options.NumberSamplesPerPlot;
        currentRow = startRow:endRow;

        currentPair = [desiredPairs(j,1),desiredPairs(j,2)];
        otherAxes = setdiff(1:nDesignVariable,currentPair);

        % Store data for this plot
        plotData(j) = struct(...
            'DesignSample',designSample(currentRow,currentPair),...
            'RequirementViolated',iRequirementViolated(currentRow),...
            'IsPhysicallyFeasible',isPhysicallyFeasible(currentRow),...
            'DesignSpaceLowerBound',designSpaceLowerBound(currentPair),...
            'DesignSpaceUpperBound',designSpaceUpperBound(currentPair),...
            'DesignBox',designBox(:,currentPair),...
            'DesignVariablePairIndex',currentPair,...
            'DesignSampleOtherVariables',designSample(currentRow,otherAxes),...
            'PerformanceMeasure',get_array_subset_if_nonempty(performanceMeasure,currentRow),...
            'PhysicalFeasibilityMeasure',get_array_subset_if_nonempty(physicalFeasibilityMeasure,currentRow),...
            'PerformanceDeficit',get_array_subset_if_nonempty(performanceDeficit,currentRow),...
            'PhysicalFeasibilityDeficit',get_array_subset_if_nonempty(physicalFeasibilityDeficit,currentRow));
    end

    if(nargout>1)
        evaluationData = struct(...
            'DesignSample',designSample,...
            'PerformanceMeasure',performanceMeasure,...
            'PhysicalFeasibilityMeasure',physicalFeasibilityMeasure,...
            'PerformanceDeficit',performanceDeficit,...
            'PhysicalFeasibilityDeficit',physicalFeasibilityDeficit,...
            'EvaluatorOutput',evaluationOutput,...
            'PerformanceActiveStatus',isActivePerformance,...
            'PhysicalFeasibilityActiveStatus',isActivePhysicalFeasibility,...
            'IsGoodPerformance',isGoodPerformance,...
            'IsPhysicallyFeasible',isPhysicallyFeasible);
    end
end