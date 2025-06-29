function design_textbox_callback(src, dataManager, varIndex, boundType)
% DESIGN_TEXTBOX_CALLBACK Updates design variable bounds from textbox input.
%   DESIGN_TEXTBOX_CALLBACK(SRC, DATAMANAGER, VARINDEX, BOUNDTYPE) is a 
%   callback function for GUI textboxes that allows users to update 
%   the lower or upper bounds of a design variable in an interactive UI.
%
%   INPUT:
%       src        - The source UI control (textbox) triggering the callback
%       dataManager - Struct or class instance managing all design data and UI handles.
%           Required fields:
%               - DesignVariables: array of structs with fields:
%                   - dslb: lower bound
%                   - dsub: upper bound
%               - SliderHandles: array of slider handles linked to each variable
%       varIndex   - Index of the design variable to update
%       boundType  - Integer indicating bound type:
%                       1: Lower bound
%                       2: Upper bound
%
%   FUNCTIONALITY:
%       - Reads new bound value from the textbox
%       - Validates input against the corresponding upper/lower bound
%       - Updates the bound using dataManager.updateDesignVarBounds
%       - Resets textbox value if input is invalid
%       - Dynamically updates corresponding slider limits
%
%   OUTPUT:
%       None (modifies dataManager in-place and updates GUI elements)
%
%   NOTE:
%       This function assumes `dataManager.updateDesignVarBounds(...)` is defined
%       and handles internal state synchronization.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    % Read user input from the text box
    newValue = str2double(src.String);

    % Update the value if it's valid
    if boundType == 1 && newValue <= dataManager.DesignVariables(varIndex).dsub
        dataManager.updateDesignVarBounds(varIndex, boundType, newValue);
    elseif boundType == 2 && newValue >= dataManager.DesignVariables(varIndex).dslb
        dataManager.updateDesignVarBounds(varIndex, boundType, newValue);
    else
        % Reset invalid input to current limits
        if boundType == 1
            set(src, 'String', num2str(dataManager.DesignVariables(varIndex).dslb));
        else
            set(src, 'String', num2str(dataManager.DesignVariables(varIndex).dsub));
        end
        return;
    end

    % Update the slider limit display
    set(dataManager.SliderHandles(varIndex), 'Limits', ...
        [dataManager.DesignVariables(varIndex).dslb,...
        dataManager.DesignVariables(varIndex).dsub]);
end