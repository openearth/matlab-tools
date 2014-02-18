classdef setproperty < oop.handle
    %% abstract class with generic function to parse varargin. Depends on properties
    methods
        function set(self,varargin)
            if nargin == 1
                % short circuit when nothing to set
                return
            end
            
            % use arrayfun when assignments to multiple objects are made simultaneously
            if numel(self)>1
                arrayfun(@(self) self.set(varargin{:}),self);
            end
            
            % input check
            
            % possible are keyword/value pairs, or a single struct
            if nargin == 2
                % assume struct
                assert(isstruct(varargin{1}),...
                    'Could not set object of class ''%s'',\nExpected varargin to be a single struct, or keyword/value pairs',class(self));
                prop_names     = fieldnames(varargin{1});
                prop_values    = struct2cell(varargin{1});
            else
                % check for odd number of inputs
                assert(rem(nargin,2)==1,...
                    'Could not set object of class ''%s'',\nExpected varargin to be a single struct, or keyword/value pairs',class(self));
                prop_names     = varargin(1:2:end);
                prop_values    = varargin(2:2:end);
                
            end
            
            availabe_props = properties(self);
            
            for ii = 1:length(prop_names)
                prop_name = prop_names{ii};
                % allow property assignment with different case with
                % warnings
                n = strcmpi(prop_name,availabe_props);
                if any(n)
                    % if there is exactly one match, check case
                    if sum(n) == 1 && ~strcmp(prop_name,availabe_props{n})
                        error('Could not set ''%s'' for object of class ''%s'',\n Did you mean ''%s''?',...
                            prop_name,class(self),availabe_props{n});
                    end
                    if ~isequaln(self.(prop_name),prop_values{ii})
                        % pass non-default values to self
                        self.(prop_name) = prop_values{ii};
                    end
                else
                    msg = [...
                        sprintf('Unknown property: ''%s'' for object of class ''%s''\n',prop_name,class(self)),...
                        sprintf('Available properties are:\n'),...
                        sprintf('   %s \n',availabe_props{:})];                   
                    error('TEXTBOX:IllegalProperty',...
                        msg);
                end
            end
        end
    end
end