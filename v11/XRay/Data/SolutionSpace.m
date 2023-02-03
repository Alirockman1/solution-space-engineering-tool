function SolutionSpace(control_panel_figure)

% ===
%figure_menubar_height = 83;
% ===


% ===
figure_menubar_height_1 = 31;
figure_menubar_height_2 = 80;
% ===


screensize = get( groot, 'Screensize' );
contr_position = get(control_panel_figure,'position'); %control_panel_figure_position

% icon for axes toolbar
[img,map] = imread(fullfile(matlabroot,'toolbox','matlab','icons','paintbrush.gif'));
icon = ind2rgb(img,map);


%define sizes

if screensize(4)-contr_position(2)-contr_position(4)-figure_menubar_height_1-figure_menubar_height_2<=200
    height = 200;
    bottom = screensize(4)-height;
else
    height = screensize(4)-contr_position(2)-contr_position(4)-figure_menubar_height_1-figure_menubar_height_2;
    bottom = contr_position(2)+contr_position(4)+figure_menubar_height_1;
end

% set violation visibility in user interface to default
    for i = 1:size(control_panel_figure.UserData.y,2)
    
        checkbox = findall(control_panel_figure,'Tag',['visible' num2str(i)]);
        set(checkbox,'Value',1);
       
    end

% find existing result figure
if ~isempty(findobj('Type','figure','name','results'))==true
    % delete its content
    l = findobj('type','axes');
    delete(l)
    % set results figure as current figure
    result_figure = findobj('Type','figure','name','results');  %Steger 26.11.2019
else
    % create new results figure
%     result_figure = figure('name','results','Position',[0 contr_position(2)+contr_position(4)+figure_menubar_height...
%         screensize(3) screensize(4)-contr_position(2)-contr_position(4)-2*figure_menubar_height]);

    result_figure = figure('name','results','Position',[0 bottom screensize(3) height],'windowkeypressfcn',@update);
    men = uimenu(result_figure,'Text','&Manage Plots');
 
    menu_add = uimenu(men,'Text','&Add plot');
    menu_add.MenuSelectedFcn = @Add_plot;
    
    menu_subtr = uimenu(men,'Text','&Remove plot');
    menu_subtr.MenuSelectedFcn = @Remove_plot;
 
end

% ========== Some shorthands ============
probl_def = control_panel_figure.UserData;

SystemResponse=@probl_def.SystemResponse;

x=probl_def.x;
y=probl_def.y;
index=probl_def.index;
samples=probl_def.samples;

sampleSize=probl_def.sampleSize;
diagram=probl_def.diagram;

m=probl_def.m;
d=probl_def.d;
good_design_color=probl_def.good_design_color;

solutionspace_line_color=probl_def.solutionspace_line_color;
solutionspace_line_width=probl_def.solutionspace_line_width;
solutionspace_line_type=probl_def.solutionspace_line_type;

legend=probl_def.legend;
% =======================================



%--------------------------------------------------
% Loop over all diagrams
%--------------------------------------------------


for h=1:size(diagram,1)
    x1=diagram(h,1);
    x2=diagram(h,2);
    
    %--------------------------------------------------
    %Sample creation
    %--------------------------------------------------
    samples.x = samplePointCreation(probl_def, h);

    
    %--------------------------------------------------
    %Calculating System response
    %--------------------------------------------------
    samples.y = SystemResponse(samples.x);
    
    %--------------------------------------------------
    %Evaluating System performance
    %--------------------------------------------------
    for j=1:m
        index(1).range(j,:)=(samples.y(j,:)<y(j).l|y(j).u<samples.y(j,:))&(probl_def.y(j).active==1); %checks if output is in range, 1 if violated, zero otherwise
        if j==1
            index(1).color(j,:)=index(1).range(j,:);
            index(1).color(m+1,:)=~index(1).range(j,:);
        else
            index(1).color(j,:)=index(1).color((m+1),:)&index(1).range(j,:); %this can only consider consecutive matches
            index(1).color(m+1,:)=index(1).color(m+1,:)&~index(1).color(j,:);
        end
  
    end	
    
    
    %--------------------------------------------------
    %Graphical visualization x-values
    %--------------------------------------------------
    %     subplot(round(length(diagram)/2),round(length(diagram)/2),h);
    
    % select result figure
    WindowState = result_figure.WindowState;        %Steger 26.11.2019
    figure(result_figure)                           %Steger 22.11.2019
    set(result_figure,'WindowState',WindowState)    %Steger 26.11.2019
    subplot(ceil((size(diagram,1)+1)/5), 5,h);      % +1 for the legend
    
    hold all
    
    % plot the good (feasible) samples
    plot(samples.x(x1,index(1).color(m+1,:)),samples.x(x2,index(1).color(m+1,:)),samples.marker.type,'MarkerSize',samples.marker.size ,'color',good_design_color);
    
    % plot the samples that violates the upper/lower limits on the m quantities of Interests y
    for j=1:m
        plot(samples.x(x1,index(1).color(j,:)),samples.x(x2,index(1).color(j,:)),samples.marker.type,'MarkerSize',samples.marker.size ,'color',y(j).color);
    end
    
    % draw vertical lines of the tightend limits (bounds)
    line([x(x1).l x(x1).l],[x(x2).dsl x(x2).dsu],'Color',solutionspace_line_color,'LineStyle',solutionspace_line_type,'LineWidth',solutionspace_line_width);
    line([x(x1).u x(x1).u],[x(x2).dsl x(x2).dsu],'Color',solutionspace_line_color,'LineStyle',solutionspace_line_type,'LineWidth',solutionspace_line_width);
    
    % draw horizontal lines of the tightend limits (bounds)
    line([x(x1).dsl x(x1).dsu],[x(x2).l x(x2).l],'Color',solutionspace_line_color,'LineStyle',solutionspace_line_type,'LineWidth',solutionspace_line_width);
    line([x(x1).dsl x(x1).dsu],[x(x2).u x(x2).u],'Color',solutionspace_line_color,'LineStyle',solutionspace_line_type,'LineWidth',solutionspace_line_width);
    
