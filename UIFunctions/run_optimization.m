function run_optimization(dataManager)
%RUN_OPTIMIZATION Executes the optimization routine and updates UI accordingly.
%
%   run_optimization(dataManager) performs the optimization process based on
%   the design variables and evaluation setup contained within dataManager.
%   It updates UI elements such as buttons and sliders to reflect the running
%   status and resets variables to original bounds before running the core
%   optimization function.
%
%   INPUT:
%       dataManager - Struct containing all relevant data, design variables,
%                     UI handles, evaluation functions, and options needed
%                     for the optimization process.
%
%   WORKFLOW:
%       - Changes the calling button's appearance to indicate the process is running.
%       - Computes bottom-up mapping using selected design function and parameters.
%       - Initializes the design evaluator with the mapping and QoI limits.
%       - Resets design variable bounds and updates associated UI sliders and text.
%       - Runs the optimization routine (box_optimization).
%       - Displays success or error message dialogs.
%       - Restores the button to its original appearance after completion.
%
%   Example:
%       run_optimization(dataManager);
%
%   Note:
%       This function assumes dataManager contains methods like
%       restoreOriginalDesignVariables and handles for sliders, text, etc.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    button = gcbo;
    originalColor = button.BackgroundColor;                                % Save original color
    button.BackgroundColor = [1, 0.8, 0.5];                                % Set to light orange
    button.String = 'Running...';                                          % Update the button label
    drawnow;                                                               % Force UI update

    %% Bottom up Mapping
    % Required: Functioncall and Design Variables
    bottomUpMapping = BottomUpMappingFunction(dataManager.selectedFunction,[dataManager.DesignParameters.value]);
    
    %% Design Evaluator
    % Required: BottomupMapping and design space limits
    dataManager.DesignEvaluator = DesignEvaluatorBottomUpMapping(bottomUpMapping,...
        dataManager.QOIs.crll,dataManager.QOIs.crul);

    %% Achieve optimum box
    try
        % Run the optimization process
        box_optimization(dataManager);

        % Provide feedback after the process completes
        msgbox('Optimization completed successfully!', 'Success', 'help');
    catch ME
        % Display an error message if the process fails
        errordlg(['An error occurred: ', ME.message], 'Error', 'modal');
    end

    %% Update box shape handles
    for varIdx = 1:length(dataManager.OptimumDesignBox)

        % Update Design Variable Bounds
        % update upper design variables
        dataManager.updateDesignBounds(varIdx, 1, dataManager.OptimumDesignBox(1,varIdx));
        % update lower design  variables
        dataManager.updateDesignBounds(varIdx, 2, dataManager.OptimumDesignBox(2,varIdx));

        % Update Slider Value
        set(dataManager.SliderHandles(varIdx), 'Value',...
        [dataManager.DesignVariables(varIdx).sblb...
        dataManager.DesignVariables(varIdx).sbub]);

        % Update box shaped solution space
        set(dataManager.TextHandles.DesignBox(varIdx,1), 'String',...
            sprintf('%.2f', dataManager.DesignVariables(varIdx).sblb));
        set(dataManager.TextHandles.DesignBox(varIdx,2), 'String',...
            sprintf('%.2f', dataManager.DesignVariables(varIdx).sbub));   
        update_design_variable_lines(varIdx, dataManager);

    end
    
    % dataManager.restoreOriginalDesignVariables();
    % 
    % for varIndex = 1:numel(dataManager.OriginalDesignVariables)
    %     dataManager.DesignVariables(varIndex).sblb = dataManager.OriginalDesignVariables(varIndex).sblb;
    %     dataManager.DesignVariables(varIndex).sbub = dataManager.OriginalDesignVariables(varIndex).sbub;
    %     dataManager.DesignVariables(varIndex).dslb = dataManager.OriginalDesignVariables(varIndex).dslb;
    %     dataManager.DesignVariables(varIndex).dsub = dataManager.OriginalDesignVariables(varIndex).dsub;
    % 
    %     % Reset slider value
    %     set(dataManager.SliderHandles(varIndex), 'Value',...
    %         [dataManager.DesignVariables(varIndex).sblb...
    %         dataManager.DesignVariables(varIndex).sbub]);
    % 
    %     % Reset box shaped solution space
    %     set(dataManager.TextHandles.DesignBox(varIndex,1), 'String',...
    %         sprintf('%.2f', dataManager.DesignVariables(varIndex).sblb));
    %     set(dataManager.TextHandles.DesignBox(varIndex,2), 'String',...
    %         sprintf('%.2f', dataManager.DesignVariables(varIndex).sbub));   
    %     update_design_variable_lines(varIndex, dataManager)
    % 
    %     % Reset solution space limits
    %     set(dataManager.TextHandles.DesignLimits(varIndex,1), 'String',...
    %         sprintf('%.2f', dataManager.DesignVariables(varIndex).dslb));
    %     set(dataManager.TextHandles.DesignLimits(varIndex,2), 'String',...
    %         sprintf('%.2f', dataManager.DesignVariables(varIndex).dsub));      
    % end

    % Restore the button's original appearance
    button.BackgroundColor = originalColor;
    button.String = 'Optimize';
    drawnow;                                                               
end