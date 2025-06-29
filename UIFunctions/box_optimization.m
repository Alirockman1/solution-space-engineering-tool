function box_optimization(dataManager)   
%BOX_OPTIMIZATION Performs box-constrained stochastic optimization.
%
%   box_optimization(dataManager) runs a stochastic optimization process
%   within the design space bounds defined in dataManager.DesignVariables.
%   It uses initial design values and lower/upper limits to find an optimal
%   design solution by minimizing the objective defined in dataManager.DesignEvaluator.
%
%   INPUT:
%       dataManager - Struct containing design variables and evaluator, with fields:
%                     .DesignVariables (array of structs with fields dinit, dslb, dsub)
%                     .DesignEvaluator (function handle or object defining the evaluation)
%
%   OUTPUT:
%       Updates dataManager.OptimumDesignBox with the resulting optimal design vector.
%
%   DETAILS:
%       - Initializes the design vector from dataManager.DesignVariables.dinit.
%       - Uses stochastic optimization options specifying box constraints and
%         a random sampling method.
%       - Calls sso_box_stochastic to perform the optimization.
%
%   Example:
%       box_optimization(dataManager);
%
%   Note:
%       Requires sso_box_stochastic and sso_stochastic_options functions.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    initialDesign = [dataManager.DesignVariables.dinit];       
    
    options = sso_stochastic_options('box','SamplingMethodFunction',@sampling_random);

    [dataManager.OptimumDesignBox,~] = sso_box_stochastic(...
        dataManager.DesignEvaluator,...
        initialDesign,...
        [dataManager.DesignVariables.dslb],...
        [dataManager.DesignVariables.dsub],...
        options);
end