%     % draw box lines
%     line([x(x1).l x(x1).u], [x(x2).l x(x2).l],'Color','k','LineStyle','-','LineWidth',solutionspace_line_width);
%     line([x(x1).l x(x1).u], [x(x2).u x(x2).u],'Color','k','LineStyle','-','LineWidth',solutionspace_line_width);
%     line([x(x1).l x(x1).l], [x(x2).l x(x2).u],'Color','k','LineStyle','-','LineWidth',solutionspace_line_width);
%     line([x(x1).u x(x1).u], [x(x2).l x(x2).u],'Color','k','LineStyle','-','LineWidth',solutionspace_line_width);


% Steger

    % draw toolbar
    tb = axtoolbar({'zoomin','zoomout','restoreview','export'});
    btn = axtoolbarbtn(tb,'push');
    btn.Tooltip = 'Change ordinate and abscissa variables';
    btn.Icon = icon;
    btn.Tag = strcat('change',num2str(h));
    btn.ButtonPushedFcn = @callback_change_dv;
    
    % draw lines
    linie = images.roi.Line(gca,...                        % lower horizontal line
        'Position',[x(x1).l x(x2).l;x(x1).u x(x2).l],...
        'InteractionsAllowed','translate',...
        'Color','k',...
        'LineWidth',solutionspace_line_width,...
        'Tag',[int2str(h) ':line_lo:' int2str(x2)],...              %Tagformat: '(Number of Plot the line is in):line_lo:(Number of designvariable)'
        'DrawingArea',[x(x1).l x(x2).dsl 0 max(x(x2).u-x(x2).dsl,0)]);
    addlistener(linie,'ROIMoved',@edit_current_lower_value_callback);
    addlistener(linie,'MovingROI',@move_current_lower_line);



    linie = images.roi.Line(gca,...                        % left vertikal line
        'Position',[x(x1).l x(x2).l;x(x1).l x(x2).u],...
        'InteractionsAllowed','translate',...
        'Color','k',...
        'LineWidth',solutionspace_line_width,...
        'Tag',[int2str(h) ':line_le:' int2str(x1)],...              %Tagformat: '(Number of Plot the line is in):line_le:(Number of designvariable)'
        'DrawingArea',[x(x1).dsl x(x2).l max(x(x1).u-x(x1).dsl,0) 0]);
    addlistener(linie,'ROIMoved',@edit_current_lower_value_callback);
    addlistener(linie,'MovingROI',@move_current_left_line);


    linie = images.roi.Line(gca,...                        % upper horizontal line
        'Position',[x(x1).l x(x2).u;x(x1).u x(x2).u],...
        'InteractionsAllowed','translate',...
        'Color','k',...
        'LineWidth',solutionspace_line_width,...
        'Tag',[int2str(h) ':line_up:' int2str(x2)],...              %Tagformat: '(Number of Plot the line is in):line_up:(Number of designvariable)'
        'DrawingArea',[x(x1).l x(x2).l 0 max(x(x2).dsu-x(x2).l,0)]);
    addlistener(linie,'ROIMoved',@edit_current_upper_value_callback);
    addlistener(linie,'MovingROI',@move_current_upper_line);


    linie = images.roi.Line(gca,...                        % right vertikal line
        'Position',[x(x1).u x(x2).l;x(x1).u x(x2).u],...
        'InteractionsAllowed','translate',...
        'Color','k',...
        'LineWidth',solutionspace_line_width,...
        'Tag',[int2str(h) ':line_ri:' int2str(x1)],...              %Tagformat: '(Number of Plot the line is in):line_ri:(Number of designvariable)'
        'DrawingArea',[x(x1).l x(x2).l max(x(x1).dsu-x(x1).l,0) 0]);
    addlistener(linie,'ROIMoved',@edit_current_upper_value_callback);
    addlistener(linie,'MovingROI',@move_current_right_line);

