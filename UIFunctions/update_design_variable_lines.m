function update_design_variable_lines(index, dataManager)
%UPDATE_DESIGN_VARIABLE_LINES Updates draggable boundary lines on design plots.
%
%   update_design_variable_lines(index, dataManager) updates the positions of
%   vertical and horizontal draggable boundary lines associated with the design
%   variable at the specified index across all individual subplot axes. The lines
%   represent the lower and upper bounds of the design variables and are visually
%   updated to match the current values stored in dataManager.DesignVariables.
%
%   INPUTS:
%       index       - Integer index specifying which design variable to update.
%       dataManager - Struct containing design variable data and handles to
%                     plot axes and line objects. It must include:
%                     .DesignVariables (with sblb and sbub fields for bounds),
%                     .AxisHandles.IndividualPlots (array of axes handles).
%
%   DETAILS:
%       - Searches each subplot axis for line objects tagged with UserData
%         indicating they are draggable boundary lines (types 'left', 'right',
%         'lower', 'upper').
%       - Updates the XData for vertical boundary lines ('left', 'right') and
%         YData for horizontal boundary lines ('lower', 'upper') according to
%         the design variable bounds at the given index.
%
%   Example:
%       update_design_variable_lines(3, dataManager);
%
%   Note:
%       This function assumes the lines have UserData structs containing fields
%       'type' and 'index' to identify their role and associated design variable.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    for i = 1:length(dataManager.AxisHandles.IndividualPlots)
        % Get current axes
        axesHandle = dataManager.AxisHandles.IndividualPlots(i);
        
        % Find all line objects in the current axes
        allLines = findobj(axesHandle, 'Type', 'line');
        
        % Initialize empty arrays for vertical and horizontal lines
        vLines = [];
        hLines = [];
        
        % Separate vertical and horizontal lines based on UserData
        for verticallineIteration = 1:length(allLines)
            userData = get(allLines(verticallineIteration), 'UserData');
            if isfield(userData, 'type') && isfield(userData, 'index')
                if ismember(userData.type, {'left', 'right'})
                    vLines = [vLines; allLines(verticallineIteration)];
                elseif ismember(userData.type, {'lower', 'upper'})
                    hLines = [hLines; allLines(verticallineIteration)];
                end
            end
        end
        
        % Update the vertical lines for the given index
        for verticalLineIteration = 1:length(vLines)
            userData = get(vLines(verticalLineIteration), 'UserData');
            if userData.index == index
                switch userData.type
                    case 'left'
                        % Update the line position based on the new value
                        newValue = dataManager.DesignVariables(index).sblb; % Assuming you want to update based on lower bound
                    case 'right'
                        % Update the line position based on the new value
                        newValue = dataManager.DesignVariables(index).sbub; % Assuming you want to update based on upper bound
                end
                set(vLines(verticalLineIteration), 'XData', [newValue newValue]);
            end
        end
        
        % Update the horizontal lines for the given index
        for horizontalLineIteration = 1:length(hLines)
            userData = get(hLines(horizontalLineIteration), 'UserData');
            if userData.index == index
                switch userData.type
                    case 'lower'
                        % Update the line position based on the new value
                        newValue = dataManager.DesignVariables(index).sblb; % Assuming you want to update based on lower bound
                    case 'upper'
                        % Update the line position based on the new value
                        newValue = dataManager.DesignVariables(index).sbub; % Assuming you want to update based on upper bound
                end
                % Update the line position based on the new value
                set(hLines(horizontalLineIteration), 'YData', [newValue newValue]);
            end
        end
    end
end