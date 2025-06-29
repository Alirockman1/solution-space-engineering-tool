%setup_xray_toolbox
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Author)
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
close all;
fclose all;
clear all;
clc;
more off;
diary off;


%% get folder of setup
setupFilePath = mfilename('fullpath');
if contains(setupFilePath,'LiveEditorEvaluationHelper')
    setupFilePath = matlab.desktop.editor.getActiveFilename;
end
toolboxFolderPath = replace(erase(setupFilePath,mfilename),'\','/');
addpath(toolboxFolderPath);
clear setupFilePath


%% Add Folders (and potentially Subfolders) to Path
% 'foldername',includeSubfolder
addDirectory = {...
    ... % public folders
    'GUI/',true;...
    'ProblemDefinition/',true;...
    'TestScripts/',true;...
    'InputReadingfunctions/',true;...
    'UIFunctions/',true;...
    'SavedFiles/',true;...
    'Systems/',true};

for i=1:size(addDirectory,1)
    currentPath = [toolboxFolderPath,addDirectory{i,1}];

    if(addDirectory{i,2})
        totalCurrentPath = genpath(currentPath);                           % also add subfolders
    else
        totalCurrentPath = currentPath;                                    % add only main folder
    end

    if(exist(currentPath, 'dir'))
       addpath(totalCurrentPath);
    end
end
clear addDirectory i currentPath totalCurrentPath


%% clear remaining variables
clear toolboxFolderPath  


%% Add SSO-Toolbox
run('./sso-toolbox/setup_sso_toolbox.m');

%% Compatability check %%

% Check correct version of MATLAB
% Retrieve version
v = version;
pos = strfind(v,'R');
v = v(pos:pos+5);

jear = str2double(v(2:5));
releas = v(end);

if ~(jear >= 2019 || (jear == 2018 && releas == 'b'))
    error('Your current MATLAB version is not capable of running this version of the programm.\n%s',...
        'Please use MATLAB R2018b or newer versions of MATLAB or consider using an older version of the SSE-program.')
end

% Check if Image Processing Toolbox is installed
v = ver;
for i=1:length(v)
    if strcmp(v(i).Name,'Image Processing Toolbox')
        installed = 1;
        break
    else
        installed = 0;
    end
end

if ~installed
    
    error('Image Processing Toolbox is not installed.\n%s',...
        'Please install the required toolbox or consider using an older version of the SSE-program.')
end


% Check if Image Processing Toolbox is installed
v = ver;
for i=1:length(v)
    if strcmp(v(i).Name,'Image Processing Toolbox')
        installed = 1;
        break
    else
        installed = 0;
    end
end

if ~installed
    
    error('Image Processing Toolbox is not installed.\n%s',...
        'Please install the required toolbox or consider using an older version of the SSE-program.')
end