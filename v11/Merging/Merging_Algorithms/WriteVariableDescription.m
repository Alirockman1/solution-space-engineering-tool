function Text = WriteVariableDescription (Text1,Text2,TextForIntermediate,Matlabfile,AllVariablesList,AnalyzedVariablesList,VariableType,NextVariableType)
%Description : Write in the Matlabfile the description of the variables of
%the AnalyzedVariablesList (it will be the input, intermediate or output
%variables of the model)
%
%Input variables :
%Text1 : Matlabfile of the first model
%Text2 : Matlabfile of the second model
%TextForIntermediate : use for the intermediate variables
%Matlabfile : Name of the new 
%AllVariablesList : list of all variables of the model
%AnalyzedVariablesList : list of variables that are of the Type
%VariableType : Type of variables group (input,intermediate or output variables)
%NextVariableType : Type of the next variables group (input,intermediate or output variables)
%
%The 2 last variables -> we use this to help the algorithm to see the begining
%and the end of the text to analyze -> only the input/intermediate/output variables
%
%Output Variables :
%Text : the text that is written in the Matlabfile during the algorithm    
    Type1 = join(['% ',VariableType,':']); %begining of the type of variables (input,intermediate or output variables)
    Type2 = join(['% ',NextVariableType,':']); %end of the type of variables (input,intermediate or output variables)
    fprintf(Matlabfile,'\n%s\n',Type1);
    Text1_p1 = regexp(Text1,Type1,'end')+1; %take the position in the text1 of the word Type1
    Text1_p2 = regexp(Text1,Type2,'start')-1; %take the position in the text1 of the word Type2
    Text1_2 = Text1(Text1_p1:Text1_p2);  %take only the text between the 2 limits (Text1_p1 and Text1_p2)
    Text2_p1 = regexp(Text2,Type1,'end')+1;
    Text2_p2 = regexp(Text2,Type2,'start')-1;
    Text2_2 = Text2(Text2_p1:Text2_p2);
    Text = join([Text1_2,Text2_2,TextForIntermediate]); 
    %Text = Merging the texts of the 2 input models with the variables description
    %Intermediate of total system are : the intermediate of 1 and 2 but also the inputs that become intermediate when merging
    N = numel(AnalyzedVariablesList);
    if N > 0
        for i = 1:N
            Variable = AnalyzedVariablesList{1,i};
            VariableT = join(['% ',Variable,' =']); % variable (+ '% ' and ' =') to search in the Text
            if any(strcmp(Variable,AllVariablesList)) % If the variable is listed in all variables list, write the description in the new Matlabfile
                Text_p1 = regexp(Text,VariableT,'start');
                Text_p1 = Text_p1(1,1);
                Text_p2 = regexp(Text(Text_p1:end),']','start');
                fprintf(Matlabfile,'%s\n', Text(Text_p1:Text_p1 + Text_p2)); %writing in the new file
            end
        end
    end
end