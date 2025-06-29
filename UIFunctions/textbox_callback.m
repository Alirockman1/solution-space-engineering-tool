function textbox_callback(dataManager, varIndex, boundType)
% TEXTBOX_CALLBACK Updates slider and design bounds based on text input.
%
%   TEXTBOX_CALLBACK(DATAMANAGER, VARINDEX, BOUNDTYPE) is a GUI callback 
%   that handles user input for design variable bounds entered via textboxes.
%   It validates the input and updates the corresponding slider and internal
%   data structures accordingly. It also triggers visual updates to reflect 
%   any changes.
%
%   INPUT:
%       dataManager - Struct or class instance containing:
%           - DesignVariables: array of structs with design variable info:
%               - dslb: design space lower bound
%               - dsub: design space upper bound
%               - sblb: slider bound lower value
%               - sbub: slider bound upper value
%           - SliderHandles: array of slider UI handles
%           - TextHandles.DesignBox: text input handles for bounds
%           - TextHandles.DesignLimits: text display for valid bounds
%       varIndex    - Index of the design variable to be updated
%       boundType   - Integer indicating the bound type:
%                       1: Lower bound
%                       2: Upper bound
%
%   FUNCTIONALITY:
%       - Reads user input from associated textbox
%       - Validates input against current design variable bounds
%       - Updates internal bounds via dataManager.updateDesignBounds
%       - Sets corresponding slider values based on new bounds
%       - Reverts textbox and slider if input is invalid
%       - Calls updateDesignVariableLines to refresh the visual plots
%
%   OUTPUT:
%       None (operates via GUI handles and modifies dataManager in-place)
%
%   DEPENDENCIES:
%       - dataManager.updateDesignBounds
%       - updateDesignVariableLines
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    newValue = str2double(get(dataManager.TextHandles.DesignBox(varIndex, boundType), 'String'));

    % Validate and update the value
    if boundType == 1 && newValue >= dataManager.DesignVariables(varIndex).dslb % Lower bound
        dataManager.updateDesignBounds(varIndex, boundType, newValue);
        set(dataManager.SliderHandles(varIndex), 'Value', ...
            [dataManager.DesignVariables(varIndex).sblb, dataManager.DesignVariables(varIndex).sbub]);

    elseif boundType == 2 && newValue <= dataManager.DesignVariables(varIndex).dsub % Upper bound
        dataManager.updateDesignBounds(varIndex, boundType, newValue);
        set(dataManager.SliderHandles(varIndex), 'Value', ...
            [dataManager.DesignVariables(varIndex).sblb, dataManager.DesignVariables(varIndex).sbub]);

    else
        % Reset to previously defined limit if invalid
        if boundType == 1
            set(dataManager.TextHandles.DesignLimits(varIndex, 1), 'String',...
                num2str(dataManager.DesignVariables(varIndex).dslb));
            set(dataManager.SliderHandles(varIndex), 'Value',...
                [dataManager.DesignVariables(varIndex).dslb,...
                dataManager.DesignVariables(varIndex).sbub]);
        elseif boundType == 2
            set(dataManager.TextHandles.DesignLimits(varIndex, 2), 'String',...
                num2str(dataManager.DesignVariables(varIndex).dsub));
            set(dataManager.SliderHandles(varIndex), 'Value',...
                [dataManager.DesignVariables(varIndex).sblb,...
                dataManager.DesignVariables(varIndex).dsub]);
        end
    end

    % Update plot visuals after bounds change
    update_design_variable_lines(varIndex, dataManager);
end