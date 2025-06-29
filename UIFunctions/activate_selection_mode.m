function activate_selection_mode(dataManager)
% ACTIVATE_SELECTION_MODE Enables selection mode in the GUI.
%
%   ACTIVATE_SELECTION_MODE(DATAMANAGER) sets the SelectionModeActive flag to true,
%   indicating that the application is now in selection mode, typically triggered
%   by a button click in the user interface.
%
%   INPUT:
%       dataManager - Struct or class instance managing application state
%
%   OUTPUT:
%       None (modifies dataManager.SelectionModeActive in-place)
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    dataManager.SelectionModeActive = true;

end