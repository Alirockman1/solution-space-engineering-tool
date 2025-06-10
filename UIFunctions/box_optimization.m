%% Function create the design evaluator
function box_optimization(dataManager)   
% Box-shaped Design Space
% Option 1: The initial design is specified and a stochastic optimized box created
% Option 2: Both upper and lower values are provided for the design variables and a box created

    initialDesign = [dataManager.DesignVariables.dinit];       
    
    options = sso_stochastic_options('box','SamplingMethodFunction',@sampling_random);
    
    [dataManager.OptimumDesignBox,~,~] = sso_box_stochastic(...
        dataManager.DesignEvaluator,...
        initialDesign,...
        [dataManager.DesignVariables.dslb],...
        [dataManager.DesignVariables.dsub],...
        options);
end