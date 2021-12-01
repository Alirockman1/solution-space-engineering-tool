function [NewFilepath] = NameOfNewCSVFile(OldFile,Suffix)
%Description : Naming of the new CSV file by adding a suffix (used for
%sequencing a simple CSV file
%
%Input variables :
%OldFile : the csv file
%Suffix : name of the new file by adding a suffix (if empty = replace file)
%
%Output variables :
%NewFilepath : new csv file path and also name with '.csv'

    FileName = dir(OldFile).name;
    FileName = FileName(1:end-4);
    Folder = dir(OldFile).folder;
    if Suffix == ""
        NewFileName = join([FileName,'.csv'],'');
    else
        NewFileName = join([FileName,Suffix,'.csv'],'');
    end
    NewFilepath = join([Folder,'\',NewFileName],'');
end