function update_quantities_of_interest_upper_limit_given_textbox_input(src, event, dataManager, iQuantityOfInterest)
%UPDATE_QUANTITIES_OF_INTEREST_UPPER_LIMIT_GIVEN_TEXTBOX_INPUT Update QOI upper limit from textbox
%   UPDATE_QUANTITIES_OF_INTEREST_UPPER_LIMIT_GIVEN_TEXTBOX_INPUT is a
%   callback function that updates the upper limit for a specific quantity of
%   interest when the user changes the value in the corresponding textbox.
%
%   UPDATE_QUANTITIES_OF_INTEREST_UPPER_LIMIT_GIVEN_TEXTBOX_INPUT(SRC, EVENT,
%   DATAMANAGER, IQUANTITYOFINTEREST) is called when the user edits the upper
%   limit textbox for a quantity of interest.
%
%   Inputs:
%       - SRC : uieditfield
%           -- handle to the textbox that was edited
%       - EVENT : event data
%           -- event data from textbox ValueChanged callback (unused)
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing QOI definitions
%       - IQUANTITYOFINTEREST : (1,1) integer
%           -- index of the quantity of interest to update
%
%   Outputs:
%       None (data manager is updated)
%
%   See also update_quantities_of_interest_lower_limit_given_textbox_input,
%   SolutionSpaceBoxXrayDataManager.update_quantities_of_interest_upper_limits.

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

    newValue = src.Value;
    dataManager.update_quantities_of_interest_upper_limits(newValue, iQuantityOfInterest);
end