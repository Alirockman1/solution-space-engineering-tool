function [MatVar2,MatType2,MatColor2,Mat2] = AdequacyOrdering(MatVar1,MatVar2,MatType2,MatColor2,Mat2)
%Description : Ordering 2nd matrix in adequacy with first matrix
%
%Input variables :
%MatVar1: table with variable name of first CSV
%MatVar2: table with variable name of 2nd CSV
%MatType2: table with variable type of 2nd CSV
%MatColor2: table with variable color of 2nd CSV
%Mat2 : Matrix of the dependency graph of 2nd CSV
%
%Output variables :
%MatVar2: table with variable name
%MatType2: table with variable type
%MatColor2: table with variable color
%Mat2 : Matrix of the dependency graph
    
    N1 = numel(MatVar1);
    N2 = numel(MatVar2);
    Step2 = 0;                                  % Step2 = numbre of same variable in both matrices during algo (not a fixed variable)
    for i = N1:-1:1
        CellVar1 = table2cell(MatVar1);
        Letter1 = char(CellVar1(1,i));
        for j = (N2-Step2):-1:1
            CellVar2 = table2cell(MatVar2);
            Letter2 = char(CellVar2(1,j));
            if j == N2-Step2                    %Special condition for last position because not sure if function P1toP2Matrix works when P2 = P1
                if strcmp(Letter1,Letter2)
                    Step2 = Step2 + 1;
                end
            else
                if strcmp(Letter1,Letter2)
                    [MatVar2,MatType2,MatColor2] = P1toP2Tables(MatVar2,MatType2,MatColor2,j,N2-Step2);
                    [Mat2] = P1toP2Matrix (Mat2,j,N2-Step2);
                    Step2 = Step2 + 1;
                end
            end
        end
    end
end