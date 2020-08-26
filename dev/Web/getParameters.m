function [parameters] = getParameters(jsonString)
%GETPARAMETERS This function get all the web parameters and transform them
%into the right matlab type
%Example:
%jsonString = '[{"matlabtype":"string","data":"asd"},{"matlabtype":"number","data":"33"},{"matlabtype":"matrix","data":"[0.8147    0.6324    0.9575    0.9572;0.9058    0.0975    0.9649    0.4854;0.1270    0.2785    0.1576    0.8003;0.9134    0.5469    0.9706    0.1419]"},{"matlabtype":"string","data":""},{"matlabtype":"string","data":""}]';

elements = loadjson(jsonString);

for i=1:numel(elements)
    field = elements{i};
    fieldName = strcat('field', num2str(i));
    data = [];
    if isfield(field, 'matlabtype')
        switch field.matlabtype
            case 'string'
                data = field.data;
            case 'number'
                data = str2double(field.data);
                
            case 'vector'
                temp = regexp(field.data,' ','split');
                data = str2double(temp)';
                
                %check the vector direction
                if isfield(field, 'direction')
                    if strcmpi(field.direction, 'column')
                        data = data';
                    end
                end
                
            case 'matrix'
                %the json lib transform automatically into a matrix
                data = loadjson(field.data);
                
            case 'file'
                data = field.data;
                
            otherwise
                
        end
    end
    
    parameters.(fieldName) = data;
end



end

