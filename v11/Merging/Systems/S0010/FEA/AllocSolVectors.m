% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [A] = AllocSolVectors(A)

% This function allocates the main vectors needed for the static FE
% solution.
% Input:  A     : Analysis data
% Output: A.F and A.U

% Allocate basic vectors: A.F is the load vector and A.U is the global 
% displacement vector. Both vectors contain both free and prescribed
% values.
A.F = zeros(A.nDOFs,1);
A.U = zeros(A.nDOFs,1);

