%% Function: Create Bottom-up Mapping Files 
% Author: Del
%
% This function creates a template, self-documented bottom-up mapping for a
% problem to be used in the X-Ray tool.
% 
% Inputs:
%   - filename : name of the file and function of the bottom-up mapping for
%   the problem. Can contain a folder structure of where the file should be
%   - x : structure array with all information about the problem design
%   variables. Necessary information are:
%       -- varname : name of variable (code)
%       -- desc : text description of design variable
%       -- unit : physical unit of the design variable
%       -- dslb : design space lower bound
%       -- dsub : design space upper bound
%   - param : structure array of constant parameters. Necessary information are:
%       -- varname : name of variable (code)
%       -- des : text description of constant parameter
%       -- unit : physical unit of the constant parameter
%       -- value : value of the parameter
%   - qoi : structure array of quantities of interest. Necessary information are:
%       -- varname : name of variable (code)
%       -- des : text description of design variable
%       -- unit : physical unit of the design variable
%       -- crll : critical values lower limit
%       -- crul : critical values upper limit

function createBottomUpMappingFiles(filename,x,param,qoi)
    %% Bottom-up Mapping
    fid = fopen(filename,'w+');
    
    % get problem name
    splitfilename = split(filename,'/');
    problemfilename = splitfilename{end}; % remove folder structure
    splitproblemfilename = split(problemfilename,'.');
    problemname = splitproblemfilename{1}; % remove '.m'
    
    %% Bottom-up Mapping - Pre-amble
    fprintf(fid,'%%%% Function: Bottom-up Mapping of Problem %s\n',problemname);
    fprintf(fid,'%% Template generated automatically\n');
    fprintf(fid,'%% \n');
    
    %% Bottom-up Mapping - Documentation of Inputs
    fprintf(fid,'%% Inputs:\n');
    fprintf(fid,'%%     - x: Design Variables - Array size: [%d,sample size]\n',size(x,2));
    for i=1:size(x,2)
        fprintf(fid,'%%         -- %s: %s [%s] - Bounds: [%g,%g]\n',x(i).varname,x(i).desc,x(i).unit,x(i).dslb,x(i).dsub);
    end
    fprintf(fid,'%%     - param: Constant Parameters - Array size: [1,%d]\n',size(param,2));
    for i=1:size(param,2)
        fprintf(fid,'%%         -- %s: %s [%s] - Value: %g\n',param(i).varname,param(i).desc,param(i).unit,param(i).value);
    end
    fprintf(fid,'%% \n');
    
    %% Bottom-up Mapping - Documentation of Outputs
    fprintf(fid,'%% Outputs:\n');
    fprintf(fid,'%%     - qoi: Quantities of Interest - Array size: [%d,sample size]\n',size(qoi,2));
    for i=1:size(qoi,2)
        fprintf(fid,'%%         -- %s: %s [%s] - Critical values: [%g,%g]\n',qoi(i).varname,...
                                                    qoi(i).desc,qoi(i).unit,qoi(i).crll,qoi(i).crul);
    end
    
    %% Bottom-up Mapping - Function
    fprintf(fid,'\n');
    fprintf(fid,'function qoi = %s(x,param)\n',problemname);
    fprintf(fid,'    %%%% Initialization\n');
    fprintf(fid,'    %% Unwrapping inputs - design variables\n');
    for i=1:size(x,2)
        fprintf(fid,'    %s = x(%d,:)'';\n',x(i).varname,i);
    end
    fprintf(fid,'    %% Unwrapping inputs - constant parameters\n');
    for i=1:size(param,2)
        fprintf(fid,'    %s = param(%d);\n',param(i).varname,i);
    end
    fprintf(fid,'    %% Alocating space for output arrays\n');
    for i=1:size(qoi,2)
        fprintf(fid,'    %s = nan(size(x,2),1);\n',qoi(i).varname);
    end
    fprintf(fid,'    \n');
    fprintf(fid,'    %%%% Bottom-up Mapping\n');
    fprintf(fid,'    \n');
    fprintf(fid,'    %%%% Closing operations\n');
    fprintf(fid,'    %% Wrapping outputs\n');
    fprintf(fid,'    qoi = nan(%d, size(x,2));\n',size(qoi,2));
    for i=1:size(qoi,2)
        fprintf(fid,'    qoi(%d,:) = %s'';\n',i,qoi(i).varname);
    end
    fprintf(fid,'end');
    
    %% Bottom-up Mapping - Finish
    fclose(fid);
end