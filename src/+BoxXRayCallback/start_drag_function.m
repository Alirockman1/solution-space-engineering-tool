function start_drag_function(srcStartDrag, eventStartDrag, dataManager)
%START_DRAG_FUNCTION Start interactive dragging of boundary lines
%   START_DRAG_FUNCTION initializes mouse-tracking callbacks to enable
%   interactive dragging of design variable boundary lines (vertical or
%   horizontal) in the solution space plots. The function sets up motion and
%   release callbacks that update line positions and synchronize GUI elements.
%
%   START_DRAG_FUNCTION(SRCSTARTDRAG, EVENTSTARTDRAG, DATAMANAGER) is called
%   when the user clicks on a draggable boundary line or patch. It sets up
%   WindowButtonMotionFcn and WindowButtonUpFcn callbacks for dragging.
%
%   Inputs:
%       - SRCSTARTDRAG : graphics object
%           -- handle to the line or patch that was clicked
%       - EVENTSTARTDRAG : event data
%           -- event data from click (unused)
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing patch width settings and GUI handles
%
%   Outputs:
%       None (callbacks are set up for dragging)
%
%   Local Functions:
%       - drag_function : updates line/patch position during mouse movement
%       - stop_drag_Function : finalizes position and updates GUI elements
%
%   See also BoxXRayGUI.create_patch_for_line,
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

    % Make sure button for point selection is not activated
    if(~isempty(dataManager.TabGroupHandle) && (strcmpi(dataManager.TabGroupHandle.SelectedTab.Title, 'Values from Plot')))
        BoxXRayCallback.select_data_from_plot(srcStartDrag, eventStartDrag, dataManager);
        return; % Ignore click if not in selection mode
    end

    % Determine whether the clicked object is a line or patch
    if strcmp(get(srcStartDrag, 'Type'), 'patch')
        patchData = get(srcStartDrag, 'UserData');
        lineHandle = patchData.line;
    else
        lineHandle = srcStartDrag;
    end

    % Get the figure and current axes
    currentAxes = ancestor(lineHandle, 'axes');
    fig = ancestor(currentAxes, 'figure');

    % Get axes limits and ranges
    xLimits = xlim(currentAxes);
    yLimits = ylim(currentAxes);
    xRange  = diff(xLimits);
    yRange  = diff(yLimits);
    
    % Patch half-width: 5% of axis range
    patchWidthX = dataManager.PatchRelativeWidth * xRange;
    patchWidthY = dataManager.PatchRelativeWidth * yRange;

    % Set the WindowButtonMotionFcn to track movement
    set(fig, 'WindowButtonMotionFcn', @(srcButtonMotion,event)drag_function(srcButtonMotion, event, currentAxes, lineHandle, srcStartDrag, xLimits, yLimits, patchWidthX, patchWidthY));
    set(fig, 'WindowButtonUpFcn', @(srcButtonUp,event)stop_drag_Function(srcButtonUp, event, fig, lineHandle, dataManager));
    
    if ~strcmp(get(lineHandle, 'Type'), 'line')
        return;                                                                % Exit if it's not a line
    end
end

function drag_function(~, ~, currentAxes, lineHandle, srcStartDrag, xLimits, yLimits, patchWidthX, patchWidthY)
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

            if strcmp(get(srcStartDrag, 'Type'), 'patch')
                % Horizontal orientation: patch spans full X limits, centered vertically around yPos
                xPatch = [xLimits(1), xLimits(2), xLimits(2), xLimits(1)];
                yPatch = [yPosition - patchWidthY, yPosition - patchWidthY, yPosition + patchWidthY, yPosition + patchWidthY];
                set(srcStartDrag, 'XData', xPatch, 'YData', yPatch);
            end

        case {'left', 'right'}
            % Update vertical line (X position)
            set(lineHandle, 'XData', [xPosition xPosition]);

            if strcmp(get(srcStartDrag, 'Type'), 'patch')
                % Vertical orientation: patch spans full Y limits, centered horizontally around xPos
                yPatch = [yLimits(1), yLimits(1), yLimits(2), yLimits(2)];
                xPatch = [xPosition - patchWidthX, xPosition + patchWidthX, xPosition + patchWidthX, xPosition - patchWidthX];
                set(srcStartDrag, 'XData', xPatch, 'YData', yPatch);
            end
    end
end

function stop_drag_Function(~, ~, fig, lineHandle, dataManager)
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
    index = userData.index; % Get the index of the variable

    switch userData.type
        case 'lower'
            newValue = get(lineHandle, 'YData');
            BoxXRayOperations.update_gui_box_lower_bound(dataManager, index, newValue(1));
        case 'upper'
            newValue = get(lineHandle, 'YData');
            BoxXRayOperations.update_gui_box_upper_bound(dataManager, index, newValue(1));
        case 'left'
            newValue = get(lineHandle, 'XData');
            BoxXRayOperations.update_gui_box_lower_bound(dataManager, index, newValue(1));
        case 'right'
            newValue = get(lineHandle, 'XData');
            BoxXRayOperations.update_gui_box_upper_bound(dataManager, index, newValue(1));
    end
end