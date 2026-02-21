function rgb = convert_color_name_or_hexcode_to_rgb(colorName)
%CONVERT_COLOR_NAME_OR_HEXCODE_TO_RGB Convert color name or hexcode to RGB
%   CONVERT_COLOR_NAME_OR_HEXCODE_TO_RGB converts color names (e.g., 'red',
%   'blue') or hexadecimal color codes (e.g., '#FF0000', 'FF0000') to RGB
%   triplets. The function supports common color names and various hexcode
%   formats (with or without '#' prefix, different digit lengths).
%
%   RGB = CONVERT_COLOR_NAME_OR_HEXCODE_TO_RGB(COLORNAME) converts the color
%   name or hexcode in COLORNAME to an RGB triplet. COLORNAME can be a string,
%   character array, or cell array of strings/character arrays.
%
%   Inputs:
%       - COLORNAME : char/string OR (1,nColor) cell array of char/string
%           -- color name (e.g., 'red', 'blue') or hexcode (e.g., '#FF0000')
%
%   Outputs:
%       - RGB : (nColor,3) double
%           -- RGB triplets with values in [0,1]
%
%   See also convert_hexcode_to_rgb, is_hex_color.

%   Developed at the Laboratory for Product Development and Lightweight Design
%   (LPL), Technical University of Munich (TUM), 2024-2025.
%   Copyright 2024-2025 Eduardo Rodrigues Della Noce
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

    % Convert single string/char to cell array for uniform processing
    if ischar(colorName) || isstring(colorName)
        colorName = {colorName};
    end
    
    % Ensure it's a cell array
    if ~iscell(colorName)
        error('colorName must be a string, char array, or cell array');
    end
    
    nColors = length(colorName);
    rgb = zeros(nColors, 3);
    
    % Map common color names to RGB triplets
    colorMap = containers.Map();
    colorMap('red') = [1.0, 0.0, 0.0];
    colorMap('green') = [0.0, 1.0, 0.0];
    colorMap('blue') = [0.0, 0.0, 1.0];
    colorMap('yellow') = [1.0, 1.0, 0.0];
    colorMap('black') = [0.0, 0.0, 0.0];
    colorMap('white') = [1.0, 1.0, 1.0];
    colorMap('cyan') = [0.0, 1.0, 1.0];
    colorMap('magenta') = [1.0, 0.0, 1.0];
    colorMap('gray') = [0.5, 0.5, 0.5];
    colorMap('orange') = [1.0, 0.65, 0.0];
    colorMap('pink') = [1.0, 0.75, 0.8];
    colorMap('purple') = [0.5, 0.0, 0.5];
    colorMap('brown') = [0.6, 0.4, 0.2];
    colorMap('lime') = [0.0, 1.0, 0.0];
    colorMap('navy') = [0.0, 0.0, 0.5];
    colorMap('teal') = [0.0, 0.5, 0.5];
    colorMap('olive') = [0.5, 0.5, 0.0];
    colorMap('maroon') = [0.5, 0.0, 0.0];
    colorMap('aqua') = [0.0, 1.0, 1.0];
    colorMap('silver') = [0.75, 0.75, 0.75];
    colorMap('gold') = [1.0, 0.84, 0.0];
    colorMap('indigo') = [0.29, 0.0, 0.51];
    colorMap('violet') = [0.93, 0.51, 0.93];
    colorMap('coral') = [1.0, 0.5, 0.31];
    colorMap('salmon') = [1.0, 0.55, 0.41];
    colorMap('khaki') = [0.94, 0.9, 0.55];
    colorMap('tan') = [0.82, 0.71, 0.55];
    colorMap('turquoise') = [0.25, 0.88, 0.82];
    colorMap('chocolate') = [0.82, 0.41, 0.12];
    colorMap('crimson') = [0.86, 0.08, 0.24];
    colorMap('darkgreen') = [0.0, 0.39, 0.0];
    colorMap('darkblue') = [0.0, 0.0, 0.55];
    colorMap('darkred') = [0.55, 0.0, 0.0];
    colorMap('darkgray') = [0.66, 0.66, 0.66];
    colorMap('lightblue') = [0.68, 0.85, 0.9];
    colorMap('lightgreen') = [0.56, 0.93, 0.56];
    colorMap('lightcoral') = [0.94, 0.5, 0.5];
    colorMap('lightyellow') = [1.0, 1.0, 0.88];
    colorMap('lightgray') = [0.83, 0.83, 0.83];
    colorMap('lightpink') = [1.0, 0.71, 0.76];
    
    % Process each color
    for i = 1:nColors
        currentColor = colorName{i};
        
        % Convert to char if it's a string
        if isstring(currentColor)
            currentColor = char(currentColor);
        end
        
        % Check if hexcode
        if is_hex_color(currentColor)
            hexRgb = convert_hexcode_to_rgb(currentColor);
            rgb(i, :) = hexRgb;
        else
            % Look up color name
            if ~isKey(colorMap, lower(currentColor))
                error('Color name "%s" not recognized. Valid names are: %s', ...
                    currentColor, strjoin(colorMap.keys(), ', '));
            end
            rgb(i, :) = colorMap(lower(currentColor));
        end
    end
end