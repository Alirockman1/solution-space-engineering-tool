function [PositionDb,PositionUnik] = SimilaritiesInDSMFor2ndCell(Cell1,Cell2) %Positions in Cell2
%Description : Give the position in Cell2 of variables that are present in Cell 1 and Cell 2 and the one that are only in Cell2
%
%Input variables :
%Cell1 : Variables of first DSM
%Cell2 : Variables of second DSM
%
%Output Variables :
%PositionDb : position of variables that are present in Cell 1 and Cell2
%PositionUnik : position of variables that are only in Cell 2

    CellDb = [];
    CellUnik = [];
    for i = 1:numel(Cell2)
        Detector = 0;
        for j = 1:numel(Cell1)
            if strcmp(Cell2(i),Cell1(j))
                CellDb = [CellDb i];  %Can be optimize : change size of a array to add new data take a lot of time. better if use already a table with the exact size
                Detector = 1;
            end
        end
        if Detector == 0
            CellUnik = [CellUnik i]; %to optimize
        end
    end
    PositionDb = CellDb; %Positions in Cell2
    PositionUnik = CellUnik; %Positions in Cell2
end