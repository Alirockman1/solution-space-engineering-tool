%TEST_CANDIDATE_SPACE_GROWTH Test candidate space growth
%   TEST_CANDIDATE_SPACE_GROWTH tests the growth of the candidate space.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2024-2025.
%   Copyright 2024-2025 Eduardo Rodrigues Della Noce
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
RNGstate = rng;
saveFolder = save_diary_files(mfilename);
goldenratio = (1+sqrt(5))/2;
figureSize = [goldenratio 1]*8.5;


%% create separable region
designSpaceLowerBound = [0 0];
designSpaceUpperBound = [1 1];

designSample = designSpaceLowerBound + rand(1000,2).*(designSpaceUpperBound-designSpaceLowerBound);

systemFunction = @(x,sysParam) [sqrt((x(:,1)-sysParam(1)).^2 + (x(:,2)-sysParam(2)).^2)];
systemParameter = [0.5 0.5];
bottomUpMapping = BottomUpMappingFunction(systemFunction,systemParameter);

performanceLowerLimit = 0.2;
performanceUpperLimit = 0.4;
designEvaluator = DesignEvaluatorBottomUpMapping(bottomUpMapping,performanceLowerLimit,performanceUpperLimit);
labelSample = design_deficit_to_label_score(designEvaluator.evaluate(designSample));


%% plot
figure;
plot(designSample(labelSample,1),designSample(labelSample,2),'g.');
hold all;
plot(designSample(~labelSample,1),designSample(~labelSample,2),'r.');
grid minor;


%% train candidate space
candidateSpace = CandidateSpaceConvexHull(designSpaceLowerBound,designSpaceUpperBound);
candidateSpace = candidateSpace.generate_candidate_space(designSample,labelSample);
isShapeDefinition = candidateSpace.IsShapeDefinition;

figure;
candidateSpace.plot_candidate_space(gca,'FaceColor','g','FaceAlpha',0.5,'EdgeColor','k');
hold all
plot(designSample(labelSample,1),designSample(labelSample,2),'g.');
plot(designSample(~labelSample,1),designSample(~labelSample,2),'r.');
plot(designSample(isShapeDefinition,1),designSample(isShapeDefinition,2),'bo');
grid minor;
legend({'Inside Points','Outside Points','Candidate Space Inside Region','Shape Points'});


%% grow candidate space
grownCandidateSpace = candidateSpace.expand_candidate_space(0.1);

figure;
plot(designSample(labelSample,1),designSample(labelSample,2),'g.');
hold all;
plot(designSample(~labelSample,1),designSample(~labelSample,2),'r.');
grownCandidateSpace.plot_candidate_space(gca,'FaceColor','g','FaceAlpha',0.5,'EdgeColor','none');
grid minor;


%% Save and Stop Transcripting
save([saveFolder,'Data.mat']);
diary off;

