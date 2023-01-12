function X11 = loc_boundary_profile_v2(znat,xnat,x0,zb0,maxwl,V_input,fig)
%loc_boundary_profile_v2  Compute position of boundary profile
%
%   Compute position of boundary profile
%
%   Syntax:
%   X11 = loc_boundary_profile_v2(znat,xnat,x0,zb0,maxwl)
%
%   Input:
%   znat     = z location of wet point (positive upwards)
%   xnat     = x location of wet point
%   x0       = x coordinates of profile 
%   zb0      = bed level points
%   maxwel   = water level
%
%   Output:
%   X11    = Base point of boundary profile
%


% Created: 20 Okt 2012

% $Id:  $
% $Date:  $
% $Author:  $
% $Revision:  $
% $HeadURL:  $
% $Keywords: $


%% input
% --- upper limit boundary profile (zswetmax+1.5m)
z_max_grensprofiel = znat+1.5;
% --- lower limit boundary profile (Rekenpeil)
z_min_grensprofiel = maxwl;
% --- length boundary profile (top and bottom)
length_boundary_profile_top     = 3;
length_boundary_profile_bottom  = 7.5;

% --- left slope 1/1
helling1 = 1; 
% --- right slope 1/2
helling2 = 2;  

if fig
figure
end

% --- move GP based on addition volume
if V_input>0
    if fig
    plot(x0,zb0,'k.-','DisplayName','zb0');
    end
    [x0 zb0 x_basepoint] = get_basepoint_additionV(x0,zb0,z_min_grensprofiel,V_input);
    if isnan(x_basepoint)
        X11 = NaN;
        return 
    end
end


% --- add fictive point to make sure that we always have crossing at the
% back side
zb0(end+1)  = z_min_grensprofiel-1;
x0(end+1)   = x0(end);


% --- plot profile
if fig
plot(x0,zb0,'k.-','DisplayName','zb');
hold on
plot(x0, x0*0+z_max_grensprofiel,'DisplayName','Max GP')
plot(x0, x0*0+z_min_grensprofiel,'DisplayName','Min GP')
plot(xnat,z_max_grensprofiel-1.5,'*','DisplayName','Wet punt')
end

% --- checks
assert( z_max_grensprofiel>z_min_grensprofiel , 'Not possible to fit boundary profile' )

%% find crossings and add point at the crossings

% --- crossing left side
crossing_l          = [NaN]; 
% --- crossing right side
crossing_r          = [NaN]; 


x           = x0(1);
zb          = zb0(1);
count       =  1;
crossing_r  = [];
crossing_l  = [];

% --- logical required for missing lower left crossing
% (z_min_grensprofiel > minimum bed level between two dunes)
previous_left_up = true;
previous_left_up_lower = false;

for ii=2:length(zb0)
    % --- upward left min crossing
    if zb0(ii)> z_min_grensprofiel & zb0(ii-1) <= z_min_grensprofiel;
       % no upper limit in previous dune. skip previous crossings
        if previous_left_up_lower
            crossing_l(end) = [];
            crossing_r(end) = [];
        end
        
        dz          = z_min_grensprofiel - zb0(ii-1);
        x_intersect = interp1([zb0(ii-1), zb0(ii)],[x0(ii-1) x0(ii)],zb0(ii-1)+dz );
        
        % --- find x,zb at crossing
        x           = [x x_intersect];
        zb          = [zb z_min_grensprofiel];
        if fig; plot(x_intersect,z_min_grensprofiel,'m*','DisplayName','Crossing'); end;
        % --- update count and add crossing
        count       = count + 1;
        crossing_l  = [crossing_l count];
        
        previous_left_up = true;
        previous_left_up_lower = true;
        
    end
    % --- downward right min crossing
    if zb0(ii)< z_min_grensprofiel & zb0(ii-1) >= z_min_grensprofiel
        
        dz          = z_min_grensprofiel - zb0(ii-1);
        x_intersect = interp1([zb0(ii-1), zb0(ii)],[x0(ii-1) x0(ii)],zb0(ii-1)+dz );
        % --- find x,zb at crossing
        x           = [x x_intersect];
        zb          = [zb z_min_grensprofiel];
        if fig; plot(x_intersect,z_min_grensprofiel,'m*','DisplayName','Crossing'); end;
        % --- update count and add crossing
        count       = count + 1;
        crossing_r  = [crossing_r count];
        
        previous_left_up = false;
        previous_left_up_lower = false;
        
    end
    % --- upward left max crossing
    if zb0(ii)> z_max_grensprofiel & zb0(ii-1) <= z_max_grensprofiel
        
        % if previous crossing is not up, add artifial point. No crossing
        % with lower limit before crossing higher limit. Add left crossing point after
        % last crossing right and add right crossing at current location
        if ~previous_left_up
            crossing_l  = [crossing_l crossing_r(end)+1];
            crossing_r  = [crossing_r count + 1];
        end
        
        dz          = z_max_grensprofiel - zb0(ii-1);
        x_intersect = interp1([zb0(ii-1), zb0(ii)],[x0(ii-1) x0(ii)],zb0(ii-1)+dz );
        % --- find x,zb at crossing
        x   = [x x_intersect];
        zb  = [zb z_max_grensprofiel];
        if fig; plot(x_intersect,z_max_grensprofiel,'m*','DisplayName','Crossing'); end;
        % --- update count and add crossing
        count       = count + 1;
        crossing_l  = [crossing_l count];
        
        previous_left_up = false;
        previous_left_up_lower = false;
        
    end
    % --- downward right max crossing
    if zb0(ii)< z_max_grensprofiel & zb0(ii-1) >= z_max_grensprofiel
        
        dz          = z_max_grensprofiel - zb0(ii-1);
        x_intersect = interp1([zb0(ii-1), zb0(ii)],[x0(ii-1) x0(ii)],zb0(ii-1)+dz );
        % --- find x,zb at crossing
        x   = [x x_intersect];
        zb  = [zb z_max_grensprofiel];
        if fig; plot(x_intersect,z_max_grensprofiel,'m*','DisplayName','Crossing'); end;
        % --- update count and add crossing
        count       = count + 1;
        crossing_r  = [crossing_r count];
        
        previous_left_up = false;
        previous_left_up_lower = false;
    end
    x       = [x x0(ii)];
    zb      = [zb zb0(ii)];
    count   = count + 1;
