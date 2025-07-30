function update_plot(dataManager)
% UPDATE_PLOT Updates design variable bounds and redraws the solution space plot.
%S
%   UPDATE_PLOT reads current design variable bounds from UI text boxes, updates
%   the internal data manager, clears previous plots, and triggers a refresh of
%   the solution space visualization.
%
%   INPUT:
%       dataManager - Struct or class instance managing design variables, UI handles,
%                     and plot axes
%       nVariables  - Number of design variables to update and plot
%
%   OPERATION:
%       - Iterates over each design variable to:
%           * Read lower and upper bounds from associated UI text boxes
%           * Update design variable bounds within dataManager (rounded to 2 decimals)
%           * Clear individual plot axes for fresh drawing
%       - Temporarily changes the button appearance (color and label) to indicate processing
%       - Calls `solution_space_plot_axis(dataManager)` to regenerate the solution space plot
%       - Shows a message box on successful completion or an error dialog on failure
%       - Restores the button appearance at the end
%
%   OUTPUT:
%       None (updates GUI and internal data state)
%
%   DEPENDENCIES:
%       - dataManager with methods `updateDesignVarBounds` and fields for UI handles
%       - `solution_space_plot_axis` function to render plots
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0
    
    for i = 1:numel(dataManager.AxisHandles.IndividualPlots)
        % Clear plot data
        cla(dataManager.AxisHandles.IndividualPlots(i));    % Clear it safely
    end

    % Change the button's appearance to indicate the process is running
    button = gcbo;
    originalColor = button.BackgroundColor;                                % Save original color
    button.BackgroundColor = [1, 0.8, 0.5];                                % Set to light orange
    button.String = 'Plotting Solution';                                   % Update the button label
    drawnow;

    try
        % Clear and plot the solution space based on new bounds
        solution_space_plot_axis(dataManager);

        % Provide feedback after the process completes
        msgbox('Solution Space Plot Completed!', 'Success', 'help');

    catch ME
        % Display an error message if the process fails
        errordlg(['An error occurred while plotting: ', ME.message], 'Error', 'modal');
    end

    % Restore the button's original appearance
    button.BackgroundColor = originalColor;
    button.String = 'Update Plot';
    drawnow;

end