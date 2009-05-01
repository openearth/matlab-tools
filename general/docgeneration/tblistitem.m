classdef tblistitem
    properties
        targetdir = '';
        label = '';
        icon = '';
        call = '';
    end
    methods
        function obj = tblistitem(varargin)
            if nargin==0
                obj(1) = [];
            else
                obj = setProperty(obj,varargin);
            end
        end
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
            end
            str{end+1,:} = '</listitem>'; %#ok<AGROW>;
        end
        function obj = set.icon(obj,ico)
            if isempty(ico)
                obj.icon = '';
                return
            end
            %             iconsavailable = {'HDF_SDS.gif','HDF_VData.gif','HDF_VGroup.gif','HDF_filenew.gif','HDF_grid.gif','HDF_gridfieldset.gif','HDF_object01.gif','HDF_object02.gif','HDF_point.gif','HDF_pointfieldset.gif','HDF_rasterimage.gif','HDF_swath.gif','HDF_swathfieldset.gif','boardicon.gif','book_link.gif','book_mat.gif','book_sim.gif','bookicon.gif','chain.gif','csh_icon.gif','demoicon.gif','figureicon.gif','foldericon.gif','greenarrowicon.gif','greencircleicon.gif','guideicon.gif','helpicon.gif','matlabicon.gif','notesicon.gif','pageicon.gif','pagesicon.gif','paintbrush.gif','pdficon.gif','pin_icon.gif','profiler.gif','reficon.gif','simulinkicon.gif','text_arrow.gif','tool_align.gif','tool_arrow.gif','tool_colorbar.gif','tool_data_cursor.gif','tool_double_arrow.gif','tool_edgecolor.gif','tool_ellipse.gif','tool_facecolor.gif','tool_legend.gif','tool_line.gif','tool_rectangle.gif','tool_rotate_3d.gif','tool_text.gif','tool_text_arrow.gif','unknownicon.gif','upfolder.gif','view_zoom_in.gif','view_zoom_out.gif','warning.gif','webicon.gif'};
            % $toolbox/matlab/icons/.......
            iconnames = {'HDF_SDS','HDF_VData','HDF_VGroup','HDF_filenew','HDF_grid','HDF_gridfieldset','HDF_object01','HDF_object02','HDF_point','HDF_pointfieldset','HDF_rasterimage','HDF_swath','HDF_swathfieldset','boardicon','book_link','book_mat','book_sim','bookicon','chain','csh_icon','demoicon','figureicon','foldericon','greenarrowicon','greencircleicon','guideicon','helpicon','matlabicon','notesicon','pageicon','pagesicon','paintbrush','pdficon','pin_icon','profiler','reficon','simulinkicon','text_arrow','tool_align','tool_arrow','tool_colorbar','tool_data_cursor','tool_double_arrow','tool_edgecolor','tool_ellipse','tool_facecolor','tool_legend','tool_line','tool_rectangle','tool_rotate_3d','tool_text','tool_text_arrow','unknownicon','upfolder','view_zoom_in','view_zoom_out','warning','webicon'};
            if ~ischar(ico)
                error('Toolbox:NoIcon','Icon should be specified as a char');
            end
            if any(strcmp(iconnames,ico))
                obj.icon = fullfile('$toolbox/matlab/icons/',[ico,'.gif']);
            else
                warning('Toolbox:IconNotFound','Icon was not found.');
            end
        end

    end
end