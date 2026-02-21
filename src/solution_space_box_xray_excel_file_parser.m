function dataManager = solution_space_box_xray_excel_file_parser(filename, dataManager)
%SOLUTION_SPACE_BOX_XRAY_EXCEL_FILE_PARSER Parse Excel file for BoxXRay GUI
%   SOLUTION_SPACE_BOX_XRAY_EXCEL_FILE_PARSER reads a structured Excel file
%   containing design problem configuration and creates or updates a
%   SolutionSpaceBoxXrayDataManager object. The parser validates input data,
%   performs necessary conversions (e.g., comma to dot for numeric values,
%   color code conversions), and initializes default values where appropriate.
%
%   DATAMANAGER = SOLUTION_SPACE_BOX_XRAY_EXCEL_FILE_PARSER(FILENAME)
%   creates a new SolutionSpaceBoxXrayDataManager object populated with data
%   from the Excel file FILENAME. If the file path does not include the .xlsx
%   extension, it is automatically appended.
%
%   DATAMANAGER = SOLUTION_SPACE_BOX_XRAY_EXCEL_FILE_PARSER(FILENAME,
%   DATAMANAGER) updates an existing SolutionSpaceBoxXrayDataManager object
%   with data from the Excel file. All existing data in the dataManager is
%   replaced with the parsed values from the Excel file.
%
%   Inputs:
%       - FILENAME : char/string
%           -- path to Excel file (.xlsx extension is optional and will be
%           added automatically if missing). The file must exist at the
%           specified location.
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager (optional)
%           -- existing data manager object to update. If not provided, a new
%           object is created.
%
%   Outputs:
%       - DATAMANAGER : SolutionSpaceBoxXrayDataManager
%           -- data manager object with parsed and validated configuration
%           data. The object contains initialized design variables, quantities
%           of interest, design parameters, plot pairs, and GUI options.
%
%   Excel File Structure:
%       The Excel file must contain exactly five sheets with the following
%       names and structures:
%
%       1. 'Design Variables' Sheet:
%          Required columns: VariableName, DisplayName, Description, Unit,
%          DesignSpaceLowerBound, DesignSpaceUpperBound,
%          SolutionBoxLowerBound, SolutionBoxUpperBound
%          - Each row defines one design variable
%          - If SolutionBox bounds are empty, they default to centered half
%            of the design space
%          - DisplayName defaults to VariableName if empty
%
%       2. 'Constant Parameters' Sheet:
%          Required columns: VariableName, DisplayName, Description, Unit,
%          Value
%          - Each row defines one constant parameter passed to the system
%            evaluation function
%          - Values can be numeric (comma or dot decimal separator)
%
%       3. 'Quantities of Interest' Sheet:
%          Required columns: VariableName, DisplayName, Description, Unit,
%          CriticalLowerValue, CriticalUpperValue, TextWhenViolated,
%          ColorOfPointsWhereViolated, ColorOfPointsWhereViolatedBackground
%          - Each row defines one QOI constraint
%          - Violation colors can be specified as color names, hex codes, or
%            Excel background colors (read via COM interface)
%          - Missing limits default to -inf (lower) or +inf (upper)
%
%       4. 'Desired Plots' Sheet:
%          Required columns: DesignVariableX_axis, DesignVariableY_axis
%          - Each row defines one 2D projection plot pair
%          - Variable names must match VariableName entries in Design
%            Variables sheet
%
%       5. 'Other Options' Sheet:
%          Required columns: Description, Value
%          - Each row defines one GUI/plotting option
%          - Description becomes the option name (spaces removed)
%          - Values are evaluated as MATLAB expressions or stored as strings
%
%   Parsing Details:
%       - Numeric values with comma decimal separators are automatically
%         converted to dot separators
%       - Excel background colors in the QOI sheet are read using ActiveX COM
%         interface and converted to RGB values
%       - Color specifications support MATLAB color names, hex codes, and
%         Excel color indices
%       - Input validation checks for required fields, valid bounds
%         (lower < upper), and missing critical values
%
%   Error Handling:
%       - Throws error if Excel file does not exist
%       - Throws MException if required sheet columns are missing
%       - Throws MException if design variable bounds are invalid
%       - Throws MException if QOI limits are invalid
%
%   See also SolutionSpaceBoxXrayDataManager,
%   solution_space_box_xray_create_gui, read_numeric_entries_with_comma_dot,
%   convert_base10hexcode_to_rgb, convert_color_name_or_hexcode_to_rgb.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2024-2025.
%   Copyright 2024-2025 Eduardo Rodrigues Della Noce (Author)
%   Copyright 2024-2025 Ali Abbas Kapadia (Author)
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
    
    filename = erase(filename, '.xlsx'); % delete so it doesn't get added twice
    filename = fullfile([filename, '.xlsx']);
    if(~exist(filename, 'file'))
        error('Incorrect excel file specified. Please check the file location or name');
    end
    
    
    %% Read Excel Spreadsheets Information
    warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');
    % Design Variables
    opts = detectImportOptions(filename,'Sheet','Design Variables');
    opts = setvartype(opts, 'char');
    tableDesignVariables = readtable(filename,opts);
    % Constant Parameters
    opts = detectImportOptions(filename,'Sheet','Constant Parameters');
    opts = setvartype(opts, 'char');
    tableSystemParameter = readtable(filename,opts);
    % Quantities of Interest
    opts = detectImportOptions(filename,'Sheet','Quantities of Interest');
    opts = setvartype(opts, 'char');
    tableQuantitiesOfInterest = readtable(filename,opts);
    % Desired Plots
    opts = detectImportOptions(filename,'Sheet','Desired Plots');
    opts = setvartype(opts, 'char');
    tablePlotDesiredPairs = readtable(filename,opts);
    % Extra Options
    opts = detectImportOptions(filename,'Sheet','Other Options');
    opts = setvartype(opts, 'char');
    tableExtraOptions = readtable(filename,opts);
    warning('ON','MATLAB:table:ModifiedAndSavedVarnames'); % ok, reset it now
    clear opts;


    %% Read Color Information - Quantities of Interest
    excel = actxserver('Excel.Application'); % start excel
    excel.Visible = false; % optional, make sure excel doesn't open
    workbook = excel.Workbooks.Open(which(filename)); % open excel file using full path
    worksheet = workbook.Worksheets.Item('Quantities of Interest'); % get worksheet reference
    for i=1:size(tableQuantitiesOfInterest,1)
        tableQuantitiesOfInterest.ColorOfPointsWhereViolatedBackground{i} = worksheet.Cells.Item(8).Item(i+1).Interior.Color; % 9=column 'I'; i+1=skip first row
    end
    workbook.Close;
    excel.Quit;
    clear excel workbook worksheet;


    %% Parse: Design Variables
    designVariables = struct([]);
    for i=1:size(tableDesignVariables,1)
        designVariables(i).VariableName = tableDesignVariables.VariableName{i};
        designVariables(i).DisplayName = tableDesignVariables.DisplayName{i};
        designVariables(i).Description = tableDesignVariables.Description{i};
        designVariables(i).Unit = tableDesignVariables.Unit{i};
        designVariables(i).DesignSpaceLowerBound = read_numeric_entries_with_comma_dot(tableDesignVariables.DesignSpaceLowerBound{i});
        designVariables(i).DesignSpaceUpperBound = read_numeric_entries_with_comma_dot(tableDesignVariables.DesignSpaceUpperBound{i});
        designVariables(i).BoxLowerBound = read_numeric_entries_with_comma_dot(tableDesignVariables.SolutionBoxLowerBound{i});
        designVariables(i).BoxUpperBound = read_numeric_entries_with_comma_dot(tableDesignVariables.SolutionBoxUpperBound{i});
    end
    
    %% Parse: Constant Parameters
    systemParameter = struct([]);
    for i=1:size(tableSystemParameter,1)
        systemParameter(i).VariableName = tableSystemParameter.VariableName{i};
        systemParameter(i).DisplayName = tableSystemParameter.DisplayName{i};
        systemParameter(i).Description = tableSystemParameter.Description{i};
        systemParameter(i).Unit = tableSystemParameter.Unit{i};
        systemParameter(i).Value = read_numeric_entries_with_comma_dot(tableSystemParameter.Value{i});
    end
    
    %% Parse: Quantities of Interest
    quantitiesOfInterest = struct([]);
    for i=1:size(tableQuantitiesOfInterest,1)
        quantitiesOfInterest(i).VariableName = tableQuantitiesOfInterest.VariableName{i};
        quantitiesOfInterest(i).DisplayName = tableQuantitiesOfInterest.DisplayName{i};
        quantitiesOfInterest(i).Description = tableQuantitiesOfInterest.Description{i};
        quantitiesOfInterest(i).Unit = tableQuantitiesOfInterest.Unit{i};
        quantitiesOfInterest(i).LowerLimit = read_numeric_entries_with_comma_dot(tableQuantitiesOfInterest.CriticalLowerValue{i});
        quantitiesOfInterest(i).UpperLimit = read_numeric_entries_with_comma_dot(tableQuantitiesOfInterest.CriticalUpperValue{i});
        quantitiesOfInterest(i).ViolatedText = tableQuantitiesOfInterest.TextWhenViolated{i};

        colorCurrent = tableQuantitiesOfInterest.ColorOfPointsWhereViolated{i};
        if(isempty(colorCurrent))
            quantitiesOfInterest(i).ColorWhenViolated = convert_base10hexcode_to_rgb(...
                tableQuantitiesOfInterest.ColorOfPointsWhereViolatedBackground{i});
        else
            quantitiesOfInterest(i).ColorWhenViolated = convert_color_name_or_hexcode_to_rgb(colorCurrent);
        end
    end
    
    %% Parse: Desired Plots
    plotDesiredPairs = struct([]);
    for i=1:size(tablePlotDesiredPairs,1)
        plotDesiredPairs(i).DesignVariableName = {tablePlotDesiredPairs.DesignVariableX_axis{i}, tablePlotDesiredPairs.DesignVariableY_axis{i}};
    end
    
    
    %% Parse: Other Options
    extraOptions = struct;
    for i=1:size(tableExtraOptions,1)
        description = strrep(tableExtraOptions.Description{i}, ' ', '');
        try 
            extraOptions.(description) = eval(tableExtraOptions.Value{i});
        catch
            extraOptions.(description) = char(tableExtraOptions.Value{i});
        end
    end

    %% Input Validation: Design Variables
    for i=1:size(designVariables,2)
        % design variable must have at least a variable name and design
        % space limits
        if(isempty(designVariables(i).VariableName) || isnan(designVariables(i).DesignSpaceLowerBound) || isnan(designVariables(i).DesignSpaceUpperBound))
            ME = MException('ExcelParser:DVMissingEntry','Design variable %d must have a variable name and both design space bounds',i);
            throw(ME);
        end
        
        % lower bound must be lower than upper bound
        if(designVariables(i).DesignSpaceLowerBound>designVariables(i).DesignSpaceUpperBound)
            ME = MException('ExcelParser:DVInvalidBounds','Design variable %d has a design space lower bound greater than its upper bound',i);
            throw(ME);
        end
        
        % if no display name is given, use variable name
        if(isempty(designVariables(i).DisplayName))
            designVariables(i).DisplayName = designVariables(i).VariableName;
        end
        
        % If box shaped design space is not given initialize half the design space
        designSpaceLength = designVariables(i).DesignSpaceUpperBound - designVariables(i).DesignSpaceLowerBound;
        halfLength = designSpaceLength / 2;
        
        % Position the solution box centered inside the design space
        midPoint = (designVariables(i).DesignSpaceLowerBound + designVariables(i).DesignSpaceUpperBound) / 2;
        
        % Set sblb and sbub to cover half the design space centered around midpoint
        designVariables(i).BoxLowerBound = midPoint - halfLength/2;
        designVariables(i).BoxUpperBound = midPoint + halfLength/2;
        
        % Just to be safe, clamp to design space bounds (optional)
        designVariables(i).BoxLowerBound = max(designVariables(i).BoxLowerBound, designVariables(i).DesignSpaceLowerBound);
        designVariables(i).BoxUpperBound = min(designVariables(i).BoxUpperBound, designVariables(i).DesignSpaceUpperBound);
    end
    
    
    %% Input Validation: Constant Parameters
    
    
    %% Input Validation: Quantities of Interest
    for i=1:size(quantitiesOfInterest,2)
        % quantity of interest must have at least a variable name
        if(isempty(quantitiesOfInterest(i).VariableName))
            ME = MException('ExcelParser:QoIMissingEntry','Quantity of interest %d must have a variable name',i);
            throw(ME);
        end
        
        % lower bound must be lower than upper bound
        if(quantitiesOfInterest(i).LowerLimit>quantitiesOfInterest(i).UpperLimit)
            ME = MException('ExcelParser:QoIInvalidLimits','Quantity of Interest %d has a critical lower limit greater than its upper limit',i);
            throw(ME);
        end
        
        % if no display name is given, use variable name
        if(isempty(quantitiesOfInterest(i).DisplayName))
            quantitiesOfInterest(i).DisplayName = quantitiesOfInterest(i).VariableName;
        end
        
        % if no lower value, use -inf; if no upper value, use +inf
        if(isnan(quantitiesOfInterest(i).LowerLimit))
            quantitiesOfInterest(i).LowerLimit = -inf;
        end
        if(isnan(quantitiesOfInterest(i).UpperLimit))
            quantitiesOfInterest(i).UpperLimit = +inf;
        end
    end

    if(nargin>=2)
        dataManager.set_design_variables(designVariables);
        dataManager.set_quantities_of_interest(quantitiesOfInterest);
        dataManager.set_system_parameters(systemParameter);
        dataManager.set_plot_desired_pairs(plotDesiredPairs);
        dataManager.set(extraOptions);
    else
        dataManager = SolutionSpaceBoxXrayDataManager(...
            'DesignVariables',designVariables, ...
            'QuantatiesOfInterests',quantitiesOfInterest, ...
            'DesignParameters',systemParameter, ...
            'PlotDesiredPairs',plotDesiredPairs,...
            extraOptions);
    end
end

function d = read_numeric_entries_with_comma_dot(s)
    commas = (s==',');
    s(commas) = '.';
    d = str2double(s);
end