% Steger Ende


    str = [x(x1).name,' over ',x(x2).name];
    title(str);
    xlabel([x(x1).name,' (',x(x1).unit,')']);
    ylabel([x(x2).name,' (',x(x2).unit,')']);
    axis([x(x1).dsl,x(x1).dsu,x(x2).dsl,x(x2).dsu]);
    
    set(gca,'Tag',['plot' int2str(h)]); %Steger  Tagformat: 'plot(Number of Plot)'

end
% select result figure
figure(result_figure)           %Steger 22.11.2019
% select the first empty subplot
subplot(ceil((size(diagram,1)+1)/5), 5, size(diagram,1)+1);
% create a dummy plot
plot(1,1);
% set axes invisible
set(gca,'Visible','off');

%Draw legend into the current axes
text(0.0,1.0, legend, 'EdgeColor', 'k', 'BackGroundColor','w');
end


%% Callbackfunctions Steger
function edit_current_lower_value_callback(src,evt)

user_interface = findobj('type','figure','name','user interface');
result_figure = src.Parent.Parent;

colon_pos = strfind(src.Tag,':');                       %Positions of colons in Tag
dv_number = str2double(src.Tag(colon_pos(2)+1:end));    %Number of changed designvariable

%change color of update-button and line
update_button = findall(user_interface,'Tag','update_button');
update_button.BackgroundColor = 'r';
src.Color = 'r';

% change value of textbox
lower_value = findall(user_interface,'Tag',['current_lower_value' int2str(dv_number)]);

dv = findall(user_interface,'Title','Design Variables');    %Tab with dv´s in user interface

% get slider handles
slider = findall(dv,'Tag',['slider' int2str(dv_number)]);
slider_position = slider.Position;
current_slider_values = get(slider,'UserData');


% different opperation for left- and bottom-line
if strcmp(src.Tag((colon_pos(1)+1):(colon_pos(2)-1)),'line_le')
    
    set(lower_value,'string',num2str(evt.CurrentPosition(2)));
    
    new_slider_values = [(evt.CurrentPosition(2)-user_interface.UserData.x(dv_number).dsl)/(user_interface.UserData.x(dv_number).dsu-user_interface.UserData.x(dv_number).dsl) current_slider_values(1,2)];
    
    user_interface.UserData.x(dv_number).l = evt.CurrentPosition(2);    %change Data
    
    % change lines in every plot
    for i=1:size(user_interface.UserData.diagram,1)
        
        current_plot = findall(result_figure,'Tag',['plot' num2str(i)]);
        
        if ~isempty(findall(current_plot,'Tag',[num2str(i) ':line_lo:' int2str(dv_number)]))
            line = findall(current_plot,'Tag',[num2str(i) ':line_lo:' int2str(dv_number)]);
            
            new_position = line.Position;
            new_position(:,2) = evt.CurrentPosition(2)*ones(2,1);
            
            set(line,'Position',new_position,'Color','r');
            
            
            other_dv = erase(int2str(user_interface.UserData.diagram(i,:)),int2str(dv_number));
            other_dv = strtrim(other_dv);   %remove leading and tailing spaces
            line_le = findall(current_plot,'Tag',[num2str(i) ':line_le:' other_dv]);
            line_ri = findall(current_plot,'Tag',[num2str(i) ':line_ri:' other_dv]);
            line_up = findall(current_plot,'Tag',[num2str(i) ':line_up:' int2str(dv_number)]);
            
            line_le.Position(1,2) = evt.CurrentPosition(2);
            line_le.DrawingArea(2) = evt.CurrentPosition(2);
            
            line_ri.Position(1,2) = evt.CurrentPosition(2);
            line_ri.DrawingArea(2) = evt.CurrentPosition(2);
            
            line_up.DrawingArea(2) = evt.CurrentPosition(2);
            line_up.DrawingArea(4) = user_interface.UserData.x(dv_number).dsu - evt.CurrentPosition(2);
            
        elseif ~isempty(findall(current_plot,'Tag',[num2str(i) ':line_le:' num2str(dv_number)]))
            line = findall(current_plot,'Tag',[num2str(i) ':line_le:' num2str(dv_number)]);
            
            new_position = line.Position;
            new_position(:,1) = evt.CurrentPosition(2)*ones(2,1);
            
            set(line,'Position',new_position,'Color','r');
            
            
            other_dv = erase(int2str(user_interface.UserData.diagram(i,:)),int2str(dv_number));
            other_dv = strtrim(other_dv);   %remove leading and tailing spaces
            line_lo = findall(current_plot,'Tag',[num2str(i) ':line_lo:' other_dv]);
            line_up = findall(current_plot,'Tag',[num2str(i) ':line_up:' other_dv]);
            line_ri = findall(current_plot,'Tag',[num2str(i) ':line_ri:' int2str(dv_number)]);
            
            line_lo.Position(1,1) = evt.CurrentPosition(2);
            line_lo.DrawingArea(1) = evt.CurrentPosition(2);
            
            line_up.Position(1,1) = evt.CurrentPosition(2);
            line_up.DrawingArea(1) = evt.CurrentPosition(2);
            
            line_ri.DrawingArea(1) = evt.CurrentPosition(2);
            line_ri.DrawingArea(3) = user_interface.UserData.x(dv_number).dsu - evt.CurrentPosition(2);
            
        end
        
    end
