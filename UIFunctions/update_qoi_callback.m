function update_qoi_callback(dataManager, nQuantatiesOfInterests)
% UPDATE_QOI_CALLBACK Updates Quantity of Interest (QoI) bounds from UI inputs.
%
%   UPDATE_QOI_CALLBACK(DATAMANAGER, NQOI) reads new lower and upper limit values
%   from the corresponding text boxes for each QoI and updates the bounds in the
%   dataManager. For QoIs marked as 'active', it applies user-defined limits;
%   for inactive QoIs, it sets bounds to unbounded (-inf, inf).
%
%   INPUT:
%       dataManager - Struct or class instance managing QoIs and UI handles
%       nQOI        - Number of QoIs to update
%
%   FUNCTIONALITY:
%       - Iterates over all QoIs (1 to nQOI)
%       - For each active QoI:
%           * Reads lower and upper bound values from text boxes
%           * Calls dataManager.updateQOIBounds to update bounds
%       - For inactive QoIs:
%           * Sets bounds to unbounded values (-inf, inf)
%
%   OUTPUT:
%       None (modifies dataManager in-place)
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    for QuantatiesOfInterestIdx = 1:nQuantatiesOfInterests
        if strcmp(dataManager.QuantatiesOfInterests(QuantatiesOfInterestIdx).status, 'active')
            % Get new QOI limits from text fields
            lowerVal = str2double(get(dataManager.QOITextHandles(QuantatiesOfInterestIdx, 1), 'String'));
            upperVal = str2double(get(dataManager.QOITextHandles(QuantatiesOfInterestIdx, 2), 'String'));
            
            dataManager.updateQOIBounds(QuantatiesOfInterestIdx, 1, lowerVal);            % Lower bound
            dataManager.updateQOIBounds(QuantatiesOfInterestIdx, 2, upperVal);            % Upper bound
        else
            % Inactive: set bounds to unbounded values
            dataManager.updateQOIBounds(QuantatiesOfInterestIdx, 1, -inf);
            dataManager.updateQOIBounds(QuantatiesOfInterestIdx, 2, inf);
        end
    end
end