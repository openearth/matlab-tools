function dist = distance(x1        ,y1        ,x2        ,y2        , sferic)

% distance: Calculates distance (m) between 2 poinst, either sferical or cartesian coordinates
%
%    Function: Calculates distance between two points on earth
% Method used: Circular distance when sferic is true,
%              Euclidic distance when sferic is false
%

    if sferic
       %
       ddegrad    = pi/180.;
       dearthrad  = 6378137.0;
       %
       x1rad = x1*ddegrad;
       x2rad = x2*ddegrad;
       y1rad = y1*ddegrad;
       y2rad = y2*ddegrad;
       %
       xcrd1 = cos(y1rad).*sin(x1rad);
       ycrd1 = cos(y1rad).*cos(x1rad);
       zcrd1 = sin(y1rad);
       %
       xcrd2 = cos(y2rad).*sin(x2rad);
       ycrd2 = cos(y2rad).*cos(x2rad);
       zcrd2 = sin(y2rad);
       %
       dslin = sqrt((xcrd2-xcrd1).^2 + (ycrd2-ycrd1).^2 + (zcrd2-zcrd1).^2);
       alpha = asin(dslin/2.0);
       dist  = dearthrad*2.0*alpha;
    else
       xcrd1 = x1;
       xcrd2 = x2;
       ycrd1 = y1;
       ycrd2 = y2;
       dist  = sqrt((xcrd2 - xcrd1).^2 + (ycrd2 - ycrd1).^2);
    end
