function [bndval,thick] = nesthd_flipori(bndval,thick)

%% Flips verical orientation
no_times = length(bndval);
no_pts   = size(bndval(1).value,1);
kmax     = size(bndval(1).value,2)/2;

lstci    = -1; if length(size(bndval(1).value)) == 3 lstci = nfs_inf.lstci; end

for i_time = 1: no_times
    for i_point = 1: no_pts
        if lstci >= 1
            for l = 1: lstci
                bndval(i_time).value(i_point,1     :kmax  ,l) = flip(bndval(i_time).value(i_point,1     :kmax  ,l));
                bndval(i_time).value(i_point,kmax+1:2*kmax,l) = flip(bndval(i_time).value(i_point,kmax+1:2*kmax,l));
            end
        else
            bndval(i_time).value(i_point,1     :kmax  ) = flip(bndval(i_time).value(i_point,1     :kmax  ));
            bndval(i_time).value(i_point,kmax+1:2*kmax) = flip(bndval(i_time).value(i_point,kmax+1:2*kmax));
        end
    end
end

thick = flip(thick);
