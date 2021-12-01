%USER
    Model_Name_CSV = 'MXXXX_a_Simple_Transmission.csv';
    Suffix = SEQUENCED;
    
    cd ..
    Folder_Main = pwd;
    Folder_Database = 'Database';
    Folder_Merging_Algorithms = 'Merging\Merging_Algorithms';

%DONT TOUCH
    cd(Folder_Main);
    addpath(Folder_Merging_Algorithms);
    NewFile = CSVSequencing (Model_Name_CSV,Suffix,Folder_Database,Folder_Merging_Algorithms,Folder_Main);   