classdef tbindexitem
    %% Description
    % A TBIndexItem object stores the properties / attributes of an index 
    % item for the matlab help nevigator
    %
    
    %% Properties
    % this object has the following properties:
    %
    % * name: The name and title that will appear in the help navigator
    % * children: The children of the index item. 
    % 

    properties
        name = '';
        children = '';
    end
    
    methods
        function str = toString(obj)
            if isempty(obj.children)
                str = {['<indexitem>' obj.name '</indexitem>']};
            else
                str = {['<indexitem>' obj.name]};
                for ich = 1:length(obj.children)
                    chstr = obj.children(ich).toString;
                end
                str = cat(2,str,chstr);
                str(end+1,1) = {'</indexitem>'};
            end
        end
    end
end
