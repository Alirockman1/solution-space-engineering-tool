function [NewFilepath,NewFileName] = NameOfNewFileMerge(File1,File2,UserNewFileName,Type)
%Descirption : Name of the file after merging 2 files. The user will
%probably always give the name of the new file. If not the case, then the new file will just use the name of the 2 used files.
%Any type of file is accepted : CSV, Matlab, PPX, etc
%
%Input variables :
%File1, File2 : name of the 2 used files with the suffix '.csv', '.m', etc
%UserNewFileName : name of the file if user give one without the suffix '.csv', '.m', etc. User can let it empty : ''
%Type : type of file '.csv', '.m', etc
%
%Output variables :
%NewFilepath : path of the new file
%NewFileName : name of the file with the suffix '.csv', '.m', etc

    N = numel(Type); %length of '.csv', '.m', etc so that it can be removed
    FileName1 = dir(File1).name;
    FileName1 = FileName1(1:end-N); %remove the '.csv' or '.m', etc
    FileName2 = dir(File2).name;
    FileName2 = FileName2(1:end-N); %remove the '.csv' or '.m', etc
    Folder = dir(File1).folder;
    if UserNewFileName == ""
        NewFileName = join([FileName1,'+',FileName2,Type]); %creat name if user dont give name
    else
        NewFileName = join([UserNewFileName,Type]);
    end
    NewFilepath = join([Folder,'\',NewFileName]);
end