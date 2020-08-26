function mask = opheimSimplify(x,y,tol)
    % Opheim path simplification algorithm
    %
    % Given a path of vertices V and a tolerance TOL, the algorithm:
    %   1. selects the first vertex as the KEY;
    %   2. finds the first vertex farther than TOL from the KEY and links
    %      the two vertices with a LINE;
    %   3. finds the last vertex from KEY which stays within TOL from the
    %      LINE and sets it to be the LAST vertex. Removes all points in
    %      between the KEY and the LAST vertex;
    %   4. sets the KEY to the LAST vertex and restarts from step 2.
    %
    % The Opheim algorithm can produce unexpected results if the path
    % returns back on itself while remaining within TOL from the LINE.
    % This behaviour can be seen in the following example:
    %
    %   x   = [1,2,2,2,3];
    %   y   = [1,1,2,1,1];
    %   tol < 1
    %
    % The algorithm undesirably removes the second last point. See
    % https://github.com/matlab2tikz/matlab2tikz/pull/585#issuecomment-89397577
    % for additional details.
    %
    % To rectify this issues, step 3 is modified to find the LAST vertex as
    % follows:
    %   3*. finds the last vertex from KEY which stays within TOL from the
    %       LINE, or the vertex that connected to its previous point forms
    %       a segment which spans an angle with LINE larger than 90
    %       degrees.
    %
    % https://raw.githubusercontent.com/matlab2tikz/matlab2tikz/master/src/cleanfigure.m

    mask = false(size(x));
    mask(1) = true;
    mask(end) = true;

    N = numel(x);
    i = 1;
    while i <= N-2
        % Find first vertex farther than TOL from the KEY
        j = i+1;
        v = [x(j)-x(i); y(j)-y(i)];
        while j < N && norm(v) <= tol
            j = j+1;
            v = [x(j)-x(i); y(j)-y(i)];
        end
        v = v/norm(v);

        % Unit normal to the line between point i and point j
        normal = [v(2);-v(1)];

        % Find the last point which stays within TOL from the line
        % connecting i to j, or the last point within a direction change
        % of pi/2.
        % Starts from the j+1 points, since all previous points are within
        % TOL by construction.
        while j < N
            % Calculate the perpendicular distance from the i->j line
            v1 = [x(j+1)-x(i); y(j+1)-y(i)];
            d = abs(normal.'*v1);
            if d > tol
                break
            end

            % Calculate the angle between the line from the i->j and the
            % line from j -> j+1. If
            v2 = [x(j+1)-x(j); y(j+1)-y(j)];
            anglecosine = v.'*v2;
            if anglecosine <= 0;
                break
            end
            j = j + 1;
        end
        i = j;
        mask(i) = true;
    end