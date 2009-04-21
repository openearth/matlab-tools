classdef tbcontentitem
    properties
        name = '';
        target = '';
        icon = '';
        
        children = [];
    end
    
    methods
        function obj = tbcontentitem(varargin)
            if nargin==0
                obj(1)=[];
                return
            end
            if any(strcmp(varargin,'fcnref'))
                %This is the location where function references must be
                %placed
                obj.name = '#tb_fcnref';
                obj.target = 'n.t.b.';
                obj.icon = '';
            else
                obj = setProperty(obj,varargin);
            end
        end
        function obj = prepare(obj)
            if strcmp(obj.name,'#tb_fcnref');
                % not a real item, this must be replaced by function pages
                % html... create string at toolbox level
                obj = '#tb_fcnref';
            elseif isempty(obj.name)
                TODO('Give this object a name please.....');
            else
                % prepare item call and icon
                % correct callback
                obj = obj.validatetarget;
            end
        end
        function obj = validatetarget(obj)
            if isempty(obj.target)
                obj.target = 'html/blank.htm';
            end
        end
        function str = toString(obj)
            % create xml code for helptoc.xml to add this particular item
            % and its children
            str{1,1} = ['<tocitem'...
                ' target="' strrep(obj.target,filesep,'/') '"'...
                ' image="$toolbox/matlab/icons/' obj.icon '.gif">'...
                strrep(obj.name,filesep,[filesep filesep])];
            
            if ~isempty(obj.children)
                for ich=1:length(obj.children)
                    obj.children(ich) = obj.children(ich).prepare;
                    str = cat(1,str,obj.children(ich).toString);
                end
            end
            str{end+1,:} = '</tocitem>'; %#ok<AGROW>;
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
                obj.icon = ico;
            else
                warning('Toolbox:IconNotFound','Icon was not found.');
            end
        end
    end
end