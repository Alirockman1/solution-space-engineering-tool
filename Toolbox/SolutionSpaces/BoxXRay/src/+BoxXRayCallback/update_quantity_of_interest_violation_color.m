function update_quantity_of_interest_violation_color(src, event, dataManager, iQuantityOfInterest)
%UPDATE_QUANTITY_OF_INTEREST_VIOLATION_COLOR Update QOI violation color from color picker
%   UPDATE_QUANTITY_OF_INTEREST_VIOLATION_COLOR is a callback function that
%   updates the color used to display violated requirements for a specific
%   quantity of interest when the user changes the color in the color picker.
%
%   UPDATE_QUANTITY_OF_INTEREST_VIOLATION_COLOR(SRC, EVENT, DATAMANAGER,
%   IQUANTITYOFINTEREST) is called when the user selects a new color in the
%   color picker for a quantity of interest.
%
%   Inputs:
%       - SRC : uicolorpicker
%           -- handle to the color picker that was changed
%       - EVENT : event data
%           -- event data from color picker ValueChanged callback (unused)
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing QOI definitions
%       - IQUANTITYOFINTEREST : (1,1) integer
%           -- index of the quantity of interest to update
%
%   Outputs:
%       None (data manager is updated, plots will use new color on next update)
%
%   See also SolutionSpaceBoxXrayDataManager.update_quantities_of_interest_color_when_violated.

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

    newColor = [src.Value];
    dataManager.update_quantities_of_interest_color_when_violated(newColor, iQuantityOfInterest);
end