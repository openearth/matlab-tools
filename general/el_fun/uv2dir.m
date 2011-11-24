function dir = uv2dir(u,v,convention)
% UV2DIR derives the direction (in cartesian or nautical convention) from the u and v data
% 
% u = u or x vector of parameter
% v = v or y vector of parameter
% convention = either 'cartesian' or 'nautical'
%
% where:
% 'cartesian', the direction to where the vector points
% 'nautical', the direction where the vector comes from
% if no convention is assigned, 'cartesian'  convention is applied

% created by E.Moerman 24-11-2011

if nargin == 2,
    convention='cartesian';
end;

if u >= 0 && v >= 0 % quadrant 1, 0-90 degrees
    
    dir = 90 - rad2deg(atan(v./u));
    dir = mod(dir,360);
    if strcmp(convention,'nautical')
        dir = mod(dir+180,360);
    end
    
elseif u >= 0 && v < 0 % quadrant 2, 90-180 degrees
    
    dir = 90 + abs(rad2deg(atan(v./u)));
    dir = mod(dir,360);
    if strcmp(convention,'nautical')
        dir = mod(dir+180,360);
    end
    
elseif u < 0 && v < 0 % quadrant 3, 180-270 degrees
    
    dir = 180 + abs(rad2deg(atan(u./v)));
    dir = mod(dir,360);
    if strcmp(convention,'nautical')
        dir = mod(dir+180,360);
    end
    
elseif u < 0 && v >= 0 % quadrant 4, 270-360 degrees
    
    dir = 360 - abs(rad2deg(atan(u./v)));
    dir = mod(dir,360);
    if strcmp(convention,'nautical')
        dir = mod(dir+180,360);
    end
    
elseif u == 0 && v > 0
    dir = 360;
    if strcmp(convention,'nautical')
        dir = mod(dir+180,360);
    end
    
elseif u == 0 && v < 0
    dir = 180;
    if strcmp(convention,'nautical')
        dir = mod(dir+180,360);
    end
    
elseif u < 0 && v == 0
    dir = 270;
    if strcmp(convention,'nautical')
        dir = mod(dir+180,360);
    end
    
elseif u > 0 && v == 0
    dir = 90;
    if strcmp(convention,'nautical')
        dir = mod(dir+180,360);
    end

end
