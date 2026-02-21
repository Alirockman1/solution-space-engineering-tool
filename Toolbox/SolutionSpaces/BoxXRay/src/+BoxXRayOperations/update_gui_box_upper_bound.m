function update_gui_box_upper_bound(dataManager, iVariable, newValue)
%UPDATE_GUI_BOX_UPPER_BOUND Update solution box upper bound and synchronize GUI
%   UPDATE_GUI_BOX_UPPER_BOUND updates the solution box upper bound for a
%   design variable and synchronizes all related GUI elements (sliders,
%   textboxes, draggable lines and patches). The function validates the new
%   value against design space and solution box constraints.
%
%   UPDATE_GUI_BOX_UPPER_BOUND(DATAMANAGER, IVARIABLE, NEWVALUE) updates the
%   solution box upper bound and all related GUI elements.
%
%   Inputs:
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing design variable bounds and GUI handles
%       - IVARIABLE : (1,1) integer
%           -- index of the design variable to update
%       - NEWVALUE : (1,1) double
%           -- new upper bound value for the solution box
%
%   Outputs:
%       None (GUI and data manager are updated)
%
%   See also update_gui_box_lower_bound,
%   update_gui_design_space_upper_bound, update_gui_design_space_lower_bound.

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
    designBox = dataManager.get_design_box(iVariable);

    if(newValue == designBox(2))
        return;
    end

    boundLowerLimit = designBox(1);
    boundUpperLimit = designSpace(2);

    if(newValue > boundUpperLimit)
        newValue = boundUpperLimit;
        warning('New value is greater than the design space upper bound. Resetting to design space upper bound.');
    end
    if(newValue < boundLowerLimit)
        newValue = boundLowerLimit;
        warning('New value is less than the box lower bound. Resetting to box lower bound.');
    end

    set(dataManager.SliderHandles(iVariable), 'Value', [boundLowerLimit,newValue]);
    set(dataManager.TextboxDesignBoxHandles(2, iVariable), 'Value', num2str(newValue));

    vLines = dataManager.DraggabbleVerticalLineHandles{iVariable};
    for iLine = 1:size(vLines,2)
        set(vLines(2,iLine), 'XData', [newValue newValue]);
    end

    hLines = dataManager.DraggabbleHorizontalLineHandles{iVariable};
    for iLine = 1:size(hLines,2)
        set(hLines(2,iLine), 'YData', [newValue newValue]);
    end

    vPatches = dataManager.DraggabbleVerticalPatchHandles{iVariable};
    for iPatch = 1:size(vPatches,2)
        % Get existing patch geometry to infer width
        xData = get(vPatches(2,iPatch), 'XData');
        halfWidth = abs(xData(2) - xData(1)) / 2;

        % Update patch XData based on new line position
        xPatch = [newValue - halfWidth, newValue + halfWidth, ...
                  newValue + halfWidth, newValue - halfWidth];
        set(vPatches(2,iPatch), 'XData', xPatch);
    end

    hPatches = dataManager.DraggabbleHorizontalPatchHandles{iVariable};
    for iPatch = 1:size(hPatches,2)
        % Get existing patch geometry to infer height
        yData = get(hPatches(2,iPatch), 'YData');
        halfHeight = abs(yData(3) - yData(1)) / 2;

        % Update patch YData based on new line position
        yPatch = [newValue - halfHeight, newValue - halfHeight, ...
                  newValue + halfHeight, newValue + halfHeight];
        set(hPatches(2,iPatch), 'YData', yPatch);
    end

    dataManager.update_design_box_upper_bounds(newValue, iVariable);
end