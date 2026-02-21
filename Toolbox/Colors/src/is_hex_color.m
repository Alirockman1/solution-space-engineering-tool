function isValid = is_hex_color(colorStr)
%IS_HEX_COLOR Check if string is a valid hexadecimal color code
%   IS_HEX_COLOR checks whether the input string is a valid hexadecimal color
%   code. Valid hex codes can have an optional '#' prefix and must contain
%   hexadecimal digits only, with the total number of digits (excluding '#')
%   being divisible by 3 (for RGB decomposition).
%
%   ISVALID = IS_HEX_COLOR(COLORSTR) returns true if COLORSTR is a valid hex
%   color code, false otherwise.
%
%   Inputs:
%       - COLORSTR : char/string
%           -- string to check (e.g., '#FF0000', 'FF0000', 'ABC')
%
%   Outputs:
%       - ISVALID : (1,1) logical
%           -- true if COLORSTR is a valid hex color code, false otherwise
%
%   See also convert_hexcode_to_rgb, convert_color_name_or_hexcode_to_rgb.

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
    isValid = false;

    if(ischar(colorStr) && (mod(length(colorStr)-1,3) == 0) && (colorStr(1) == '#'))
        hexPart = colorStr(2:end); % Skip the '#' part
    elseif(ischar(colorStr) && (mod(length(colorStr),3) == 0))
        hexPart = char(colorStr);
    else
        return; % not a valid hex color code
    end
    isValid = all(isstrprop(hexPart, 'xdigit')); % Check if the rest is valid hex digits
end