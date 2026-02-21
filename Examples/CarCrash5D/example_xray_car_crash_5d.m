%EXAMPLE_XRAY_CAR_CRASH_5D Interactive solution space exploration for 5D car crash
%   EXAMPLE_XRAY_CAR_CRASH_5D demonstrates the use of the BoxXRay interactive
%   GUI tool for exploring solution spaces of a 5-dimensional car crash
%   problem. The script loads problem configuration from an Excel file and
%   launches an interactive interface where users can adjust design variable
%   bounds and performance requirements to visualize the solution space in
%   real-time through 2D projections.

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
dataManager = solution_space_box_xray_excel_file_parser('XRayInputCarCrash5d.xlsx');
dataManager.set('SystemEvaluation',@car_crash_5d);
solution_space_box_xray_create_gui(dataManager);
