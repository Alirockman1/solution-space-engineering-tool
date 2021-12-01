function [Input,Intermediate,Output] = TypeOfVariables(MatVar,Matrix)
%Description : Give the type of variable of the variables of the DSM. The
%type can be input, intermediate or output variable
%
%Input Variables :
%MatVar : list of variable of the DSM
%Matrix : matrix of the DSM (order respected of course)
%
%Output Variables :
%Input : list of variable that are input variables
%Intermediate : list of variable that are intermediate variables
%Output : list of variable that are output variables

    Input = [];
    Intermediate = [];
    Output = [];
    N=numel(MatVar);
    Sums1 = sum(Matrix);
    Sums2 = sum(Matrix,2);
    for i = 1:N
        if Sums1(i) == 0  %if the column is full of 0 it is a input variable of the model
            Input = [Input MatVar(1,i)];
        end
        if Sums2(i) == 0 %if the row is full of 0 it is a output variable of the model
            Output = [Output MatVar(1,i)];
        end
        if Sums1(i) ~= 0 && Sums2(i) ~= 0 % if there is no 0 in row and column (at least a 1) it's a intermediate variable of the model
            Intermediate = [Intermediate MatVar(1,i)];
        end
    end
end