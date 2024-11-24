%% Function: Create Problem Definition Files 
% Author: Del
%
% This function creates a template, self-documented problem definition 
% to be used in the X-Ray tool.
% 
% Inputs:
%   - filename : name of the file and class of the problem definition. Can 
%   contain a folder structure of where the file should be
%   - x : structure array with all information about the problem design
%   variables. Necessary information are:
%       -- dispname : name to be displayed in plots and figures
%       -- unit : physical unit of the design variable
%       -- dslb : design space lower bound
%       -- dsub : design space upper bound
%       -- sblb : solution box lower bound
%       -- sbub : solution box upper bound
%   - param : structure array of constant parameters. Necessary information are:
%       -- dispname : name to be displayed in plots and figures
%       -- unit : physical unit of the constant parameter
%       -- value : value of the parameter
%   - qoi : structure array of quantities of interest. Necessary information are:
%       -- dispname : name to be displayed in plots and figures
%       -- unit : physical unit of the design variable
%       -- color : [R,G,B] array with color of sample points where condition
%       is violated
%       -- crll : critical values lower limit
%       -- crul : critical values upper limit
%       -- viol : text to be displayed when condition is violated
%   - lbl : [currently unused]
%   - extraopt : extra options structure. Necessary information are:
%       -- SolSpLineWidth : line width of the solution box ('linewidth' option of 'plot' function)
%       -- SolSpLineType : line type of the solution box (options of 'plot' function)
%       -- SampleSize : number of samples to be used
%       -- SampleMarkerSize : size of sample markers ('linewidth' option of 'plot' function)
%       -- SampleMarkerType : type of sample markers (options of 'plot' function)

