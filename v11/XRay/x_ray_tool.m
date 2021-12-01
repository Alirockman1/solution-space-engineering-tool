clc
clear
close all
main_dir = pwd;
cd(fullfile(main_dir,'Data','Design_Problems'));
problems=dir;
problems=problems([problems.isdir]==0);
entries = cell(1,length(problems));


%check for correct MATLAB version and if Toolbox is installed
v = version;
pos = strfind(v,'R');
v = v(pos:pos+5);
clear pos

jear = str2double(v(2:5));
releas = v(end);

v = ver;
for i=1:length(v)
    if strcmp(v(i).Name,'Image Processing Toolbox')
        installed = 1;
        break
    else
        installed = 0;
    end
end

if ~(jear >= 2019 || (jear == 2018 && releas == 'b'))
    
    error('Your current MATLAB version is not capable of running this version of the programm.\n%s',...
        'Please use MATLAB R2018b or newer versions of MATLAB or consider using an older version of the SSE-program.')

elseif ~installed
    
    error('Image Processing Toolbox is not installed.\n%s',...
        'Please install the required toolbox or consider using an older version of the SSE-program.')
end

clear v jear releas installed

for i=1:length(problems)
    entries{i}=problems(i).name;
end
cd(main_dir);

cdp=figure;
cdp.UserData = problems;
set(cdp,'Name','Choose Design Problem');
set(cdp,'Position',[1150, 200, 300, 60]);
uicontrol('parent',cdp,...
    'style','popupmenu',...
    'String',entries,...
    'Units','normalized',...
    'position',[0.05 0 0.9 0.9],...
    'callback',{@choose_design_problem});