elseif strcmp(src.Tag((colon_pos(1)+1):(colon_pos(2)-1)),'line_lo')
    
    set(lower_value,'string',num2str(evt.CurrentPosition(3)));
    
    new_slider_values = [(evt.CurrentPosition(3)-user_interface.UserData.x(dv_number).dsl)/(user_interface.UserData.x(dv_number).dsu-user_interface.UserData.x(dv_number).dsl) current_slider_values(1,2)];
    
    user_interface.UserData.x(dv_number).l = evt.CurrentPosition(3);    %change Data
    
    
    % change lines in every other plot
    for i=1:size(user_interface.UserData.diagram,1)
        
        current_plot = findall(result_figure,'Tag',['plot' num2str(i)]);
        
        if ~isempty(findall(current_plot,'Tag',[num2str(i) ':line_lo:' num2str(dv_number)]))
            line = findall(current_plot,'Tag',[num2str(i) ':line_lo:' num2str(dv_number)]);
            
            new_position = line.Position;
            new_position(:,2) = evt.CurrentPosition(3)*ones(2,1);
            
            set(line,'Position',new_position,'Color','r');
            
            
            other_dv = erase(int2str(user_interface.UserData.diagram(i,:)),int2str(dv_number));
            other_dv = strtrim(other_dv);   %remove leading and tailing spaces
            line_le = findall(current_plot,'Tag',[num2str(i) ':line_le:' other_dv]);
            line_ri = findall(current_plot,'Tag',[num2str(i) ':line_ri:' other_dv]);
            line_up = findall(current_plot,'Tag',[num2str(i) ':line_up:' int2str(dv_number)]);
            
            line_le.Position(1,2) = evt.CurrentPosition(3);
            line_le.DrawingArea(2) = evt.CurrentPosition(3);
            
            line_ri.Position(1,2) = evt.CurrentPosition(3);
            line_ri.DrawingArea(2) = evt.CurrentPosition(3);
            
            line_up.DrawingArea(2) = evt.CurrentPosition(3);
            line_up.DrawingArea(4) = user_interface.UserData.x(dv_number).dsu - evt.CurrentPosition(3);
            
        elseif ~isempty(findall(current_plot,'Tag',[num2str(i) ':line_le:' num2str(dv_number)]))
            line = findall(current_plot,'Tag',[num2str(i) ':line_le:' num2str(dv_number)]);
            
            new_position = line.Position;
            new_position(:,1) = evt.CurrentPosition(3)*ones(2,1);
            
            set(line,'Position',new_position,'Color','r');
            
            
            other_dv = erase(int2str(user_interface.UserData.diagram(i,:)),int2str(dv_number));
            other_dv = strtrim(other_dv);   %remove leading and tailing spaces
            line_lo = findall(current_plot,'Tag',[num2str(i) ':line_lo:' other_dv]);
            line_up = findall(current_plot,'Tag',[num2str(i) ':line_up:' other_dv]);
            line_ri = findall(current_plot,'Tag',[num2str(i) ':line_ri:' int2str(dv_number)]);
            
            line_lo.Position(1,1) = evt.CurrentPosition(3);
            line_lo.DrawingArea(1) = evt.CurrentPosition(3);
            
            line_up.Position(1,1) = evt.CurrentPosition(3);
            line_up.DrawingArea(1) = evt.CurrentPosition(3);
            
            line_ri.DrawingArea(1) = evt.CurrentPosition(3);
            line_ri.DrawingArea(3) = user_interface.UserData.x(dv_number).dsu - evt.CurrentPosition(3);
            
        end
        
    end
    
