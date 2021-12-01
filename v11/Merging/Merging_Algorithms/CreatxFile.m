function Matlabx = CreatxFile (System_Name_CSV,SampleSize,Folder_Design_Problems,Folder_Systems,Folder_Database,Folder_Merging_Algorithms,Folder_Main)
%Description :
%Creat the file for the X ray tool of the Model and save it in the XFile
%
%Input variables :
%Model : Name of the CSV file without '.csv' at the end
%SampleSize : Number of samples
%Folder_Systems : Folder with CSV and Matlab files of the systems
%Folder_Design_Problems : Folder with the X_ray tool file of the systems
%Folder_Database : Folder with all modular models
%Folder_Merging_Algorithms : Folder with all the algorithms
%
%Output variables :
%Matlabx : Name of the final Matlab file for the XRay tool

    %F_Intro
    cd(Folder_Main);
    addpath(Folder_Design_Problems);
 	addpath(Folder_Systems);
    addpath(Folder_Database);
    addpath(Folder_Merging_Algorithms);
    cd(Folder_Systems);
    
    %Go
    [MatVar,MatType,MatColor,Matrix] = CSV2MatrixAndTables(System_Name_CSV);
    [MatVar,MatType,MatColor] = deal (table2cell(MatVar),table2cell(MatType),table2cell(MatColor));
    [Input,~,Output] = TypeOfVariables(MatVar,Matrix);
    NInput = numel(Input);
    %NIntermediate = numel(Intermediate);
    NOutput = numel(Output);
    Matlabf = FromType1toType2(System_Name_CSV,'.csv','.m','f');   	%FileName
    Matlabx = FromType1toType2(System_Name_CSV,'.csv','.m','x');    %FileName    
    Matlabs = FromType1toType2(System_Name_CSV,'.csv','.m','s');    %FileName
    Text = fileread(Matlabf);
    MatlabWriter = fopen(Matlabx,'w+');
    %Preparation for the diagram code lines
    NDiagram = fix(NOutput/2);
    DiagramList = "[";
    for i = 1:NDiagram
        DiagramList = DiagramList + (i*2-1) + " " + (i*2) + ";";
    end
    DiagramList = DiagramList + "]";
    
    % Begining
    fprintf(MatlabWriter,'%s\n\n\n',"%% " + Matlabx);
    fprintf(MatlabWriter,'%s\n',"%% Code:");
    fprintf(MatlabWriter,'%s\n\t',"classdef " + Matlabx(1:end-2) + " < handle"); %title
    fprintf(MatlabWriter,'%s\n\n\t\t',"properties");                                       %properties
    fprintf(MatlabWriter,'%s\n\t\t',"%--------------------------------------------------");
    fprintf(MatlabWriter,'%s\n\t\t',"% Definitions of variables");
    fprintf(MatlabWriter,'%s\n\t\t',"%--------------------------------------------------");
    fprintf(MatlabWriter,'%s\n\t\t',"x=struct; % Design variables");
    fprintf(MatlabWriter,'%s\n\t\t',"y=struct; % Quantities of interest");
    fprintf(MatlabWriter,'%s\n\t\t',"p=struct;");
    fprintf(MatlabWriter,'%s\n\t\t',"index=struct;");
    fprintf(MatlabWriter,'%s\n\n\t\t',"samples=struct;");
    fprintf(MatlabWriter,'%s\n\t\t',"%--------------------------------------------------");
    fprintf(MatlabWriter,'%s\n\t\t',"% Input variables");
    fprintf(MatlabWriter,'%s\n\t\t',"%--------------------------------------------------");
    fprintf(MatlabWriter,'%s\n\t\t',"% Number of samples");
    fprintf(MatlabWriter,'%s\n\t\t',"sampleSize;");
    fprintf(MatlabWriter,'%s\n\t\t',"% Diagram list");
    fprintf(MatlabWriter,'%s\n\n\t\t',"diagram;");
    fprintf(MatlabWriter,'%s\n\t\t',"m; % Number of quantities of interest");
    fprintf(MatlabWriter,'%s\n\t\t',"d; % Number of design variables");
    fprintf(MatlabWriter,'%s\n\t\t',"np; % Number of parameters");
    fprintf(MatlabWriter,'%s\n\t\t',"k; % necessary for plot_m_x");
    fprintf(MatlabWriter,'%s\n\n\t\t',"b; % necessary for writeInputOutput");
    fprintf(MatlabWriter,'%s\n\t\t',"% Color of good designs");
    fprintf(MatlabWriter,'%s\n\n\t\t',"good_design_color='green';");
    fprintf(MatlabWriter,'%s\n\t\t',"% Line definiton for solution spaces");
    fprintf(MatlabWriter,'%s\n\t\t',"solutionspace_line_color='black';");
    fprintf(MatlabWriter,'%s\n\t\t',"solutionspace_line_width=2;");
    fprintf(MatlabWriter,'%s\n\n\t\t',"solutionspace_line_type='--';");
    fprintf(MatlabWriter,'%s\n\t\t',"% Legend text");
    fprintf(MatlabWriter,'%s\n\n\t\t',"legend;");
    fprintf(MatlabWriter,'%s\n\t\t',"% Filename of saved file");
    fprintf(MatlabWriter,'%s\n\t',"save_as = '" + Matlabs + "at';");
    fprintf(MatlabWriter,'%s\n\n\t',"end");
    % Methods
    fprintf(MatlabWriter,'%s\n\t\t',"methods");
    fprintf(MatlabWriter,'%s\n\n\t\t\t',"function obj = " + Matlabx(1:end-2) + "()");
    
    fprintf(MatlabWriter,'%s\n\n\t\t\t',"addpath('Data\Save');");
    
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"try");
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"load(obj.save_as);");
    fprintf(MatlabWriter,'%s\n\n\t\t\t',"obj = OBJ;");
    
    fprintf(MatlabWriter,'%s\n\n\t\t\t',"catch");
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"obj.sampleSize=" + SampleSize + ";");
    
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"% Choosing variables to be shown in the diagramms");
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"obj.diagram=" + DiagramList + ";");
    
    % Design variables
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"% Design variables");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"design_variables = {...");
%     fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"% Text design_variables  %'Name', 'Unit', 0, 1000;...");
    for i = 1:NInput
        for j = 1:numel(MatVar)
            if strcmp(Input(1,i),MatVar(1,j))
                TypeOfTheVar = MatType(1,j);
            end
        end
        fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"'" + Input(1,i) + "','" + TypeOfTheVar + "'," + "0" + "," + "100" + ";...");
    end
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"% Design variables 2");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"for i=1:size(design_variables,1)");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.x(i).name = design_variables{i,1};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.x(i).unit = design_variables{i,2};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.x(i).dsl = design_variables{i,3};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.x(i).dsu = design_variables{i,4};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.x(i).l = design_variables{i,3};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"obj.x(i).u = design_variables{i,4};");
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"end");
    
    % Quantities of interest
     fprintf(MatlabWriter,'%s\n\t\t\t\t',"% Quantities of interest");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"quantities_of_interest = {...");
