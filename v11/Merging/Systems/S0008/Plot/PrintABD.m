
%% printing the ABD matrices in latex syntax
function PrintABD(A,B,D)
  jj = 1;
  decimals = '%.4E'; 
  tempArray = {A, B, D};
  for jj = 1:length(tempArray)
    fprintf('\n\\begin{align} \n')
    if jj == 1
      name = 'A';
    elseif jj == 2
      name = 'B';
    else
      name = 'D';
    end
    fprintf(['\\mathbf{' name '} =  \n'])
    fprintf('\\begin{bmatrix} \n')
    fprintf([num2str(tempArray{jj}(1,1),decimals) ' & ' num2str(tempArray{jj}(1,2),decimals) ' & ' num2str(tempArray{jj}(1,3),decimals) ' \\\\ \n'])
    fprintf([num2str(tempArray{jj}(2,1),decimals) ' & ' num2str(tempArray{jj}(2,2),decimals) ' & ' num2str(tempArray{jj}(2,3),decimals) ' \\\\ \n'])
    fprintf([num2str(tempArray{jj}(3,1),decimals) ' & ' num2str(tempArray{jj}(3,2),decimals) ' & ' num2str(tempArray{jj}(3,3),decimals) ' \n'])
    jj = jj + 1;
    fprintf('\\end{bmatrix} \n')
    fprintf('\\end{align} \n \n')
  end
  
end
