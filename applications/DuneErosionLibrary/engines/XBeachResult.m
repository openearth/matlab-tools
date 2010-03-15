classdef XBeachResult < DuneErosionResult
    
    properties (SetAccess = 'protected')
        % profiles (time dependant?)
        xPreStorm;
        zPreStorm;
        xPostStorm;
        zPostStorm;
    end
    
    properties
    end
    
    methods
        function obj = XBeachResult(varargin)
            % use XB_read_result
        end
    end
end