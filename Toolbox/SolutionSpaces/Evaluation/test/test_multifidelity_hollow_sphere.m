%TEST_MULTIFIDELITY_HOLLOW_SPHERE Surrogate model of the hollow sphere problem
%   TEST_MULTIFIDELITY_HOLLOW_SPHERE creates a surrogate model for the 
%   hollow sphere problem. This is done using an active set strategy.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2023-2025.
%   Copyright 2023-2025 Eduardo Rodrigues Della Noce
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


%% function call
systemFunction = @(x,sysParam) [sqrt((x(:,1)-sysParam(1)).^2 + (x(:,2)-sysParam(2)).^2 + (x(:,3)-sysParam(3)).^2)];
systemParameter = [0,0,0];

%                          x1  x2  x3
designSpaceLowerBoundary = [-6 -6 -6];
designSpaceUpperBoundary = [ 6  6  6];
initialDesign = [3 0 0];

performanceLowerLimit = -inf;
performanceUpperLimit = 5;


%% Active Learning Options
options = active_learning_model_training_point_prediction_options(...
    'MaxIter',2,...
    'NumberSamplesEvaluation',20,...
    'FixIter',true,...
    'LoggingLevel','all',...
    'ActiveLearningSamplingFunction',@active_learning_sampling_random,...
    'ExplorationToBoundaryRatio',0.5,...
    'FastForwardModelInitial',@DesignFastForwardAnn);


%% 
bottomUpMapping = BottomUpMappingFunction(systemFunction,systemParameter);
[designFastForward,problemDataTraining,iterDataTraining] = active_learning_model_training_point_prediction(...
    bottomUpMapping,...
    designSpaceLowerBoundary,...
    designSpaceUpperBoundary,...
    performanceLowerLimit,...
    performanceUpperLimit,...
    options);


%% approximate the threshold value of score where errors start happening
[scoreThreshold,iterDataUncertainty] = design_fast_forward_find_uncertainty_score(bottomUpMapping,designFastForward,...
    'NumberCandidateSamples',2000,'NumberNeighborEvaluations',3);


%% make multi-fidelity evaluator
designEvaluatorHighFidelity = DesignEvaluatorBottomUpMapping(bottomUpMapping,...
    performanceLowerLimit,performanceUpperLimit);

designEvaluatorLowFidelity = DesignEvaluatorFastForward(designFastForward);

designEvaluatorMultiFidelity = DesignEvaluatorMultiFidelity(...
    designEvaluatorLowFidelity,...
    designEvaluatorHighFidelity,...
    @multifidelity_decision_score_threshold,...
    'DecisionOptions',{'PerformanceScoreThreshold',scoreThreshold});


%% solve sphere problem with three evaluators to compare results
options = sso_stochastic_options('box',...
    'FixIterNumberExploration',true,...
    'FixIterNumberConsolidation',true,...
    'UseAdaptiveGrowthRate',true,...
    'GrowthRate',0.1,...
    'MaxIterExploration',30,...
    'MaxIterConsolidation',30);

initialRngState = rng;
[designBoxHighFidelity,optimizationDataHighFidelity] = ...
    sso_box_stochastic(...
        designEvaluatorHighFidelity,...
        initialDesign,...
        designSpaceLowerBoundary,...
        designSpaceUpperBoundary,...
        options);

rng(initialRngState);
[designBoxLowFidelity,optimizationDataLowFidelity] = ...
    sso_box_stochastic(...
        designEvaluatorLowFidelity,...
        initialDesign,...
        designSpaceLowerBoundary,...
        designSpaceUpperBoundary,...
        options);

rng(initialRngState);
[designBoxMultiFidelity,optimizationDataMultiFidelity] = ...
    sso_box_stochastic(...
        designEvaluatorMultiFidelity,...
        initialDesign,...
        designSpaceLowerBoundary,...
        designSpaceUpperBoundary,...
        options);


%% known analytical solution
boxSideAnalytical = performanceUpperLimit*sqrt(4/3);
solutionAnalytical = [-boxSideAnalytical/2 ,  -boxSideAnalytical/2 ,  -boxSideAnalytical/2;...
    boxSideAnalytical/2 , boxSideAnalytical/2 , boxSideAnalytical/2];


%% analyze result in terms of volume and purity
volumeHighFidelity = prod(designBoxHighFidelity(2,:)-designBoxHighFidelity(1,:));
volumeLowFidelity = prod(designBoxLowFidelity(2,:)-designBoxLowFidelity(1,:));
volumeMultiFidelity = prod(designBoxMultiFidelity(2,:)-designBoxMultiFidelity(1,:));
volumeAnalytical = prod(solutionAnalytical(2,:)-solutionAnalytical(1,:));

nSamplePurity = 1e5;

errorHighFidelity = design_deficit_to_label_score(designEvaluatorHighFidelity.evaluate(...
    sampling_latin_hypercube(designBoxHighFidelity,nSamplePurity)));
purityHighFidelity = sum(errorHighFidelity)/size(errorHighFidelity,1);

errorLowFidelity = design_deficit_to_label_score(designEvaluatorHighFidelity.evaluate(...
    sampling_latin_hypercube(designBoxLowFidelity,nSamplePurity)));
purityLowFidelity = sum(errorLowFidelity)/size(errorLowFidelity,1);

errorMultiFidelity = design_deficit_to_label_score(designEvaluatorHighFidelity.evaluate(...
    sampling_latin_hypercube(designBoxMultiFidelity,nSamplePurity)));
