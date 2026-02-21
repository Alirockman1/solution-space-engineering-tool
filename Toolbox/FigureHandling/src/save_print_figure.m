function save_print_figure(figureHandle,filename,varargin)
%SAVE_PRINT_FIGURE Save and print given figure
%   SAVE_PRINT_FIGURE saves figure in '.fig' and other formats, using the
%   desired sizes and options. It also updates it in MATLAB itself for 
%   visualization.
%
%   SAVE_PRINT_FIGURE(FIGUREHANDLE,FILENAME) saves the figure FIGUREHANDLE with
%   name FILENAME (can also include a folder structure, like: 
%   "./figures/data/image"). The saved image retains the current position and
%   size, and is saved both as '.fig' and '.png'.
%
%   SAVE_PRINT_FIGURE(...NAME,VALUE,...) also allows for the specification of 
%   options as name-value pair arguments. Available are:
%       - 'Units' : units to be used in all other options (first to be set).
%       Default: 'centimeters'.
%       - 'Size' : size of the figure as (width, height). Default is the current
%       size.
%       - 'Position' : position of the figure relative to the primary monitor. 
%       Default is the current position.
%       - 'PrintFormat' : formats to save/print the figure as; available are:
%           -- 'jpg' : JPEG 24-bit
%           -- 'png' : PNG 24-bit
%           -- 'tif-compressed' : TIFF 24-bit (compressed)
%           -- 'tif' : TIFF 24-bit (not compressed)
%           -- 'emf' : Enhanced metafile (Windows only)
%           -- 'pdf' : Full page Portable Document Format (PDF) color
%           -- 'eps' : Encapsulated PostScript (EPS) Level 3 color
%           -- 'eps-b&w' : Encapsulated PostScript (EPS) Level 3 black and white
%           -- 'svg' : SVG (Scalable Vector Graphics)
%       - 'AdditionalProperties' : name-value pair cell for other properties one
%       may wish to change. By default, the following are set:
%           -- 'Color' : 'white'
%           -- 'Renderer' : 'opengl'
%           -- 'PaperType' : 'A4'
%           -- 'PaperPositionMode' : 'manual'
%       These may be overwritten, and other options may be set according to
%       'matlab.ui.Figure'.
%
%   Input:
%       - FIGUREHANDLE : Figure
%       - FILENAME : string 
%       - 'Units' : char OR string
%       - 'Size' : (1,2) double
%       - 'Position' : (1,2) double
%       - 'AdditionalProperties' : (1,nOption) cell
%       - 'PrintFormat' : (1,nFormat) cell
%
%   See also figure, savefig, print.

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

    saveFormatAvailable = {'jpg','png','tif-compressed','tif','emf','pdf','eps','eps-b&w','svg'};

    parser = inputParser;
    parser.addRequired('FigureHandle',@(x)isa(x,'matlab.ui.Figure'));
    parser.addRequired('Filename',@(x)isstring(x)||ischar(x));
    parser.addParameter('Units','centimeters',@(x)ischar(x));
    parser.addParameter('Size',[],@(x)isnumeric(x)&&(length(x)==2 || isempty(x)));
    parser.addParameter('Position',[],@(x)isnumeric(x)&&(length(x)==2 || isempty(x)));
    parser.addParameter('Color','white');
    parser.addParameter('Renderer','opengl');
    parser.addParameter('PaperType','A4');
    parser.addParameter('PaperPositionMode','manual');
    parser.addParameter('PrintFormat',{'png'},@(x)iscell(x) || any(strcmpi(x,saveFormatAvailable)));
    parser.KeepUnmatched = true;
    parser.parse(figureHandle,filename,varargin{:});
    options = parser.Results;
    additionalProperties = namedargs2cell(parser.Unmatched);

    % activate figure
    activate_graphics_object(figureHandle);

    set(figureHandle, 'Color', options.Color);
    set(figureHandle, 'Renderer', options.Renderer);
    set_figure_size(figureHandle,options.Size,options.Position,'Units',options.Units);

    currentPosition = get(figureHandle, 'Position');
    set(figureHandle, 'PaperType', options.PaperType);
    set(figureHandle, 'PaperUnits', options.Units);
    set(figureHandle, 'PaperPositionMode', options.PaperPositionMode);
    set(figureHandle, 'PaperSize', currentPosition(3:4));
    set(figureHandle, 'PaperPosition', [0 0 currentPosition(3:4)]);

    for i=1:2:size(additionalProperties,2)
        set(figureHandle,additionalProperties{i},...
            additionalProperties{i+1});
    end
    
    % set correct name for title
    figureName = strsplit(filename,'/'); % separate the folder structure
    set(figureHandle,'NumberTitle','off','Name',figureName{end}); % title should be only the actual name

    % save in requested formats
    savefig(figureHandle,filename); % save figure

    % image file
    if(any(strcmpi(options.PrintFormat,'jpg')))
        print(filename,'-djpeg'); % save JPEG
    end
    if(any(strcmpi(options.PrintFormat,'png')))
        print(filename,'-dpng'); % save PNG
    end
    if(any(strcmpi(options.PrintFormat,'tif-compressed')))
        print(filename,'-dtiff'); % save PNG
    end
    if(any(strcmpi(options.PrintFormat,'tif')))
        print(filename,'-dtiffn'); % save PNG
    end
    if(any(strcmpi(options.PrintFormat,'emf')))
        print(filename,'-dmeta'); % save PNG
    end
    
    % vector graphics file
    if(any(strcmpi(options.PrintFormat,'pdf')))
        print(filename,'-dpdf'); % save PDF
    end
    if(any(strcmpi(options.PrintFormat,'eps')))
        print(filename,'-depsc','-tiff'); % save EPS with colors
    end
    if(any(strcmpi(options.PrintFormat,'eps-b&w')))
        print(filename,'-deps','-tiff'); % save EPS without colors
    end
    if(any(strcmpi(options.PrintFormat,'svg')))
        print(filename,'-dsvg'); % save EPS without colors
    end
end