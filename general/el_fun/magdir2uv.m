function [u,v] = magdir2uv(mag,dir,convention)
% magdir2uv derives the u and v component from the magnitude and direction data
%
% [u,v] = MAGDIR2UV(mag,dir,convention)
% -------------------------------------------------------------------------
% u          = u-component of magnitude
% v          = v-component of magnitude
% mag        = magnitude parameter
% dir        = directional parameter in degrees
% convention = either 'cartesian' or 'nautical'
%
% where:
% 'cartesian', the direction to where the vector points
% 'nautical', the direction where the vector comes from
% if no convention is assigned, 'cartesian'  convention is applied
% note that both convention are considered clockwise from geographic North

% created by E.Moerman 08-08-2012

if nargin == 2,
    convention='cartesian';
end;

for ii = 1:size(dir,1)
    for jj=1:size(dir,2)
        
        if dir(ii,jj) > 0 && dir(ii,jj) < 90 % qu(ii,jj)adrant 1, 0-90 degrees
            if strcmp(convention,'cartesian')
                u(ii,jj) = sind(dir(ii,jj)).*mag(ii,jj);
                v(ii,jj) = cosd(dir(ii,jj)).*mag(ii,jj);
            else
                u(ii,jj) = sind(dir(ii,jj)).*mag(ii,jj).*-1;
                v(ii,jj) = cosd(dir(ii,jj)).*mag(ii,jj).*-1;
            end
            
        elseif dir(ii,jj) > 90 && dir(ii,jj) < 180 % qu(ii,jj)adrant 2, 90-180 degrees
            if strcmp(convention,'cartesian')
                u(ii,jj) = cosd(dir(ii,jj)-90).*mag(ii,jj);
                v(ii,jj) = sind(dir(ii,jj)-90).*mag(ii,jj).*-1;
            else
                u(ii,jj) = cosd(dir(ii,jj)-90).*mag(ii,jj).*-1;
                v(ii,jj) = sind(dir(ii,jj)-90).*mag(ii,jj);
            end
            
        elseif dir(ii,jj) > 180 && dir(ii,jj) < 270 % qu(ii,jj)adrant 3, 180-270 degrees
            if strcmp(convention,'cartesian')
                u(ii,jj) = sind(dir(ii,jj)-180).*mag(ii,jj).*-1;
                v(ii,jj) = cosd(dir(ii,jj)-180).*mag(ii,jj).*-1;
            else
                u(ii,jj) = sind(dir(ii,jj)-180).*mag(ii,jj);
                v(ii,jj) = cosd(dir(ii,jj)-180).*mag(ii,jj);
            end
            
        elseif dir(ii,jj) > 270 && dir(ii,jj) < 360 % qu(ii,jj)adrant 4, 270-360 degrees
            if strcmp(convention,'cartesian')
                u(ii,jj) = cosd(dir(ii,jj)-270).*mag(ii,jj).*-1;
                v(ii,jj) = sind(dir(ii,jj)-270).*mag(ii,jj);
            else
                u(ii,jj) = cosd(dir(ii,jj)-270).*mag(ii,jj);
                v(ii,jj) = sind(dir(ii,jj)-270).*mag(ii,jj).*-1;
            end
            
        elseif dir(ii,jj) == 0 || dir(ii,jj) == 360;
            if strcmp(convention,'cartesian')
                u(ii,jj) = 0;
                v(ii,jj) = mag(ii,jj);
            else
                u(ii,jj) = 0;
                v(ii,jj) = mag(ii,jj).*-1;
            end
            
        elseif dir(ii,jj) == 90
            if strcmp(convention,'cartesian')
                u(ii,jj) = mag(ii,jj);
                v(ii,jj) = 0;
            else
                u(ii,jj) = mag(ii,jj).*-1;
                v(ii,jj) = 0;
            end
            
        elseif dir(ii,jj) == 180
            if strcmp(convention,'cartesian')
                
                u(ii,jj) = 0;
                v(ii,jj) = mag(ii,jj).*-1;
            else
                u(ii,jj) = 0;
                v(ii,jj) = mag(ii,jj);
            end
            
        elseif dir(ii,jj) == 270
            if strcmp(convention,'cartesian')
                u(ii,jj) = mag(ii,jj).*-1;
                v(ii,jj) = 0;
            else
                u(ii,jj) = mag(ii,jj);
                v(ii,jj) = 0;
            end
        elseif dir(ii,jj) == NaN
                u(ii,jj) = NaN;
                v(ii,jj) = NaN;
        end
    end
end