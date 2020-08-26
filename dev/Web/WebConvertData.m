%Class to declare the most common WebConvertData
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebConvertData < handle
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
        function projectData(source, options)
            %project data from web interface
            if isempty(source)
                errordlg('Error. You have to set the source file.');
                return;
            end;

            options = Util.setDefault(options,'var1','');
            if isempty(options.var1)
                errordlg('Error. You need to select the first variable to project.');
                return;
            end;

            options = Util.setDefault(options,'var2','');
            if isempty(options.var1)
                errordlg('Error. You need to select the second variable to project.');
                return;
            end;

            %Set the vector with start and end X coordinate of the
            %reference line
            options = Util.setDefault(options,'var1RefStart','');
            options = Util.setDefault(options,'var1RefEnd','');
            options = Util.setDefaultNumberField(options, 'var1RefStart');
            options = Util.setDefaultNumberField(options, 'var1RefEnd');
            if isempty(options.var1RefStart)
                errordlg(['Error. You have to specifi the start reference for ' options.var1]);
                return;
            end;
            if isempty(options.var1RefEnd)
                errordlg(['Error. You have to specifi the end reference for ' options.var1]);
                return;
            end;

            %Set the vector with start and end Y coordinate of the
            %reference line
            options = Util.setDefault(options,'var2RefStart','');
            options = Util.setDefault(options,'var2RefEnd','');
            options = Util.setDefaultNumberField(options, 'var2RefStart');
            options = Util.setDefaultNumberField(options, 'var2RefEnd');
            if isempty(options.var2RefStart)
                errordlg(['Error. You have to specifi the start reference for ' options.var2]);
                return;
            end;
            if isempty(options.var2RefEnd)
                errordlg(['Error. You have to specifi the end reference for ' options.var2]);
                return;
            end;

            %read the source file in IMDC format
            [sourceData, loadOk] = Dataset.loadData(source,0);
            if ~loadOk
                errordlg('Error to read the source file. Please verify the format.');
                return;
            end;

            try
                x = sourceData.(options.var1).data;
                y = sourceData.(options.var2).data;

                xRef = [options.var1RefStart options.var1RefEnd];
                yRef = [options.var2RefStart options.var2RefEnd];

                [xProj,yProj,dist] = Calculate.projectOnRef(x,y,xRef,yRef);

                sizeXproj                 = size(xProj);
                sourceData.Xproj.data     = xProj;
                sourceData.Xproj.longname = 'X Projection';
                sourceData.Xproj.unit     = sourceData.(options.var1).unit;

                dim = {upper(options.var1(1))};
                sourceData.Xproj.dim = repmat(dim, 1, sizeXproj(2));

                sizeYproj                 = size(yProj);
                sourceData.Yproj.data     = yProj;
                sourceData.Yproj.longname = 'Y Projection';
                sourceData.Yproj.unit     = sourceData.(options.var2).unit;

                dim = {upper(options.var2(1))};
                sourceData.Yproj.dim = repmat(dim, 1, sizeYproj(2));

                sizeDist                     = size(dist);
                sourceData.ProyDist.data     = dist;
                sourceData.ProyDist.longname = 'Projection Distance';
                sourceData.ProyDist.unit     = sourceData.(options.var2).unit;

                dim = {upper(options.var2(1))};
                sourceData.ProyDist.dim = repmat(dim, 1, sizeDist(2));

                saveOk = Dataset.saveData(sourceData,source);
                if ~saveOk
                    errordlg('Error. The file could not been saved.');
                    return;
                end;
            catch
                sct = lasterror;
                errordlg([sct.message ' Error. The projection could not be done.']);
                return;
            end;
        end;

    end
end