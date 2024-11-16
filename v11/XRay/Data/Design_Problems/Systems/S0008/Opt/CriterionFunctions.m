% Copyright Erik Lund, Aalborg University, email: el@mp.aau.dk
% The m-file is supplied for the PhD course "Analysis and Gradient Based
% Optimization of Laminated Composite Structures"

function [ O ] = CriterionFunctions(G, A, O);

%********************************************************
% File: CriterionFunctions.m

%   This function computes the criterion functions and their derivatives.
%
% Syntax:
%   [ O ] = CriterionFunctions(G, O, A);
%
% Input:
%   G  : Global data
%   A  : Analysis data
%   O  : Optimization data
%
% Output:
%   O           : Optimization data
%
% Revisions:
%   Version 1.0    02.12.2015   Erik Lund


% Calculate compliance and compliance sensitivities
[O] = Compliance(G, A, O, 0);
[O] = Compliance(G, A, O, O.DSAMode);

% Calculate mass and mass sensitivity
[O] = Mass(G, O, 0);
[O] = Mass(G, O, O.DSAMode);
