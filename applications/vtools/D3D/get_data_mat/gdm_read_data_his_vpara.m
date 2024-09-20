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
%

function data=gdm_read_data_his_vpara(fdir_mat,fpath_his,station,layer,time_dnum,simdef,sim_idx,depth_average,projection_angle,elev)

if isnan(projection_angle)
    error('You want to project the velocity, but the angle is NaN.')
end

%this is a speacial treatment because depth average velocity already exists in 3D simulations as a native variable. For the rest, it is done in `gdm_read_data_his`
if depth_average
    data_x=gdm_read_data_his(fdir_mat,fpath_his,'depth-averaged_x_velocity','station',station,'layer',layer,'tim',time_dnum(1),'tim2',time_dnum(end),'structure',simdef.D3D.structure,'sim_idx',sim_idx);
    data_y=gdm_read_data_his(fdir_mat,fpath_his,'depth-averaged_y_velocity','station',station,'layer',layer,'tim',time_dnum(1),'tim2',time_dnum(end),'structure',simdef.D3D.structure,'sim_idx',sim_idx);
    vx=data_x.val;
    vy=data_y.val;
    data=data_x;
else
    data=gdm_read_data_his(fdir_mat,fpath_his,'uv','station',station,'layer',layer,'tim',time_dnum(1),'tim2',time_dnum(end),'structure',simdef.D3D.structure,'sim_idx',sim_idx,'elevation',elev);
    vx=data.vel_x;
    vy=data.vel_y;
end
vx=reshape(vx,1,[]);
vy=reshape(vy,1,[]);
sz=size(data.vel_x);
[vpara,vperp]=project_vector(vx,vy,projection_angle);
data.v_para=reshape(vpara,sz);
data.v_perp=reshape(vperp,sz);

end %function