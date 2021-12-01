%USER
    System_Name_CSV = 'S0001_a_TransmissionXXX.csv';
    SampleSize = 500;
    
    cd ..
    Folder_Main = pwd;
    Folder_Design_Problems = 'XRay\Data\Design_Problems';
    Folder_Systems = 'Merging\Systems';
    Folder_Database = 'Database';
    Folder_Merging_Algorithms = 'Merging\Merging_Algorithms';
    
%DONT TOUCH
    cd(Folder_Main);
    addpath(Folder_Merging_Algorithms);
    Matlabx = CreatxFile (System_Name_CSV,SampleSize,Folder_Design_Problems,Folder_Systems,Folder_Database,Folder_Merging_Algorithms,Folder_Main);
    
   