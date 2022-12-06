function x_basepoint = get_basepoint_additionV(x,z,Rp,V_input)
%get_basepoint_additionV  Compute position of boundary profile given of
%addition volume
%
%   Compute position of boundary profile
%
%   Syntax:
%   x_basepoint = get_basepoint_additionV(x,z,Rp,V_input)
%
%   Input:
%   x     = x-coordinates
%   z     = z-coordinates
%   Rp    = water level
%   V_input      = Volume required before boundary profile and above water
%   level
%
%   Output:
%   x_basepoint    = Base point of boundary profile
%


% Created: 20 Okt 2012

% $Id:  $
% $Date:  $
% $Author:  $
% $Revision:  $
% $HeadURL:  $
% $Keywords: $

% --- step size for iteration
dx      = 10;
% --- stop creteria
stop    = false;
for ii=1:dx:length(x)
    
    % --- compute volume
    V = compute_volume(x,z,Rp,ii);
    
    % --- stop seraching when volume is larger than specified volume
    if V > V_input
        
        % --- perform second step of iteration process
        for jj=ii:1:ii+dx
            % --- compute volume
            V = compute_volume(x,z,Rp,jj);
            
            % --- stop seraching when volume is larger than specified volume
            if V > V_input
                % --- base point
                x_basepoint = x(jj);

                %plot(x_basepoint,Rp,'*')
                stop = true;
                break
            end
        end
    end
    
    if stop
       break 
    end
end

if ~stop
    x_basepoint = NaN;
end

end

function V = compute_volume(x,z,Rp,index)
% compute volume above water level (Rp) seaward of index


    % --- volume above Rp
    z(z<Rp) = 0;
    % --- remove z after given index
    z(x>x(index)) = 0;
    % --- compute volume
    V = trapz(x,z);
end