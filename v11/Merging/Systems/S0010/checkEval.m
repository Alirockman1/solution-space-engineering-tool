clear
close all
clc

addpath('FEA','Opt','Plot');

A = cfkEval([10 -10], [0 4e-3 ], 1);