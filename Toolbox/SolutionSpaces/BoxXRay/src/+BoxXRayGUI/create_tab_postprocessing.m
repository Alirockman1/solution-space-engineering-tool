function create_tab_postprocessing(tabPost,dataManager,hFig)
%CREATE_TAB_POSTPROCESSING Create post-processing tab UI
%   CREATE_TAB_POSTPROCESSING creates the "Post-processing" tab in the BoxXRay
%   GUI, providing controls for saving plots and evaluation data. The tab
%   includes a textbox for specifying the save path and a button to trigger
%   the save operation.
%
%   CREATE_TAB_POSTPROCESSING(TABPOST, DATAMANAGER, HFIG) creates the
%   post-processing tab UI elements and stores handles in the data manager.
%
%   Inputs:
%       - TABPOST : uitab
%           -- handle to the tab where the UI will be created
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing save folder path and handles storage
%       - HFIG : Figure
%           -- handle to the main figure (passed to save callback)
%
%   Outputs:
%       None (UI elements are created and handles stored in dataManager)
%
%   UI Components Created:
%       - Textbox for save path (stored in dataManager.TextboxSavePathHandle)
%       - Button to save figures and data (calls BoxXRayCallback.save_files)
%
%   See also BoxXRayCallback.save_files, create_tab_design_variables,
%   create_tab_quantities_of_interest.

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

    % Create parent grid in the tab (2 rows for consistency with your other tabs)
    postProcessGrid = uigridlayout(tabPost, [2 1]);
    postProcessGrid.RowHeight = {'fit', 'fit'};        % upper area expandable, bottom row fixed (optional)
    postProcessGrid.ColumnWidth = {'1x'};             % single column
    postProcessGrid.Padding = [10 10 10 10];
    
    % Create the Post-processing Panel (Title container)
    postProcessingPanel = uipanel('Parent', postProcessGrid,...
        'BorderType','line', ... 
        'Title','');

    postProcessingPanel.Layout.Row = 1;
    postProcessingPanel.Layout.Column = 1;

    drawnow;

    % Create the uigridlayout inside the panel
    postProcessingGrid = uigridlayout(postProcessingPanel, [2 2]); % 4 Rows (3 inputs + 1 button), 2 Columns (Label, Input)
    
    % Configuration
    postProcessingGrid.RowHeight = {30, '1x'}; % Fixed height for inputs, '1x' for the button row spacer
    postProcessingGrid.ColumnWidth = {'fit', '1x'};      % 150px for labels, '1x' for inputs
    postProcessingGrid.Padding = [10 10 10 10];
    
    % --- Save Path ---
    
    % Col 1: Label
    hPathLabel = uilabel('Parent', postProcessingGrid, 'Text', 'Save Path:', ...
        'HorizontalAlignment', 'right');
    hPathLabel.Layout.Row = 1;
    
    % Col 2: Text box
    hPathEdit = uieditfield(postProcessingGrid);
    hPathEdit.Layout.Row = 1;
    hPathEdit.Layout.Column = 2;
    if(~isempty(dataManager.SaveFolder))
        hPathEdit.Value = dataManager.SaveFolder;
    end
    dataManager.TextboxSavePathHandle = hPathEdit;
    
    % --- Create a nested grid to center the button ---
    buttonGrid = uigridlayout(postProcessGrid, [1 4]); % 1 row, 4 columns
    buttonGrid.Layout.Row = 2;
    buttonGrid.Layout.Column = 1;
    buttonGrid.Padding = [5 5 5 5];
    buttonGrid.ColumnSpacing = 5;
    
    % Define column widths: empty, button, button, empty
    buttonGrid.ColumnWidth = {'1x', 'fit', 'fit', '1x'};
    buttonGrid.RowHeight = {'fit'};
    
    % Create the Save button inside the nested grid
    hSaveButton = uibutton(buttonGrid, ...
        'Text', 'Save Figure and Data', ...
        'ButtonPushedFcn', @(src, event) BoxXRayCallback.save_files(src, event, dataManager, hFig));
    hSaveButton.Layout.Row = 1;
    hSaveButton.Layout.Column = [2 3]; % Assign the button to span columns 2 and 3 (center)
end