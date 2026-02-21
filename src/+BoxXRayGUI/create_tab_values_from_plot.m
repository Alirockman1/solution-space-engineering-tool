function create_tab_values_from_plot(tabValues,dataManager)
% CREATE_TAB_VALUES_FROM_PLOT Builds the "Values from Plot" tab UI.
%   CREATE_TAB_VALUES_FROM_PLOT(TABVALUES, DATAMANAGER) constructs a scrollable
%   interface showing the current values of design variables and quantities of
%   interest as extracted from the plot. Users can view, but not edit, these values,
%   and can select points interactively from the plot using a dedicated button.
%
%   INPUTS:
%       tabValues    - uitab handle where the values display is placed
%       dataManager  - Struct or object containing design variable and QoI definitions,
%                      as well as handles for storing UI controls.
%                      Expected fields and subfields include:
%           .DesignVariables(i).DisplayName   % Display name of each design variable
%           .QuantatiesOfInterests(j).varname % Display name of each quantity of interest
%           .DataTextHandles               % Storage for numeric display field handles
%
%   FUNCTIONALITY:
%       - Displays read-only values for all design variables and QoIs in a
%         scrollable panel.
%       - Each variable or QoI is displayed with a label and a disabled edit field.
%       - Includes a bottom-centered button to activate interactive point selection
%         from the associated plot.
%
%   UI COMPONENTS:
%       - uigridlayout for structured responsive layout
%       - uipanel for grouping the scrollable display area
%       - uilabel for variable and QoI names
%       - uieditfield (read-only) for displaying values
%       - uibutton for activating interactive plot selection
%
%   CALLBACKS USED:
%       activate_selection_mode(dataManager) % Puts the GUI into point selection mode
%
%   OUTPUT:
%       None (UI elements created and handles stored in dataManager)
%
%   NOTES:
%       - The scrollable region grows automatically with the number of variables and QoIs.
%       - Design variable and QoI fields are read-only to prevent accidental edits.
%       - The bottom button triggers an interactive mode to select points directly from
%         the plot and update the corresponding UI fields.

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

    designVariableDisplayNames = dataManager.get_design_variable_display_names;
    designVariableUnit = dataManager.get_design_variable_units;
    quantitiesOfInterestDisplayNames = dataManager.get_quantities_of_interest_display_names;
    quantitiesOfInterestUnit = dataManager.get_quantities_of_interest_units;
    nVariables = length(designVariableDisplayNames);
    nQuantitiesOfInterest = length(quantitiesOfInterestDisplayNames);
    nTotalQuantities = nVariables + nQuantitiesOfInterest;

    % Main Grid on Tab (1 row only)
    mainGridSelectedValues = uigridlayout(tabValues, [1 1]);
    mainGridSelectedValues.RowHeight = {'1x'};  % Top scroll area grows, bottom fixed height
    mainGridSelectedValues.ColumnWidth = {'1x'};
    
    % ---- Scrollable Display Panel (Row 1) ----
    selectedValuesPanel = uipanel(mainGridSelectedValues, ...
        'Title', 'Selected Values from Plot', ...
        'Units', 'normalized');
    
    selectedValuesPanel.Layout.Row = 1;
    
    % Grid inside the panel
    selectedValuesGrid = uigridlayout(selectedValuesPanel, [nTotalQuantities, 2]);
    selectedValuesGrid.RowHeight = [repmat({30}, 1, nTotalQuantities), 25];
    selectedValuesGrid.ColumnWidth = {180, '1x'};   % Label width, flexible textbox
    selectedValuesGrid.Scrollable = 'on';
    selectedValuesGrid.Padding = [8 8 8 8];
    
    % ---- Loop: Design Variables ----
    for iVariable = 1:nVariables

        if ~isempty(designVariableUnit{iVariable})
            % create the panel title text
            designVariableText = sprintf('%s [%s] :', designVariableDisplayNames{iVariable}, designVariableUnit{iVariable});
        else
            designVariableText = sprintf('%s :', designVariableDisplayNames{iVariable});
        end
        
        label = uilabel(selectedValuesGrid, ...
            'Text', designVariableText, ...
            'HorizontalAlignment', 'right');
        label.Layout.Row = iVariable;
        label.Layout.Column = 1;
    
        valueField = uieditfield(selectedValuesGrid, ...
            'Value', 'N/A', ...
            'Enable', 'off', ...
            'HorizontalAlignment', 'left');
        valueField.Layout.Row = iVariable;
        valueField.Layout.Column = 2;
    
        dataManager.TextboxSelectDataHandles(iVariable) = valueField;
    end
    
    % ---- Loop: Quantities of Interest ----
    for iQuantityOfInterest = 1:nQuantitiesOfInterest
        rowIndex = nVariables + iQuantityOfInterest;

        if ~isempty(quantitiesOfInterestUnit{iQuantityOfInterest})
            % create the panel title text
            quantitiesOfInterestText = sprintf('%s [%s] :', quantitiesOfInterestDisplayNames{iQuantityOfInterest}, quantitiesOfInterestUnit{iQuantityOfInterest});
        else
            quantitiesOfInterestText = sprintf('%s :', quantitiesOfInterestDisplayNames{iQuantityOfInterest});
        end
    
        label = uilabel(selectedValuesGrid, ...
            'Text', quantitiesOfInterestText, ...
            'HorizontalAlignment', 'right');
        label.Layout.Row = rowIndex;
        label.Layout.Column = 1;
    
        valueField = uieditfield(selectedValuesGrid, ...
            'Value', 'N/A', ...
            'Enable', 'off', ...
            'HorizontalAlignment', 'left');
        valueField.Layout.Row = rowIndex;
        valueField.Layout.Column = 2;
    
        dataManager.TextboxSelectDataHandles(rowIndex) = valueField;
    end
end