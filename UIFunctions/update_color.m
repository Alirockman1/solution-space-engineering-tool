%% Function to save colour of QOI
function update_color(src,dataManager,variableIteration)
    dataManager.QOIs(variableIteration).color = [src.Value, zeros(1, 6)];
end