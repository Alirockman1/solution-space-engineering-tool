function selectedFunction = select_function(projectRoot)
%SELECT_FUNCTION Lists and selects a function from the Systems folder.
%
%   selectedFunction = SELECT_FUNCTION(projectRoot) scans the 'Systems'
%   subdirectory within the given projectRoot for all available MATLAB
%   function files (*.m), displays them in a numbered list, and prompts
%   the user to select one by entering its corresponding number.
%
%   The function returns a function handle to the selected MATLAB function,
%   allowing it to be called programmatically using standard syntax:
%       selectedFunction(); 
%       result = selectedFunction(args);
%
%   INPUT:
%       projectRoot - A string or character vector specifying the root
%                     directory of the project.
%
%   OUTPUT:
%       selectedFunction - A function handle to the selected .m file
%
%   Example:
%       f = select_function('C:\MyProject');
%       f();  % Calls the selected function
%
%   Note:
%       The selected file must define a valid MATLAB function (not a script).
%       This function assumes the 'Systems' folder exists under projectRoot.

    % Define the folder path for available functions (dynamically set)
    folderPath = fullfile(projectRoot, 'Systems');
    
    % Get all .m files in the folder
    mFiles = dir(fullfile(folderPath, '*.m'));
    
    % Check if the folder contains any .m files
    if isempty(mFiles)
        disp('No MATLAB (.m) files found in the specified folder.');
    else
        % Print the names of all .m files with numbering
        disp('The available list of functions are:');
        for i = 1:length(mFiles)
            % Remove the .m extension and display the numbered function name
            [~, functionName, ~] = fileparts(mFiles(i).name);
            fprintf('%d. %s\n', i, functionName);
        end
        
        % Prompt the user to input the number of the function they want to select
        selectedNumber = input('Please enter the number of the function you want to select: ');
        
        % Ensure the input is valid
        if selectedNumber >= 1 && selectedNumber <= length(mFiles)
            selectedFunction = mFiles(selectedNumber).name(1:end-2);           % Get function name without extension
            fprintf('You have selected function: %s\n', selectedFunction);
        else
            disp('Invalid selection. Please enter a valid number.');
        end
    end
    
    selectedFunction = str2func(mFiles(selectedNumber).name(1:end-2));         % Create a function handle directly
end