function toggle_textbox(chk, dataManager, qoiIndex)
%TOGGLE_TEXTBOX Callback to toggle the activation state of a QoI text box.
%
%   toggle_textbox(chk, dataManager, qoiIndex)
%
%   This function serves as a callback for a checkbox UI control. When the checkbox
%   is toggled, it triggers a method in the `dataManager` object to update the status
%   of a specific Quantity of Interest (QoI) based on the given index.
%
%   INPUTS:
%       chk         - The UI checkbox handle that was interacted with.
%       dataManager - Object or structure managing evaluation state, which must
%                     implement the `toggleQOIStatus` method.
%       qoiIndex    - Index of the QoI to toggle (numeric).
%
%   FUNCTIONALITY:
%       - If the input handle is a valid UI control of type 'uicontrol', the function
%       calls `dataManager.toggleQOIStatus(qoiIndex)` to update the activation state
%       of the corresponding QoI (e.g., enable or disable related textbox entry).
%
%   OUTPUT:
%       None (modifies dataManager in-place)
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    
    if isgraphics(chk) && ishandle(chk) && strcmp(chk.Type, 'uicontrol')
        dataManager.toggleQOIStatus(qoiIndex);
    end
end