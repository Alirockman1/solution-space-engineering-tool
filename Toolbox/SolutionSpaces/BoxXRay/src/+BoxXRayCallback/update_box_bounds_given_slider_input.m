function update_box_bounds_given_slider_input(src, event, dataManager, iVariable)
%UPDATE_BOX_BOUNDS_GIVEN_SLIDER_INPUT Update solution box bounds from slider
%   UPDATE_BOX_BOUNDS_GIVEN_SLIDER_INPUT is a callback function that updates
%   the solution box bounds (lower and/or upper) for a design variable when
%   the user moves the range slider. The function detects which bound changed
%   and updates only that bound to avoid unnecessary updates.
%
%   UPDATE_BOX_BOUNDS_GIVEN_SLIDER_INPUT(SRC, EVENT, DATAMANAGER, IVARIABLE)
%   is called when the user moves the range slider for a design variable.
%
%   Inputs:
%       - SRC : uislider
%           -- handle to the slider that was moved
%       - EVENT : event data
%           -- event data containing Value (current) and PreviousValue
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing design variable bounds and GUI handles
%       - IVARIABLE : (1,1) integer
%           -- index of the design variable to update
%
%   Outputs:
%       None (GUI and data manager are updated)
%
%   See also BoxXRayOperations.update_gui_box_lower_bound,
%   BoxXRayOperations.update_gui_box_upper_bound.

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

    hasChanged = (event.Value~=event.PreviousValue);

    if(hasChanged(1))
        newValue = event.Value(1);
        BoxXRayOperations.update_gui_box_lower_bound(dataManager, iVariable, newValue);
    end

    if(hasChanged(2))
        newValue = event.Value(2);
        BoxXRayOperations.update_gui_box_upper_bound(dataManager, iVariable, newValue);
    end
end