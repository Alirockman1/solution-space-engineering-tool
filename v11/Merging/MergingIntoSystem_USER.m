%USER
    CODEs = [{'MXXXX'},{'MXXXX'},{'MXXXX'},{'MXXXX'}];
    System_Name = 'Simple_Transmission';
    SampleSize = 500;
    
	cd ..
    Folder_Main = pwd;
    Folder_Systems = 'Merging\Systems';
    Folder_Database = 'Database';
    Folder_Merging_Algorithms = 'Merging\Merging_Algorithms';
    
%DONT TOUCH
    cd(Folder_Main);
    addpath(Folder_Merging_Algorithms);
    CSVFinal = MergingIntoSystem (CODEs,System_Name,Folder_Systems,Folder_Database,Folder_Merging_Algorithms,Folder_Main);
    
   