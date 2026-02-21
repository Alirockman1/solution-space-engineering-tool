function arrayRgb = convert_hexcode_to_rgb(hexcodeColor)
%CONVERT_HEXCODE_TO_RGB Convert hexadecimal color codes to RGB triplets
%   CONVERT_HEXCODE_TO_RGB converts hexadecimal color codes to RGB triplets
%   with values normalized to [0,1]. The function supports hexcodes with or
%   without '#' prefix and handles different digit lengths (e.g., 3, 6, 9
%   digits for RGB, RRGGBB, RRRGGGBBB formats).
%
%   ARRAYRGB = CONVERT_HEXCODE_TO_RGB(HEXCODECOLOR) converts the hexcode(s)
%   in HEXCODECOLOR to RGB triplets. HEXCODECOLOR can be a string, character
%   array, or cell array of strings/character arrays.
%
%   Inputs:
%       - HEXCODECOLOR : char/string OR (1,nColor) cell array of char/string
%           -- hexadecimal color code(s) (e.g., '#FF0000', 'FF0000', 'ABC')
%
%   Outputs:
%       - ARRAYRGB : (nColor,3) double
%           -- RGB triplets with values in [0,1]
%
%   See also convert_color_name_or_hexcode_to_rgb, is_hex_color.

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
	if(ischar(hexcodeColor))
		hexcodeColor = {hexcodeColor};
	end

	nColor = length(hexcodeColor);
	redColor = nan(nColor,1);
	greenColor = nan(nColor,1);
	blueColor = nan(nColor,1);

	for i=1:nColor
		hexcodeColorCurrent = hexcodeColor{i};
		if(hexcodeColorCurrent(1)=='#')
			hexcodeColorCurrent = hexcodeColorCurrent(2:end);
		end

		nDigit = numel(hexcodeColorCurrent);
		if(mod(nDigit,3)~=0)
			error('convert_hexcode_to_rgb:invalid_hexcode','Hexcode %s not valid, as it is not a triplet for RGB decomposition.',hexcodeColorCurrent);
		end

		nDigitPerColor = round(nDigit/3);
		normalizationFactor = round(16^nDigitPerColor) - 1;
		
		redColor(i) = hex2dec(hexcodeColorCurrent(1:nDigitPerColor)) / normalizationFactor;
		greenColor(i) = hex2dec(hexcodeColorCurrent((nDigitPerColor+1):(2*nDigitPerColor))) / normalizationFactor;
		blueColor(i) = hex2dec(hexcodeColorCurrent((2*nDigitPerColor+1):(3*nDigitPerColor))) / normalizationFactor;
	end

	arrayRgb = [redColor,greenColor,blueColor]; 
end