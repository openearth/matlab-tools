classdef TestCategory
    methods (Static = true)
        function out = Unit()
            out = 0;
        end
        function out = Intergration()
            out = 1;
        end
        function out = Performance()
            out = 2;
        end
        function out = DataAccess()
            out = 3;
        end
        function out = WorkInProgress()
            out = 4;
        end
        function out = UserInput()
           out = 5; 
        end
    end
    methods (Static = true, Hidden = true)
        function str = toString(int)
            switch int
                case 0
                    str = 'Unit';
                case 1
                    str = 'Integration';
                case 2
                    str = 'Performance';
                case 3
                    str = 'Data Access';
                case 4
                    str = 'Work In Progress';
                case 5
                    str = 'User Input';
                otherwise
                    str = 'Unknown';
            end
        end
    end
end