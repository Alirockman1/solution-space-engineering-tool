% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [A] = DecompositionExample(G, A)

% Example of solution procedure using factorization (matrix decomposition).
% The factored matrix may then be reused when having several right-hand-sides.

% We loop over all finite elements and assemble the sparse stiffness matrix A.K.
[A] = AssembleK(G, A);

% Example with 10 right-hand-sides stored in A.P(:,i)
A.P = zeros(A.nDOFs,10);
for i = 1:10
  A.P(:,i) = A.F;
end

% Measure time for matrix factorization and forward-backward substitution
tic
% The stiffness matrix is factored using default matrix decomposition
A.KFactored = decomposition(A.K(A.FreeDOFs,A.FreeDOFs)); 
% The static equilibrium equations are solved
A.U(A.FreeDOFs,1) = A.KFactored \ A.P(A.FreeDOFs,1);
A.U(A.FixedDOFs,1)= 0.0;
toc

% Measure time for forward-backward substitution when reusing the factored
% stiffness matrix
for i = 1:10
  tic
  A.U(A.FreeDOFs,i) = A.KFactored \ A.P(A.FreeDOFs,i);
  A.U(A.FixedDOFs,i)= 0.0;
  toc
end
