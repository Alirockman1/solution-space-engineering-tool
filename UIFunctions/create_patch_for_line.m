function patchHandle = create_patch_for_line(plotAxes, pos1, pos2, orientation, tag, varIdx, dataManager, linkedLine)
% CREATE_PATCH_FOR_LINE Creates a transparent draggable patch aligned with a boundary line.
%   Generates a patch centered on a line (vertical/horizontal) to enable dragging.
%   Stores linked line handle in UserData for synchronized updates during drag.
%
% INPUTS:
%   plotAxes   - Axes handle to draw patch on
%   pos1       - For vertical: x coordinate; for horizontal: [xMin, xMax]
%   pos2       - For vertical: [yMin, yMax]; for horizontal: y coordinate
%   orientation- 'vertical' or 'horizontal'
%   tag        - Identifier string ('left', 'right', 'lower', 'upper')
%   varIdx     - Index of the related design variable
%   dataManager- Struct or object with app state (passed to drag callback)
%   linkedLine - Handle to the line this patch is associated with
%
% OUTPUT:
%   patchHandle - Handle to the created patch object
%
%   NOTE:
%       - Assumes dataManager contains properly initialized handles and data fields.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Author)
%   SPDX-License-Identifier: Apache-2.0

    patchAlpha = 0.01; % Nearly invisible

    % Calculate relative patch width based on axis limits for consistent sizing
    xLimits = xlim(plotAxes);
    yLimits = ylim(plotAxes);
    xRange  = diff(xLimits);
    yRange  = diff(yLimits);

    % Patch half-width: 1% of axis range
    patchWidthX = 0.05 * xRange;
    patchWidthY = 0.05 * yRange;

    switch orientation
        case 'vertical'
            xCenter = pos1;
            yLims = pos2;

            % Define patch rectangle around vertical line
            xPatch = [xCenter - patchWidthX, xCenter + patchWidthX, ...
                      xCenter + patchWidthX, xCenter - patchWidthX];
            yPatch = [yLims(1), yLims(1), yLims(2), yLims(2)];

        case 'horizontal'
            xLims = pos1;
            yCenter = pos2;

            % Define patch rectangle around horizontal line
            xPatch = [xLims(1), xLims(2), xLims(2), xLims(1)];
            yPatch = [yCenter - patchWidthY, yCenter - patchWidthY, ...
                      yCenter + patchWidthY, yCenter + patchWidthY];
    end

    % Create patch and store metadata including linked line handle in UserData
    patchHandle = patch(plotAxes, xPatch, yPatch, 'b', ...
        'FaceAlpha', patchAlpha, ...
        'EdgeColor', 'none', ...
        'HitTest', 'on', ...
        'PickableParts', 'all', ...
        'UserData', struct( ...
            'type', tag, ...
            'index', varIdx, ...
            'line', linkedLine), ...
        'ButtonDownFcn', @(src, event) start_drag_function(src, event, dataManager));

    % Disable the patch from appearing in the legend
    set(get(get(patchHandle, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');

end