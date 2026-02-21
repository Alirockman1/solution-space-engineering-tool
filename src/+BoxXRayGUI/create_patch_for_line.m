function patchHandle = create_patch_for_line(plotAxes, patchCentralPosition, patchOrientation, tag, varIdx, linkedLine, dataManager)
%CREATE_PATCH_FOR_LINE Create draggable patch for boundary line
%   CREATE_PATCH_FOR_LINE creates a transparent patch aligned with a boundary
%   line (vertical or horizontal) to enable easier dragging. The patch spans
%   the full axis extent in one direction and has a small width in the other
%   direction, making it easier to click and drag than the thin line itself.
%
%   PATCHHANDLE = CREATE_PATCH_FOR_LINE(PLOTAXES, PATCHCENTRALPOSITION,
%   PATCHORIENTATION, TAG, VARIDX, LINKEDLINE, DATAMANAGER) creates a patch
%   for dragging a boundary line.
%
%   Inputs:
%       - PLOTAXES : Axes
%           -- axes handle where the patch will be created
%       - PATCHCENTRALPOSITION : (1,1) double
%           -- central position of the patch (x for vertical, y for horizontal)
%       - PATCHORIENTATION : char/string
%           -- 'vertical' or 'horizontal' orientation
%       - TAG : char/string
%           -- identifier for the boundary type ('left', 'right', 'lower',
%           'upper')
%       - VARIDX : (1,1) integer
%           -- index of the design variable this boundary belongs to
%       - LINKEDLINE : Line
%           -- handle to the line object this patch is associated with
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing patch width settings and drag callback
%
%   Outputs:
%       - PATCHHANDLE : Patch
%           -- handle to the created patch (cleared if nargout < 1)
%
%   See also BoxXRayCallback.start_drag_function,
%   solution_space_plot_axis_patch.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2025.
%   Copyright 2025 Eduardo Rodrigues Della Noce (Contributor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
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

    patchAlpha = dataManager.PatchAlpha; % Nearly invisible

    % Calculate relative patch width based on axis limits for consistent sizing
    xLimits = xlim(plotAxes);
    yLimits = ylim(plotAxes);
    xRange  = diff(xLimits);
    yRange  = diff(yLimits);

    % Patch half-width: 1% of axis range
    patchWidthX = dataManager.PatchRelativeWidth * xRange;
    patchWidthY = dataManager.PatchRelativeWidth * yRange;

    switch patchOrientation
        case 'vertical'
            % Define patch rectangle around vertical line
            xPatch = [...
                patchCentralPosition - patchWidthX, patchCentralPosition + patchWidthX, ...
                patchCentralPosition + patchWidthX, patchCentralPosition - patchWidthX];
            yPatch = [yLimits(1), yLimits(1), yLimits(2), yLimits(2)];

        case 'horizontal'
            % Define patch rectangle around horizontal line
            xPatch = [xLimits(1), xLimits(2), xLimits(2), xLimits(1)];
            yPatch = [...
                patchCentralPosition - patchWidthY, patchCentralPosition - patchWidthY, ...
                patchCentralPosition + patchWidthY, patchCentralPosition + patchWidthY];
    end

    % Create patch and store metadata including linked line handle in UserData
    patchHandle = patch(plotAxes, xPatch, yPatch, dataManager.DraggableLinesColor, ...
        'FaceAlpha', patchAlpha, ...
        'EdgeColor', 'none', ...
        'HitTest', 'on', ...
        'PickableParts', 'all', ...
        'UserData', struct( ...
            'type', tag, ...
            'index', varIdx, ...
            'line', linkedLine), ...
        'ButtonDownFcn', @(src, event) BoxXRayCallback.start_drag_function(src, event, dataManager),...
        dataManager.PatchOptions{:});

    % Disable the patch from appearing in the legend
    set(get(get(patchHandle, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');

    if(nargout<1)
        clear patchHandle;
    end
end