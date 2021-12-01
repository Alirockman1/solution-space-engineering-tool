%USER
    CODEs = [{'M0004'},{'M0002'},{'M0003'},{'M0001'}];
    System_Name = 'Simple_Transmission';
    SampleSize = 500;
    
    Folder_Design_Problems = 'C:\Users\Nicky\Desktop\Exchange folder\04_Design_Space_Projection_Tool\v08_Final\03_XRay\Data\Design_Problems';
    Folder_Systems = 'C:\Users\Nicky\Desktop\Exchange folder\04_Design_Space_Projection_Tool\v08_Final\02_Merging\Systems';
    Folder_Database = 'C:\Users\Nicky\Desktop\Exchange folder\04_Design_Space_Projection_Tool\v08_Final\01_Database';
    Folder_Merging_Algorithms = 'C:\Users\Nicky\Desktop\Exchange folder\04_Design_Space_Projection_Tool\v08_Final\02_Merging\Merging_Algorithms';

%DONT TOUCH
    addpath(Folder_Merging_Algorithms);
    [MATFinal,Matlabx] = System_XRay_From_Models(CODEs,System_Name,SampleSize,Folder_Design_Problems,Folder_Systems,Folder_Database,Folder_Merging_Algorithms)
    