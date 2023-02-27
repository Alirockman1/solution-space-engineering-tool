%% Description

%This function creates an Excel document with the upper and lower limits of
%the design variables and the quantities of interest.


%% Code:
function writeInputOutput(obj)
    warning('off','all')
    mkdir InputOutput
    main_dir = pwd;
    pfad = [main_dir '\InputOutput'];
    name1 = class(obj);
    name2 = ['.\InputOutput\' name1 '.xlsx'];
    
    if obj.b == 0
        recycle on
        try
            delete(name2);
        catch
            warning('Old output file was not deletet.')
        end
        xlswrite(name2,'1','design_variables');
        objExcel = actxserver('Excel.Application');
        objExcel.Workbooks.Open(fullfile(pfad,name1));
        
        try
            objExcel.ActiveWorkbook.Worksheets.Item('Tabelle1').Delete;
        catch PROBABLE_LANGUAGE_ISSUE % sheet 1 name depends on language of excel
            try
                objExcel.ActiveWorkbook.Worksheets.Item('Sheet1').Delete;
            catch NOT_ENGLISH_OR_GERMAN
                objExcel.ActiveWorkbook.Save;
                objExcel.ActiveWorkbook.Close;
                objExcel.Quit;
                objExcel.delete;
                
                msg = ['Excel might be in a language other than English or German, which causes an issue with deletion of Sheet1; see writeInputOutput function.'];
                causeException = MException('MATLAB:writeInputOutput:WrongSheetName',msg);
                NOT_ENGLISH_OR_GERMAN = addCause(NOT_ENGLISH_OR_GERMAN,causeException);
                rethrow(NOT_ENGLISH_OR_GERMAN);
            end
        end
        
        objExcel.ActiveWorkbook.Save;
        objExcel.ActiveWorkbook.Close;
        objExcel.Quit;
        objExcel.delete;
        obj.b = obj.b+1;
    end
    
    obj.b = obj.b+1;
    
    if obj.b == length(obj.diagram)+1
        cHeader = cell(obj.d,1);
        CSV = zeros(obj.d,2);

        for i = 1:obj.d
            cHeader(i) = {obj.x(i).name};
        end
        %cHeader = erase(cHeader,'{');
        %cHeader = erase(cHeader,'}');
        %cHeader = erase(cHeader,'(');
        %cHeader = erase(cHeader,')');
        xlswrite(name2,cHeader,'design_variables');
        CSV = [obj.x.l; obj.x.u]';
        xlswrite(name2,CSV,'design_variables','B1');
        cUnit = cell(obj.d,1);
        for i = 1:obj.d
            cUnit(i) = {obj.x(i).unit};
        end
        xlswrite(name2,cUnit,'design_variables','D1');

        cHeader = cell(obj.m,1);
        CSV = zeros(obj.m,2);
        cUnit = cell(obj.m,1);

        for i = 1:obj.m
            cHeader(i) = {obj.y(i).name};
        end
        %cHeader = erase(cHeader,'{');
        %cHeader = erase(cHeader,'}');
        %cHeader = erase(cHeader,'(');
        %cHeader = erase(cHeader,')');
        xlswrite(name2,cHeader,'quantities_of_interest');
        CSV = [obj.y.l; obj.y.u]';
        xlswrite(name2,CSV,'quantities_of_interest','B1');
        for i = 1:obj.m
            cUnit(i) = {obj.y(i).unit};
        end
        xlswrite(name2,cUnit,'quantities_of_interest','D1');
        
        obj.b = 1;
    end

    warning('on','all')
end