function create_tab_design_variables(tabVariables,dataManager)
% CREATE_TAB_DESIGN_VARIABLES Creates the Design Variables configuration tab.
%   CREATE_TAB_DESIGN_VARIABLES(TABVARIABLES, DATAMANAGER) dynamically builds a
%   scrollable tab where each design variable is presented with editable 
%   lower/upper limits and an interactive range slider.
%
%   INPUTS:
%       tabVariables - uitab handle where the controls are placed
%       dataManager  - Struct or class instance containing design variable 
%                      definitions and callback handlers. Expected fields:
%           .DesignVariables(index).DisplayName  % Display name for UI title
%           .DesignVariables(index).DesignSpaceLowerBound      % Design-space lower bound
%           .DesignVariables(index).DesignSpaceUpperBound      % Design-space upper bound
%           .DesignVariables(index).BoxLowerBound      % Solution-box lower bound
%           .DesignVariables(index).BoxUpperBound      % Solution-box upper bound
%           .TextHandles.DesignLimits         % Handles for design-space fields
%           .TextHandles.DesignBox            % Handles for solution-box fields
%           .SliderHandles                    % Slider handle storage array
%
%   FUNCTIONALITY:
%       - Creates one panel per design variable, arranged vertically with scroll
%       - Each variable panel contains:
%           * Editable fields for design-space bounds (DSLB, DSUB)
%           * Editable fields for solution-box bounds (SBLB, SBUB)
%           * Slider to adjust solution-box limits interactively
%       - Connects UI elements to appropriate callbacks to update dataManager
%
%   UI COMPONENTS USED:
%       - uigridlayout for panel layout structure
%       - uipanel for variable grouping
%       - uieditfield for numeric input
%       - uislider for interval selection
%
%   OUTPUT:
%       None (UI controls added to the tab and handles stored in dataManager)
%
%   NOTES:
%       - Scrollable grid used for scalability with many variables
%       - ValueChanged callbacks propagate updates to dataManager logic
%
%   DEPENDENCIES:
%       design_textbox_callback() — for design-space bound edits
%       textbox_callback()        — for solution-box edits
%       slider_callback()         — for slider adjustments

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

    designBox = dataManager.get_design_box;
    designSpace = dataManager.get_design_space;
    displayNames = dataManager.get_design_variable_display_names;
    designVariableUnit = dataManager.get_design_variable_units;
    nVariables = size(designBox, 2);
    
    % 1. Create the main layout in the tab
    gridPanels = uigridlayout(tabVariables);
    
    % Configure the grid to flow vertically and manage padding
    gridPanels.RowHeight = repmat({'fit'}, 1, nVariables); % Each row fits its content (the variable panel)
    gridPanels.ColumnWidth = {'1x'};
    gridPanels.Padding = [10 10 10 10]; % [left bottom right top]
    gridPanels.Scrollable = 'on'; % Enable scrolling for the entire grid if content exceeds tab size
    
    % Preallocate handles (optional, but good practice)
    variablePanel = gobjects(nVariables, 1);
    
    for iVariable = 1:nVariables

       if ~isempty(designVariableUnit{iVariable})
            % create the panel title text
            designVariableTitle = sprintf('%s [%s]', displayNames{iVariable}, designVariableUnit{iVariable});
        else
            designVariableTitle = sprintf('%s', displayNames{iVariable});
        end

        % 2. Create a uipanel for the variable inside the grid
        variablePanel(iVariable) = uipanel(gridPanels, ...
            'Title', designVariableTitle, ...
            'Tag', ['VariablePanel_' num2str(iVariable)]);
        
        % Use a nested uigridlayout inside the panel for control placement
        pGrid = uigridlayout(variablePanel(iVariable), [3 5]); % 3 rows (labels, controls, gap), 5 columns (DSLB, SBLB, Slider, SBUB, DSUB)
        pGrid.RowHeight = {10, 40, '1x'};
        pGrid.ColumnWidth = {60, 60, '3x', 60, 60}; % Fixed width for edit fields, '1x' for the slider
        pGrid.Padding = [5 5 5 5]; % Tight padding
        
        % --- Row 2: Controls ---
        % Col 1: Design Space Lower Bound (DSLB)
        dataManager.TextboxDesignSpaceHandles(1,iVariable) = uieditfield(pGrid, ...
            'Value', num2str(designSpace(1, iVariable), '%.2f'), ...
            'Editable', 'on', ...
            'FontSize', 10, ...
            'FontColor', [1 0 0], ...
            'Tooltip', 'Design Space Lower Bound', ...
            'HorizontalAlignment', 'center', ...
            'ValueChangedFcn', @(src, event) BoxXRayCallback.update_design_space_lower_bound_given_textbox_input(src, event, dataManager, iVariable));
        dataManager.TextboxDesignSpaceHandles(1,iVariable).Layout.Row = 2;
        dataManager.TextboxDesignSpaceHandles(1,iVariable).Layout.Column = 1;

        % Col 2: Solution Box Lower Bound (SBLB)
        dataManager.TextboxDesignBoxHandles(1,iVariable) = uieditfield(pGrid, ...
            'Value', num2str(designBox(1, iVariable), '%.2f'), ...
            'Editable', 'on', ...
            'FontSize', 10, ...
            'Tooltip', 'Solution Box Lower Bound', ...
            'HorizontalAlignment', 'center', ...
            'ValueChangedFcn', @(src, event) BoxXRayCallback.update_box_lower_bound_given_textbox_input(src, event, dataManager, iVariable));
        dataManager.TextboxDesignBoxHandles(1,iVariable).Layout.Row = 2;
        dataManager.TextboxDesignBoxHandles(1,iVariable).Layout.Column = 2;
        
        % Col 3: Slider
        hSlider = uislider(pGrid,...
            'range', ...
            'Value', [designBox(1, iVariable) designBox(2, iVariable)], ...
            'Limits', [designSpace(1, iVariable) designSpace(2, iVariable)], ...
            'MinorTicks', [], ...
            'ValueChangedFcn', @(src, event) BoxXRayCallback.update_box_bounds_given_slider_input(src, event, dataManager, iVariable));
        hSlider.Layout.Row = 2;
        hSlider.Layout.Column = 3;
        dataManager.SliderHandles(iVariable) = hSlider;
        
        % Col 4: Solution Box Upper Bound (SBUB)
        dataManager.TextboxDesignBoxHandles(2,iVariable) = uieditfield(pGrid, ...
            'Value', num2str(designBox(2, iVariable), '%.2f'), ...
            'Editable', 'on', ...
            'FontSize', 10, ...
            'Tooltip', 'Solution Box Upper Bound', ...
            'HorizontalAlignment', 'center', ...
            'ValueChangedFcn', @(src, event) BoxXRayCallback.update_box_upper_bound_given_textbox_input(src, event, dataManager, iVariable));
        dataManager.TextboxDesignBoxHandles(2,iVariable).Layout.Row = 2;
        dataManager.TextboxDesignBoxHandles(2,iVariable).Layout.Column = 4;
        
        % Col 5: Design Space Upper Bound (DSUB)
        dataManager.TextboxDesignSpaceHandles(2,iVariable) = uieditfield(pGrid, ...
            'Value', num2str(designSpace(2, iVariable), '%.2f'), ...
            'Editable', 'on', ...
            'FontSize', 10, ...
            'FontColor', [1 0 0], ...
            'Tooltip', 'Design Space Upper Bound', ...
            'HorizontalAlignment', 'center', ...
            'ValueChangedFcn', @(src, event) BoxXRayCallback.update_design_space_upper_bound_given_textbox_input(src, event, dataManager, iVariable));  
        dataManager.TextboxDesignSpaceHandles(2,iVariable).Layout.Row = 2;
        dataManager.TextboxDesignSpaceHandles(2,iVariable).Layout.Column = 5;

    end
end