function update_gui_design_space_lower_bound(dataManager, iVariable, newValue)
%UPDATE_GUI_DESIGN_SPACE_LOWER_BOUND Update design space lower bound and synchronize GUI
%   UPDATE_GUI_DESIGN_SPACE_LOWER_BOUND updates the design space lower bound
%   for a design variable and synchronizes all related GUI elements
%   (sliders, textboxes, draggable lines). The function validates the new
%   value against constraints and automatically adjusts solution box bounds
%   if necessary to maintain consistency.
%
%   UPDATE_GUI_DESIGN_SPACE_LOWER_BOUND(DATAMANAGER, IVARIABLE, NEWVALUE)
%   updates the design space lower bound and all related GUI elements.
%
%   Inputs:
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing design variable bounds and GUI handles
%       - IVARIABLE : (1,1) integer
%           -- index of the design variable to update
%       - NEWVALUE : (1,1) double
%           -- new lower bound value for the design space
%
%   Outputs:
%       None (GUI and data manager are updated)
%
%   See also update_gui_design_space_upper_bound,
%   update_gui_box_upper_bound, update_gui_box_lower_bound.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2025.
%   Copyright 2025 Eduardo Rodrigues Della Noce (Author)
%   Copyright 2025 Ali Abbas Kapadia (Author)
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

    designSpace = dataManager.get_design_space(iVariable);
    designSpaceUpperBound = designSpace(2);

    if(newValue == designSpace(1))
        return;
    end

    if(newValue >= designSpaceUpperBound)
        newValue = designSpace(1);
        warning('New value is greater than the design space upper bound. Resetting to design space lower bound.');
    end

    designBox = dataManager.get_design_box(iVariable);
    if(newValue > designBox(2))
        BoxXRayOperations.update_gui_box_upper_bound(dataManager, iVariable, newValue);
    end
    if(newValue > designBox(1))
        BoxXRayOperations.update_gui_box_lower_bound(dataManager, iVariable, newValue);
    end

    set(dataManager.SliderHandles(iVariable), 'Limits', [newValue,designSpaceUpperBound]);
    set(dataManager.TextboxDesignSpaceHandles(1, iVariable), 'Value', num2str(newValue));
    dataManager.update_design_space_lower_bounds(newValue, iVariable);
end