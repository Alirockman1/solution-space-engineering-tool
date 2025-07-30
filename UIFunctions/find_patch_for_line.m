function patchHandle = find_patch_for_line(lineHandle, allPatches)
%FINDPATCHFORLINE Finds the patch associated with a given line.
%
%   patchHandle = findPatchForLine(lineHandle, allPatches) searches through the
%   array of patch handles `allPatches` and returns the patch whose UserData
%   field `line` matches the input `lineHandle`.
%
%   Note:
%       Returns empty if no matching patch is found.
%
%   Copyright 2025 Eduardo Rodrigues Della Noce (Supervisor)
%   Copyright 2025 Ali Abbas Kapadia (Main Author)
%   SPDX-License-Identifier: Apache-2.0

    patchHandle = [];
    for p = allPatches'
        ud = get(p, 'UserData');
        if isstruct(ud) && isfield(ud, 'line') && isequal(ud.line, lineHandle)
            patchHandle = p;
            return;
        end
    end
end