%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%interpolates based on the closest data points of semi-structured
%data.
%
%'ny' measurements are conducted at a fixed y-coordinate (e.g., elevation, distance,...)
%for a varying x-coordinate (e.g., time). The measurements are used for interpolation 
%in a structured matrix for a surf plot. The measurement closest in x-coordinate is taken 
%and interpolated
%
%INPUT
%   -y: y-coordinate of measurements; double(1,ny);
%   -x: x-coordinate of measurements; cell(1,ny);
%   -val: value of the measurements; cell(1,ny);
%   -y_v: y-coordinate where to interpolate measurements; double(1,nyv)
%   -x_v: x-coordinate where to interpolate measurements; double(1,nxv)
%   -x_thres: maximum x-distance from a measured point to a query point to be considered close enough to interpolate; double(1,1)

function [x_m,y_m,val_m]=interpolate_xy(y,x,val,y_v,x_v,x_thres)
        
ny=numel(y);

nxv=numel(x_v);
nyv=numel(y_v);
[x_m,y_m]=meshgrid(x_v,y_v);

val_m=NaN(nyv,nxv);    
for kyv=1:nyv %y queary points
    for kxv=1:nxv %x query points
        x_loc=x_m(kyv,kxv); 
        y_loc=y_m(kyv,kxv); 
        val_loc=NaN(ny,1);
        for kx=1:ny
            x_q_loc=x{kx};
            bol_out=x_q_loc>(x_loc+x_thres) | x_q_loc<(x_loc-x_thres); %do not take values further than t_thresh into consideration
%                     bol_out=false(size(t_q_loc)); %take all values into consideration
            x_q_loc_int=x_q_loc(~bol_out);
            val_q_loc_int=val{kx}(~bol_out);
            if ~isempty(x_q_loc_int) && numel(x_q_loc_int)>1
                val_loc(kx,1)=interp1(x_q_loc_int,val_q_loc_int,x_loc);
            end
            %taking the x-coordinate directly if density is large (faster)
%             [~,idx_min]=min(abs(x_q_loc(~bol_out)-x_loc));
%             if ~isempty(idx_min)
%                 idx_1=find(~bol_out);
%                 idx_min=idx_1(idx_min);
%                 val_loc(kx,1)=val{kx}(idx_min);
%             end
        end %kx
        if ~any(~isnan(val_loc))
            
        else
            y_int=y(~isnan(val_loc));
            val_int=val_loc(~isnan(val_loc));
            val_m(kyv,kxv)=interp1(y_int,val_int,y_loc);             
        end

        %display
        fprintf('Interpolating y %3.2f %%; x %3.2f %%\n',kyv/nyv*100,kxv/nxv*100)
    end %ktv
end %kxv
