%Class to declare the most common WebCalculate
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebCalculate < handle
    %Public properties
    properties
        Property1;
    end

    %Dependand properties
    properties (Dependent = true, SetAccess = private)

    end

    %Private properties
    properties(SetAccess = private)

    end

    %Default constructor
    methods
        function obj = Template(property1)
            if nargin > 0
                obj.Property1 = property1;
            end
        end
    end

    %Set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end

    %Get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end

    %Public methods
    methods

    end

    %Private methods
    methods (Access = 'private')

    end

    %Stactic methods
    methods (Static)
        function calculateData(source, options)
            %function to apply different calculation in the selected dataset.
            %The avaliable calculations are: calculate salinity, calculate rotation,
            %use custom calculator to build your own calculation
            if isempty(source)
                errordlg('Error. You have to set the source file.');
                return;
            end;

            [sourceData, loadOk] = Dataset.loadData(source,0);
            if ~loadOk
                errordlg('Error to read the source file. Please verify the format.');
                return;
            end;

            %set default options.
            options = Util.setDefault(options,'calcSal',0);
            options = Util.setDefault(options,'calcRotation',0);
            options = Util.setDefault(options,'calculator',0);

            %transform to numbers if the input is an string
            options = Util.setDefaultNumberField(options, 'calcSal');
            options = Util.setDefaultNumberField(options, 'calcRotation');
            options = Util.setDefaultNumberField(options, 'calculator');

            %apply calculate salinity
            if options.calcSal
                if ~isfield(sourceData, 'Cond') || ~isfield(sourceData, 'Temp') || ~isfield(sourceData, 'WatPress')
                    errordlg('Error. The files selected does not contain the variables Cond, Temp, or WatPress.');
                    return;
                else
                    %calculate salinity from conductivity and temperature
                    salinity                = Physics.calculateSalinity(sourceData.Cond.data, sourceData.Temp.data, sourceData.WatPress.data);
                    sourceData.Sal.data     = salinity;
                    sourceData.Sal.longname = 'Salinity';
                    sourceData.Sal.unit     = 'psu';

                    saveOk = Dataset.saveData(sourceData,source);
                    if ~saveOk
                        errordlg('Error. The file could not been saved');
                        return;
                    end;
                end;

                clear sourceData;
                [sourceData, loadOk] = Dataset.loadData(source,0);
                if ~loadOk
                    errordlg('Error to read the source file. Please verify the format.');
                    return;
                end;
            end;

            %apply rotation calculation
            if options.calcRotation
                options = Util.setDefault(options,'rotationVar1','');
                options = Util.setDefault(options,'rotationVar2','');
                var1 = options.rotationVar1;
                var2 = options.rotationVar2;
                if ~isfield(sourceData, var1) || ~isfield(sourceData, var2)
                    errordlg('Error. The files selected does not contain the variables selected for the rotation.');
                    return;
                else
                    try
                        options = Util.setDefault(options,'rotationAngle',0);
                        options = Util.setDefaultNumberField(options, 'rotationAngle');
                        if isempty(options.rotationAngle)
                            errordlg('Error. You have to set the rotation degree.');
                            return;
                        end;

                        [uNew,vNew] = Calculate.rotateVector(sourceData.(var1).data,sourceData.(var2).data, options.rotationAngle);
                        sourceData.(var1).data = uNew;
                        sourceData.(var2).data = vNew;

                        saveOk = Dataset.saveData(sourceData,source);
                        if ~saveOk
                            errordlg('Rotation Error. The file could not been saved.');
                            return;
                        end;
                    catch
                        sct = lasterror;
                        errordlg(['Rotation Error.' sct.message]);
                        return;
                    end;
                end;

                clear sourceData;
                [sourceData, loadOk] = Dataset.loadData(source,0);
                if ~loadOk
                    errordlg('Error to read the source file. Please verify the format.');
                    return;
                end;
            end;

            %apply mini calculator
            if options.calculator
                options = Util.setDefault(options,'outputVarName','');
                options = Util.setDefault(options,'outputLongname','');
                options = Util.setDefault(options,'unit','');
                if isempty(options.outputVarName)
                    errordlg('Error. You need to set a new variable name.');
                    return;
                end;

                options = Util.setDefault(options,'varA','');
                options = Util.setDefault(options,'varB','');
                options = Util.setDefault(options,'varC','');
                options = Util.setDefault(options,'varD','');
                var1 = options.varA;
                var2 = options.varB;
                var3 = options.varC;
                var4 = options.varD;

                value1 = [];
                if ~isempty(var1) && isfield(sourceData, var1)
                    value1 = sourceData.(var1).data;
                end;

                value2 = [];
                if ~isempty(var2) && isfield(sourceData, var2)
                    value2 = sourceData.(var2).data;
                end;

                value3 = [];
                if ~isempty(var3) && isfield(sourceData, var3)
                    value3 = sourceData.(var3).data;
                end;

                value4 = [];
                if ~isempty(var4) && isfield(sourceData, var4)
                    value4 = sourceData.(var4).data;
                end;

                options = Util.setDefault(options,'equation','');
                if isempty(options.equation)
                    errordlg('Mini Calculator Error. You have to set the equation.');
                    return;
                end

                try
                    %build the new function
                    f = str2func(['@(a,b,c,d)' lower(options.equation)]);

                    %eval the function
                    result = f(value1, value2, value3, value4);

                    %set the new data in the source
                    sourceData.(options.outputVarName).data = result;
                    if isempty(options.outputLongname)
                        sourceData.(options.outputVarName).longname = options.outputVarName;
                    else
                        sourceData.(options.outputVarName).longname = options.outputLongname;
                    end;

                    sourceData.(options.outputVarName).unit = options.unit;

                    resultSize = size(result);
                    sourceData.(options.outputVarName).dim = {repmat(upper(options.outputVarName(1)), 1, resultSize(2))};

                    saveOk = Dataset.saveData(sourceData,source);
                    if ~saveOk
                        errordlg('Calculator Error. The file could not been saved.');
                        return;
                    end;

                catch
                    sct = lasterror;
                    errordlg(['Error. The equation could not be evaluate correctly ' sct.message]);
                    return;
                end;
            end;

        end;

    end
end