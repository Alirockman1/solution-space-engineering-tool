%USER
    CODEs = [{'M0001'},{'M0002'},{'M0003'}];
    System_Name = '5d_Crash_Problem';
    SampleSize = 3000;
   
    cd ..
    Folder_Main = pwd;
    Folder_Design_Problems = 'XRay\Data\Design_Problems';
    Folder_Systems = 'Merging\Systems';
    Folder_Database = 'Database';
    Folder_Merging_Algorithms = 'Merging\Merging_Algorithms';

%DONT TOUCH
    cd(Folder_Main);
    addpath(Folder_Merging_Algorithms);
    [CSVFinal,Matlabx] = System_XRay_From_Models(CODEs,System_Name,SampleSize,Folder_Design_Problems,Folder_Systems,Folder_Database,Folder_Merging_Algorithms,Folder_Main)
    