%     fprintf(MatlabWriter,'%s\n\t\t\t\t',"% Text quantities_of_interest %'Name', 'Unit', 'color', 0, 320,1;...");
    for i = 1:NOutput
        for j = 1:numel(MatVar)
            if strcmp(Output(1,i),MatVar(1,j))
                TypeOfTheVar = MatType(1,j);
                ColorOfTheVar = MatColor(1,j);
            end
        end
        Outputi = Output(1,i);
        Type1 = join(['% ',Outputi{1,1},' =']);
        Position1 = regexp(Text,Type1,'end')+1;
        Text2 = Text(Position1:end);
        Position2 = regexp(Text2,"[",'start')-1;
        DescriptionVar = Text2(1:Position2(1,1));
        DescriptionVar = strtrim(DescriptionVar);   % remove leading and trailing whitespace
        % transforme color string into rgb format
        try
            [~,ColorOfTheVar_rgb] = colornames('SVG',ColorOfTheVar);
        catch
            ColorOfTheVar_rgb = [rand() 0 rand()];
            ColorOfTheVar_rgb(2) = min(ColorOfTheVar_rgb(1),ColorOfTheVar_rgb(3)) * rand();     % green ist the lightest color
        end
        
        fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"'" + Output(1,i) + "','" + TypeOfTheVar + "',[" + ColorOfTheVar_rgb(1) + " " + ColorOfTheVar_rgb(2) + " " + ColorOfTheVar_rgb(3) + "], " + "0" + ", " + "200" + ", " + "1" + ",'" + DescriptionVar + " is violated'" + ";...");
    end
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"% Quantities of interest 2");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"for i=1:size(quantities_of_interest,1)");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.y(i).name = quantities_of_interest{i,1};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.y(i).unit = quantities_of_interest{i,2};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.y(i).color = quantities_of_interest{i,3};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.y(i).l = quantities_of_interest{i,4};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.y(i).u = quantities_of_interest{i,5};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.y(i).active = quantities_of_interest{i,6};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"obj.y(i).condition = quantities_of_interest{i,7};");
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"end");
    
 	% Parameters
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"% Parameters");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"parameters = {...");
    %For now this is empty
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"% Text parameters %'Name','Unit',15.6;...");
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"% Parameters 2");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"for i=1:size(parameters,1)");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.p(i).name = parameters{i,1};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"obj.p(i).unit = parameters{i,2};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"obj.p(i).value = parameters{i,3};");
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"end");
    
    %Marker size
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"% Marker size of samples");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"obj.samples.marker.size = 10;");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"obj.samples.marker.type = '.';");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"obj.m=length(obj.y);");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"obj.d=length(obj.x);");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"if max(size(obj.p))>1");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"obj.np=length(obj.p);");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"else");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"obj.np = 0;");
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"end");
    % input of CreateLegend function
    fprintf(MatlabWriter,'%s\n\n\t\t\t\t',"obj.legend = CreateLegend(obj,obj.y); %Legende erstellen vereinfacht durch Steger");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"obj.k = 0;");
    fprintf(MatlabWriter,'%s\n\n\t\t\t',"obj.b = 0;");
    fprintf(MatlabWriter,'%s\n\n\t\t',"end");
    fprintf(MatlabWriter,'%s\n\n\t',"end");
    %end function obj = SXXXX
    
    % System response
    fprintf(MatlabWriter,'%s\n\t\t',"% Calculates system response");
    fprintf(MatlabWriter,'%s\n\n\t\t\t',"function [y] = SystemResponse(obj, x)");
        %Position of the folders
    fprintf(MatlabWriter,'%s\n\t\t\t',"% Paths");
    fprintf(MatlabWriter,'%s\n\t\t\t',"Folder_Actual = pwd;");
    fprintf(MatlabWriter,'%s\n\t\t\t',"cd ..");
    fprintf(MatlabWriter,'%s\n\t\t\t',"addpath('" + Folder_Database + "');");
    fprintf(MatlabWriter,'%s\n\t\t\t',"addpath('" + Folder_Systems + "');");
    fprintf(MatlabWriter,'%s\n\n\t\t\t',"cd(Folder_Actual)");
        %Function
