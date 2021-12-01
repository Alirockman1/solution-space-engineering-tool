function [Input3,Intermediate3,Output3] = Merging2Matlab(Model1,Model2,Model3,Folder_Database,Folder_Merging_Algorithms,Folder_Main) %without '.csv' at the end !
%Description : Merging 2 matlab file of 2 models into a merged file (no ordering system)
%
%Input variables :
%Model1 : CSV file of first model without '.csv'
%Model2 : CSV file of second model without '.csv'
%Model3 : CSV file of merged model without '.csv'
%
%Output variables :
%Input3 : list of input variables of the merged model
%Intermediate3 : list of intermediate variables of the merged model
%Output3 : list of output variables of the merged model
    
    %F_Intro
    cd(Folder_Main);
    addpath(Folder_Database);
    addpath(Folder_Merging_Algorithms);
    cd(Folder_Database);
    
    %Code
    CSV1 = join([Model1,'.csv']);
    CSV2 = join([Model2,'.csv']);
    CSV3 = join([Model3,'.csv']);
    % 2 Functions to merge.
    [MatVar1,MatType1,MatColor1,Matrix1] = CSV2MatrixAndTables(CSV1);
    [MatVar2,MatType2,MatColor2,Matrix2] = CSV2MatrixAndTables(CSV2);
    [MatVar3,MatType3,MatColor3,Matrix3] = CSV2MatrixAndTables(CSV3);
    [MatVar1,MatType1,MatColor1] = deal (table2cell(MatVar1),table2cell(MatType1),table2cell(MatColor1));
    [MatVar2,MatType2,MatColor2] = deal (table2cell(MatVar2),table2cell(MatType2),table2cell(MatColor2));
    [MatVar3,~,~] = deal (table2cell(MatVar3),table2cell(MatType3),table2cell(MatColor3));
    % Input, Intermediates, Outputs
    [Input1,~,~] = TypeOfVariables(MatVar1,Matrix1);
    [Input3,Intermediate3,Output3] = TypeOfVariables(MatVar3,Matrix3);
    
    VerifVar = OneVarIn2ndList (Input1,Intermediate3);
    %if in 1st CSV file Inputs are Intermediate variables of the final system. Then need to change position of both matrix by inverse them and the files
    if VerifVar == 1 %That is when VerifVar = 1
        [MatVarA,MatTypeA,MatColorA,MatA] = deal(MatVar2,MatType2,MatColor2,Matrix2);
        [MatVar2,~,~,~] = deal(MatVar1,MatType1,MatColor1,Matrix1);
        [MatVar1,~,~,~] = deal(MatVarA,MatTypeA,MatColorA,MatA);
        CSVA = CSV2;
        CSV2 = CSV1;
        CSV1 = CSVA;
    end
    %Now File1/CSV1 is first !
    
    %Creating  .m file name from .csv
    Matlab1 = FromType1toType2(CSV1,'.csv','.m','f');    %FileName
    Matlab2 = FromType1toType2(CSV2,'.csv','.m','f');    %FileName
    %TXT3 = FromType1toType2(CSV3,'.csv','.txt','f');%FileName
    Matlab3 = FromType1toType2(CSV3,'.csv','.m','f');
    Text1 = fileread(Matlab1);    
    Text2 = fileread(Matlab2);
    Matlab3Writer = fopen(Matlab3,'w+');
    
    %START OF WRITTING THE NEW FILE
    fprintf(Matlab3Writer,'%s\n\n\n',"%% " + Matlab3);	%title
    fprintf(Matlab3Writer,'%s\n',"%% Discription:");	%description
    
    [~,UnikInMatVar2] = VariablesOfList2inList1orNot(MatVar1,MatVar2);
    VariableList = [MatVar1 UnikInMatVar2];

    %Input
    Text_input = WriteVariableDescription (Text1,Text2,'',Matlab3Writer,VariableList,Input3,'Input','Intermediate');
    % Intermediate
    WriteVariableDescription (Text1,Text2,Text_input,Matlab3Writer,VariableList,Intermediate3,'Intermediate','Output');
    % Output
   	WriteVariableDescription (Text1,Text2,'',Matlab3Writer,VariableList,Output3,'Output','Example');
    
    % Example
   	fprintf(Matlab3Writer,'\n%s\n\n',"% Example:");

    % Formula
    fprintf(Matlab3Writer,'\n%s\n\n',"%% Formula:");
    
    % Code
    fprintf(Matlab3Writer,'\n%s\n',"%% Code:");
    %Function line
    fprintf(Matlab3Writer,'%s',"function [");
    Noutput3 = numel(Output3);
    for i = 1:Noutput3
        Var = string(Output3(1,i));
        fprintf(Matlab3Writer,'%s',Var);
        if i < Noutput3
            fprintf(Matlab3Writer,'%s',",");
        else
            FunctionTitel = Matlab3(1:end-2);
            fprintf(Matlab3Writer,'%s',join(['] = ',FunctionTitel,' (']));
        end
    end
    Ninput3 = numel(Input3);
    for i = 1:Ninput3
        Var = string(Input3(1,i));
        fprintf(Matlab3Writer,'%s',Var);
        if i < Ninput3
            fprintf(Matlab3Writer,'%s',",");
        else
            fprintf(Matlab3Writer,'%s\n',")");
        end
    end
    %functions and main part
    Text1_functionline_p1 = regexp(Text1,'function [','end');
    Text1_functionline_p2 = regexp(Text1(Text1_functionline_p1:end),')','start')-1;
    Text1_functionline = join([Text1(Text1_functionline_p1:Text1_functionline_p1 + Text1_functionline_p2),';']);
    Text2_functionline_p1 = regexp(Text2,'function [','end');
    Text2_functionline_p2 = regexp(Text2(Text2_functionline_p1:end),')','start')-1;
    Text2_functionline = join([Text2(Text2_functionline_p1:Text2_functionline_p1 + Text2_functionline_p2),';']);
    fprintf(Matlab3Writer,'\t%s\n',Text1_functionline);
    fprintf(Matlab3Writer,'\t%s\n',Text2_functionline);
    %end
    fprintf(Matlab3Writer,'%s',"end");
    fclose(Matlab3Writer);
   
    %F_Outro
    cd(Folder_Main)
end