end

% visualize new slider with changed values
delete(slider);
newslider = superSlider(dv,...
    'min',(0),...
    'max',(1),...
    'numSlides',2,...
    'value',new_slider_values,...
    'stepSize',0.05,...
    'tagName',['slider' int2str(dv_number)],...
    'callback',{@slider_callback});
newslider.Position = slider_position;

end


function edit_current_upper_value_callback(src,evt)

user_interface = findobj('type','figure','name','user interface');
result_figure = src.Parent.Parent;

colon_pos = strfind(src.Tag,':');                       %Positions of colons in Tag
dv_number = str2double(src.Tag(colon_pos(2)+1:end));    %Number of changed designvariable

%change color of update-button and line
update_button = findall(user_interface,'Tag','update_button');
update_button.BackgroundColor = 'r';
src.Color = 'r';

% change value of textbox
upper_value = findall(user_interface,'Tag',['current_upper_value' int2str(dv_number)]);

dv = findall(user_interface,'Title','Design Variables');    %Tab with dv´s in user interface

% get slider handles
slider = findall(dv,'Tag',['slider' int2str(dv_number)]);
slider_position = slider.Position;
current_slider_values = get(slider,'UserData');


% different opperation for right- and top-line
if strcmp(src.Tag((colon_pos(1)+1):(colon_pos(2)-1)),'line_ri')

    set(upper_value,'string',num2str(evt.CurrentPosition(2)));

    new_slider_values = [current_slider_values(1,1) (evt.CurrentPosition(2)-user_interface.UserData.x(dv_number).dsl)/(user_interface.UserData.x(dv_number).dsu-user_interface.UserData.x(dv_number).dsl)];

    user_interface.UserData.x(dv_number).u = evt.CurrentPosition(2);    %change Data

    % change lines in every plot
    for i=1:size(user_interface.UserData.diagram,1)

        current_plot = findall(result_figure,'Tag',['plot' num2str(i)]);

        if ~isempty(findall(current_plot,'Tag',[num2str(i) ':line_up:' num2str(dv_number)]))
            line = findall(current_plot,'Tag',[num2str(i) ':line_up:' num2str(dv_number)]);

            new_position = line.Position;
            new_position(:,2) = evt.CurrentPosition(2)*ones(2,1);

            set(line,'Position',new_position,'Color','r');


            other_dv = erase(int2str(user_interface.UserData.diagram(i,:)),int2str(dv_number));
            other_dv = strtrim(other_dv);   %remove leading and tailing spaces
            line_le = findall(current_plot,'Tag',[num2str(i) ':line_le:' other_dv]);
            line_ri = findall(current_plot,'Tag',[num2str(i) ':line_ri:' other_dv]);
            line_lo = findall(current_plot,'Tag',[num2str(i) ':line_lo:' int2str(dv_number)]);

            line_le.Position(2,2) = evt.CurrentPosition(2);

            line_ri.Position(2,2) = evt.CurrentPosition(2);

            line_lo.DrawingArea(4) = evt.CurrentPosition(2) - user_interface.UserData.x(dv_number).dsl;

        elseif ~isempty(findall(current_plot,'Tag',[num2str(i) ':line_ri:' num2str(dv_number)]))
            line = findall(current_plot,'Tag',[num2str(i) ':line_ri:' num2str(dv_number)]);

            new_position = line.Position;
            new_position(:,1) = evt.CurrentPosition(2)*ones(2,1);

            set(line,'Position',new_position,'Color','r');


            other_dv = erase(int2str(user_interface.UserData.diagram(i,:)),int2str(dv_number));
            other_dv = strtrim(other_dv);   %remove leading and tailing spaces
            line_lo = findall(current_plot,'Tag',[num2str(i) ':line_lo:' other_dv]);
            line_up = findall(current_plot,'Tag',[num2str(i) ':line_up:' other_dv]);
            line_le = findall(current_plot,'Tag',[num2str(i) ':line_le:' int2str(dv_number)]);

            line_lo.Position(2,1) = evt.CurrentPosition(2);

            line_up.Position(2,1) = evt.CurrentPosition(2);

            line_le.DrawingArea(3) = evt.CurrentPosition(2) - user_interface.UserData.x(dv_number).dsl;

        end

    end