%    fprintf(MatlabWriter,'%s\n\t\t\t',"y = zeros(obj.m, obj.sampleSize);");
    fprintf(MatlabWriter,'%s\n\t\t\t',"% Function :");
    fprintf(MatlabWriter,'%s',"[");
    for i = 1:NOutput
        fprintf(MatlabWriter,'%s',"y(" + i + ",:)");
        if i == NOutput
            fprintf(MatlabWriter,'%s',"]");
        else
            fprintf(MatlabWriter,'%s',",");
        end
    end
    fprintf(MatlabWriter,'%s'," = " + Matlabf(1:end-2) + "(");
    for i = 1:NInput
      	fprintf(MatlabWriter,'%s',"x(" + i + ",:)");
       	if i == NInput
            fprintf(MatlabWriter,'%s\n\n\t\t\t',");");
        else
            fprintf(MatlabWriter,'%s',",");
        end
    end
    fprintf(MatlabWriter,'%s\n\n\t\t',"writeInputOutput(obj); %Create Excel file with in- and output");
    fprintf(MatlabWriter,'%s\n\n\t\t',"end");
    
    %function legend = CreateLegend
    fprintf(MatlabWriter,'%s\n\t\t\t',"function legend = CreateLegend(obj,y)");
    fprintf(MatlabWriter,'%s\n\t\t\t',"legend = {'{\color{green} \bullet }Good design'};");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"for i=1:obj.m");
    fprintf(MatlabWriter,'%s\n\t\t\t\t\t',"if obj.y(i).active == 1");
    fprintf(MatlabWriter,'%s\n\t\t\t\t',"legend{end+1}=strcat('{\color[rgb]{',num2str(y(i).color),']} \bullet }', y(i).condition);");
    fprintf(MatlabWriter,'%s\n\t\t\t',"end");
    fprintf(MatlabWriter,'%s\n\t\t',"end");
    fprintf(MatlabWriter,'%s\n\t',"end");
    fprintf(MatlabWriter,'%s\n',"end");	%end methods
    fprintf(MatlabWriter,'%s',"end");   %end classdef
    
    %closing the writing
    fclose(MatlabWriter);
    
   	%final position in Folder_Design_Problems
    cd(Folder_Main)
    cd(Folder_Design_Problems)
    Folder_Design_Problems2 = pwd;
    cd(Folder_Main);
    cd(Folder_Systems);
    copyfile(Matlabx,Folder_Design_Problems2);
    
    delete (Matlabx);
    
    %F_Outro
    cd(Folder_Main)
end