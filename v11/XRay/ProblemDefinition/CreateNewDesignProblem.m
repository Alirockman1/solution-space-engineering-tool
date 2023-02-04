%% Script: Create New Design Problem
% Author: del
%
% Use this script to create new files (problem definition and respective
% bottom-up mapping) to use with the X-Ray tool.


%% Cleanup
close all;
fclose all;
clear all;
clc;
more off;
diary off;


%% Start User Interaction
% Problem Name
prompt = 'Please name your problem (no spaces of special characters): ';
problemname = input(prompt,'s');
while(~isvarname(problemname))
    prompt = 'Invalid name. Please name the problem as you would a variable: ';
    problemname = input(prompt,'s');
end

% Excel File
prompt = 'Please input the name of the Excel file with the problem definition: ';
excelfilename = input(prompt,'s');
while(~isfile(excelfilename))
    prompt = 'File not found. Please try again: ';
    excelfilename = input(prompt,'s');
end

% Create full problem name
designproblemsfolderinfo = dir('./../Data/Design_Problems');
itemnumber = size(designproblemsfolderinfo,1)-1; % 1 file per design problem, 
                % two extra entries '.','..', means next entry should be
                % numebered in this way (totalfiles - 2 + 1)

% Check if problem has been defined before
i = find(contains({designproblemsfolderinfo.name},problemname),1,'first');
if(~isempty(i))
    prompt = sprintf(['Problem with same name encountered in design problems folder(%s);',...
                     ' do you wish to overwrite it? (y/n): '],designproblemsfolderinfo(i).name);
    if(lower(input(prompt,'s'))=='y')
        itemnumber = i-2; % do not consider '.' and '..'
    end
end

% Create name for design problem file and bottom-up mapping file
designproblemfile = ['./../Data/Design_Problems/',sprintf('S%04d_x_%s.m',itemnumber,problemname)];
bottomupmappingfile = ['./../../Merging/Systems/',sprintf('S%04d_f_%s.m',itemnumber,problemname)];


%% Create Files
[x,param,qoi,lbl,plotdes,extraopt] = excelParserXRayTool(excelfilename);
createProblemDefinitionFiles(designproblemfile,x,param,qoi,lbl,plotdes,extraopt);
createBottomUpMappingFiles(bottomupmappingfile,x,param,qoi);


%% Instruct User
fprintf(['\nFiles created. The bottom-up mapping file will now be opened. \nOnce you are done with it,',...
        'run ''x_ray_tool.m'' and select the problem to begin analysis.\n\n']);
open(bottomupmappingfile);

