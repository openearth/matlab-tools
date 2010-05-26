%% TBContentItem
% TBContentItem class definition of the tbcontentitem

%%
classdef tbcontentitem
    %% Description
    % A TBContentItem object stores the properties / attributes of an item 
    % for the table of contents of the help navigator
    %
    
    %% Properties
    % this object has the following properties:
    %
    % * name: The name and title that will appear in the help navigator
    % * target: The target that is loaded when the user clicks the content
    %           item.
    % * icon: The name of the icon that is used for this toc-item. 
    % 
    
    properties (SetAccess = public, GetAccess = public)
        % General properties
        name = '';
        target = '';
        icon = '';
        
        % children
        children = [];
    end
    
    methods
        %% Constructor method
        function obj = tbcontentitem(varargin)
            %%
            % Check input arguments.
            
            if nargin==0
                obj(1)=[];
                return
            end
            
            %%
            % * If the input argument is 'fcnref' The toc-item will reference
            % to html pages created for a certain toolbox. This requires a
            % special setup of the object.
            % * If the input does not contain 'fcnref', the properties are
            % set with the use of setproperty.
            
            if any(strcmp(varargin,'fcnref'))
                %This is the location where function references must be
                %placed
                obj.name = '#tb_fcnref';
                obj.target = 'n.t.b.';
                obj.icon = '';
            else
                obj = setproperty(obj,varargin);
            end
        end
        
        %% methods to prepare the content item to be incorporated in a toolbox documentation
        function obj = prepare(obj)
            % PREPARE prepares the object to be incorporated in a toolbox documentation
            %
            % This function checks the name of the toc item (#tb_fcnref
            % means reference to a toolbox), the name of the object and
            % validates the target.
            %
            
            % check the name of the object
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
            % VALIDATETARGET validates the target of the toc item
            %
            % This method checks the target. If it is blank, reference is
            % made to the blank htm page. 
            if isempty(obj.target)
                obj.target = 'html/blank.htm';
            end
        end
        function [str obj] = toString(obj)
            % TOSTRING converts the objject to an xml string
            %
            % This mehtod converts the object to an xml string that can be 
            % put into an helptoc.xml file to include this object and its 
            % children.
            
            % make basic string
            str{1,1} = ['<tocitem'...
                ' target="' strrep(obj.target,filesep,'/') '"'...
                ' image="$toolbox/matlab/icons/' obj.icon '.gif">'...
                strrep(obj.name,filesep,[filesep filesep])];
            
            % process children and add to string
            if ~isempty(obj.children)
                for ich=1:length(obj.children)
                    obj.children(ich) = obj.children(ich).prepare;
                    str = cat(1,str,obj.children(ich).toString);
                end
            end
            
            % conclude with the closure of the main tocitem
            str{end+1,:} = '</tocitem>';
        end
        
        %% set methods
        function obj = set.icon(obj,ico)
            
            %% check input
            if isempty(ico)
                obj.icon = '';
                return
            end
            
            %% if the input is not empty verify the name of the icon
            iconms = obj.iconnames; %#ok<MCSUP>
            if ~ischar(ico)
                error('Toolbox:NoIcon','Icon should be specified as a char');
            end
            if any(strcmp(iconms,ico))
                obj.icon = ico;
            else
                % including a home made icon is possible, but this needs to
                % be stored somewhere in the docroot. This is not possible
                % on our network drive...
                warning('Toolbox:IconNotFound','Icon was not found.');
            end
        end
        function obj = set.name(obj,nm)
            %% check input
            if isempty(nm)
                obj.name = '';
                return
            end
            
            %% if the name includes an & sign replace it by "and"
            if ~isempty(strfind(nm,'&'))
                nm = strrep(nm,'&','and');
            end
            obj.name = nm;
        end
    end
    methods (Static = true)
        function iconms = iconnames()
            iconms = {'HDF_SDS','HDF_VData','HDF_VGroup','HDF_filenew','HDF_grid','HDF_gridfieldset','HDF_object01','HDF_object02','HDF_point','HDF_pointfieldset','HDF_rasterimage','HDF_swath','HDF_swathfieldset','boardicon','book_link','book_mat','book_sim','bookicon','chain','csh_icon','demoicon','figureicon','foldericon','greenarrowicon','greencircleicon','guideicon','helpicon','matlabicon','notesicon','pageicon','pagesicon','paintbrush','pdficon','pin_icon','profiler','reficon','simulinkicon','text_arrow','tool_align','tool_arrow','tool_colorbar','tool_data_cursor','tool_double_arrow','tool_edgecolor','tool_ellipse','tool_facecolor','tool_legend','tool_line','tool_rectangle','tool_rotate_3d','tool_text','tool_text_arrow','unknownicon','upfolder','view_zoom_in','view_zoom_out','warning','webicon'}';
        end
    end
end