function run_optimization(src, event, dataManager)
%RUN_OPTIMIZATION Run box-shaped solution space optimization
%   RUN_OPTIMIZATION executes the stochastic box-shaped solution space
%   optimization algorithm to find the optimal solution space box bounds.
%   The function sets up the design evaluator, runs the optimization, and
%   updates the GUI with the optimal bounds. Button appearance is changed
%   during optimization to provide visual feedback.
%
%   RUN_OPTIMIZATION(SRC, EVENT, DATAMANAGER) is called when the user clicks
%   the "Optimize" button. It runs sso_box_stochastic and updates the GUI
%   with optimal bounds.
%
%   Inputs:
%       - SRC : uibutton
%           -- handle to the button that triggered the callback (unused)
%       - EVENT : event data
%           -- event data from button callback (unused)
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing system evaluation function, design
%           box, design space bounds, QOI limits, and optimization options
%
%   Outputs:
%       None (GUI is updated with optimal bounds, button appearance restored)
%
%   See also sso_box_stochastic, DesignEvaluatorBottomUpMapping,
%   BoxXRayOperations.update_gui_box_lower_bound,
%   BoxXRayOperations.update_gui_box_upper_bound.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2025.
%   Copyright 2025 Eduardo Rodrigues Della Noce (Contributor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
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

    button = gcbo;
    originalColor = button.BackgroundColor;                                % Save original color
    button.BackgroundColor = [1, 0.8, 0.5];                                % Set to light orange
    button.Text = 'Running...';                                          % Update the button label
    drawnow;                                                               % Force UI update


    %% Get data
    designBox = dataManager.get_design_box;
    designSpace = dataManager.get_design_space;
    designParameters = dataManager.get_design_parameters;
    performanceLimits = dataManager.get_quantities_of_interest_limits;

    systemEvaluation = dataManager.SystemEvaluation;
    if(isa(systemEvaluation,'function_handle'))
        if(nargin(systemEvaluation)==1)
            systemEvaluation = BottomUpMappingFunction(dataManager.SystemEvaluation);
        else
            systemEvaluation = BottomUpMappingFunction(dataManager.SystemEvaluation,designParameters);
        end
    end

    if(isa(systemEvaluation,'BottomUpMappingBase'))
        performanceLowerLimit = performanceLimits(1,:);
        performanceUpperLimit = performanceLimits(2,:);
        systemEvaluation = DesignEvaluatorBottomUpMapping(systemEvaluation,performanceLowerLimit,performanceUpperLimit);
    end

    %% Achieve optimum box
    try
        options = sso_stochastic_options('box',dataManager.OptimizationOptions{:});

        [optimalBox,dataManager.OptimizationData] = sso_box_stochastic(...
            systemEvaluation,...
            designBox,...
            designSpace(1,:),...
            designSpace(2,:),...
            options);

        % Provide feedback after the process completes
        msgbox('Optimization completed successfully!', 'Success', 'help');

        % separate updates depending on order based on current state
        % --> example, if new lower bound is above previous upper bound, then update the upper bound first
        canUpdateLowerBoundFirst = (optimalBox(1,:) <= designBox(2,:));
        canUpdateUpperBoundFirst = (optimalBox(2,:) >= designBox(1,:));

        nVariable = size(designBox,2);
        for iVariable = 1:nVariable
            if(canUpdateLowerBoundFirst(iVariable))
                BoxXRayOperations.update_gui_box_lower_bound(dataManager, iVariable, optimalBox(1,iVariable));
            end
            if(canUpdateUpperBoundFirst(iVariable))
                BoxXRayOperations.update_gui_box_upper_bound(dataManager, iVariable, optimalBox(2,iVariable));
            end
        end
        for iVariable = 1:nVariable
            if(~canUpdateLowerBoundFirst(iVariable))
                BoxXRayOperations.update_gui_box_lower_bound(dataManager, iVariable, optimalBox(1,iVariable));
            end
            if(~canUpdateUpperBoundFirst(iVariable))
                BoxXRayOperations.update_gui_box_upper_bound(dataManager, iVariable, optimalBox(2,iVariable));
            end
        end


    catch ME
        % Display an error message if the process fails
        errordlg(['An error occurred: ', ME.message], 'Error', 'modal');
    end

    % Restore the button's original appearance
    button.BackgroundColor = originalColor;
    button.Text = 'Optimize';
    drawnow;                                                               
end