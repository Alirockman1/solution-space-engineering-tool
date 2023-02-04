%% Function: Excel Parser - X-Ray Tool
%
% Input:
%   - filename : filename of the Excel file (can include path structure)
%
% Output:
%   - x : structure of design variables
%   - param : structure of constant parameters
%   - qoi : structure of quantities of interest
%   - lbl : structure of labels

function [x,param,qoi,lbl,plotdes,extraopt] = excelParserXRayTool(filename)
    %% Read Excel Spreadsheets Information
    warning('OFF','MATLAB:table:ModifiedAndSavedVarnames'); % yes, I know, sheet names will be changed when converted to variables...
    % Design Variables
    opts = detectImportOptions(filename,'Sheet','Design Variables');
    opts = setvartype(opts, 'char');
    Tx = readtable(filename,opts);
    % Constant Parameters
    opts = detectImportOptions(filename,'Sheet','Constant Parameters');
    opts = setvartype(opts, 'char');
    Tparam = readtable(filename,opts);
    % Quantities of Interest
    opts = detectImportOptions(filename,'Sheet','Quantities of Interest');
    opts = setvartype(opts, 'char');
    Tqoi = readtable(filename,opts);
    % Labels
    opts = detectImportOptions(filename,'Sheet','Labels');
    opts = setvartype(opts, 'char');
    Tlbl = readtable(filename,opts);
    % Desired Plots
    opts = detectImportOptions(filename,'Sheet','Desired Plots');
    opts = setvartype(opts, 'char');
    Tplot = readtable(filename,opts);
    % Extra Options
    opts = detectImportOptions(filename,'Sheet','Other Options');
    opts = setvartype(opts, 'char');
    Topt = readtable(filename,opts);
    warning('ON','MATLAB:table:ModifiedAndSavedVarnames'); % ok, reset it now
    
    %% Read Color Information - Quantities of Interest
    excel = actxserver('Excel.Application'); % start excel
    excel.Visible = false; % optional, make sure excel doesn't open
    workbook = excel.Workbooks.Open([pwd,'\',filename]); % open excel file using full path
    worksheet = workbook.Worksheets.Item('Quantities of Interest'); % get worksheet reference
    for i=1:size(Tqoi,1)
        Tqoi.ColorOfPointsWhereViolated{i} = worksheet.Cells.Item(8).Item(i+1).Interior.Color; % 8=column 'H'; i+1=skip first row
    end
    workbook.Close;
    excel.Quit;

    %% Parse: Design Variables
    x = struct([]);
    for i=1:size(Tx,1)
        x(i).varname = Tx.VariableName{i};
        x(i).dispname = Tx.DisplayName{i};
        x(i).desc = Tx.Description{i};
        x(i).unit = Tx.Unit{i};
        x(i).dslb = readNumericEntries(Tx.DesignSpaceLowerBound{i});
        x(i).dsub = readNumericEntries(Tx.DesignSpaceUpperBound{i});
        x(i).sblb = readNumericEntries(Tx.SolutionBoxLowerBound{i});
        x(i).sbub = readNumericEntries(Tx.SolutionBoxUpperBound{i});
    end
    
    %% Parse: Constant Parameters
    param = struct([]);
    for i=1:size(Tparam,1)
        param(i).varname = Tparam.VariableName{i};
        param(i).dispname = Tparam.DisplayName{i};
        param(i).desc = Tparam.Description{i};
        param(i).unit = Tparam.Unit{i};
        param(i).value = readNumericEntries(Tparam.Value{i});
    end
    
    %% Parse: Quantities of Interest
    qoi = struct([]);
    for i=1:size(Tqoi,1)
        qoi(i).varname = Tqoi.VariableName{i};
        qoi(i).dispname = Tqoi.DisplayName{i};
        qoi(i).desc = Tqoi.Description{i};
        qoi(i).unit = Tqoi.Unit{i};
        qoi(i).crll = readNumericEntries(Tqoi.CriticalLowerValue{i});
        qoi(i).crul = readNumericEntries(Tqoi.CriticalUpperValue{i});
        qoi(i).viol = Tqoi.TextWhenViolated{i};
        qoi(i).color = convertRGB(Tqoi.ColorOfPointsWhereViolated{i}); % think of best solution...
    end
    
    %% Parse: Labels
    lbl = struct([]);
    for i=1:size(Tlbl,1)
        lbl(i).varname = Tlbl.LabelName{i};
        lbl(i).dispname = Tlbl.TextToDisplay{i};
        lbl(i).desc = Tlbl.Description{i};
        lbl(i).unit = Tlbl.Unit{i};
        lbl(i).val = Tlbl.ValueOfDesignVariables{i};
        lbl(i).color = Tlbl.Color{i};
    end
    
    %% Parse: Desired Plots
    plotdes = struct([]);
    for i=1:size(Tplot,1)
        plotdes(i).axdes = {Tplot.DesignVariableX_axis{i}, Tplot.DesignVariableY_axis{i}};
    end
    
    
    %% Parse: Other Options
    extraopt = struct;
    extraopt.SampleSize = Topt.Value{find(contains(Topt.Description,'Sample Size'),1,'first')};
    extraopt.SampleMarkerSize = Topt.Value{find(contains(Topt.Description,'Marker Size of Samples'),1,'first')};
    extraopt.SampleMarkerType = Topt.Value{find(contains(Topt.Description,'Sample Marker Type'),1,'first')};
    extraopt.SolSpLineWidth = Topt.Value{find(contains(Topt.Description,'Solution Space Line Width'),1,'first')};
    extraopt.SolSpLineType = Topt.Value{find(contains(Topt.Description,'Solution Space Line Type'),1,'first')};
    
    
    %% Input Validation: Design Variables
    for i=1:size(x,2)
        % design variable must have at least a variable name and design
        % space limits
        if(isempty(x(i).varname) || isnan(x(i).dslb) || isnan(x(i).dsub))
            ME = MException('ExcelParser:DVMissingEntry','Design variable %d must have a variable name and both design space bounds',i);
            throw(ME);
        end
        
        % lower bound must be lower than upper bound
        if(x(i).dslb>x(i).dsub)
            ME = MException('ExcelParser:DVInvalidBounds','Design variable %d has a design space lower bound greater than its upper bound',i);
            throw(ME);
        end
        
        % if no display name is given, use variable name
        if(isempty(x(i).dispname))
            x(i).dispname = x(i).varname;
        end
        
        % if no solution box is given or solution box values exceed design space values, use design space
        if(isnan(x(i).sblb) || (x(i).sblb<x(i).dslb))
            x(i).sblb = x(i).dslb;
        end
        if(isnan(x(i).sbub) || (x(i).sbub>x(i).dsub))
            x(i).sbub = x(i).dsub;
        end
    end
    
    
    %% Input Validation: Constant Parameters
    
    
    %% Input Validation: Quantities of Interest
    for i=1:size(qoi,2)
        % quantity of interest must have at least a variable name
        if(isempty(qoi(i).varname))
            ME = MException('ExcelParser:QoIMissingEntry','Quantity of interest %d must have a variable name',i);
            throw(ME);
        end
        
        % lower bound must be lower than upper bound
        if(qoi(i).crll>qoi(i).crul)
            ME = MException('ExcelParser:QoIInvalidLimits','Quantity of Interest %d has a critical lower limit greater than its upper limit',i);
            throw(ME);
        end
        
        % if no display name is given, use variable name
        if(isempty(qoi(i).dispname))
            qoi(i).dispname = qoi(i).varname;
        end
        
        % if no lower value, use -inf; if no upper value, use +inf
        if(isnan(qoi(i).crll))
            qoi(i).crll = -inf;
        end
        if(isnan(qoi(i).crul))
            qoi(i).crul = +inf;
        end
    end
    
    
    %% Input Validation: Labels
    
    
    %% Input Validation: Desired Plots
    
    
    %% Input Validation: Other Options
    
    
    %% Input Validation: Cross-references
    
    
end

function arrayRGB = convertRGB(rgb)
    r = mod(rgb, 256);
    g = floor(mod(rgb/256, 256));
    b = floor(rgb/65536);
    arrayRGB = [r,g,b]/255;
end

function d = readNumericEntries(s)
    commas = (s==',');
    s(commas) = '.';
    d = str2double(s);
end