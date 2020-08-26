classdef Fit < handle
    %Public properties
    properties
        Property1;
    end

    %Dependand properties
    properties (Dependent = true, SetAccess = private)

    end

    %Private properties
    properties(SetAccess = private)

    end

    %Default constructor
    methods
        function obj = Template(property1)
            if nargin > 0
                obj.Property1 = property1;
            end
        end
    end

    %Set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end

    %Get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end

    %Public methods
    methods

    end

    %Stactic methods
    methods (Static)
        function y = applyExp(x,coef)
            % calculate fitted values for the exponential equation
            %
            % INPUT:
            %  - x: vector with x values
            %  - coef: coefficients determined from exponential fit
            % 
            % OUTPUT:
            %  - y: calculated values of the fitted equation at all x
            %  - locations
            y = coef(2)*exp(coef(1)*x) ;
        end

        function y = applyLog(x,coef)
            % calculate fitted values for the logaritmic equation
            % 
            % INPUT:
            %  - x: vector with x values
            %  - coef: cooefficient determined from logaritmic fit
            %
            % OUTPUT:
            %  - y: calculated values of the fitted eequation at all x
            % locations

            x = Util.negative2nan(x);
            y = coef(1)*log(x) + coef(2);
        end

        function y = applyPolynomial(x,coef)
            % calculate fitted values for the polynomial equation
            %
            % INPUT:
            %  - x: vector with x values
            %  - coef: coefficient determined from polynomial fit
            % OUTPUT:
            %  - y: calculated values of the fitted eequation at all x
            % locations

            y = polyval(coef,x);
        end

        function y = applyPower(x,coef)
            % calculate fitted values for a power law
            %
            % INPUT:
            %  - x: vector with x values
            %  - coef: coefficient determined from power law fit
            % OUTPUT:
            %  - y: calculated values of the fitted eequation at all x
            % locations
            y = coef(2) .* x.^coef(1);
        end

        function equation = equationExp(coef,options)
            %coef: result of fitPolynomial
            % options.format: number format

            % default output format

            if ~isfield(options,'format')
                options.format= '%8.5f';
            end

            % start the equation with the output part
            equation = 'y = ';
            % constant term
            equation = [equation, num2str(coef(2),options.format)];

            % exp term
            equation = [equation,' exp(',num2str(coef(1),options.format),' x)'];

        end

        function equation = equationLog(coef,options)
            %coef: result of fitPolynomial
            % options.format: number format

            % default output format

            if ~isfield(options,'format')
                options.format= '%8.5f';
            end

            % start the equation with the output part
            equation = 'y = ';
            % log term
            equation = [equation,num2str(coef(1),options.format),' ln(x)'];

            % constant term
            equation = [equation,Fit.writeCoef(coef(2),options)];

        end

        function equation = equationPolynomial(coef,options)
            %coef: result of fitPolynomial
            % options.format: number format

            % default output format

            if nargin == 1 || ~isfield(options,'format')
                options.format= '%8.5f';
            end

            % start the equation wity the output part
            equation = 'y = ';
            lengthCoef = length(coef);
            % nonlinear term of polynomial
            equation = [equation,num2str(coef(1),options.format),' x^',num2str(lengthCoef-1)];
            for i = 2:lengthCoef-2
                equation = [equation,Fit.writeCoef(coef(i),options),' x^',num2str(lengthCoef-i)];
            end
            % linear term
            if lengthCoef>=2
                equation = [equation,Fit.writeCoef(coef(lengthCoef-1),options),' x'];
            end
            % constant term
            equation = [equation,Fit.writeCoef(coef(lengthCoef),options)];

        end

        function equation = equationPower(coef,options)
            %coef: result of fitPolynomial
            % options.format: number format

            % default output format

            if ~isfield(options,'format')
                options.format= '%8.5f';
            end

            % start the equation with the output part
            equation = 'y = ';
            % constant term
            equation = [equation, num2str(coef(2),options.format)];

            % exp term
            equation = [equation,' x^{',num2str(coef(1),options.format),'}'];
        end

        function coef = fitExp(x,y)
            % fits the equations y = coef(1)exp(x) + coef(2)
            %
            % INPUT:
            %  - x: x-data
            %  - y: y-data
            % OUTPUT:
            %  - coef: fitted coefficients in the equations
            %
            
            % check input data

            y = Util.negative2nan(y);
            x = Util.makeColVec(x);
            y = Util.makeColVec(y);
            
            % delete nan values from the data
            [x,y] = Util.deleteNansColumn(x,y);

            % fit the coefficients
            y = log(y);
            coef = real(polyfit(x,y,1));
            % apply transformation (log(y) = ax+b => y = exp(ax+b) = exp(ax)*exp(b) = C*exp(ax)
            coef(2) = exp(coef(2));

        end

        function coef = fitLog(x,y)
            % fits the equations y = coef(1)log(x) + coef(2)
            %
            % INPUT:
            %  - x: x-data
            %  - y: y-data
            % OUTPUT:
            %  - coef: fitted coefficients in the equations

            % check input data

            x = Util.negative2nan(x);

            % delete nan values from the data
            % delete nan values from the data
            if size(x,2)>1
                x = Util.deleteNansColumn(x);
            else
                x = Util.deleteNansRow(x);
            end
            if size(y,2)>1
                y = Util.deleteNansColumn(y);
            else
                y = Util.deleteNansRow(y);
            end
            %[x,y] = Util.deleteNans(x,y);

            % fit the coefficients
            x = log(x);
            coef = real(polyfit(x,y,1));
        end

        function coef = fitPolynomial(x,y,options)
            % fits a polynomial
            %
            % INPUT
            %  - x: x-data
            %  - y: y-data
            %  - options.order;     order of polynomial: 1 = linear, 2 is parabolic etc.
            %  - option.throughzero  true if polynomial is forces through zero, 0 otherwise;
            % OUTPUT
            %  - coef: fitted coefficients (as can be used in polyval)

            if nargin == 2 || ~isfield(options,'order')
                options.order = 1;
            end

            if nargin == 2 || ~isfield(options,'throughzero')
                options.throughzero = 0;
            end
            % delete nan values from the data
            if size(x,2)>1
                x = Util.deleteNansColumn(x);
            else
                x = Util.deleteNansRow(x);
            end
            if size(y,2)>1
                y = Util.deleteNansColumn(y);
            else
                y = Util.deleteNansRow(y);
            end

            % fit the coefficients
            coef = real(polyfit_zero(x,y,options.order,options.throughzero));

        end

        function coef = fitPower(x,y)
            % fits the equations y = coef(2) x^coef(1)
            %
            % INPUT:
            %  - x: x-data
            %  - y: y-data
            % OUTPUT:
            %  - coef: fitted coefficients

            % check input data
            x = Util.negative2nan(x);
            y = Util.negative2nan(y);

            % delete nan values from the data
            if size(x,2)>1
                x = Util.deleteNansColumn(x);
            else
                x = Util.deleteNansRow(x);
            end
            if size(y,2)>1
                y = Util.deleteNansColumn(y);
            else
                y = Util.deleteNansRow(y);
            end

            % fit the coefficients
            x = log(x);
            y = log(y);
            coef = real(polyfit(x,y,1));
            % apply transformation (log(y) = a log(x)+b => y = exp(aLog(x)+b) = exp(log(x)a)*exp(b) = C*x^a
            coef(2) = exp(coef(2));

        end

        function r2 = rSquared(yorg,yfit)
            % determines goodness of fit
            %
            % INPUT:
            %  - yorg = origional y values
            %  - yfit : fitted values (from applyPolynomial, applyExponential)
            % OUTPUT:
            %  - R2 = R^2 (goodness of fit)

            % make sure data are in columns
            if size(yorg,2)>1
                yorg = yorg';
            end

            if size(yfit,2)>1
                yfit = yfit';
            end

            [yorg,yfit] = Util.deleteNans(yorg,yfit);
            % calculate correlation coefficient

            r = corr(yorg,yfit);
            r2 = r.^2;
            %r2 = 1 - sum((yfit-yorg).^2)./sum((yorg-mean(yorg)).^2);
        end

        function coefString = writeCoef(coef,options)
            % writes the coefficient in an equation to nice format
            if coef>=0
                coefString  = [' + ',num2str(coef,options.format)];
            else
                coefString  = [' - ',num2str(-coef,options.format)];
            end
        end
        
        function [a,b,c] = fitLine(x,y)
            % determines coeffcient of a line of the form ax+by +c = 0
            %
            % [a,b,c] = fitLine(x,y)
            %
            % INPUT:
            %  - x: column vector with x coordinates
            %  - y: column vector with y coordinates
            %
            % OUTPUT:
            % -a, b and c: fitted values for the equation ax+by +c = 0
            
            % delete nans
            mask = isnan(x) | isnan(y);
            x = x(~mask);
            y = y(~mask);
            
            %check where the largest variance
            if std(x)>std(y)
                %fit y = ax+b
                p = polyfit(x,y,1);
                a = p(1);
                b = -1;
                c = p(2);
            else
                %fit x = ay+b
                p = polyfit(y,x,1);
                a = -1;
                b = p(1);
                c = p(2);
            end
        end
            

    end
end