function [MatVar,MatType,MatColor,Matrix] = Merging2DSM(MatVar1,MatType1,MatColor1,Matrix1,MatVar2,MatType2,MatColor2,Matrix2)
%Description : Merging 2DSM into a new DSM -> only the tables and matrices,
%the creation of the CSV file and rename file is done in another algorithm.
%
%Input variables : 
%MatVar1,MatVar2 : variable name table of CSV file 1 and 2
%MatType1,MatType2 : variable type table of CSV file 1 and 2
%MatColor1,MatColor2 : variable color table of CSV file 1 and 2
%Matrix1,Matrix2 : DSM of CSV file 1 and 2
%
%Output variables :
%MatVar : variable name table of merged DSM
%MatType : variable type table of merged DSM
%MatColor : variable color table of merged DSM
%Matrix : DSM of merged DSM

    NbVar1 = numel(MatVar1);
    %Next from table to cells because impossible to manipulate what's inside a table
    CellVar1 = table2cell (MatVar1);
    CellVar2 = table2cell (MatVar2);
    CellType1 = table2cell (MatType1);
    CellType2 = table2cell (MatType2);
    CellColor1 = table2cell (MatColor1);
    CellColor2 = table2cell (MatColor2);
    [PositionDouble1,PositionUnique1,PositionDouble2,PositionUnique2] = SimilarityInDSM(CellVar1,CellVar2); %Output are cells
    %Next steps : add unique variables of 2nd DSM to the variables of 1st DSM
    %(variable name + variable type + variable color)
    CellVar = [CellVar1 CellVar2(PositionUnique2)];
    CellType = [CellType1 CellType2(PositionUnique2)];
    CellColor = [CellColor1 CellColor2(PositionUnique2)];
    NbVar = numel(CellVar);
    MatVar = cell2table(CellVar);
    MatType = cell2table(CellType,'VariableNames',MatVar.Properties.VariableNames);
    MatColor = cell2table(CellColor,'VariableNames',MatVar.Properties.VariableNames);
    
    %Start of merging the matrix
    Matrix = zeros(NbVar); %Creat the new matrix full of zeros
    %First Part
    %Copy first DSM into new DSM
    Matrix(PositionUnique1,1:NbVar1) = Matrix1(PositionUnique1,1:NbVar1); % Step 1.a. line of Variable which are only in matrice 1
    Matrix(1:NbVar1,PositionUnique1) = Matrix1(1:NbVar1,PositionUnique1) ;% Step 1.b. Column of Variable which are only in matrice 1
    %If input and output variables are in both DSM : take max -> 1 if there is a dependency in one of the 2 matrices
    Matrix(PositionDouble1,PositionDouble1) = max(Matrix1(PositionDouble1,PositionDouble1),Matrix2(PositionDouble2,PositionDouble2));
    %Second Part
    %Input and output variables are only in 2nd variable
    Matrix(NbVar1+1:NbVar,NbVar1+1:NbVar)= Matrix2(PositionUnique2,PositionUnique2);
    %third Part
    %Inputvariables are only in 2nd DSM and Outputvariables are in both
    Matrix(NbVar1+1:NbVar,PositionDouble1) = Matrix2(PositionUnique2,PositionDouble2);
    %fourth Part
    %Outputvariables are only in 2nd DSM and Inputvariables are in both
    Matrix(PositionDouble1,NbVar1+1:NbVar) = Matrix2(PositionDouble2,PositionUnique2);

% Alternative version with matlab graph objects
% % create digraph objects of DSM 1 and 2
% CellVar1 = transpose(table2cell(MatVar1));
% CellType1 = transpose(table2cell(MatType1));
% CellColor1 = transpose(table2cell(MatColor1));
% 
% CellVar2 = transpose(table2cell(MatVar2));
% CellType2 = transpose(table2cell(MatType2));
% CellColor2 = transpose(table2cell(MatColor2));
% 
% NodeTable_1 = table(CellVar1,CellType1,CellColor1,'VariableNames',{'Name' 'Unit' 'Color'});
% NodeTable_2 = table(CellVar2,CellType2,CellColor2,'VariableNames',{'Name' 'Unit' 'Color'});
% 
% DSM_1 = digraph(Matrix1,NodeTable_1);
% DSM_2 = digraph(Matrix2,NodeTable_2);
% 
% DSM_2_unique = DSM_2;
% remove_from_DSM_2 = [];
% 
% % remove nodes which are in DSM 1 from DSM 2
% for i = 1:numnodes(DSM_1)
%     for j = 1:numnodes(DSM_2_unique)
%         
%         if strcmp(char(DSM_1.Nodes.Name(i)), char(DSM_2_unique.Nodes.Name(j)))
%             
%             remove_from_DSM_2 = [remove_from_DSM_2 j];
%             
%         end
%     end
% end
% DSM_2_unique = rmnode(DSM_2_unique,remove_from_DSM_2);
% 
% % merge the two digraphs
% DSM_3 = mergedigraphs(DSM_1,DSM_2);
% 
% % create new table for the nodes in DSM 3 because mergedigraphs just takes
% % the names of the nodes of DSM 1 and 2
% NodeTable_3 = table(DSM_3.Nodes.Name(:,1),cell(numnodes(DSM_3),1),cell(numnodes(DSM_3),1),'VariableNames',{'Name' 'Unit' 'Color'});
% 
% for i = 1:numnodes(DSM_3)
%     for j = 1:numnodes(DSM_1)
%         if strcmp(char(DSM_3.Nodes.Name(i)), char(DSM_1.Nodes.Name(j)))
%             
%             NodeTable_3.Unit(i) = DSM_1.Nodes.Unit(j);
%             NodeTable_3.Color(i) = DSM_1.Nodes.Color(j);
%             
%         end
%     end
%     
%     for k = 1:numnodes(DSM_2_unique)
%         if strcmp(char(DSM_3.Nodes.Name(i)), char(DSM_2_unique.Nodes.Name(k)))
%             
%             NodeTable_3.Unit(i) = DSM_2_unique.Nodes.Unit(k);
%             NodeTable_3.Color(i) = DSM_2_unique.Nodes.Color(k);
%             
%         end
%     end
% end
% 
% DSM_3.Nodes = NodeTable_3;
% 
% % write outputs in correct style (table and matrix)
% MatVar = cell2table(transpose(DSM_3.Nodes.Name));
% MatType = cell2table(transpose(DSM_3.Nodes.Unit));
% MatColor = cell2table(transpose(DSM_3.Nodes.Color));
% Matrix = full(adjacency(DSM_3));


end