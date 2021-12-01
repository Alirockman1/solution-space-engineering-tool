%USER
    CSV1 = 'MXXXX_a_1.csv';
    CSV2 = 'MXXXX_a_2.csv';
    MergedModel_Name = 'SXXXX_a_3.csv';
    
	cd ..
    Folder_Main = pwd;
    Folder_Database = 'Database';
    Folder_Merging_Algorithms = 'Merging\Merging_Algorithms';

%DONT TOUCH
    cd(Folder_Main);
    addpath(Folder_Merging_Algorithms);
    Model1 = CSV1(1:end-4);
    Model2 = CSV2(1:end-4);
    MergedModel = MergedModel_Name(1:end-4);
    [InputVariables,IntermediateVariables,OutputVariables] = Merging2Models(Model1,Model2,MergedModel,DataFolder,FunctionsFolder,Folder_Main);
    
    
   