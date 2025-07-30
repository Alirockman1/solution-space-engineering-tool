function [x,param,qoi,lbl,plotdes,extraopt] = excel_parser_xray_tool(filename)
% EXCEL_PARSER_XRAY_TOOL Parses structured design data from a standardized Excel file.
%
%   [x, param, qoi, lbl, plotdes, extraopt] = EXCEL_PARSER_XRAY_TOOL(filename)
%   reads multiple sheets from the specified Excel file and converts the
%   content into structured data types used for design exploration and 
%   visualization in engineering and optimization contexts.
%
%   INPUT:
%       filename - Full path to the Excel file containing all required sheets.
%
%   OUTPUT:
%       x         - Struct array of design variables, each with:
%                    - varname, dispname, description, unit
%                    - design space bounds (dslb, dsub)
%                    - initial design (dinit)
%                    - solution box bounds (sblb, sbub)
%
%       param     - Struct array of constant parameters with:
%                    - varname, dispname, description, unit, value
%
%       qoi       - Struct array of Quantities of Interest, each with:
%                    - varname, dispname, description, unit, status
%                    - critical lower and upper limits (crll, crul)
%                    - text for when violated (viol)
%                    - color (color), parsed as RGB or named string
%
%       lbl       - Struct array of label metadata used for sample annotation,
%                   including:
%                    - varname, dispname, description, unit, value, color
%
%       plotdes   - Struct array defining which pairs of variables to use
%                   for plotting (X-Y combinations), stored as index references.
%
%       extraopt  - Struct of plotting or sampling configuration read from the
%                   "Other Options" sheet, including:
%                    - SampleSize, SampleMarkerSize, SampleMarkerType
%                    - SolSpLineWidth, SolSpLineType
%
%   Each sheet must follow a predefined structure, and the parser includes
%   robust error checking for:
%       - Missing or invalid variable names
%       - Malformed numeric inputs
%       - Out-of-bound design space definitions
%       - Unrecognized color formats in QoI definitions
%
%   Recognized color formats include MATLAB named colors and hex codes
%   (e.g., '#FF0000' or 'red').
%
%   REQUIREMENTS:
%       The following Excel sheets are expected:
%           - 'Design Variables'
%           - 'Constant Parameters'
%           - 'Quantities of Interest'
%           - 'Labels'
%           - 'Desired Plots'
%           - 'Other Options'
%
%   See also: DETECTIMPORTOPTIONS, READTABLE, STRUCT, CONTAINERS.MAP
%
%   Developed for the X-Ray Design Space Exploration Framework.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor, Main Author)
%   Copyright 2025 Ali Abbas Kapadia (Contributor)
%   SPDX-License-Identifier: Apache-2.0

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
    % Read the Excel file directly into a table
    dataTable = readtable(filename, 'Sheet', 'Quantities of Interest');
    
    % Assuming column H corresponds to the 8th column in the table
    colorTexts = dataTable{:, end}; % Extract all values from column H
    
    % List of recognized color names
    validColorNames = {'red', 'green', 'blue', 'yellow', 'black', 'white', 'cyan', 'magenta', 'gray', 'orange', 'pink', 'purple', 'brown'};
    
    % Loop through each color text
    for i = 1:length(colorTexts)
        colorText = colorTexts{i}; % Get the color text
    
        % Check if it's a valid hex code or color name
        if isHexColor(colorText)
            Tqoi.ColorOfPointsWhereViolated{i} = colorText; % Store valid hex code
        elseif ismember(lower(colorText), validColorNames)
            Tqoi.ColorOfPointsWhereViolated{i} = colorText; % Store valid color name
        else
            error('Invalid color format in row %d. Must be a hex code or a recognized color name.', i);
        end
    end

    %% Parse: Design Variables
    x = struct([]);
    for i=1:size(Tx,1)
        x(i).varname = Tx.VariableName{i};
        x(i).dispname = Tx.DisplayName{i};
        x(i).desc = Tx.Description{i};
        x(i).unit = Tx.Unit{i};
        x(i).dslb = readNumericEntries(Tx.DesignSpaceLowerBound{i});
        x(i).dsub = readNumericEntries(Tx.DesignSpaceUpperBound{i});
        x(i).dinit = readNumericEntries(Tx.InitialDesign{i});
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
        qoi(i).status = Tqoi.Status{i};
        qoi(i).crll = readNumericEntries(Tqoi.CriticalLowerValue{i});
        qoi(i).crul = readNumericEntries(Tqoi.CriticalUpperValue{i});
        qoi(i).viol = Tqoi.TextWhenViolated{i};
        qoi(i).color = colorNameToRGB(Tqoi.ColorOfPointsWhereViolated{i}); % think of best solution...
    end
    
    %% Parse: Labels
    lbl = struct([]);
    for i=1:size(Tlbl,1)
        lbl(i).varname = Tlbl.LabelName{i};
        lbl(i).dispname = Tlbl.TextToDisplay{i};
        lbl(i).varno = Tlbl.DesignVarNo{i};
        lbl(i).desc = Tlbl.Description{i};
        lbl(i).unit = Tlbl.Unit{i};
        lbl(i).val = Tlbl.ValueOfDesignVariables{i};
        lbl(i).color = Tlbl.Color{i};
    end

    %% Reorder the design variables
    
    % Step 1: Collect all x.varname values
    x_varnames = {x.varname};
    
    % Step 2: Reorder using lbl(i).varname and lbl(i).varno
    x_reordered = repmat(x(1), size(x));  % Preallocate
    
    for i = 1:length(lbl)
        idx = str2double(lbl(i).varno);          % Target index
        targetVar = lbl(i).varname;            % Name to find in x
        x_idx = find(strcmp(x_varnames, targetVar));  % Find in x
        if isempty(x_idx)
            error("Variable name '%s' from lbl(%d) not found in x.", targetVar, idx);
        end
        x_reordered(idx) = x(x_idx);  % Place x entry at correct idx
    end
    
    % Step 3: Overwrite original x
    x = x_reordered;
    
    %% Parse: Desired Plots
    plotdes = struct([]);

    % Flatten lbl.varno to a plain cell array of strings
    if iscell(lbl(1).varno)
        varnoList = cellfun(@(c) c{1}, {lbl.varname}, 'UniformOutput', false);  % If each lbl.varno is like {'X1'}
    else
        varnoList = {lbl.varname};  % If each lbl.varno is like 'X1'
    end

    for i=1:size(Tplot,1)
        variableNumberX = find(strcmp(Tplot.DesignVariableX_axis{i}, varnoList));
        variableNumberY = find(strcmp(Tplot.DesignVariableY_axis{i}, varnoList));
        plotdes(i).axdes = {lbl(variableNumberX).varno, ...
                        lbl(variableNumberY).varno};
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
        
        % If box shaped design space is not given initialize half the design space
        designSpaceLength = x(i).dsub - x(i).dslb;
        halfLength = designSpaceLength / 2;
        
        % Position the solution box centered inside the design space
        midPoint = (x(i).dslb + x(i).dsub) / 2;
        
        % Set sblb and sbub to cover half the design space centered around midpoint
        x(i).sblb = midPoint - halfLength/2;
        x(i).sbub = midPoint + halfLength/2;
        
        % Just to be safe, clamp to design space bounds (optional)
        x(i).sblb = max(x(i).sblb, x(i).dslb);
        x(i).sbub = min(x(i).sbub, x(i).dsub);
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
    label = struct([]);
    for i=1:size(Tlbl,1)
        label(i).name = Tlbl.LabelName{i};
        label(i).text = Tlbl.TextToDisplay{i};
        label(i).desc = Tlbl.Description{i};
        label(i).unit = Tlbl.Unit{i};
    end
    
    %% Input Validation: Desired Plots
    
    
    %% Input Validation: Other Options
    
    
    %% Input Validation: Cross-references
    
    
