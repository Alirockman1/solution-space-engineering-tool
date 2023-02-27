%% S0012_x_cfkIter3.m
% Template generated automatically
% 
classdef S0012_x_cfkIter3 < handle
    properties
		%--------------------------------------------------
		% Definitions of variables
		%--------------------------------------------------
		x=struct; % Design variables
		y=struct; % Quantities of interest
		p=struct;
		index=struct;
		samples=struct;

		%--------------------------------------------------
		% Input variables
		%--------------------------------------------------
		% Number of samples
		sampleSize;
		% Diagram list
		diagram;

		m; % Number of quantities of interest
		d; % Number of design variables
		np; % Number of parameters
		k; % necessary for plot_m_x
		b; % necessary for writeInputOutput

		% Color of good designs
		good_design_color='green';

		% Line definiton for solution spaces
		solutionspace_line_color='black';
		solutionspace_line_width=2;
		solutionspace_line_type='--';

		% Legend text
		legend;

		% Filename of saved file
		save_as = 'S0012_x_cfkIter3.mat';
	end

    methods
		function obj = S0012_x_cfkIter3()
			addpath('Data\Save');
			try
				load(obj.save_as);
				obj = OBJ;
			catch
               obj.sampleSize=1000;         

               % Design variables
               design_variables = {...
                   '\alpha_1','°',-90,90,-90,90;...
                   '\alpha_2','°',-90,90,-90,90;...
                   '\alpha_3','°',-90,90,-90,90;...
                   '\alpha_4','°',-90,90,-90,90;...
                   '\alpha_5','°',-90,90,-90,90;...
                   '\alpha_6','°',-90,90,-90,90;...
                   };
               % Cell to structure
               for i=1:size(design_variables,1)
                   obj.x(i).name = design_variables{i,1};
                   obj.x(i).unit = design_variables{i,2};
                   obj.x(i).dsl = design_variables{i,3};
                   obj.x(i).dsu = design_variables{i,4};
                   obj.x(i).l = design_variables{i,5};
                   obj.x(i).u = design_variables{i,6};
               end

               % Choosing variables to be shown in the diagramms
               obj.diagram=[...
                   nchoosek(1:size(design_variables,1),2);... % all combinations
                   ];

               % Quantities of interest
               quantities_of_interest = {...
                   'f','mm',[0.356863,0.607843,0.835294],-Inf,5,1,'Deflection is too high';...
                   't','mm',[0.929412,0.490196,0.192157],0,5,1,'Laminate too thick';...
                   '\xi','°',[0.647059,0.647059,0.647059],-5,1,1,'Deflection angle violated';...
                   };
               % Cell to structure
               for i=1:size(quantities_of_interest,1)
                   obj.y(i).name = quantities_of_interest{i,1};
                   obj.y(i).unit = quantities_of_interest{i,2};
                   obj.y(i).color = quantities_of_interest{i,3};
                   obj.y(i).l = quantities_of_interest{i,4};
                   obj.y(i).u = quantities_of_interest{i,5};
                   obj.y(i).active = quantities_of_interest{i,6};
                   obj.y(i).condition = quantities_of_interest{i,7};
               end

               % Parameters
               parameters = {...
                   };
               % Cell to structure
               for i=1:size(parameters,1)
                   obj.p(i).name = parameters{i,1};
                   obj.p(i).unit = parameters{i,2};
                   obj.p(i).value = parameters{i,3};
               end

               % Marker size of samples
               obj.samples.marker.size = 10;
               obj.samples.marker.type = '.';
               obj.m=length(obj.y);
               obj.d=length(obj.x);
               if max(size(obj.p))>1
                   obj.np=length(obj.p);
               else
                   obj.np = 0;
               end
               obj.legend = CreateLegend(obj,obj.y); %Legende erstellen vereinfacht durch Steger
               obj.k = 0;
               obj.b = 0;
           end
       end

       % Calculates system response
		function [y] = SystemResponse(obj, x, param)
			% Paths
			Folder_Actual = pwd;
			cd ..
			addpath('Database');
			addpath('Merging\Systems');
			cd(Folder_Actual)

			% Function :
			y = S0012_f_cfkIter3(x,param);
			writeInputOutput(obj); %Create Excel file with in- and output
		end

		function legend = CreateLegend(obj,y)
			legend = {'{\color{green} \bullet }Good design'};
			for i=1:obj.m
				if obj.y(i).active == 1
					legend{end+1}=strcat('{\color[rgb]{',num2str(y(i).color),']} \bullet }', y(i).condition);
				end
			end
		end
	end
end
