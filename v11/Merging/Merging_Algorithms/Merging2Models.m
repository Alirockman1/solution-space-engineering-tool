function [InputVariables,IntermediateVariables,OutputVariables] = Merging2Models(Model1,Model2,MergedModel,Folder_Database,Folder_Merging_Algorithms,Folder_Main) %FileName : not with the .type of file !!!  
%Description : Merging 2 models (CSV+matlab file but without ordering system)
%(this algo is just regrouping sub algorithms which make the big part of the work)
%
%Input variables :
%Model1 : name of CSV file of the first model without '.csv'
%Model2 : name of CSV file of the second model without '.csv'
%MergedModel : Name of the new merged csv file without '.csv'
%Folder_Database : Folder with all modular models
%Folder_Merging_Algorithms : Folder with all the algorithms
%
%Output variables
%InputVariables : list of the input varialbes of the new merged model
%IntermediateVariables : list of the intermediate varialbes of the new merged model
%OutputVariables : list of the output varialbes of the new merged model

    %F_Intro
    cd(Folder_Main);
    addpath(Folder_Database);
    addpath(Folder_Merging_Algorithms);
    cd(Folder_Database);
    
    %go
    CSV1 = join([Model1,'.csv']);
    CSV2 = join([Model2,'.csv']);
    % Reorder CSV inputs in case it's not ordered
%     CSVSequencing(CSV1,"",DataFolder,FunctionsFolder);
%     CSVSequencing(CSV2,"",DataFolder,FunctionsFolder);
    
    % Merging 2 CSV in a 3rd one with name of it. Nothing more
    CSV3 = Merging2CSV(CSV1,CSV2,MergedModel,Folder_Database,Folder_Merging_Algorithms,Folder_Main);
    
    % Merging 2 matlab files in 3rd one. You need the CSV of final model
    Model3 = CSV3(1:end-4);
    [InputVariables,IntermediateVariables,OutputVariables] = Merging2Matlab(Model1,Model2,Model3,Folder_Database,Folder_Merging_Algorithms,Folder_Main);
    
    %F_Outro
    cd(Folder_Main)
end