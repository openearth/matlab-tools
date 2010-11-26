classdef MTestCategory
    methods (Static = true)
        function cat = Unit()
            cat = 0;
            MTestCategory.setcategory(cat);
        end
        function cat = Integration()
            cat = 1;
            MTestCategory.setcategory(cat);
        end
        function cat = Performance()
            cat = 2;
            MTestCategory.setcategory(cat);
        end
        function cat = DataAccess()
            cat = 3;
            MTestCategory.setcategory(cat);
        end
        function cat = WorkInProgress()
            cat = 4;
            MTestCategory.setcategory(cat);
        end
        function cat = UserInput()
           cat = 5; 
           MTestCategory.setcategory(cat);
        end
    end
    methods (Static = true, Hidden = true)
        function setcategory(cat)
            if TeamCity.running
                currentTest = TeamCity.currenttest;
                if ~isempty(currentTest)
                    currentTest.Category = cat;
                end
            end
        end
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