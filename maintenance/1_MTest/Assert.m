classdef Assert
    methods (Static = true)
        function areequal(expected, realization)
            try
                Assert.typesareequal(expected,realization);
                Assert.variablesizeisequal(expected,realization);
                Assert.variablecontentisequal(expected,realization)
            catch me
                rethrow(me);
            end
        end
        function arenotequal(expected, realization)
                if Assert.typesarenotequal(expected,realization)
                    TODO('Implement');
                end
        end
        function greaterthan()
            try
                Assert.typesareequal(expectedVariable,actualVariable);
                Assert.variablesizeisequal(expetedVariable,actualVariable);
                TODO('Implement');
            catch me
                rethrow(me);
            end
        end
        function smallerthan()
            try
                Assert.typesareequal(expectedVariable,actualVariable);
                Assert.variablesizeisequal(expetedVariable,actualVariable);
                TODO('Implement');
            catch me
                rethrow(me);
            end
        end
        function typesareequal(expected,realization)
            actualClass = class(realization);
            expectedClass = class(expected);
            if ~strcmp(expectedClass,actualClass)
                error('AssertionFailure:UnEqualVarTypes',['Assertion failure:', char(10),...
                    'Expected and Actual value are of different type', char(10),...
                    'Expected is of type: ' expectedClass,...
                    'Actual is of type: ' actualClass]);
            end
        end
    end
    methods (Static = true, Hidden = true)
        function [expectedSize, actualSize] = variablesizeisequal(expetedVariable,actualVariable)
            expectedSize = size(expetedVariable);
            actualSize = size(actualVariable);
            if length(expectedSize) ~= length(actualSize)
                error('AssertionFailure:UnEqualVarSizes',['Assertion faileure:',char(10),...
                    'Number of dimensions in expected variable differs from the number of dimensions of the actual value',char(10),...
                    'Expected has ' length(expectedSize), ' dimensions',char(10),...
                    'Actual has ' length(actualSize), 'dimensions']);
            end
            if ~all(expectedSize==actualSize)
                error('AssertionFailure:UnEqualVarSizes',['Assertion failure:',char(10),...
                    'Size of expected variable differs from the size of the actual variable',char(10),...
                    'Expected size: ', num2str(expectedSize) ,char(10),...
                    'Actual size: ', num2str(actualSize)]);
            end
        end
        function variablecontentisequal(expectedVariable,actualVariable)
            switch class(actualVariable)
                case {'double', 'int', 'int32', 'logical'}
                    if ~isequalwithequalnans(expectedVariable,actualVariable);
                        [location, indices] = Assert.findwronglocationindex(expectedVariable,actualVariable);
                        error('AssertionFailure:ExpectedDiffersFromActual',['Assertion failure:',char(10),...
                            'Expected and actual vallue differ at location (', num2str(indices), ')' ,char(10),...
                            'Expected: ' num2str(expectedVariable(location)),char(10),...
                            'Actual:   ' num2str(actualVariable(location))]);
                    end
                case 'char'
                    if ~strcmp(expectedVariable,actualVariable)
                        error('AssertionFailure:ExpectedDiffersFromActual',['Assertion failure:',char(10),...
                            'Expected and actual vallue were different',char(10),...
                            'Expected: ' expectedValue,char(10),...
                            'Actual:   ' actualValue]);
                    end
                case 'cell'
                    cellfun(@assertvariablecontentisequal,expectedVariable,actualVariable,'ErrorHandler',@handlecellasserterror);
                case 'struct'
                    
                otherwise
                    error('AssertionFailure:UnknownVarTypes',['Cannot assert variables of type "', actualClass, '"']);
            end
            
        end
        function handlecellasserterror(varargin)
            location = errorStruct.index;
            indices = findindicesoflocation(location, variableSize);
            error('AssertionFailure:ExpectedDiffersFromActual',['Assertion failure:',char(10),...
                'Expected and actual cell arrays differ at location (', num2str(indices), ')']);
        end
        function [location, indices] = findwronglocationindex(expectedVariable,actualVariable)
            %% get location
            location = find(expectedVariable~=actualVariable,1,'first');
            if nargout > 1
                variableSize = size(actualVariable);
                indices = Assert.findindicesoflocation(location, variableSize);
            end
        end
        function [location, indices] = findcorrectlocationindex(expectedVariable,actualVariable)
            %% get location
            location = find(expectedVariable==actualVariable,1,'first');
            if nargout > 1
                variableSize = size(actualVariable);
                indices = findindicesoflocation(location, variableSize);
            end
        end
        function indices = findindicesoflocation(location, variableSize)
            indices = nan(1,length(variableSize));
            if isnumeric(location)
                str = '[';
                for i = 1:length(indices)
                    str = cat(2,str,'indices(',num2str(i),'), ');
                end
                str = cat(2,str,'] = ind2sub(variableSize,location);');
                eval(str);
            end
        end
        function tf = typesarenotequal(expected,realization)
            actualClass = class(realization);
            expectedClass = class(expected);
            tf = strcmp(expectedClass,actualClass);
        end
    end
end