end

function rgb = colorNameToRGB(colorName)
    % Map common color names to RGB triplets
    validColorNames = {'red', 'green', 'blue', 'yellow', 'black', 'white', ...
                       'cyan', 'magenta', 'gray', 'orange', 'pink', 'purple', 'brown'};
    rgbValues = [ ...
        1.0, 0.0, 0.0;      % red
        0.0, 1.0, 0.0;      % green
        0.0, 0.0, 1.0;      % blue
        1.0, 1.0, 0.0;      % yellow
        0.0, 0.0, 0.0;      % black
        1.0, 1.0, 1.0;      % white
        0.0, 1.0, 1.0;      % cyan
        1.0, 0.0, 1.0;      % magenta
        0.5, 0.5, 0.5;      % gray
        1.0, 0.65, 0.0;     % orange
        1.0, 0.75, 0.8;     % pink
        0.5, 0.0, 0.5;      % purple
        0.6, 0.4, 0.2       % brown
    ];

    idx = find(strcmpi(colorName, validColorNames), 1);
    if isempty(idx)
        error('Color name "%s" not recognized. Valid names are: %s', colorName, strjoin(validColorNames, ', '));
    end
    rgb = rgbValues(idx, :);
end

function d = readNumericEntries(s)
    commas = (s==',');
    s(commas) = '.';
    d = str2double(s);
end

% Function to check if the string is a valid hex color code or a known colour
function isValid = isHexColor(colorStr)
    isValid = false;
    if ischar(colorStr) && length(colorStr) == 7 && colorStr(1) == '#'
        hexPart = colorStr(2:end); % Skip the '#' part
        isValid = all(isstrprop(hexPart, 'xdigit')); % Check if the rest is valid hex digits
    end
end