function dms=rad2dms(rad)
%RAD2DMS  Converts radians to degrees-minutes-seconds (vectorized).
%
% Version: 12 Mar 00
% Useage:  dms=rad2dms(rad)
% Input:   rad - vector of angles in radians
% Output:  dms - [d m s] array of angles in deg-min-sec, where
%                d = vector of degrees
%                m = vector of minutes
%                s = vector of seconds
%
%See also:

d  = abs(rad).*180/pi;
id = floor(d);
rm = (d-id).*60;
im = floor(rm);
s  = (rm-im).*60;
s  = round(s*1000000)/1000000;
if s>59.9999
    s=0;
    im=im+1;
    if im>=60
        im=0;
        if rad<0
            id=id-1;
        else
            id=id+1;
        end
    end
end


%if rad<0
%  if id==0
%    if im==0
%      s = -s;
%    else
%      im = -im;
%    end
%  else
%    id = -id;
%  end
%end

ind=(rad<0 & id~=0);
id(ind)=-id(ind);

ind=(rad<0 & id==0 & im~=0);
im(ind)=-im(ind);

ind=(rad<0 & id==0 & im==0);
s(ind)=-s(ind);

dms=[id im s];
