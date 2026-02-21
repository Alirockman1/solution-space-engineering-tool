%EXAMPLE_BOX_CAR_CRASH_2D 2D Car Crash example for box-shaped solution spaces
%   EXAMPLE_BOX_CAR_CRASH_2D allows to test the box SSO algorithm with a 
%   problem with a known analytical solution, namely the simplifed 2D car 
%   crash problem.
%   Both solution and algorithm performance metrics are plotted at the end.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2022-2025.
%   Copyright 2022-2025 Eduardo Rodrigues Della Noce
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

%% cleanup
close all;
fclose all;
clear all;
clc;
more off;
diary off;


%% debugging
rng(5);


%% documentation / archive
rngState = rng;
goldenRatio = (1+sqrt(5))/2;
figureSize = [goldenRatio 1]*8.5;


%% problem setup
dataManager = solution_space_box_xray_excel_file_parser('XRayInputCarCrash2d.xlsx');
dataManager.set('SystemEvaluation',@car_crash_2d);
solution_space_box_xray_create_gui(dataManager);

