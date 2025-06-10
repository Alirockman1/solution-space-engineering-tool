%% Function to update plot
function update_plot(dataManager,nVariables)

    % Get current values for design-space bounds from textbox
    for i = 1:nVariables
        lb = str2double(get(dataManager.TextHandles(i, 1), 'String'));
        ub = str2double(get(dataManager.TextHandles(i, 2), 'String'));
        
        % Update data in dataManager
        dataManager.updateDesignVarBounds(i, 1, round(lb,2));              % Lower bound
        dataManager.updateDesignVarBounds(i, 2, round(ub,2));              % Upper bound

    end

    % Change the button's appearance to indicate the process is running
    button = gcbo;
    originalColor = button.BackgroundColor; % Save original color
    button.BackgroundColor = [1, 0.8, 0.5]; % Set to light orange
    button.String = 'Plotting Solution';           % Update the button label
    drawnow; % Force UI update

    try

        % Clear and plot the solution space based on new bounds
        solution_space_plot(dataManager);

        % Provide feedback after the process completes
        msgbox('Solution Space Plot Completed!', 'Success', 'help');

    catch ME
        % Display an error message if the process fails
        errordlg(['An error occurred while plotting: ', ME.message], 'Error', 'modal');
    end

    % Restore the button's original appearance
    button.BackgroundColor = originalColor;
    button.String = 'Update Plot';
    drawnow; % Force UI update

end