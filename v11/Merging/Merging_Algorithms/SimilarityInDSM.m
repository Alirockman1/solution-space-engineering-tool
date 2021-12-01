function [PositionDb1,PositionUnik1,PositionDb2,PositionUnik2] =  SimilarityInDSM(Cell1,Cell2)
%Description : Give the position of variables that are present in Cell 1
%and Cell 2 and the one that are only in Cell1 and the one that are only in
%Cell2
%
%Input variables :
%Cell1 : variables of first DSM
%Cell2 : variables of second DSM
%
%Output Variables :
%PositionDb1,PositionDb2 : position of variables that are present in Cell1 / Cell2
%PositionUnik1, PositionUnik2 : position of variables that are only in Cell1 / Cell2

    [PositionDb1,PositionUnik1] = SimilaritiesInDSMFor2ndCell(Cell2,Cell1); %Positions in Cellule1
    [PositionDb2,PositionUnik2] = SimilaritiesInDSMFor2ndCell(Cell1,Cell2); %Positions in Cellule2
end