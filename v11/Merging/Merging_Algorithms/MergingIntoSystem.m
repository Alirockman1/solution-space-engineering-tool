function CSVFinal = MergingIntoSystem (CODEs,System_Name,Folder_Systems,Folder_Database,Folder_Merging_Algorithms,Folder_Main) 
%Description : Merging models into the global system with DSM Sequencing and
%system function depending of the models function in a matlab file
%
%Input variables :
%CODEs : list of code of the modular models used in the system (which are
%going to be merged. THE FORMAT SHOULD BE : [{'MXXXX'},{'MXXXX'},{'MXXXX'},{'MXXXX'}]
%System_Name : name of the system (without "SXXXX_a_" and ".csv")
%TemporaryFolder : name of the folder for the algorithm. Can be a random name (will be creat and deleted in the algorithm was important for the programming work)
%Folder_Systems : Folder with CSV and Matlab files of the systems
%Folder_Database : Folder with all modular models
%Folder_Merging_Algorithms : Folder with all the algorithms
%
%Output variables : output is useless in our algorithm. Can be changed
%CSVFinal : name of the CSV file of the merged system
%
%CODEs format : [{'MXXXX'},{'MXXXX'},{'MXXXX'},{'MXXXX'}]
%system name format : SystemName_a_ThisForm (without .csv)    

    %F_Intro
    cd(Folder_Main)
 	addpath(Folder_Systems);
    addpath(Folder_Database);
    addpath(Folder_Merging_Algorithms);
    
    % Creat TemporaryFolder
    cd(Folder_Main);
    cd(Folder_Merging_Algorithms);
    cd ..
    TemporaryFolderName = 'temp_Simple_Transmission';
    mkdir (TemporaryFolderName)
    cd(TemporaryFolderName);
    Folder_Temporary = pwd;
    %Folder_Temporary = fullfile(Folder_Main,TemporaryFolder);
    
    % Cd
    cd(Folder_Main);
    cd(Folder_Systems);
    
    % From SystemName to SXXXX_a_SystemName
    %Listing all the already used numbers
    FileList = dir('*.csv');
    List = {};
    List = [List, FileList.name];
    for i = 1:numel(List)
        Intermedi = List{1,i};
        List{1,i} = str2double(Intermedi(2:5));
    end
    List2 = cell2mat(List);
    j = 0;
    k = 1;
    %Loop to find the empty number that is going to be used
    while j == 0
        Empty1 = isempty(find(List2 == k)); %#ok<EFIND>
        if Empty1
            j = 1;
        else
            k = k + 1;
        end
    end
    %add the zeros
    k2 = int2str(k);
    if k < 10
        Number = join(['000',k2]);
    else
        if k < 100
            Number = join(['00',k2]);
        else
            if k < 1000
                Number = join(['0',k2]);
            else
                Number = join(['',k2]);
            end
        end
    end
    %   Join everything in the final name
    SystemName_a_ThisForm = join(['S',Number,'_a_',System_Name]);

    % Cd
    cd(Folder_Main)
    cd(Folder_Database)
    
    % CODEs = cellstr(CODEs);
    N = numel(CODEs);
    MATs = CODEs;
    CSVs = CODEs;
    MODELs = CODEs;
    TEMPOs = CODEs;
    for i = 1:N
        Coded = join([CODEs{1,i},'*']);
        MATs{1,i} = dir(join([Coded,'.m'])).name;
        CSVs{1,i} = dir(join([Coded,'.csv'])).name;
        MODELs{1,i} = CSVs{1,i}(1:end-4);
        copyfile(MATs{1,i},Folder_Temporary);
        copyfile(CSVs{1,i},Folder_Temporary);
        TEMPOs{1,i} = join(['TXXXX_a_Temporary',num2str(i)]);
    end
    
    cd(Folder_Main)
    %Explanation in DSM Paper or Nicky's master thesis
    Merging2Models(MODELs{1,1},MODELs{1,2},TEMPOs{1,1},Folder_Temporary,Folder_Merging_Algorithms,Folder_Main);
    if N > 2
        for i = 3:N
            if i == N
                TEMPOs{1,i-1} = SystemName_a_ThisForm;
            end
            [InputVariables,IntermediateVariables,OutputVariables] = Merging2Models(TEMPOs{1,i-2},MODELs{1,i},TEMPOs{1,i-1},Folder_Temporary,Folder_Merging_Algorithms,Folder_Main);
            ReplaceTemporaryLineCode(TEMPOs{1,i-2},MODELs{1,i},TEMPOs{1,i-1},Folder_Temporary,Folder_Merging_Algorithms);
        end
    end
    
    %Here reorder
    ReorderLines(SystemName_a_ThisForm,InputVariables,IntermediateVariables,OutputVariables,Folder_Temporary,Folder_Merging_Algorithms);
    
    %rename with _f_
    cd(Folder_Main)
    cd(Folder_Temporary)
    CSVFinal = join([SystemName_a_ThisForm,'.csv']);
    MATFinal = FromType1toType2(CSVFinal,'.csv','.m','f');
    
    %final position in SystemsFolder
    cd(Folder_Main)
    cd(Folder_Systems)
    Folder_Systems2 = pwd;
    
    cd(Folder_Main)
    cd(Folder_Temporary)
    
    copyfile(CSVFinal,Folder_Systems2);
    copyfile(MATFinal,Folder_Systems2);
    
    %delete TemporaryFolder
    cd(Folder_Main)
    cd(Folder_Merging_Algorithms);
    cd ..
    try
        rmdir(TemporaryFolderName,'s');
    catch
        warning('Deleting of temporary folder could not be performed due to not existing access permissions. Please delete temporary folder!')
    end
    
    %F_Outro
    cd(Folder_Main)
end