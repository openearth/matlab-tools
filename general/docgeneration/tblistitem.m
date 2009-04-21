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
                str{end+1,:} = ['<icon>icons' filesep filesep obj.icon '</icon>'];
            end
            str{end+1,:} = '</listitem>'; %#ok<AGROW>;
        end
    end
end