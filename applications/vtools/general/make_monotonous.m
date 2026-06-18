function y_interp = make_monotonous(x, y)
    % MAKE_MONOTONOUS Remove non-monotonous points and interpolate
    %
    % Syntax:
    %   y_interp = make_monotonous(x, y)
    %
    % Input:
    %   x - Independent variable (e.g., discharge values)
    %   y - Dependent variable to be made monotonously increasing
    %
    % Output:
    %   y_interp - Interpolated y-values that are monotonously increasing
    %
    % Description:
    %   This function removes points where y is not monotonously increasing
    %   and then interpolates the values using griddedInterpolant to estimate
    %   values at the original x locations based on the monotonous subset.
    
    % Ensure inputs are column vectors
    x = x(:);
    y = y(:);
    
    % Keep points that are strictly above all previous values.
    % This removes runs of consecutive low points after a local high.
    prev_max = [y(1); cummax(y(1:end-1))];
    valid_idx = y > prev_max;
    valid_idx(1) = true;
    
    % Keep only valid points
    x_valid = x(valid_idx);
    y_valid = y(valid_idx);
    
    % Check if we have enough points for interpolation
    if numel(x_valid) < 2
        warning('Not enough monotonous points for interpolation');
        y_interp = y;
        return;
    end
    
    % Create interpolant from valid points
    f = griddedInterpolant(x_valid, y_valid, 'linear', 'nearest');
    
    % Interpolate to get values at all original x positions
    y_interp = f(x);
end
