function [NewVar,NewType,NewColor] = P1toP2Tables(OldVar,OldType,OldColor,P1,P2)
%Description : Reorder the variable name table + variable type table + variable color table when change variable position from Position 1
%to position 2 (P1<P2 always).
%This algorithm is linked with P1toP2Matrix.m
%
%Input variables : 
%OldVar : table of variable names
%OldType : table of variable type
%OldColor : table of variable color
%P1 : Initial position of variable
%P2 : Final position of variable
%
%Output variables :
%NewVar : new table of variable names after ordering
%NewType : new table of variable type after ordering
%NewColor : new table of variable color after ordering

    N = numel(OldVar);
    NewVar = OldVar;
    NewType = OldType;
    NewColor = OldColor;
    % first part : variable in P1 go to position P2
    NewVar(1,P2) = OldVar(1,P1);                     %1 for variable name
    NewType(1,P2) = OldType(1,P1);                   %1 for variable type
    NewColor(1,P2) = OldColor(1,P1);                 %1 for variable color
    % second part : variables before P1 don't move
    if P1 ~= 1
        NewVar(1,1:P1-1) = OldVar(1,1:P1-1);         %2 for variable name
        NewType(1,1:P1-1) = OldType(1,1:P1-1);       %2 for variable type
        NewColor(1,1:P1-1) = OldColor(1,1:P1-1);     %2 for variable color
    end
    % third part : variables after P2 don't move
    if P2 ~= N
        NewVar(1,P2+1:N) = OldVar(1,P2+1:N);         %3 for variable name
        NewType(1,P2+1:N) = OldType(1,P2+1:N);       %3 for variable type
        NewColor(1,P2+1:N) = OldColor(1,P2+1:N);     %3 for variable color
    end
    % last part : variable between P1 and P2 move one position on the left
    NewVar(1,P1:P2-1) = OldVar(1,P1+1:P2);           %4 for variable name
    NewType(1,P1:P2-1) = OldType(1,P1+1:P2);         %4 for variable type
    NewColor(1,P1:P2-1) = OldColor(1,P1+1:P2);       %4 for variable color
end