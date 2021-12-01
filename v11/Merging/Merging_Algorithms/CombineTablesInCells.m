function [FinalCell] = CombineTablesInCells (MatVar,MatType,MatColor,Matrix)
%Descirption : Combine the table of variable, type, color and the matrix
%into a big cell
%
%Input variables :
%MatVar : 1: table with variable name
%MatType : 1: table with variable type
%MatColor : 1: table with variable color
%Matrix : Matrix of the DSM
%
%Output variables : FinalCell : The Combined Cell with variables,type,Color and matrix

    TableMatrix = array2table(Matrix,'VariableNames',MatVar.Properties.VariableNames);	%transform the matrix in table
    CellMatrix = table2cell(TableMatrix);                                                 % Transform table in cell
    CellVar = table2cell(MatVar);                                                           % Transform table in cell
    CellType = table2cell(MatType);                                                         % Transform table in cell
    CellColor = table2cell(MatColor);                                                       % Transform table in cell
    FinalCell = [CellVar ; CellType ; CellColor ; CellMatrix];                              %Merging the cells (can't do it with tables)
end