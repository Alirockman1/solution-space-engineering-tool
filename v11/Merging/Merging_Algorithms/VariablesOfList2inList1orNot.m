function [InList1,NotInList1] = VariablesOfList2inList1orNot(List1,List2)
%Description : Give the variable of list 2 that are in list 1 and the
%variable of list 2 that aren't in list 1 in 2 differend lists
%
%Input variables :
%List1 : First List
%List2 : Second List
%
%Output variables :
%InList1 : List of variable of list2 that are in list 1
%NotInList1 : List of variable of list2 that aren't in list 1

    InList1 = [];
    NotInList1 = [];
    N = numel(List2);
    for i = 1:N
        VerifList = strcmp(List2(1,i),List1); %analyze if variable is in list 1 or not
        FinalVerif = sum(VerifList); 
        if FinalVerif == 0 %If this is verified then variable is not in list 1 (the sum is equal to 0)
            NotInList1 = [NotInList1 List2(1,i)];
        else
            InList1 = [InList1 List2(1,i)];
        end
    end
end