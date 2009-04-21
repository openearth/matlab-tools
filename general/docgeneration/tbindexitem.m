classdef tbindexitem
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
