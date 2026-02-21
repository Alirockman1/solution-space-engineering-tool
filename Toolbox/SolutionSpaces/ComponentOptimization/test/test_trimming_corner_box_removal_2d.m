%

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2025.
%   Copyright 2025 Eduardo Rodrigues Della Noce
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


%% Cleanup
fclose all;
close all;
clear all;
clc;
more off;
diary off;


%% debugging
rng(4);


%% Documentation / Archive
rngState = rng;
saveFolder = save_diary_files(mfilename);
goldenRatio = (1+sqrt(5))/2;
figureSize = [goldenRatio 1]*8.5;


%% CHOSEN SAMPLES
designSpaceLowerBound = [0 0];
designSpaceUpperBound = [1 1];
designSample = [0.31,0.61;0.47,0.35;0.18,0.75;0.66,0.33;0.62,0.64];
designPadding = sampling_latin_hypercube([designSpaceLowerBound;designSpaceUpperBound],100);

designSampleComponent = [designSample;designPadding];
iRemove = 1;
options = {'NormalizeVariables',false,'TrimmingSlack',1.0,'ConsiderOnlyKeepInSlack',true};

isKeep = [true(size(designSample,1),1);false(size(designPadding,1),1)];
isKeep(iRemove) = false;
[removalCandidate,removalInformation] = component_trimming_method_corner_box_removal(designSampleComponent,iRemove,isKeep,options{:});

for i=1:size(removalCandidate,2)
    figure;
    hold on;
    plot(designSampleComponent(removalCandidate(:,i),1),designSampleComponent(removalCandidate(:,i),2),'x','color','r','MarkerSize',10);
    plot(designSampleComponent(~removalCandidate(:,i),1),designSampleComponent(~removalCandidate(:,i),2),'.','color','b','MarkerSize',10);
    plot(designSampleComponent(isKeep,1),designSampleComponent(isKeep,2),'*','color','g','MarkerSize',10);
    plot(designSampleComponent(iRemove,1),designSampleComponent(iRemove,2),'o','color','m','MarkerSize',10);
    plot(removalInformation(i).Anchor(1),removalInformation(i).Anchor(2),'+','color','k','MarkerSize',10);
    axis equal;
    axis([designSpaceLowerBound(1) designSpaceUpperBound(1) designSpaceLowerBound(2) designSpaceUpperBound(2)]);
    title(sprintf('Combination %d - Direction = [%d %d]',i,removalInformation(i).CornerDirection(1),removalInformation(i).CornerDirection(2)));
    legend({'Removed','Kept','Should be Kept','Removed Design','Anchor Created'},'location','bestoutside');
end






