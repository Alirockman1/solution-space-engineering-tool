function CSV3 = Merging2CSV (CSV1,CSV2,FileName,Folder_Database,Folder_Merging_Algorithms,Folder_Main)
%Description : Merging of 2 DSM saved  in 2 CSV file into a new CSV file (it is regrouping the different subalgorithms which make this biggest part of the work)
%
%Input variables :
%CSV1 : name of the first csv file with '.csv'
%CSV2 : name of the second csv file with '.csv'
%FileName : Name of the new merged csv file without '.csv'
%Folder_Database : Folder with all modular models
%Folder_Merging_Algorithms : Folder with all the algorithms
%
%Output variables :
%CSV3 : path of the merged CSV file with '.csv'    

    %F_Intro
    cd(Folder_Main);
    addpath(Folder_Database);
    addpath(Folder_Merging_Algorithms);
    cd(Folder_Database);
    
    % Code
    [MatVar1,MatType1,MatColor1,Mat1] = CSV2MatrixAndTables(CSV1);
    [MatVar2,MatType2,MatColor2,Mat2] = CSV2MatrixAndTables(CSV2);
    [MatVar2,MatType2,MatColor2,Mat2] = AdequacyOrdering(MatVar1,MatVar2,MatType2,MatColor2,Mat2); % Reorder 2nd in logic with 1st
    [MatVar,MatType,MatColor,Mat] = Merging2DSM (MatVar1,MatType1,MatColor1,Mat1,MatVar2,MatType2,MatColor2,Mat2);
    [MatVar,MatType,MatColor,Mat] = DSMSequencing (MatVar,MatType,MatColor,Mat);
    FinalMat = CombineTablesInCells (MatVar,MatType,MatColor,Mat);
    [CSV3path,CSV3] = NameOfNewFileMerge(CSV1,CSV2,FileName,'.csv');
    writecell(FinalMat,CSV3path); %Save new dependency graph in CSV File

    %F_Outro
    cd(Folder_Main)
end