function update_color(src,dataManager,variableIteration)
% UPDATE_COLOR Updates the color property of a QoI based on UI control input.
%
%   UPDATE_COLOR(SRC, DATAMANAGER, VARIABLEITERATION) updates the color field
%   of the specified Quantity of Interest (QoI) in dataManager using the value
%   from the UI control (e.g., slider or dropdown) that triggered the callback.
%
%   INPUT:
%       src               - Handle to the UI control triggering the callback,
%                           expected to have a 'Value' property representing color intensity.
%       dataManager       - Struct or class instance containing the QoIs array.
%       variableIteration - Index of the QoI whose color is to be updated.
%
%   FUNCTIONALITY:
%       - Sets the color of the QoI at variableIteration to a vector where the
%         first element is src.Value and the remaining six elements are zeros.
%
%   OUTPUT:
%       None (modifies dataManager in-place)
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    dataManager.QOIs(variableIteration).color = [src.Value, zeros(1, 6)];
    
end