function [MatVar,MatType,MatColor,Matrix] = CSV2MatrixAndTables(CSV)
%Descirption : From csv file to 3 lines (variable name, variable type and
%variable color) + matrix of DSM
%
%Input variables :
%CSV : csv file with '.csv'
%Folder : folder where the csv file is saved
%
%Output variables :
%MatVar : 1: table with variable name
%MatType : 1: table with variable type
%MatColor : 1: table with variable color
%Mat : Matrix of the DSM

    MatAll = readtable (CSV,'ReadVariableNames',false);
    MatVar = MatAll(1,:); %table of variable name
    MatType = MatAll(2,:); %table of Variable type linked to variable
    MatColor = MatAll(3,:); %table of color linked to variable
    Matrix = table2array(readtable(CSV,'HeaderLines',3)); %dependency matrix
end