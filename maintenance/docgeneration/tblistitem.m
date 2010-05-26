%% TBListItem
% TBListItem class definition of the tblistitem

classdef tblistitem
    %% Description
    % A TBListItem object stores the properties / attributes of an item 
    % for the toolbox tab in the matlab start menu.
    %
    
    %% Properties
    % this object has the following properties:
    %
    % * targetdir: directory name of the directory in which the documentation is going to be created.
    % * label: The name of the list item.
    % * icon: The name of the icon that is used for this list-item. 
    % * call: The call to matlab that is exeecuted when the user clicks the list item.
    % 

    properties
        targetdir = '';
        label = '';
        icon = '';
        call = '';
    end
    methods
        %% Constructor method
        function obj = tblistitem(varargin)
            if nargin==0
                obj(1) = [];
            else
                obj = setproperty(obj,varargin);
            end
        end
        %% Publication methods
        function obj = prepare(obj)
            % correct callback
            obj = obj.validatecall;
            % copy icon to destination
            obj = obj.prepareicon;
        end
        function obj = validatecall(obj)
            [dum status] = urlread(obj.call);
            if status
                obj.call = ['web ' obj.call ' -browser'];
            end
        end
        function obj = prepareicon(obj)
            % check whether icon exists
            icondir = fullfile(obj.targetdir,'icons');
            if exist(obj.icon,'file')
                % copy file to icons dir and remove original path
                if ~strcmpi(fileparts(which(obj.icon)),icondir)
                    [dum name ext] = fileparts(which(obj.icon));
                    copyfile(which(obj.icon),fullfile(icondir,[name ext]));
                end
                [path icon ext] = fileparts(which(obj.icon));
                obj.icon = [icon ext];
            elseif strncmp(obj.icon,'$toolbox',8)
                % Do nothing, icon is already ok
            else
                % empty icon ==> default will be used
                warning('Could not find icon'); %#ok<WNTAG>
                obj.icon = [];
            end
        end
        function str = toString(obj)
            % create xml code for info.xml to add this particular startmenu
            % item
            str{1,:} = '<listitem>'; %#ok<AGROW>
            str{end+1,:} = ['<label>' obj.label '</label>'];
            str{end+1,:} = ['<callback>' strrep(obj.call,filesep,[filesep filesep]) '</callback>'];
            if ~isempty(obj.icon)
                if strncmp(obj.icon,'$toolbox',8)
                    str{end+1,:} = ['<icon>' strrep(obj.icon,filesep,'/') '</icon>'];
                else
                    str{end+1,:} = ['<icon>icons/' obj.icon '</icon>'];
                end
            else
                str{end+1,:} = '<icon>$toolbox/matlab/icons/pageicon.gif</icon>';
            end
            str{end+1,:} = '</listitem>'; %#ok<AGROW>;
        end
        %% Property set methods
        function obj = set.icon(obj,ico)
            if isempty(ico)
                obj.icon = '';
                return
            end
            % $toolbox/matlab/icons/.......
            % $help/
            iconms = obj.iconnames;
            if ~ischar(ico)
                error('Toolbox:NoIcon','Icon should be specified as a char');
            end
            if any(strcmp(iconms,ico))
                obj.icon = fullfile('$toolbox/matlab/icons/',[ico,'.gif']);
            else
                warning('Toolbox:IconNotFound','Icon was not recognized as one of the build in icond in matlab. It is also possible to build in a full path of an icon. This is not supported in this function.');
            end
        end
    end
    methods (Static = true)
        function iconms = iconnames()
            iconms = {'HDF_SDS','HDF_VData','HDF_VGroup','HDF_filenew','HDF_grid','HDF_gridfieldset','HDF_object01','HDF_object02','HDF_point','HDF_pointfieldset','HDF_rasterimage','HDF_swath','HDF_swathfieldset','boardicon','book_link','book_mat','book_sim','bookicon','chain','csh_icon','demoicon','figureicon','foldericon','greenarrowicon','greencircleicon','guideicon','helpicon','matlabicon','notesicon','pageicon','pagesicon','paintbrush','pdficon','pin_icon','profiler','reficon','simulinkicon','text_arrow','tool_align','tool_arrow','tool_colorbar','tool_data_cursor','tool_double_arrow','tool_edgecolor','tool_ellipse','tool_facecolor','tool_legend','tool_line','tool_rectangle','tool_rotate_3d','tool_text','tool_text_arrow','unknownicon','upfolder','view_zoom_in','view_zoom_out','warning','webicon'}';
        end
    end
end