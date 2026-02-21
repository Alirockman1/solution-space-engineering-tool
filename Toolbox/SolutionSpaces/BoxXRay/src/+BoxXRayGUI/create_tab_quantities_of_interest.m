function create_tab_quantities_of_interest(tabQuantaties,dataManager)
%CREATE_TAB_QUANTITIES_OF_INTEREST Create quantities of interest tab UI
%   CREATE_TAB_QUANTITIES_OF_INTEREST creates the "Quantities of Interest"
%   tab in the BoxXRay GUI, providing controls for configuring QOI limits,
%   active status, and violation colors. Each QOI has a panel with checkbox,
%   lower/upper bound inputs, and a color picker.
%
%   CREATE_TAB_QUANTITIES_OF_INTEREST(TABQUANTATIES, DATAMANAGER) creates
%   the QOI tab UI elements and stores handles in the data manager.
%
%   Inputs:
%       - TABQUANTATIES : uitab
%           -- handle to the tab where the UI will be created
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing QOI definitions and handles storage
%
%   Outputs:
%       None (UI elements are created and handles stored in dataManager)
%
%   UI Components Created:
%       - Scrollable grid with one panel per QOI
%       - Each panel contains:
%           * Checkbox for active status
%           * Numeric edit fields for lower and upper bounds
%           * Color picker for violation color
%
%   See also BoxXRayCallback.update_quantity_of_interest_active_status,
%   BoxXRayCallback.update_quantities_of_interest_lower_limit_given_textbox_input,
%   BoxXRayCallback.update_quantities_of_interest_upper_limit_given_textbox_input,
%   BoxXRayCallback.update_quantity_of_interest_violation_color.

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

    quantitiesOfInterestDisplayNames = dataManager.get_quantities_of_interest_display_names;
    quantitiesOfInterestLimits = dataManager.get_quantities_of_interest_limits;
    quantitiesOfInterestColors = dataManager.get_quantities_of_interest_colors_when_violated;
    quantitiesOfInterestUnits = dataManager.get_quantities_of_interest_units;
    nQuantitiesOfInterest = size(quantitiesOfInterestLimits, 2);

    % --- Main Grid in Tab (2 rows) ---
    mainGridQuantitiesOfInterest = uigridlayout(tabQuantaties, [2 1]);
    mainGridQuantitiesOfInterest.RowHeight = {'1x', 35};  % scroll area grows, button row fixed
    mainGridQuantitiesOfInterest.ColumnWidth = {'1x'};
    
    % --- Scrollable Region for Quantity Panels ---
    scrollGridQuantitiesOfInterest = uigridlayout(mainGridQuantitiesOfInterest, [nQuantitiesOfInterest 1]);
    scrollGridQuantitiesOfInterest.Layout.Row = 1;
    scrollGridQuantitiesOfInterest.Scrollable = 'on';
    scrollGridQuantitiesOfInterest.RowHeight = repmat({'fit'},1,nQuantitiesOfInterest);
    scrollGridQuantitiesOfInterest.ColumnWidth = {'1x'};
    scrollGridQuantitiesOfInterest.Padding = [0 0 0 0];
    
    % ---- System Evaluator ---- %
    systemEvaluation = dataManager.SystemEvaluation;

    % ---- Create UI Panel for Each Quantity of Interest ----
    for iQuantityOfInterest = 1:nQuantitiesOfInterest

        if ~isempty(quantitiesOfInterestUnits{iQuantityOfInterest})
            % create the panel title text
            quantitiesOfInterestTitle = sprintf('%s [%s]', quantitiesOfInterestDisplayNames{iQuantityOfInterest}, quantitiesOfInterestUnits{iQuantityOfInterest});
        else
            quantitiesOfInterestTitle = sprintf('%s', quantitiesOfInterestDisplayNames{iQuantityOfInterest});
        end
        
        quantitiesOfInterestPanels = uipanel(scrollGridQuantitiesOfInterest, ...
            'Title', quantitiesOfInterestTitle, ...
            'Tag', ['QuantityPanel_' num2str(iQuantityOfInterest)]);
    
        panelGrid = uigridlayout(quantitiesOfInterestPanels, [2 4]);
        panelGrid.RowHeight = {18, 25};
        panelGrid.ColumnWidth = {'fit','1x','1x','fit'};
        panelGrid.Padding = [8 8 8 8];
    
        % ---- Row 1: Labels ----
        % Col 1: 'InActive' Label 
        hLabel = uilabel(panelGrid, 'Text', 'Active', 'HorizontalAlignment', 'center'); 
        hLabel.Layout.Row = 1; hLabel.Layout.Column = 1; 

        % Col 2: 'Lower Bound' Label 
        hLabel = uilabel(panelGrid, 'Text', 'Lower Bound', 'HorizontalAlignment', 'center'); 
        hLabel.Layout.Row = 1; hLabel.Layout.Column = 2; 
        
        % Col 3: 'Upper Bound' Label 
        hLabel = uilabel(panelGrid, 'Text', 'Upper Bound', 'HorizontalAlignment', 'center'); 
        hLabel.Layout.Row = 1; hLabel.Layout.Column = 3; 
        
        % Col 4: 'Colour' Label 
        hLabel = uilabel(panelGrid, 'Text', 'Colour', 'HorizontalAlignment', 'center'); 
        hLabel.Layout.Row = 1; hLabel.Layout.Column = 4;
    
        % ---- Row 2: Controls ----
        quantityCheckboxHandles = uicheckbox(panelGrid, ...
            "Text","", ...
            'Value',true,...
            'FontSize', 14,...
            'ValueChangedFcn', @(src,event) BoxXRayCallback.update_quantity_of_interest_active_status(src, event, dataManager, iQuantityOfInterest));
        quantityCheckboxHandles.Layout.Row = 2; 
        quantityCheckboxHandles.Layout.Column = 1;
    
        textboxQuantitiesOfInterestLowerLimitHandles = uieditfield(panelGrid,'numeric',...
            'Value', quantitiesOfInterestLimits(1, iQuantityOfInterest),...
            'HorizontalAlignment','center');
        textboxQuantitiesOfInterestLowerLimitHandles.Layout.Row = 2;
        textboxQuantitiesOfInterestLowerLimitHandles.Layout.Column = 2;
    
        textboxQuantitiesOfInterestUpperLimitHandles = uieditfield(panelGrid,'numeric',...
            'Value', quantitiesOfInterestLimits(2, iQuantityOfInterest),...
            'HorizontalAlignment','center');
        textboxQuantitiesOfInterestUpperLimitHandles.Layout.Row = 2;
        textboxQuantitiesOfInterestUpperLimitHandles.Layout.Column = 3;

        if(isa(systemEvaluation,'DesignEvaluatorBase'))
            textboxQuantitiesOfInterestLowerLimitHandles.Enable = 'off';
            textboxQuantitiesOfInterestUpperLimitHandles.Enable = 'off';

        else
            textboxQuantitiesOfInterestLowerLimitHandles.Editable = 'on';
            textboxQuantitiesOfInterestUpperLimitHandles.Editable = 'on';

            textboxQuantitiesOfInterestLowerLimitHandles.ValueChangedFcn = @(src,event) BoxXRayCallback.update_quantities_of_interest_lower_limit_given_textbox_input(src, event, dataManager, iQuantityOfInterest);
            textboxQuantitiesOfInterestUpperLimitHandles.ValueChangedFcn = @(src,event) BoxXRayCallback.update_quantities_of_interest_upper_limit_given_textbox_input(src, event, dataManager, iQuantityOfInterest);
        end
    
        colorPickerHandle = uicolorpicker(panelGrid,...
            'Value', quantitiesOfInterestColors(iQuantityOfInterest,:),...
            'ValueChangedFcn', @(src,event) BoxXRayCallback.update_quantity_of_interest_violation_color(src, event, dataManager, iQuantityOfInterest));
        colorPickerHandle.Layout.Row = 2;
        colorPickerHandle.Layout.Column = 4;
    end
end