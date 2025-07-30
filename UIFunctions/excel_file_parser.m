function parseValues = excel_file_parser(projectRoot,varargin)
% EXCEL_FILE_PARSER Parses design information from an Excel file.
%   EXCEL_FILE_PARSER takes in the project root directory and by allowing
%   users to select the excel file to be parsed through.
%   
%   INPUT:
%       projectRoot - Path to the root of the project directory
%
%   OUTPUT:
%       excel - Struct containing fields:
%           - x: struct with design variables
%           - param: struct with design parameters (constants)
%           - qoi: struct with quantities of interest and constraints
%           - lbl: labels or metadata (optional, based on parser)
%           - plotdes: desired design variable combinations for plotting
%           - extraopt: additional plotting options or information
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor, Contributor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    p = inputParser;
    addParameter(p, 'ExcelFile', 'ProblemDefinition', @(x) ischar(x) || isstring(x));
    parse(p, varargin{:});
    options = p.Results;

    % Add all relevant folders and subfolders to the MATLAB path dynamically
    excelFilePath = fullfile(projectRoot, options.ExcelFile);
    
    % excel file to open using the parser
    excelFileName = input('Please enter the name of the excel data file: ', 's');
    excelFileName = fullfile(excelFilePath, [excelFileName, '.xlsx']);
    
    parseValues = struct();
    
    try
        [x,param,qoi,lbl,plotdes,extraopt] = excel_parser_xray_tool(excelFileName);

        parseValues.DesignVariable = x;
        parseValues.DesignParameters = param;
        parseValues.QuantatiesOfInterest = qoi;
        parseValues.Labels = lbl;
        parseValues.PlotDesigns = plotdes;
        parseValues.ExtraOptions = extraopt;
    catch
        warning('Incorrect excel file specified. Please check the file location or name');
    end
end