function update_plot(src, event, dataManager)
%UPDATE_PLOT Update solution space plot based on current bounds
%   UPDATE_PLOT is a callback function that clears existing plots and
%   regenerates the solution space visualization based on the current design
%   variable bounds stored in the data manager. The function provides visual
%   feedback during the plotting process by changing the button appearance.
%
%   UPDATE_PLOT(SRC, EVENT, DATAMANAGER) is called when the user clicks the
%   "Update Plot" button. It clears all plot axes and calls
%   solution_space_plot_axis_patch to regenerate the plots with current bounds.
%
%   Inputs:
%       - SRC : uibutton
%           -- handle to the button that triggered the callback (unused)
%       - EVENT : event data
%           -- event data from button callback (unused)
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing plot axes handles, design bounds, and
%           evaluation data
%
%   Outputs:
%       None (plots are updated in place, button appearance is restored)
%
%   See also solution_space_plot_axis_patch, BoxXRayGUI.

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
    
    for i = 1:numel(dataManager.PlotAxesHandles)
        % Clear plot data
        cla(dataManager.PlotAxesHandles(i));    % Clear it safely
    end

    % Change the button's appearance to indicate the process is running
    button = gcbo;
    originalColor = button.BackgroundColor;                                % Save original color
    button.BackgroundColor = [1, 0.8, 0.5];                                % Set to light orange
    button.Text = 'Plotting Solution';                                    % Update the button label
    drawnow;

    try
        % Clear and plot the solution space based on new bounds
        BoxXRayGUI.solution_space_plot_axis_patch(dataManager);

        % Provide feedback after the process completes
        msgbox('Solution Space Plot Completed!', 'Success', 'help');

    catch ME
        % Display an error message if the process fails
        errordlg(['An error occurred while plotting: ', ME.message], 'Error', 'modal');
    end

    % Restore the button's original appearance
    button.BackgroundColor = originalColor;
    button.Text = 'Update Plot';
    drawnow;

end