function createProblemDefinitionFiles(filename,x,param,qoi,lbl,plotdes,extraopt)
    %% Problem Definition (Class File)
    % create / open file
    fid = fopen(filename,'w+');
    
    % get problem name
    splitfilename = split(filename,'/');
    problemfilename = splitfilename{end}; % remove folder structure
    splitproblemfilename = split(problemfilename,'.');
    problemname = splitproblemfilename{1}; % remove '.m'
    
    %% Problem Definition - Pre-amble
    fprintf(fid,'%%%% %s.m\n',problemname);
    fprintf(fid,'%% Template generated automatically\n');
    fprintf(fid,'%% \n');
    
    %% Problem Definition - Class Definition - Properties
    fprintf(fid,'classdef %s < handle\n',problemname);
    fprintf(fid,'    properties\n');
    fprintf(fid,'		%%--------------------------------------------------\n');
    fprintf(fid,'		%% Definitions of variables\n');
    fprintf(fid,'		%%--------------------------------------------------\n');
    fprintf(fid,'		x=struct; %% Design variables\n');
    fprintf(fid,'		y=struct; %% Quantities of interest\n');
    fprintf(fid,'		p=struct;\n');
    fprintf(fid,'		index=struct;\n');
    fprintf(fid,'		samples=struct;\n');
    fprintf(fid,'\n');
    fprintf(fid,'		%%--------------------------------------------------\n');
    fprintf(fid,'		%% Input variables\n');
    fprintf(fid,'		%%--------------------------------------------------\n');
    fprintf(fid,'		%% Number of samples\n');
    fprintf(fid,'		sampleSize;\n');
    fprintf(fid,'		%% Diagram list\n');
    fprintf(fid,'		diagram;\n');
    fprintf(fid,'\n');
    fprintf(fid,'		m; %% Number of quantities of interest\n');
    fprintf(fid,'		d; %% Number of design variables\n');
    fprintf(fid,'		np; %% Number of parameters\n');
    fprintf(fid,'		k; %% necessary for plot_m_x\n');
    fprintf(fid,'		b; %% necessary for writeInputOutput\n');
    fprintf(fid,'\n');
    fprintf(fid,'		%% Color of good designs\n');
    fprintf(fid,'		good_design_color=''green'';\n');
    fprintf(fid,'\n');
    fprintf(fid,'		%% Line definiton for solution spaces\n');
    fprintf(fid,'		solutionspace_line_color=''black'';\n');
    fprintf(fid,'		solutionspace_line_width=%s;\n',extraopt.SolSpLineWidth);
    fprintf(fid,'		solutionspace_line_type=''%s'';\n',extraopt.SolSpLineType);
    fprintf(fid,'\n');
    fprintf(fid,'		%% Legend text\n');
    fprintf(fid,'		legend;\n');
    fprintf(fid,'\n');
    fprintf(fid,'		%% Filename of saved file\n');
    fprintf(fid,'		save_as = ''%s.mat'';\n',problemname);
    fprintf(fid,'	end\n');
    
    %% Problem Definition - Class Definition - Methods - Desired Scatter Plots
    fprintf(fid,'\n');
    fprintf(fid,'    methods\n');
    fprintf(fid,'		function obj = %s()\n',problemname);
    fprintf(fid,'			addpath(''Data\\Save'');\n');
    fprintf(fid,'			try\n');
    fprintf(fid,'				load(obj.save_as);\n');
    fprintf(fid,'				obj = OBJ;\n');
    fprintf(fid,'			catch\n');
    fprintf(fid,'               obj.sampleSize=%s;\n',extraopt.SampleSize);
    fprintf(fid,'               %% Choosing variables to be shown in the diagramms\n');
    fprintf(fid,'               obj.diagram=[...\n');
    DVindexMapper = mapDVname2index(x); % create a map of design variable names and their indexes
    for i=1:size(plotdes,2)
        fprintf(fid,'                   %d,%d;... %% %s,%s\n',DVindexMapper(plotdes(i).axdes{1}),...
                                                              DVindexMapper(plotdes(i).axdes{2}),...
                                                              plotdes(i).axdes{1},plotdes(i).axdes{2});
    end
    fprintf(fid,'                   ];\n');
    fprintf(fid,'\n');
    
    %% Problem Definition - Class Definition - Methods - Design Variables
    fprintf(fid,'               %% Design variables\n');
    fprintf(fid,'               design_variables = {...\n');
    for i=1:size(x,2)
        fprintf(fid,'                   ''%s'',''%s'',%g,%g,%g,%g;...\n',x(i).dispname,x(i).unit,...
                                                        x(i).dslb,x(i).dsub,x(i).sblb,x(i).sbub);
    end
    fprintf(fid,'                   };\n');
    fprintf(fid,'               %% Cell to structure\n');
    fprintf(fid,'               for i=1:size(design_variables,1)\n');
    fprintf(fid,'                   obj.x(i).name = design_variables{i,1};\n');
    fprintf(fid,'                   obj.x(i).unit = design_variables{i,2};\n');
    fprintf(fid,'                   obj.x(i).dsl = design_variables{i,3};\n');
    fprintf(fid,'                   obj.x(i).dsu = design_variables{i,4};\n');
    fprintf(fid,'                   obj.x(i).l = design_variables{i,5};\n');
    fprintf(fid,'                   obj.x(i).u = design_variables{i,6};\n');
    fprintf(fid,'               end\n');
    fprintf(fid,'\n');
    
    %% Problem Definition - Class Definition - Methods - Quantities of Interest
    fprintf(fid,'               %% Quantities of interest\n');
    fprintf(fid,'               quantities_of_interest = {...\n');
    for i=1:size(qoi,2)
        fprintf(fid,'                   ''%s'',''%s'',[%g,%g,%g],%g,%g,%d,''%s'';...\n',qoi(i).dispname,qoi(i).unit,...
                                                        qoi(i).color(1),qoi(i).color(2),qoi(i).color(3),...
                                                        qoi(i).crll,qoi(i).crul,1,qoi(i).viol);
    end
    fprintf(fid,'                   };\n');
    fprintf(fid,'               %% Cell to structure\n');
    fprintf(fid,'               for i=1:size(quantities_of_interest,1)\n');
    fprintf(fid,'                   obj.y(i).name = quantities_of_interest{i,1};\n');
    fprintf(fid,'                   obj.y(i).unit = quantities_of_interest{i,2};\n');
    fprintf(fid,'                   obj.y(i).color = quantities_of_interest{i,3};\n');
    fprintf(fid,'                   obj.y(i).l = quantities_of_interest{i,4};\n');
    fprintf(fid,'                   obj.y(i).u = quantities_of_interest{i,5};\n');
    fprintf(fid,'                   obj.y(i).active = quantities_of_interest{i,6};\n');
    fprintf(fid,'                   obj.y(i).condition = quantities_of_interest{i,7};\n');
    fprintf(fid,'               end\n');
    fprintf(fid,'\n');
    
    %% Problem Definition - Class Definition - Methods - Constant Parameters
    fprintf(fid,'               %% Parameters\n');
    fprintf(fid,'               parameters = {...\n');
    for i=1:size(param,2)
        fprintf(fid,'                   ''%s'',''%s'',%g;...\n',param(i).dispname,param(i).unit,param(i).value);
    end
    fprintf(fid,'                   };\n');
    fprintf(fid,'               %% Cell to structure\n');
    fprintf(fid,'               for i=1:size(parameters,1)\n');
    fprintf(fid,'                   obj.p(i).name = parameters{i,1};\n');
    fprintf(fid,'                   obj.p(i).unit = parameters{i,2};\n');
    fprintf(fid,'                   obj.p(i).value = parameters{i,3};\n');
    fprintf(fid,'               end\n');
    fprintf(fid,'\n');
    
    %% Problem Definition - Class Definition - Methods - Plot Options
    fprintf(fid,'               %% Marker size of samples\n');
    fprintf(fid,'               obj.samples.marker.size = %s;\n',extraopt.SampleMarkerSize);
    fprintf(fid,'               obj.samples.marker.type = ''%s'';\n',extraopt.SampleMarkerType);
    fprintf(fid,'               obj.m=length(obj.y);\n');
    fprintf(fid,'               obj.d=length(obj.x);\n');
    fprintf(fid,'               if max(size(obj.p))>1\n');
    fprintf(fid,'                   obj.np=length(obj.p);\n');
    fprintf(fid,'               else\n');
    fprintf(fid,'                   obj.np = 0;\n');
    fprintf(fid,'               end\n');
    fprintf(fid,'               obj.legend = CreateLegend(obj,obj.y); %%Legende erstellen vereinfacht durch Steger\n');
    fprintf(fid,'               obj.k = 0;\n');
    fprintf(fid,'               obj.b = 0;\n');
    fprintf(fid,'           end\n');
    fprintf(fid,'       end\n');
    fprintf(fid,'\n');
    
    %% Problem Definition - Class Definition - Methods - Bottom-Up Mapping
    fprintf(fid,'       %% Calculates system response\n');
    fprintf(fid,'		function [y] = SystemResponse(obj, x, param)\n');
    fprintf(fid,'			%% Paths\n');
    fprintf(fid,'			Folder_Actual = pwd;\n');
    fprintf(fid,'			cd ..\n');
    fprintf(fid,'			addpath(''Database'');\n');
    fprintf(fid,'			addpath(''Merging\\Systems'');\n');
    fprintf(fid,'			cd(Folder_Actual)\n');
    fprintf(fid,'\n');
    fprintf(fid,'			%% Function :\n');
    fprintf(fid,'			y = %s(x,param);\n',[problemname(1:6),'f',problemname(8:end)]); % name of bottom up mapping: same name as problem, but with 'f' indicator instead of 'x'
    fprintf(fid,'			writeInputOutput(obj); %%Create Excel file with in- and output\n');
    fprintf(fid,'		end\n');
    fprintf(fid,'\n');
    fprintf(fid,'		function legend = CreateLegend(obj,y)\n');
    fprintf(fid,'			legend = {''{\\color{green} \\bullet }Good design''};\n');
    fprintf(fid,'			for i=1:obj.m\n');
    fprintf(fid,'				if obj.y(i).active == 1\n');
    fprintf(fid,'					legend{end+1}=strcat(''{\\color[rgb]{'',num2str(y(i).color),'']} \\bullet }'', y(i).condition);\n');
    fprintf(fid,'				end\n');
    fprintf(fid,'			end\n');
    fprintf(fid,'		end\n');
    fprintf(fid,'	end\n');
    fprintf(fid,'end\n');
    
    %% Problem Definition - Finish
    fclose(fid);
end

%% Function: Map Design Variable Names to Their Indexes
function DVindexMapper = mapDVname2index(x)
    DVindexMapper = containers.Map;
    for i=1:size(x,2)
        DVindexMapper(x(i).varname) = i;
    end
end