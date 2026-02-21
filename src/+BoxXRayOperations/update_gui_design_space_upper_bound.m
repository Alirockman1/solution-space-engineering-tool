function update_gui_design_space_upper_bound(dataManager, iVariable, newValue)
%UPDATE_GUI_DESIGN_SPACE_UPPER_BOUND Update design space upper bound and synchronize GUI
%   UPDATE_GUI_DESIGN_SPACE_UPPER_BOUND updates the design space upper bound
%   for a design variable and synchronizes all related GUI elements
%   (sliders, textboxes, draggable lines). The function validates the new
%   value against constraints and automatically adjusts solution box bounds
%   if necessary to maintain consistency.
%
%   UPDATE_GUI_DESIGN_SPACE_UPPER_BOUND(DATAMANAGER, IVARIABLE, NEWVALUE)
%   updates the design space upper bound and all related GUI elements.
%
%   Inputs:
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing design variable bounds and GUI handles
%       - IVARIABLE : (1,1) integer
%           -- index of the design variable to update
%       - NEWVALUE : (1,1) double
%           -- new upper bound value for the design space
%
%   Outputs:
%       None (GUI and data manager are updated)
%
%   See also update_gui_design_space_lower_bound,
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
    designSpaceLowerBound = designSpace(1);

    if(newValue == designSpace(2))
        return;
    end

    if(newValue <= designSpaceLowerBound)
        newValue = designSpace(2);
        warning('New value is less than the design space lower bound. Resetting to design space upper bound.');
    end

    designBox = dataManager.get_design_box(iVariable);
    if(newValue < designBox(1))
        BoxXRayOperations.update_gui_box_lower_bound(dataManager, iVariable, newValue);
    end
    if(newValue < designBox(2))
        BoxXRayOperations.update_gui_box_upper_bound(dataManager, iVariable, newValue);
    end

    set(dataManager.SliderHandles(iVariable), 'Limits', [designSpaceLowerBound,newValue]);
    set(dataManager.TextboxDesignSpaceHandles(2, iVariable), 'Value', num2str(newValue));
    dataManager.update_design_space_upper_bounds(newValue, iVariable);
end