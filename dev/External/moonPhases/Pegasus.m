%--------------------------------------------------------------------------
%
% Pegasus: Root finder using the Pegasus method
%
% Inputs:
%   func  Pointer to the function to be examined
%   x1    Lower bound of search interval
%   x2    Upper bound of search interval
%
% Outputs:
%   x2          Root found (valid only if Success is true)
%
% Last modified:   2015/08/12   M. Mahooti
% 
%--------------------------------------------------------------------------
function x2 = Pegasus(func,x1,x2)

itermax = 300;        % Maximal number of iterations
abserr = 0;           % absolute error
relerr = (4 * eps);   % relative error

iter = 0;             % Initialize iteration counter

f1 = func(x1);        % Function values at *x1, *x2
f2 = func(x2);

if (f1 * f2 == 0)     % One starting value is a root
    if (f1 == 0)
        x2 = x1;
        f2 = 0;
    end
    return
end

while (iter <= itermax)          % Pegasus iteration
    iter = iter+1;
    s12 = (f2 - f1) / (x2 - x1); % Secant slope
    x3  = x2 - f2 / s12;         % new approximation
    f3  = func(x3);
    if (f2 * f3 <= 0)            % new inclusion interval
        x1 = x2;
        f1 = f2;
    else
        f1 = f1 * f2 / ( f2 + f3 );
    end
    x2 = x3;
    f2 = f3;
    if ( abs(f2) < eps ) % Root found
        break
    end
    % Break-off with small step size
    if ( abs(x2 - x1) <= abs(x2) * relerr + abserr )
        break
    end
end

if ( abs(f1) < abs(f2) ) % Choose approximate root with least magnitude function value
    x2 = x1;
    f2 = f1;
end

end

