function ActualV = ReplaceTemporaryLineCode (OldTempoFile,ModelFile,ActualTempoFile,Folder_Database,Folder_Merging_Algorithms) %New = qui vient d'etre créé, Old le temporary d'avant
%Description: Inside the actual temporary file the function temporaryfile
%of previous temporary file need to be replace what is inside (functions of
%models)
%
%Input variables :
%OldTempoFile : CSV file without '.csv' of the previous Temporary file
%ModelFile : CSV file without '.csv' of the added model
%ActualFile : CSV file without '.csv' of the actual temporary file
%Folder_Database : Position of the csv file
%Folder_Merging_Algorithms : Folder with all the algorithms
%
%Output variables : output is useless in our algorithm. Can be changed
%ActualV : ActualFile with '.csv'    

    %F_Intro
    ActualFolder = pwd;
    addpath(Folder_Database);
    addpath(Folder_Merging_Algorithms);
    cd(Folder_Database);
    
    OldV = join([OldTempoFile,'.csv']);    
    ActualV = join([ActualTempoFile,'.csv']);
    ModelV = join([ModelFile,'.csv']);
    OldV = FromType1toType2(OldV,'.csv','.m','f');
    ActualV = FromType1toType2(ActualV,'.csv','.m','f');
    ModelV = FromType1toType2(ModelV,'.csv','.m','f');
    OldT = fileread(OldV);
    ActualT = fileread(ActualV);
    NewFile = fopen(ActualV,'w+');
    
    FunctionDelimiter1 = regexp(ActualT,'function [','start');
    FunctionDelimiter2 = regexp(ActualT(FunctionDelimiter1:end),')','end')-1;
    FirstPart = ActualT(1:FunctionDelimiter1+FunctionDelimiter2);
    SecondPart = ActualT(FunctionDelimiter1+FunctionDelimiter2:end);
    
    fprintf(NewFile,'%s\n\t',FirstPart);
    
    TemporarysearchList = regexp(OldT,OldV(1:end-1),'end');  %I dont know why "end-1" and not "end-2"
    Temporarysearch = TemporarysearchList(1,end);
    EndOldT = OldT(Temporarysearch:end);
    
    TemporaryBeginList = regexp(EndOldT,'[','start');
    TemporaryFinishList = regexp(EndOldT,';','end');
    N = numel(TemporaryBeginList);
    for i = 1:N
        Line = EndOldT(TemporaryBeginList(1,i):TemporaryFinishList(1,i));
        fprintf(NewFile,'%s\n\t',Line);
    end
    
    Modelsearch = regexp(SecondPart,ModelV(1:end-2),'start');
    ModelBefore = SecondPart(1:Modelsearch);
    ModelAfter = SecondPart(Modelsearch:end);
    ModelBeginList = regexp(ModelBefore,'[','start');
    ModelEndList = regexp(ModelAfter,';','end');
    ModelBegin = ModelBeginList(1,end);
    ModelEnd = ModelEndList(1,1);
    Line = SecondPart(ModelBegin : Modelsearch + ModelEnd -1);
    fprintf(NewFile,'%s\n',Line);
    
    fprintf(NewFile,'%s','end');
    
    fclose(NewFile);
    
    %F_Outro
    cd(ActualFolder)
end