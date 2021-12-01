function VerifVar = OneVarIn2ndList (List1,List2)
%Description : Check if there is at least 1 variable of first list in the
%second list. 
%
%Input variables :
%List1 : list of variables to check
%List2 : list of variables to see if it is inside
%
%Output variables :
%VerifVar : Is equal to 1 if there is at least 1 variable of first list in
%the second list. else equal to 0

    VerifVar = 0;
    N = numel(List1);
    for i = 1:N
        VerifList = strcmp(List1(1,i),List2); %Look if the variable is equal to one of the variable of the second list
        FinalVerif = sum(VerifList); %if the variable is present in second list, one of the variable of the VerifList variable is equal to 1
        if FinalVerif ~= 0 %the variable is present in second list
            VerifVar = 1;
        end
    end
end