%% Function: Run Optimization
function run_optimization(dataManager)
    % Change the button's appearance to indicate the process is running
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

    try
        % Run the optimization process
        box_optimization(dataManager);
        
        % Provide feedback after the process completes
        msgbox('Optimization completed successfully!', 'Success', 'help');
    catch ME
        % Display an error message if the process fails
        errordlg(['An error occurred: ', ME.message], 'Error', 'modal');
    end

    % Restore the button's original appearance
    button.BackgroundColor = originalColor;
    button.String = 'Optimize';
    drawnow;                                                               % Force UI update
end