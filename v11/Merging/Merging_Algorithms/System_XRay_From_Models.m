function [CSVFinal,Matlabx] = System_XRay_From_Models(CODEs,System_Name,SampleSize,Folder_Design_Problems,Folder_Systems,Folder_Database,Folder_Merging_Algorithms,Folder_Main)
%Description :
%Merging of models into a global system with a Sequenced DSM in a CSV file
%+ function of the system in a Matlab file and another Matlab file ready to
%be used in the XRay tool.
%
%Input variables :
%CODEs : list of code of the modular models used in the system (which are
%going to be merged. THE FORMAT SHOULD BE : [{'MXXXX'},{'MXXXX'},{'MXXXX'},{'MXXXX'}]
%System_Name : Name of the System (without "SXXXX_a_" and ".csv")
%TemporaryFolder : name of the folder for the algorithm. Can be a random name (will be creat and deleted in the algorithm was important for the programming work)
%SampleSize : Number of samples
%Folder_Design_Problems : Folder with the X_ray tool file of the systems
%Folder_Systems : Folder with CSV and Matlab files of the systems
%Folder_Database : Folder with all modular models
%Folder_Merging_Algorithms : Folder with all the algorithms
%
%Output variables :
%MATFinal : name of Final Matlab File with the system global function
%Matlabx : Name of the final Matlab file for the XRay tool 

	%F_Intro
    cd(Folder_Main);
    addpath(Folder_Design_Problems);
    addpath(Folder_Systems);
    addpath(Folder_Database);
    addpath(Folder_Merging_Algorithms);
    cd(Folder_Systems);
    
    %merging
    CSVFinal = MergingIntoSystem (CODEs,System_Name,Folder_Systems,Folder_Database,Folder_Merging_Algorithms,Folder_Main);
    %Creation of the file for the XRay tool
    
    Matlabx = CreatxFile (CSVFinal,SampleSize,Folder_Design_Problems,Folder_Systems,Folder_Database,Folder_Merging_Algorithms,Folder_Main);
    
 	%F_Outro
    cd(Folder_Main)
    
end