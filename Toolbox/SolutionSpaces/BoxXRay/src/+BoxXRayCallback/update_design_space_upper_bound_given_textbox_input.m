function update_design_space_upper_bound_given_textbox_input(src, event, dataManager, iVariable)
%UPDATE_DESIGN_SPACE_UPPER_BOUND_GIVEN_TEXTBOX_INPUT Update design space upper bound from textbox
%   UPDATE_DESIGN_SPACE_UPPER_BOUND_GIVEN_TEXTBOX_INPUT is a callback
%   function that updates the design space upper bound for a design variable
%   when the user changes the value in the corresponding textbox. The
%   function converts the textbox string value to a number and calls the
%   operation function to update the GUI and data manager.
%
%   UPDATE_DESIGN_SPACE_UPPER_BOUND_GIVEN_TEXTBOX_INPUT(SRC, EVENT,
%   DATAMANAGER, IVARIABLE) is called when the user edits the design space
%   upper bound textbox for a design variable.
%
%   Inputs:
%       - SRC : uieditfield
%           -- handle to the textbox that was edited
%       - EVENT : event data
%           -- event data from textbox ValueChanged callback (unused)
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing design variable bounds and GUI handles
%       - IVARIABLE : (1,1) integer
%           -- index of the design variable to update
%
%   Outputs:
%       None (GUI and data manager are updated)
%
%   See also BoxXRayOperations.update_gui_design_space_upper_bound,
%   update_design_space_lower_bound_given_textbox_input.

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

    newValue = str2double(src.Value);
    BoxXRayOperations.update_gui_design_space_upper_bound(dataManager, iVariable, newValue);
end