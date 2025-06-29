classdef SolutionSpaceData < handle
%SOLUTIONSPACEDATA Class to manage design variables, QOIs, and plotting/evaluation logic
%   This class encapsulates the optimization problem's data structure,
%   including design variables, quantities of interest (QOIs), GUI handles,
%   and methods to update, evaluate, and restore configurations.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0
    
    properties
        %% Core data
        DesignVariables             % Struct array of design variables (e.g., dinit, dslb, dsub)
        QOIs                        % Struct array of quantities of interest (e.g., crll, crul, status)
        DesignParameters            % Parameters passed to the selected function (e.g., problem constants)
        Labels                      % Cell array of axis labels or variable names
        DesiredPlots                % List of variable pairs or plot configurations
        PlotData                    % Data used for plotting (optional cache)
        EvaluationData              % Structure to hold evaluation result data
        ExtraOptions                % Additional user-defined options or settings
        DesignBox                   % Final optimized design region (set by updateDesignBox)

        %% GUI Handles
        TextHandles struct = struct( ...
            'DesignBox',    gobjects(0, 2), ...   % Handles to DesignBox input texts (e.g., dinit + optimized)
            'DesignLimits', gobjects(0, 2))       % Handles to lower/upper bound textboxes
        
        SliderHandles               % Handle(s) to GUI slider(s)
        QOITextHandles              % Handle(s) to GUI QOI value textboxes
        QOICheckHandles             % Handle(s) to GUI checkboxes for QOI selection
        PostTextHandles = gobjects(1,3); % Optional GUI textboxes for post-processing values
        AxisHandles                 % Handles to plot axes
        DataTextHandles             % Text handles for displaying point info in plot
        SelectionModeActive         % Flag to indicate GUI selection mode state

        %% Evaluation and Optimization
        DesignEvaluator             % Object to evaluate a design solution (maps input → QOI)
        selectedFunction            % Handle to the user-selected evaluation function
        OptimumDesignBox           % Output from optimization (used to update DesignBox)

        %% Backup / Recovery
        OriginalDesignVariables     % Backup of initial design variables to allow reset
    end

    methods
        function obj = SolutionSpaceData(x, qoi, param, lbl, plotdes, extraopt, selectedFunction)
            % Constructor: initializes the SolutionSpaceData object with inputs
            if nargin == 0
                return; % Allow creation of empty object
            end
            obj.DesignVariables = x;
            obj.QOIs = qoi;
            obj.DesignParameters = param;
            obj.Labels = lbl;
            obj.DesiredPlots = plotdes;
            obj.ExtraOptions = extraopt;
            obj.selectedFunction = selectedFunction;

            obj.DesignBox = [];
            obj.PlotData = [];
            obj.EvaluationData = struct();
            obj.SelectionModeActive = false;
            obj.OptimumDesignBox = [];

            % Initialize evaluator object
            obj.DesignEvaluator = createDesignEvaluator(obj);

            % Save original design variable configuration for restoration
            obj.OriginalDesignVariables = x;
        end

        function evaluator = createDesignEvaluator(obj)
            % Create a DesignEvaluator object based on selectedFunction and QOI bounds
            bottomUpMapping = BottomUpMappingFunction(obj.selectedFunction, [obj.DesignParameters.value]);
            evaluator = DesignEvaluatorBottomUpMapping( ...
                bottomUpMapping, ...
                obj.QOIs.crll, ...
                obj.QOIs.crul);
        end

        function updateDesignBounds(obj, varIndex, boundType, newValue)
            % Update search bounds (sblb/sbub) of a design variable
            % boundType: 1 = lower, 2 = upper
            if boundType == 1
                obj.DesignVariables(varIndex).sblb = newValue;
            else
                obj.DesignVariables(varIndex).sbub = newValue;
            end
        end

        function updateDesignVarBounds(obj, varIndex, boundType, newValue)
            % Update design space bounds (dslb/dsub) of a design variable
            % boundType: 1 = lower, 2 = upper
            if boundType == 1
                obj.DesignVariables(varIndex).dslb = newValue;
            else
                obj.DesignVariables(varIndex).dsub = newValue;
            end
        end

        function updateQOIBounds(obj, qoiIndex, boundType, newValue)
            % Update bounds of a quantity of interest
            % boundType: 1 = lower, 2 = upper
            if boundType == 1
                obj.QOIs(qoiIndex).crll = newValue;
            else
                obj.QOIs(qoiIndex).crul = newValue;
            end
        end

        function toggleQOIStatus(obj, qoiIndex)
            % Toggle QOI status between 'active' and 'inactive'
            if strcmp(obj.QOIs(qoiIndex).status, 'active')
                obj.QOIs(qoiIndex).status = 'inactive';
            else
                obj.QOIs(qoiIndex).status = 'active';
            end
        end

        function updateDesignBox(obj)
            % Perform stochastic optimization to compute the optimal DesignBox
            initialDesign = [obj.DesignVariables.dinit];
            options = sso_stochastic_options('box', 'SamplingMethodFunction', @sampling_random);

            [obj.OptimumDesignBox, ~, ~] = sso_box_stochastic( ...
                obj.DesignEvaluator, ...
                initialDesign, ...
                [obj.DesignVariables.dslb], ...
                [obj.DesignVariables.dsub], ...
                options);
        end

        function restoreOriginalDesignVariables(obj)
            % Restore design variables to their original state (including bounds and init)
            obj.DesignVariables = obj.OriginalDesignVariables;
        end
    end
end
