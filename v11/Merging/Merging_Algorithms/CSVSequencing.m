function NewFile = CSVSequencing (CSV,Suffix,Folder_Database,Folder_Merging_Algorithms,Folder_Main) %write with simple quotes : 'CSV' and not "CSV" !
%Description : Reorganize a CSV file
%
%Input variables :
%CSV : csv file name with '.csv'
%Suffix : name of the new file is the name of the old file + suffix or if suffix empty replace file
%Folder_Database : Position of the csv file
%Folder_Merging_Algorithms : Folder with all the algorithms
%
%Output variables :
%NewFile : reordered csv file name with '.csv'    

    %F_Intro
    cd(Folder_Main);
    addpath(Folder_Database);
    addpath(Folder_Merging_Algorithms);
    cd(Folder_Database);
    
    [MatVar,MatType,MatColor,Matrix] = CSV2MatrixAndTables(CSV); %Creat the 3 table+matrix for the rest of the algorithm
    [MatVar,MatType,MatColor,Matrix] = DSMSequencing (MatVar,MatType,MatColor,Matrix); %Modification process
    FinalMat = CombineTablesInCells (MatVar,MatType,MatColor,Matrix); %is needed to combine the matrix with the variable/Type/color tables because of compatibilities (maybe there is a better solution than using cells)
    NewFile = NameOfNewCSVFile (CSV,Suffix); %suffix given to new file if given, else the CSVFile will be directly edited
    writecell(FinalMat,NewFile);
    
    %F_Outro
    cd(Folder_Main)
end