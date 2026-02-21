function update_quantity_of_interest_active_status(src, event, dataManager, iQuantityOfInterest)
%UPDATE_QUANTITY_OF_INTEREST_ACTIVE_STATUS Update QOI active status from checkbox
%   UPDATE_QUANTITY_OF_INTEREST_ACTIVE_STATUS is a callback function that
%   updates the active status (enabled/disabled) for a specific quantity of
%   interest when the user toggles the corresponding checkbox.
%
%   UPDATE_QUANTITY_OF_INTEREST_ACTIVE_STATUS(SRC, EVENT, DATAMANAGER,
%   IQUANTITYOFINTEREST) is called when the user toggles the active checkbox
%   for a quantity of interest.
%
%   Inputs:
%       - SRC : uicheckbox
%           -- handle to the checkbox that was toggled
%       - EVENT : event data
%           -- event data from checkbox ValueChanged callback (unused)
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing QOI definitions
%       - IQUANTITYOFINTEREST : (1,1) integer
%           -- index of the quantity of interest to update
%
%   Outputs:
%       None (data manager is updated)
%
%   See also SolutionSpaceBoxXrayDataManager.update_quantities_of_interest_active_status.

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

    activeStatus = logical(src.Value);
    dataManager.update_quantities_of_interest_active_status(activeStatus, iQuantityOfInterest);
end