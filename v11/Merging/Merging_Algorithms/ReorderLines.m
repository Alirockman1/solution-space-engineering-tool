function M = ReorderLines (CSVFileName,FunctionInputVariables,~,~,Folder_Database,Folder_Merging_Algorithms)
%Description : Put the models functions inside the global system matlab file in the good order
%
%Input variables :
%CSVFileName : Name of the global system csv file without '.csv'
%FunctionInputVariables : list of the input variables of the global system
%Folder_Database : Position of the csv file
%Folder_Merging_Algorithms : Folder with all the algorithms
%
%Output variables : output is useless in our algorithm. Can be changed
%M : not assigned and useless    

    %F_Intro
    ActualFolder = pwd;
    addpath(Folder_Database);
    addpath(Folder_Merging_Algorithms);
    cd(Folder_Database);
    
    %start
    FileV0 = join([CSVFileName,'.csv']);
    FileV = FromType1toType2(FileV0,'.csv','.m','f');
    FileT = fileread(FileV);
    NewFile = fopen(FileV,'w+');
    DelimiterList = regexp(FileT,FileV(1:end-2),'end');
    Delimiter1 = DelimiterList(1,end);
    DelimiterList = regexp(FileT(Delimiter1:end),')','end')-1;
    Delimiter2 = DelimiterList(1,1);
    FirstPart = FileT(1:Delimiter1+Delimiter2);
    SecondPart = FileT(Delimiter1+Delimiter2:end);
    
    fprintf(NewFile,'%s\n\t',FirstPart);
    
    DelimiterList1 = regexp(SecondPart,'[','start');
    DelimiterList2 = regexp(SecondPart,';','end');
    
    NLine = numel(DelimiterList2);
    LineList = cell(3,NLine);
    for i = 1:NLine
        LineT = SecondPart(DelimiterList1(1,i):DelimiterList2(1,i));
        LineList{1,i} = LineT;
        
     	De1 = regexp(LineT,'= ','end')+1;
        De2 = regexp(LineT,' (','start')-1;
        FunctionName = LineT(De1:De2);
        if isempty(FunctionName)
            De2 = regexp(LineT,'(','start')-1;
            FunctionName = LineT(De1:De2);
        end
        
        MatlabName = join([FunctionName,'.m']);
        CSVName = FromType1toType2(MatlabName,'.m','.csv','a');
        [MatVar,~,~,Mat] = CSV2MatrixAndTables(CSVName);
        [Input,~,Output] = TypeOfVariables (MatVar,Mat);
        Input2 = table2cell(Input);
        Output2 = table2cell(Output);
        LineList{2,i} = Input2;
        LineList{3,i} = Output2;
    end
    
    InputAndIntermediateVariables = FunctionInputVariables; 
    %InputAndIntermediateVariables = list of all input variables and in the while loop we will add to this variable the
    %output variables of each function that are intermediate variables of
    %the global system.
    
    h=0;
    while h < NLine-1
        i = 1;
        while i <= NLine-h
            ListInputi = LineList{2,i};
            Ni = numel(ListInputi);
            Autorize = 0;
            for j = 1:Ni
                if any(strcmp(ListInputi{1,j},InputAndIntermediateVariables))  %looking if the Inputvariable taken is already existing in the FunctionInputVariables 
                    Autorize = Autorize +1;
                end
            end
            if Autorize == Ni  %If all Inputvariables of function are existing in the FunctionInputVariables than we have this equality
                fprintf(NewFile,'%s\n\t',LineList{1,i});
                InputAndIntermediateVariables = [InputAndIntermediateVariables LineList{3,i}];
                LineList(:,i) = [];
                h=h+1;
                if NLine-h ==1  %Need this to ignore the last line to copy (last line to copy will be done outside the while loop
                    i = i+1;
                end
            else
                i = i+1;
            end
        end
    end
    
    fprintf(NewFile,'%s\n',LineList{1,1});
    
    fprintf(NewFile,'%s','end');
    
    fclose(NewFile);

    %F_Outro
    cd(ActualFolder)
end