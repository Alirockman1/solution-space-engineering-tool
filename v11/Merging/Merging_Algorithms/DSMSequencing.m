function [MatVar,MatType,MatColor,Matrix] = DSMSequencing (MatVar,MatType,MatColor,Matrix)
%Description : Sequencing of a DSM (inputs are the matrix + the 3 tables
%with name type and color of variable)
%
%Input variables :
%Matrix : Matrix of the dependency graph
%MatVar : 1: table with variable name
%MatType : 1: table with variable type
%MatColor : 1: table with variable color
%
%Output variables :
%Matrix : Matrix of the dependency graph
%MatVar : 1: table with variable name
%MatType : 1: table with variable type
%MatColor : 1: table with variable color

    StepCounting = 0;   %StepCounting is counting the number of line that are respecting the rule underdiagonal is full of zero starting from the end of the matrix
    NbOfVar = numel(MatVar);
    while StepCounting < NbOfVar
        Step = StepCounting;    % When a line is correct, we interest ourself with the matrix of smaller dimension (NbOfVar-Step)
        for i = NbOfVar-Step:-1:1   % Always starting from the last line end go up
            LineAnalyzed = Matrix(i,1:NbOfVar-Step);
            SumZeros = sum(LineAnalyzed,2);
            if SumZeros == 0                    % If full of 0 : line respect rule : add 1 to the variable StepCounting after the following if
                if i < NbOfVar - StepCounting   % this is verified when at least one line before has a 1. So this line is put at the end of the small matrix end all other line are pushed 1 line at the top
                  	[MatVar,MatType,MatColor] = P1toP2Tables(MatVar,MatType,MatColor,i,NbOfVar-Step); %Move the line to the last line of the small matrix, lines between P1 and P2 are pushed 1 line at the top
                  	Matrix = P1toP2Matrix (Matrix,i,NbOfVar-Step); 
                end
                StepCounting = StepCounting + 1;
            end
        end
    end
end