purityMultiFidelity = sum(errorMultiFidelity)/size(errorMultiFidelity,1);

errorAnalytical = design_deficit_to_label_score(designEvaluatorHighFidelity.evaluate(...
    sampling_latin_hypercube(solutionAnalytical,nSamplePurity)));
purityAnalytical = sum(errorAnalytical)/size(errorAnalytical,1);


%% check total number of function evaluations
functionEvaluationHighFidelity = size(vertcat(optimizationDataHighFidelity.IterationData(:).EvaluatedDesignSamples),1);

functionEvaluationLowFidelity = size(vertcat(iterDataTraining(:).EvaluatedSamples),1);

functionEvaluationUncertain = size(vertcat(iterDataUncertainty(:).EvaluatedSamples),1);

functionEvaluationMultiFidelity = sum(vertcat(vertcat(optimizationDataMultiFidelity.IterationData(:).EvaluationOutput).IsUncertain));


%% report in text
fprintf(['\n',repelem('=',80),'\n']);
fprintf(['%14s - Volume: %6.2f; Purity: %1.4f; Function Evaluations = %g\n',...
         '%14s - Volume: %6.2f; Purity: %1.4f; Function Evaluations = %g\n',...
         '%14s - Volume: %6.2f; Purity: %1.4f; Function Evaluations = %g + %g + %g = %g\n',...
         '%14s - Volume: %6.2f; Purity: %1.4f;\n'],...
         'High Fidelity',volumeHighFidelity,purityHighFidelity,functionEvaluationHighFidelity,...
         'Low Fidelity',volumeLowFidelity,purityLowFidelity,functionEvaluationLowFidelity,...
         'Multi-Fidelity',volumeMultiFidelity,purityMultiFidelity,...
            functionEvaluationLowFidelity,functionEvaluationUncertain,functionEvaluationMultiFidelity,...
            functionEvaluationLowFidelity + functionEvaluationUncertain + functionEvaluationMultiFidelity,...
         'Analytical',volumeAnalytical,purityAnalytical);


%% see results
% sphere points
[sphereX,sphereY,sphereZ] = sphere;
sphereX = systemParameter(1)*sphereX;
sphereY = systemParameter(1)*sphereY;
sphereZ = systemParameter(1)*sphereZ;

figure;
hold all;
surf(sphereX,sphereY,sphereZ,'FaceAlpha',0.1,'FaceColor','black','EdgeColor','none');
plot_design_box_3d(gca,designBoxHighFidelity,'FaceAlpha',0.1,'FaceColor','blue');
plot_design_box_3d(gca,designBoxLowFidelity,'FaceAlpha',0.1,'FaceColor','yellow');
plot_design_box_3d(gca,designBoxMultiFidelity,'FaceAlpha',0.1,'FaceColor','cyan');
plot_design_box_3d(gca,solutionAnalytical,'FaceAlpha',0.1,'FaceColor','green');
xlabel('x_1');
ylabel('x_2');
zlabel('x_3');
grid minor;
legend({'Sphere','High-Fidelity','Low-Fidelity','Multi-Fidelity','Analytical'});

figure;
hold all;
subplot(2,2,1);
plot_design_box_2d(gca,designBoxHighFidelity(:,[1,2]),'EdgeColor','blue','Linewidth',2.0);
plot_design_box_2d(gca,designBoxLowFidelity(:,[1,2]),'EdgeColor','yellow','Linewidth',2.0);
plot_design_box_2d(gca,designBoxMultiFidelity(:,[1,2]),'EdgeColor','cyan','Linewidth',2.0);
plot_design_box_2d(gca,solutionAnalytical(:,[1,2]),'EdgeColor','green','Linewidth',2.0);
axis([-4 4 -4 4]);
xlabel('x_1');
ylabel('x_2');
grid minor;
subplot(2,2,2);
plot_design_box_2d(gca,designBoxHighFidelity(:,[1,3]),'EdgeColor','blue','Linewidth',2.0);
plot_design_box_2d(gca,designBoxLowFidelity(:,[1,3]),'EdgeColor','yellow','Linewidth',2.0);
plot_design_box_2d(gca,designBoxMultiFidelity(:,[1,3]),'EdgeColor','cyan','Linewidth',2.0);
plot_design_box_2d(gca,solutionAnalytical(:,[1,3]),'EdgeColor','green','Linewidth',2.0);
axis([-4 4 -4 4]);
xlabel('x_1');
ylabel('x_3');
grid minor;
subplot(2,2,4);
plot_design_box_2d(gca,designBoxHighFidelity(:,[2,3]),'EdgeColor','blue','Linewidth',2.0);
plot_design_box_2d(gca,designBoxLowFidelity(:,[2,3]),'EdgeColor','yellow','Linewidth',2.0);
plot_design_box_2d(gca,designBoxMultiFidelity(:,[2,3]),'EdgeColor','cyan','Linewidth',2.0);
plot_design_box_2d(gca,solutionAnalytical(:,[2,3]),'EdgeColor','green','Linewidth',2.0);
axis([-4 4 -4 4]);
xlabel('x_2');
ylabel('x_3');
grid minor;
legend({'High-Fidelity','Low-Fidelity','Multi-Fidelity','Analytical'});


%% Save and Stop Transcripting
save([saveFolder,'Data.mat']);
diary off;

