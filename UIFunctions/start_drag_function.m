function start_drag_function(src, ~, dataManager)
% START_DRAG_FUNCTION Enables interactive dragging of design variable boundary lines.
%   START_DRAG_FUNCTION initializes mouse-tracking callbacks that allow users to
%   interactively modify design variable bounds by dragging vertical or horizontal
%   lines plotted in the solution space axes.
%
%   INPUT:
%       lineHandle   - Handle to the draggable boundary line (must be of type 'line')
%       ~            - Placeholder for event data (unused)
%       dataManager  - Struct or class containing design variable bounds, UI elements,
%                      and handles to axes, sliders, and text boxes
%
%   OPERATION:
%       - Detects which type of bound line is being dragged: 'left', 'right', 'lower', or 'upper'
%       - Tracks mouse movement using WindowButtonMotionFcn while dragging
%       - On mouse release (WindowButtonUpFcn), updates the corresponding design variable
%         bounds, sliders, and text box UI elements
%
%   SUBFUNCTIONS:
%       drag_function         - Continuously updates line position as mouse moves
%       stop_drag_Function    - Finalizes new position and updates all dependent UI fields
%
%   NOTE:
%       - Only works if the input handle is a line object with a proper 'UserData' field
%       - Requires the figure and axes hierarchy to be correctly defined
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    % Make sure button for point selection is not activated
    if isempty(dataManager.SelectionModeActive) || dataManager.SelectionModeActive
        return; % Ignore click if not in selection mode
    end

    % Determine whether the clicked object is a line or patch
    if strcmp(get(src, 'Type'), 'patch')
        patchData = get(src, 'UserData');
        lineHandle = patchData.line;
    else
        lineHandle = src;
    end

    % Get the figure and current axes
    currentAxes = ancestor(lineHandle, 'axes');
    fig = ancestor(currentAxes, 'figure');

    % Set the WindowButtonMotionFcn to track movement
    set(fig, 'WindowButtonMotionFcn', @drag_function);
    set(fig, 'WindowButtonUpFcn', @stop_drag_Function);
    
    if ~strcmp(get(lineHandle, 'Type'), 'line')
        return;                                                                % Exit if it's not a line
    end

    % Get axes limits and ranges
    xLimits = xlim(currentAxes);
    yLimits = ylim(currentAxes);
    xRange  = diff(xLimits);
    yRange  = diff(yLimits);
    
    % Patch half-width: 5% of axis range
    patchWidthX = 0.05 * xRange;
    patchWidthY = 0.05 * yRange;

    function drag_function(~, ~)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DRAG_FUNCTION: Called continuously as the mouse moves while a boundary
    % line is being dragged. Updates the line position (X or Y) in real time.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Get the current mouse position
        mousePosition = get(currentAxes, 'CurrentPoint');
        xPosition = mousePosition(1, 1);                                       % X coordinate of the mouse
        yPosition = mousePosition(1, 2);                                       % Y coordinate of the mouse


        % Check which line is being dragged
        userData = get(lineHandle, 'UserData');
        switch userData.type
            case {'lower', 'upper'}
                % Update horizontal line (Y position)
                set(lineHandle, 'YData', [yPosition yPosition]);

                if strcmp(get(src, 'Type'), 'patch')
                    % Horizontal orientation: patch spans full X limits, centered vertically around yPos
                    xPatch = [xLimits(1), xLimits(2), xLimits(2), xLimits(1)];
                    yPatch = [yPosition - patchWidthY, yPosition - patchWidthY, yPosition + patchWidthY, yPosition + patchWidthY];
                    set(src, 'XData', xPatch, 'YData', yPatch);
                end

            case {'left', 'right'}
                % Update vertical line (X position)
                set(lineHandle, 'XData', [xPosition xPosition]);

                if strcmp(get(src, 'Type'), 'patch')
                    % Vertical orientation: patch spans full Y limits, centered horizontally around xPos
                    yPatch = [yLimits(1), yLimits(1), yLimits(2), yLimits(2)];
                    xPatch = [xPosition - patchWidthX, xPosition + patchWidthX, xPosition + patchWidthX, xPosition - patchWidthX];
                    set(src, 'XData', xPatch, 'YData', yPatch);
                end
        end
    end

    function stop_drag_Function(~, ~)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STOP_DRAG_FUNCTION: Called once when the mouse is released. Updates the
    % corresponding variable bounds in the dataManager, syncs sliders, and
    % updates the text box UI with the new values.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % Reset the motion and up functions
        set(fig, 'WindowButtonMotionFcn', '');
        set(fig, 'WindowButtonUpFcn', '');

        % Update the bounds based on the current position of the lines
        userData = get(lineHandle, 'UserData');
        index = userData.index;                                                % Get the index of the variable

        switch userData.type
            case 'lower'
                newValue = get(lineHandle, 'YData');
                dataManager.DesignVariables(index).sblb = newValue(1);         % Update lower bound for variable index
                set(dataManager.TextHandles.DesignBox(index, 1), 'String',...
                    num2str(dataManager.DesignVariables(index).sblb, '%.2f')); % Update text box
                set(dataManager.SliderHandles(index), 'Value',...
                    [dataManager.DesignVariables(index).sblb ...
                    dataManager.DesignVariables(index).sbub]);                 % Update Slider
 
            case 'upper'
                newValue = get(lineHandle, 'YData');
                dataManager.DesignVariables(index).sbub = newValue(1);         % Update upper bound
                set(dataManager.TextHandles.DesignBox(index, 2), 'String',...
                    num2str(dataManager.DesignVariables(index).sbub, '%.2f')); % Update text box
                set(dataManager.SliderHandles(index), 'Value',...
                    [dataManager.DesignVariables(index).sblb ...
                    dataManager.DesignVariables(index).sbub]);                 % Update Slider

            case 'left'
                newValue = get(lineHandle, 'XData');
                dataManager.DesignVariables(index).sblb = newValue(1);         % Update lower bound
                set(dataManager.TextHandles.DesignBox(index, 1), 'String',...
                    num2str(dataManager.DesignVariables(index).sblb, '%.2f')); % Update text box
                set(dataManager.SliderHandles(index), 'Value',...
                    [dataManager.DesignVariables(index).sblb ...
                    dataManager.DesignVariables(index).sbub]);                 % Update Slider

            case 'right'
                newValue = get(lineHandle, 'XData');
                dataManager.DesignVariables(index).sbub = newValue(1);         % Update upper bound
                set(dataManager.TextHandles.DesignBox(index, 2), 'String',...
                    num2str(dataManager.DesignVariables(index).sbub, '%.2f')); % Update text box
                set(dataManager.SliderHandles(index), 'Value',...
                    [dataManager.DesignVariables(index).sblb ...
                    dataManager.DesignVariables(index).sbub]);                 % Update Slider
        end

        update_design_variable_lines(index, dataManager,[patchWidthX,patchWidthY])
    end
end