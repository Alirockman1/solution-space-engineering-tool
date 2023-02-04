% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [N] = ShapeFunc9(r, s)

% Shape functions 9 node
N9 = (1-r^2)*(1-s^2);
N8 = 0.5*(1-r)*(1-s^2)-0.5*N9;
N7 = 0.5*(1-r^2)*(1+s)-0.5*N9;
N6 = 0.5*(1+r)*(1-s^2)-0.5*N9;
N5 = 0.5*(1-r^2)*(1-s)-0.5*N9;
N4 = 0.25*(1-r)*(1+s)-0.5*(N7+N8)-0.25*N9;
N3 = 0.25*(1+r)*(1+s)-0.5*(N6+N7)-0.25*N9;
N2 = 0.25*(1+r)*(1-s)-0.5*(N5+N6)-0.25*N9;
N1 = 0.25*(1-r)*(1-s)-0.5*(N8+N5)-0.25*N9; 
N = [N1 N2 N3 N4 N5 N6 N7 N8 N9];