elseif strcmp(src.Tag((colon_pos(1)+1):(colon_pos(2)-1)),'line_up')

    set(upper_value,'string',num2str(evt.CurrentPosition(3)));

    new_slider_values = [current_slider_values(1,1) (evt.CurrentPosition(3)-user_interface.UserData.x(dv_number).dsl)/(user_interface.UserData.x(dv_number).dsu-user_interface.UserData.x(dv_number).dsl)];

    user_interface.UserData.x(dv_number).u = evt.CurrentPosition(3);    %change Data


    % change lines in every other plot
    for i=1:size(user_interface.UserData.diagram,1)

        current_plot = findall(result_figure,'Tag',['plot' num2str(i)]);

        if ~isempty(findall(current_plot,'Tag',[num2str(i) ':line_up:' num2str(dv_number)]))
            line = findall(current_plot,'Tag',[num2str(i) ':line_up:' num2str(dv_number)]);

            new_position = line.Position;
            new_position(:,2) = evt.CurrentPosition(3)*ones(2,1);

            set(line,'Position',new_position,'Color','r');


            other_dv = erase(int2str(user_interface.UserData.diagram(i,:)),int2str(dv_number));
            other_dv = strtrim(other_dv);   %remove leading and tailing spaces
            line_le = findall(current_plot,'Tag',[num2str(i) ':line_le:' other_dv]);
            line_ri = findall(current_plot,'Tag',[num2str(i) ':line_ri:' other_dv]);
            line_lo = findall(current_plot,'Tag',[num2str(i) ':line_lo:' int2str(dv_number)]);

            line_le.Position(2,2) = evt.CurrentPosition(3);

            line_ri.Position(2,2) = evt.CurrentPosition(3);

            line_lo.DrawingArea(4) = evt.CurrentPosition(3) - user_interface.UserData.x(dv_number).dsl;

        elseif ~isempty(findall(current_plot,'Tag',[num2str(i) ':line_ri:' num2str(dv_number)]))
            line = findall(current_plot,'Tag',[num2str(i) ':line_ri:' num2str(dv_number)]);

            new_position = line.Position;
            new_position(:,1) = evt.CurrentPosition(3)*ones(2,1);

            set(line,'Position',new_position,'Color','r');


            other_dv = erase(int2str(user_interface.UserData.diagram(i,:)),int2str(dv_number));
            other_dv = strtrim(other_dv);   %remove leading and tailing spaces
            line_lo = findall(current_plot,'Tag',[num2str(i) ':line_lo:' other_dv]);
            line_up = findall(current_plot,'Tag',[num2str(i) ':line_up:' other_dv]);
            line_le = findall(current_plot,'Tag',[num2str(i) ':line_le:' int2str(dv_number)]);

            line_lo.Position(2,1) = evt.CurrentPosition(3);

            line_up.Position(2,1) = evt.CurrentPosition(3);

            line_le.DrawingArea(3) = evt.CurrentPosition(3) - user_interface.UserData.x(dv_number).dsl;


        end

    end

end

% visualize new slider with changed values
delete(slider);
newslider = superSlider(dv,...
    'min',(0),...
    'max',(1),...
    'numSlides',2,...
    'value',new_slider_values,...
    'stepSize',0.05,...
    'tagName',['slider' int2str(dv_number)],...
    'callback',{@slider_callback});
newslider.Position = slider_position;

end


function slider_callback(h)
user_interface = findobj('type','figure','name','user interface');

i = h.Tag(7:end);
i = str2double(i);

%check if Value was actually changed
if user_interface.UserData.x(i).l ~= h.UserData(1,1)*(user_interface.UserData.x(i).dsu-user_interface.UserData.x(i).dsl)+user_interface.UserData.x(i).dsl ||...
        user_interface.UserData.x(i).u ~= h.UserData(1,2)*(user_interface.UserData.x(i).dsu-user_interface.UserData.x(i).dsl)+user_interface.UserData.x(i).dsl

    lower_box = findobj('tag',['current_lower_value' int2str(i)]);
    set(lower_box,'string',num2str((h.UserData(1,1))*(user_interface.UserData.x(i).dsu-user_interface.UserData.x(i).dsl)+user_interface.UserData.x(i).dsl));

    upper_box = findobj('tag',['current_upper_value' int2str(i)]);
    set(upper_box,'string',num2str(h.UserData(1,2)*(user_interface.UserData.x(i).dsu-user_interface.UserData.x(i).dsl)+user_interface.UserData.x(i).dsl));

    user_interface.UserData.x(i).l = h.UserData(1,1)*(user_interface.UserData.x(i).dsu-user_interface.UserData.x(i).dsl)+user_interface.UserData.x(i).dsl;
    user_interface.UserData.x(i).u = h.UserData(1,2)*(user_interface.UserData.x(i).dsu-user_interface.UserData.x(i).dsl)+user_interface.UserData.x(i).dsl;
    % Change update button flag
    update_button = findall(user_interface,'Tag','update_button');
    update_button.BackgroundColor = 'r';
end



