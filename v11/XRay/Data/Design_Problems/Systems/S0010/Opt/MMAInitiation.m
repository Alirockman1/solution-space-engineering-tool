% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [m,n,IterNo,xval,xmin,xmax,xold1,xold2, ...
f0val,df0dx,fval,dfdx,low,upp,a0,a,c,d] = MMAInitiation(G,O,ConvTol,x)

%   m    = The number of general constraints.
m = 1;
%   n    = The number of variables x_j.
n = O.nDesVar;
%  IterNo  = Current iteration number ( =1 the first time mmasub is called).
IterNo = 1;
%  xval  = Column vector with the current values of the variables x_j.
xval = x(:);
%  xmin  = Column vector with the lower bounds for the variables x_j.
xmin = O.Lower(1:O.nDesVar);
%  xmax  = Column vector with the upper bounds for the variables x_j.
xmax = O.Upper(1:O.nDesVar);
%  xold1 = xval, one iteration ago (provided that iter>1).
xold1 = xval;
%  xold2 = xval, two iterations ago (provided that iter>2).
xold2 = xval; 
%  f0val = The value of the objective function f_0 at xval.
f0val = 1; %%%%% Is calculated later...;
%  df0dx = Column vector with the derivatives of the objective function
%          f_0 with respect to the variables x_j, calculated at xval.
df0dx = zeros(n,1); %%%%% Is calculated later...
%  fval  = Column vector with the values of the constraint functions f_i,
%          calculated at xval.
fval = 0; %%%%% Is calculated later...;
%  dfdx  = (m x n)-matrix with the derivatives of the constraint functions
%          f_i with respect to the variables x_j, calculated at xval.
%          dfdx(i,j) = the derivative of f_i with respect to x_j.
dfdx = zeros(1,n); %%%%% Is calculated later...;
%  low   = Column vector with the lower asymptotes from the previous
%          iteration (provided that iter>1).
low = xmin;
%  upp   = Column vector with the upper asymptotes from the previous
%          iteration (provided that iter>1).
upp = xmax;
%  a0    = The constants a_0 in the term a_0*z.
a0 = 1;
%  a     = Column vector with the constants a_i in the terms a_i*z.
a = 0;
%  c     = Column vector with the constants c_i in the terms c_i*y_i.
c = 1000;
%  d     = Column vector with the constants d_i in the terms
%  0.5*d_i*(y_i)^2.
d = 0;
