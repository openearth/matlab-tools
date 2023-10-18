%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Create a sloping bed level with a trapezoidal channel forming: (1) a 
%channel at an angle of 45 deg, an arc of a circle, and a straight channel.

function [z,yc,z_slope]=etab_adhoc_01(x,y,p)

tol=1e-10;

z=-p.h4; %level of downstream basin
yc=0;
z_slope=z;

if x<p.x3+tol %sloping part
    z_slope=p.slope.*(p.x3-x); %overal slope

    %channel
    b105=p.b1/2; %half width base trapezoid
    b205=p.b2/2; %half width ceil of trapezoid
    yc=fcn_centerline(x,p,0); %centerline of the channel
    
    dy=abs(y-yc); %distance from centerline
    if dy<b105+tol %inside base of trapezoid
        if x<p.x1
            dz=p.h1;
        elseif x<p.x2+p.dx2
            dz=interp_line([p.x1,p.x2+p.dx2],[p.h1,p.h3],x);
        else
            dz=p.h3;
        end
        zc=z_slope-dz; %constant value
    elseif dy<b205+tol %in the bank
        dyi=abs(b205-dy); %transverse distance from up corner of the bank
        zc=bank(dyi,z_slope,p); %vertical distance from ceil of trapezoid
    else
        zc=z_slope; %outside the bank (do nothing)
    end
    
    z=min(z_slope,zc);
end

end %function

%% 
%% FUNCTION
%%

%%

function yc=fcn_centerline(x,p,dy)

if x<p.x1 %angle 45 degrees channel
    y0=dy;
    yc=-x+y0;
elseif x<p.x2 %circle
    R=1/(2*p.b1)*(p.b1^2+(p.x2/2)^2);
    y0=R-p.b1+dy; %center of the circle
    x0=p.x2/2;
    yc=-sqrt(R^2-(x-x0)^2)+y0;
else 
    y0=dy;
    yc=0+y0;
end

end %function

%%

function zc=bank(dy,z,p)
    zc=z-dy*tan(p.slope_bank*2*pi/360);
end
