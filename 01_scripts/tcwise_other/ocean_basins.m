function [xl, yl] = ocean_basins(basin)

% gives axis back for each basin
% Possible basis 'NA','SA','WP','EP','SP','NI','SI'
switch basin
    case 'NA'
        xl = [-120 0];
        yl = [0 80];
    case 'SA'
        xl = [-120 0];
        yl = [-80 0];
    case 'WP'
        xl = [100 180];
        yl = [0 80];
    case 'EP'
        xl = [-180 -100];
        yl = [0 80];
    case 'SP'
        xl = [135-10 180+60];
        yl = [-80 0];
    case 'NI'
        xl = [45 115];
        yl = [0 30];
    case 'SI'
        xl = [20 135];
        yl = [-80 0];
    otherwise
        xl = [-180 +180];
        yl = [-90 +90];
end
% region 0: North Indian Ocean          (x > 0) & (x<+100) & (y > 0);                     
% region 1: South West Indian Ocean     (x > 0) & (x<+90)  & (y < 0)
% region 2: South East Indian Ocean	    (x>+90) & (x+135) & (y < 0);
% region 3: South Pacific Ocean'        ( (x>+135) | (x < 0) ) & (y < 0);   
% region 4: North West Pacific Ocean    (x<+100) & (x>0) & (y > 0);
% region 5: North East Pacific Ocean    (AL < 0) & (x<0) &  & (y > 0);
% region 6: Atlantic Ocean              (AL > 0)
% region 7: all data points

end