end


function move_current_lower_line(src,evt)

user_interface = findobj('type','figure','name','user interface');
current_plot = src.Parent;

colon_pos = strfind(src.Tag,':');                       %Positions of colons in Tag
dv_number = str2double(src.Tag(colon_pos(2)+1:end));    %Number of changed designvariable (number)
plot_number = src.Tag(1:colon_pos(1)-1);                %Number of current plot (string)


other_dv = erase(int2str(user_interface.UserData.diagram(str2double(plot_number),:)),int2str(dv_number));
other_dv = strtrim(other_dv);   %remove leading and tailing spaces

line_le = findall(current_plot,'Tag',[plot_number ':line_le:' other_dv]);
line_ri = findall(current_plot,'Tag',[plot_number ':line_ri:' other_dv]);

line_le.Position(1,2) = evt.CurrentPosition(3);
line_ri.Position(1,2) = evt.CurrentPosition(3);

end


function move_current_left_line(src,evt)

user_interface = findobj('type','figure','name','user interface');
current_plot = src.Parent;

colon_pos = strfind(src.Tag,':');                       %Positions of colons in Tag
dv_number = str2double(src.Tag(colon_pos(2)+1:end));    %Number of changed designvariable (number)
plot_number = src.Tag(1:colon_pos(1)-1);                %Number of current plot (string)


other_dv = erase(int2str(user_interface.UserData.diagram(str2double(plot_number),:)),int2str(dv_number));
other_dv = strtrim(other_dv);   %remove leading and tailing spaces

line_lo = findall(current_plot,'Tag',[plot_number ':line_lo:' other_dv]);
line_up = findall(current_plot,'Tag',[plot_number ':line_up:' other_dv]);

line_lo.Position(1,1) = evt.CurrentPosition(2);
line_up.Position(1,1) = evt.CurrentPosition(2);


end


function move_current_upper_line(src,evt)

user_interface = findobj('type','figure','name','user interface');
current_plot = src.Parent;

colon_pos = strfind(src.Tag,':');                       %Positions of colons in Tag
dv_number = str2double(src.Tag(colon_pos(2)+1:end));    %Number of changed designvariable (number)
plot_number = src.Tag(1:colon_pos(1)-1);                %Number of current plot (string)


other_dv = erase(int2str(user_interface.UserData.diagram(str2double(plot_number),:)),int2str(dv_number));
other_dv = strtrim(other_dv);   %remove leading and tailing spaces

line_le = findall(current_plot,'Tag',[plot_number ':line_le:' other_dv]);
line_ri = findall(current_plot,'Tag',[plot_number ':line_ri:' other_dv]);

line_le.Position(2,2) = evt.CurrentPosition(3);
line_ri.Position(2,2) = evt.CurrentPosition(3);


end


function move_current_right_line(src,evt)

user_interface = findobj('type','figure','name','user interface');
current_plot = src.Parent;

colon_pos = strfind(src.Tag,':');                       %Positions of colons in Tag
dv_number = str2double(src.Tag(colon_pos(2)+1:end));    %Number of changed designvariable (number)
plot_number = src.Tag(1:colon_pos(1)-1);                %Number of current plot (string)


other_dv = erase(int2str(user_interface.UserData.diagram(str2double(plot_number),:)),int2str(dv_number));
other_dv = strtrim(other_dv);   %remove leading and tailing spaces

line_lo = findall(current_plot,'Tag',[plot_number ':line_lo:' other_dv]);
line_up = findall(current_plot,'Tag',[plot_number ':line_up:' other_dv]);

line_lo.Position(2,1) = evt.CurrentPosition(2);
line_up.Position(2,1) = evt.CurrentPosition(2);


end

function callback_change_dv(h,~)

ui = findobj('type','figure','name','user interface');
line = str2double(h.Tag(7:end));
entries = cell([1 length(ui.UserData.x)]);

for i=1:length(ui.UserData.x)
    entries{i}=ui.UserData.x(i).name;
end

cdv=figure;
set(cdv,'Name','Choos variables of axes');
set(cdv,'Position',[1150, 500, 300, 60]);

x_new = uicontrol('parent',cdv,...
    'style','popupmenu',...
    'String',entries,...
    'Value',ui.UserData.diagram(line,1),...
    'Units','normalized',...
    'position',[0.35 0 0.45 0.9],...
    'UserData',line);

uicontrol('parent',cdv,...
    'style','text',...
    'string','x-axes:',...
    'Units','normalized',...
    'Fontsize',10,...
    'position',[0.05 0 0.3 0.9]);

y_new = uicontrol('parent',cdv,...
    'style','popupmenu',...
    'String',entries,...
    'Value',ui.UserData.diagram(line,2),...
    'Units','normalized',...
    'position',[0.35 -0.5 0.45 0.9],...
    'UserData',line);

