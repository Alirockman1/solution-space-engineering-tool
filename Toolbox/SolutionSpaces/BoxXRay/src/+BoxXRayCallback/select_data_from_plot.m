function select_data_from_plot(src, event, dataManager)
%SELECT_DATA_FROM_PLOT Select design sample from plot by clicking
%   SELECT_DATA_FROM_PLOT is a callback function that handles user clicks on
%   plot points or axes. When the "Values from Plot" tab is active, it finds
%   the closest design sample to the click location and updates the UI text
%   fields with the selected design variable values and quantities of interest.
%
%   SELECT_DATA_FROM_PLOT(SRC, EVENT, DATAMANAGER) is called when the user
%   clicks on a plot point or axis. It calculates the Euclidean distance to
%   all samples in the 2D projection and selects the closest one.
%
%   Inputs:
%       - SRC : graphics object
%           -- the object that was clicked (line, patch, or axes)
%       - EVENT : event data
%           -- event data containing IntersectionPoint with click coordinates
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager containing plot data, axes handles, and textbox
%           handles for displaying selected values
%
%   Outputs:
%       None (UI text fields are updated with selected values)
%
%   See also BoxXRayGUI.create_tab_values_from_plot.

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

    % Make sure button for point selection was activated
    if(isempty(dataManager.TabGroupHandle) || ~(strcmpi(dataManager.TabGroupHandle.SelectedTab.Title, 'Values from Plot')))
        return; % Ignore click if not in selection mode
    end

    % Get Axes
    axes = ancestor(src, 'axes');

    % Find index 'i' of the clicked axes in the list
    idx = find(dataManager.PlotAxesHandles == axes, 1);
    plotdata = dataManager.PlotData(idx);

    % Get click coordinates
    clickPoint = event.IntersectionPoint;
    xClick = clickPoint(1);
    yClick = clickPoint(2);

    % Extract the design samples for the current plot
    designSamples = plotdata.DesignSample;
    designSamplesOtherVariables = plotdata.DesignSampleOtherVariables;
    designSamplePairIndex = plotdata.DesignVariablePairIndex;
    if(~isempty(plotdata.PerformanceMeasure))
        quantitiesOfInterest = plotdata.PerformanceMeasure;
    elseif(~isempty(plotdata.PerformanceDeficit))
        quantitiesOfInterest = plotdata.PerformanceDeficit;
    else
        error('No performance measure/deficit found in plot data.');
    end

    % Calculate Euclidean distances in that 2D projection
    distances = sqrt(sum((designSamples - [xClick, yClick]).^2, 2));

    % Find the index of the closest point
    [~, closestIndex] = min(distances);
    closestPointCurrentVariables = designSamples(closestIndex, :);
    closestQuantitiesOfInterests = quantitiesOfInterest(closestIndex,:);
    closestPointOtherVariables = designSamplesOtherVariables(closestIndex, :);

    nVariable = size(designSamples, 2) + size(designSamplesOtherVariables, 2);
    closestPoint = nan(1,nVariable);
    closestPoint(designSamplePairIndex) = closestPointCurrentVariables;
    closestPoint(setdiff(1:nVariable, designSamplePairIndex)) = closestPointOtherVariables;

    % Update the text areas with the selected values
    for i = 1:nVariable
        set(dataManager.TextboxSelectDataHandles(i), 'Value', num2str(closestPoint(i), '%.4f'));
    end

    nQuantitiesOfInterest = length(closestQuantitiesOfInterests);
    for j = 1:nQuantitiesOfInterest
        set(dataManager.TextboxSelectDataHandles(nVariable+j), 'Value', num2str(closestQuantitiesOfInterests(j), '%.4f'));
    end
end