function [NewMat] = P1toP2Matrix (OldMat,P1,P2) %P2>P1 !
%Description : Reorder matrix when change variable position from Position 1
% to position 2 (P1<P2 always).
% Explanation in Nicky Rostan Master Thesis
% This algorithm is linked with P1toP2Tables.m
%
%Input variables :
%OldMat : the matrix in question
%P1 : Initial position of the variable to move
%P2 : Final position of the variable to move
%
%Output variables :
%NewMat : The matrix after moving a variable position.

    N = sqrt(numel(OldMat));
    NewMat = zeros(N);
    if (P1 ~= 1 && P2 ~= N)
        NewMat(P2+1:N,1:P1-1) = OldMat(P2+1:N,1:P1-1);      %2
        NewMat(1:P1-1,P2+1:N) = OldMat(1:P1-1,P2+1:N);      %3
    end
    if P1 ~= 1
        NewMat(1:P1-1,1:P1-1) = OldMat(1:P1-1,1:P1-1);      %1
        NewMat(1:P1-1,P1:P2-1) = OldMat(1:P1-1,P1+1:P2);    %5
        NewMat(1:P1-1,P2) = OldMat(1:P1-1,P1);              %6
        NewMat(P1:P2-1,1:P1-1) = OldMat(P1+1:P2,1:P1-1);    %9
        NewMat(P2,1:P1-1) = OldMat(P1,1:P1-1);              %11
    end
    if P2 ~= N
        NewMat(P2+1:N,P2+1:N) = OldMat(P2+1:N,P2+1:N);      %4
        NewMat(P2+1:N,P1:P2-1) = OldMat(P2+1:N,P1+1:P2);    %7
        NewMat(P2+1:N,P2) = OldMat(P2+1:N,P1);              %8
        NewMat(P1:P2-1,P2+1:N) = OldMat(P1+1:P2,P2+1:N);    %10
        NewMat(P2,P2+1:N) = OldMat(P1,P2+1:N);              %12
    end
    NewMat(P1:P2-1,P2) = OldMat(P1+1:P2,P1);                %13
    NewMat(P1:P2-1,P1:P2-1) = OldMat(P1+1:P2,P1+1:P2);      %14
    NewMat(P2,P1:P2-1) = OldMat(P1,P1+1:P2);                %15
    NewMat(P2,P2) = OldMat(P1,P1);                          %16
end