uicontrol('parent',cdv,...
    'style','text',...
    'string','y-axes:',...
    'Units','normalized',...
    'Fontsize',10,...
    'position',[0.05 -0.5 0.3 0.9]);

userdata.line = line;
userdata.x_new = x_new;
userdata.y_new = y_new;

uicontrol('parent',cdv,...
    'style','pushbutton',...
    'String','OK',...
    'Units','normalized',...
    'UserData',userdata,...
    'position',[0.825 0.05 0.15 0.85],...
    'callback',{@callback_OK});

end

function callback_OK(h,~)
ui = findobj('type','figure','name','user interface');
cdv = h.Parent;

ui.UserData.diagram(h.UserData.line,1) = h.UserData.x_new.Value;
ui.UserData.diagram(h.UserData.line,2) = h.UserData.y_new.Value;

SolutionSpace(ui);
close(cdv);


end

function Add_plot(~,~)

ui = findobj('type','figure','name','user interface');

for i=1:length(ui.UserData.x)
    entries{i}=ui.UserData.x(i).name;
end

cdv=figure;
set(cdv,'Name','Choos variables of new axes');
set(cdv,'Position',[1150, 500, 300, 60]);

uicontrol('parent',cdv,...
    'style','popupmenu',...
    'String',entries,...
    'Units','normalized',...
    'position',[0.35 0 0.45 0.9],...
    'Tag', 'x');

uicontrol('parent',cdv,...
    'style','text',...
    'string','x-axes:',...
    'Units','normalized',...
    'Fontsize',10,...
    'position',[0.05 0 0.3 0.9]);

uicontrol('parent',cdv,...
    'style','popupmenu',...
    'String',entries,...
    'Units','normalized',...
    'position',[0.35 -0.5 0.45 0.9],...
    'Tag', 'y');

uicontrol('parent',cdv,...
    'style','text',...
    'string','y-axes:',...
    'Units','normalized',...
    'Fontsize',10,...
    'position',[0.05 -0.5 0.3 0.9]);

uicontrol('parent',cdv,...
    'style','pushbutton',...
    'String','ADD',...
    'Units','normalized',...
    'position',[0.825 0.05 0.15 0.85],...
    'callback',{@callback_add});

end

function callback_add(h,~)

ui = findobj('type','figure','name','user interface');
cdv = h.Parent;
x_handle = findall(cdv,'Tag','x');
y_handle = findall(cdv,'Tag','y');

x_val = x_handle.Value;
y_val = y_handle.Value;

ui.UserData.diagram = [ui.UserData.diagram; [x_val y_val]];

SolutionSpace(ui);
close(cdv);

end

function Remove_plot(h,~)

ui = findobj('type','figure','name','user interface');
plots = findall(h.Parent.Parent,'Type','axes');

for i=1:length(plots)
    Tag = get(plots(i),'Tag');
    num = str2double(erase(Tag,'plot'));
    if ~isnan(num)
        entries{num}=plots(i).Title.String;
    end
end

cdv=figure;
set(cdv,'Name','Choos plot to delete');
set(cdv,'Position',[1150, 500, 300, 60]);

uicontrol('parent',cdv,...
    'style','popupmenu',...
    'String',entries,...
    'Units','normalized',...
    'position',[0.4 0 0.3 0.9],...
    'Tag', 'remove_plot');

uicontrol('parent',cdv,...
    'style','text',...
    'string','Remove number:',...
    'Units','normalized',...
    'Fontsize',10,...
    'position',[0 0 0.4 0.9]);

uicontrol('parent',cdv,...
    'style','pushbutton',...
    'String','Remove',...
    'Units','normalized',...
    'position',[0.725 0.45 0.25 0.5],...
    'callback',{@callback_remove});

end


function callback_remove(h,~)

ui = findobj('type','figure','name','user interface');
cdv = h.Parent;
remove_handle = findall(cdv,'Tag','remove_plot');
line = remove_handle.Value;

ui.UserData.diagram = [ui.UserData.diagram(1:line-1,:); ui.UserData.diagram(line+1:end,:)];

SolutionSpace(ui);
close(cdv);
end

function update(~,evt)

Pressed_Key = evt.Key;
Pressed_Modifier = evt.Modifier;

if strcmp(Pressed_Key,'u') && isempty(setdiff(Pressed_Modifier,{'control'})) && ~isempty(Pressed_Modifier)
    update_button_handle = findobj('Tag','update_button');
    update_button_handle.BackgroundColor = 'g';
    SolutionSpace(update_button_handle.Parent);
    figure(update_button_handle.Parent);
end

end

