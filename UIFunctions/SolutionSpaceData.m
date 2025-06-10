%% Data Management Class
classdef SolutionSpaceData < handle
    properties
        % Core data
        DesignVariables
        QOIs
        DesignParameters
        Labels
        DesiredPlots
        PlotData
        ExtraOptions
        DesignBox
        
        % Handles to GUI components (optional, can be managed separately)
        TextHandles
        SliderHandles
        QOITextHandles
        QOICheckHandles
        PostTextHandles = gobjects(1,3);
        PlotHandles
        
        % Evaluator
        DesignEvaluator

        % OptimizationProblem
        selectedFunction
        OptimumDesignBox = [];
    end
    
    methods
        function obj = SolutionSpaceData(x, qoi, param, lbl, plotdes, extraopt, selectedFunction)
            % Constructor - initialize all data
            obj.DesignVariables = x;
            obj.QOIs = qoi;
            obj.DesignParameters = param;
            obj.Labels = lbl;
            obj.DesiredPlots = plotdes;
            obj.ExtraOptions = extraopt;
            obj.DesignBox = [];
            obj.PlotData = [];
            obj.selectedFunction = selectedFunction;
            
            % Initialize design evaluator
            obj.DesignEvaluator = createDesignEvaluator(obj);
        end
        
        function evaluator = createDesignEvaluator(obj)
            % Create design evaluator
            bottomUpMapping = BottomUpMappingFunction(obj.selectedFunction, [obj.DesignParameters.value]);
            evaluator = DesignEvaluatorBottomUpMapping(bottomUpMapping,...
                obj.QOIs.crll, obj.QOIs.crul);
        end
        
        function updateDesignVarBounds(obj, varIndex, boundType, newValue)
            % Update design variable bounds
            if boundType == 1 % Lower bound
                obj.DesignVariables(varIndex).sblb = newValue;
            else % Upper bound
                obj.DesignVariables(varIndex).sbub = newValue;
            end
        end
        
        function updateQOIBounds(obj, qoiIndex, boundType, newValue)
            % Update QOI bounds
            if boundType == 1 % Lower bound
                obj.QOIs(qoiIndex).crll = newValue;
            else % Upper bound
                obj.QOIs(qoiIndex).crul = newValue;
            end
        end
        
        function toggleQOIStatus(obj, qoiIndex)
            % Toggle QOI active status
            if strcmp(obj.QOIs(qoiIndex).status, 'active')
                obj.QOIs(qoiIndex).status = 'inactive';
            else
                obj.QOIs(qoiIndex).status = 'active';
            end
        end
        
        function updateDesignBox(obj)
            % Run optimization
            initialDesign = [obj.DesignVariables.dinit];
            options = sso_stochastic_options('box','SamplingMethodFunction',@sampling_random);
            
            [obj.OptimdesignBox, ~, ~] = sso_box_stochastic(...
                obj.DesignEvaluator,...
                initialDesign,...
                [obj.DesignVariables.dslb],...
                [obj.DesignVariables.dsub],...
                options);
        end
    end
end