end




% --- remove last value if length is odd
if mod(length(crossing_r),2)==1 & length(crossing_r)>1
    crossing_r(end) = [];
end

% --- plot crossings
if ~isnan(crossing_l(1))
if fig; plot(x(crossing_l),squeeze(zb(crossing_l)),'rs','DisplayName','Crossing left'); end
end
if ~isnan(crossing_r(1)) 
if fig; plot(x(crossing_r),zb(crossing_r),'bs','DisplayName','Crossing right');end
end

%% --- find location boundary profile

% ---
if isnan(crossing_l(1)) || length(crossing_l)==1
    disp('Kan geen grensprofiel inpassen');
    X11 = NaN;

else
    found_sol = false;

    for jj=1:2:length(crossing_l)
        % --- number of points between crossings
        N                   = crossing_l(jj+1)-crossing_l(jj)+1;
        % --- fit boundary profile left side
        [X11 X12 Z11 Z12]   = inpassen_links(N, crossing_l(jj), helling1, z_max_grensprofiel, z_min_grensprofiel,zb,x);
        

            

        if fig; plot([X11 X12],[Z11 Z12],'m-','DisplayName','GP-left'); end

%         % ---
%         if length(crossing_r) < jj
%             found_sol       = true;
%             break
%         end
        
        % --- number of points between crossings
        N = crossing_r(jj+1)-crossing_r(jj)+1;
        % --- fit boundary profile left side
        [X21 X22 Z21 Z22] = inpassen_rechts(N, crossing_r(jj), helling2, z_max_grensprofiel, z_min_grensprofiel,zb,x);
        
        if fig; plot([X21 X22],[Z21 Z22],'m-','DisplayName','GP-right'); end;
        
        % --- check whether boundary profile fits
        if X21-X12> length_boundary_profile_top & X22-X11 > length_boundary_profile_bottom
            found_sol       = true;
            break
        end
        
    end
    if ~found_sol
        disp('kan geen grensprofiel inpassen');
        X11 = NaN;
    else
        if fig; plot(X11,maxwl,'o','markersize',10,'DisplayName','GP0'); end
    end
end

if fig; legend('Location','Northwest'); end

%%
function [X11 X12 Z11 Z12] = inpassen_links(N, crossing1, helling, z_max_grensprofiel, z_min_grensprofiel,zb0,x)
    x_list_dummy1 = nan(1,N);
    for ii=1:N
        z_dummy             = zb0(crossing1 + ii -1) - z_min_grensprofiel;
        x_dummy             = x(crossing1 + ii -1) - z_dummy * helling;
        %plot(x(crossing1 + ii -1),zb0(crossing1 + ii -1),'o')
        x_list_dummy1(ii)   = x_dummy;

    end
    
    
    index = find( max(x_list_dummy1)==x_list_dummy1);
    
    X11 = x_list_dummy1(index);
    Z11 = z_min_grensprofiel;
    X12 = x_list_dummy1(index)+(z_max_grensprofiel-z_min_grensprofiel)*helling;
    Z12 = z_max_grensprofiel;
end

function [X21 X22 Z21 Z22] = inpassen_rechts(N, crossing2, helling2, z_max_grensprofiel, z_min_grensprofiel,zb0,x)
    x_list_dummy2 = nan(1,N);
    for ii=1:N
        z_dummy = zb0(crossing2 + ii -1) - z_min_grensprofiel;
        x_dummy = x(crossing2 + ii -1) + z_dummy * helling2;
        x_list_dummy2(ii)   = x_dummy;
        %plot(x(crossing2 + ii -1),zb0(crossing2 + ii -1),'o')
    end
    index = find( min(x_list_dummy2)==x_list_dummy2);
    
    X21 = x_list_dummy2(index)-helling2*(z_max_grensprofiel-z_min_grensprofiel);
    Z21 = z_max_grensprofiel;
    X22 = x_list_dummy2(index);
    Z22 = z_min_grensprofiel;
end



end