% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [A] = SolveStatic(G, A)

% This function solves the static analysis problem, i.e. assembles the 
% global system matrix, and solves the system of equations.
% Input:  G : Global data
%         A : Analysis data including A.F containing loads
% Output: A : A.K, A.i, A.j, A.Kij and A.U (displacements)

% We loop over all finite elements and assemble the sparse stiffness matrix A.K.
[A] = AssembleK(G, A);

% We solve the algebraic system of equations
% The stiffness matrix is factored using default matrix decomposition
A.KFactored = decomposition(A.K(A.FreeDOFs,A.FreeDOFs)); 
% The static equilibrium equations are solved
A.U(A.FreeDOFs,:) = A.KFactored \ A.F(A.FreeDOFs,:);
A.U(A.FixedDOFs,:)= 0.0;

% Alternative solution procedure without factorization
% A.U(A.FreeDOFs,:) = A.K(A.FreeDOFs,A.FreeDOFs) \ A.F(A.FreeDOFs,:);      
% A.U(A.FixedDOFs,:)= 0.0;
