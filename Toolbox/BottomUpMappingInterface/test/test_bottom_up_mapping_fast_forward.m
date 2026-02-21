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
goldenRatio = (1+sqrt(5))/2;
figureSize = [goldenRatio 1]*8.5;


%% data
designSample = sampling_latin_hypercube([10,20,30;20,30,40],100);

analyticalLinearCoefficients = [1 4; 2 5; 3 6];
analyticalLinearIntercept = [100,200];

measureSample = designSample*analyticalLinearCoefficients + analyticalLinearIntercept + [10,20].*(rand(100,2)-0.5); % introduce some noise


%% model
linearModel = DesignFastForwardLinear('UseStrictlyLinear',false);

linearModel = linearModel.train_model(designSample,measureSample);


%% bottom up mapping
bottomUpMapping = BottomUpMappingFastForward(linearModel);

isequal(bottomUpMapping.response(designSample),linearModel.predict_design_measure(designSample))