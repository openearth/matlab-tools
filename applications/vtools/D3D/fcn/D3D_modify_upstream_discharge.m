%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17449 $
%$Date: 2021-08-06 12:38:36 +0200 (Fri, 06 Aug 2021) $
%$Author: chavarri $
%$Id: D3D_write_bc.m 17449 2021-08-06 10:38:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_write_bc.m $
%
%Based on a simulation it redistributes the discharge at the
%upstream boundary based on the function <f_m> along s-coordinate
%<s_m>. The discharge is read along pli-file <fpath_pli>
%
%To do:
%allow more than one bc. I.e., read and sum the discharge of all of them.
%time series management
%read the grid and find the nodes closest to the pli for substituting <fpath_pli>

function D3D_modify_upstream_discharge(fdir_sim,fpath_pli,s_m,f_m)


%% path
simdef.D3D.dire_sim=fdir_sim;
simdef=D3D_simpath(simdef);
fpath_map=simdef.file.map;
fpath_ext=simdef.file.extforcefilenew;
% nci=ncinfo(fpath_map);

%% read original q

ext=D3D_io_input('read',fpath_ext);
[fdir_ext]=fileparts(fpath_ext);

%find upstream boundary
field_name=fieldnames(ext);
nfn=numel(field_name);
kubc=0;
for kfn=1:nfn
    if ~strcmp(field_name{kfn}(1:4),'boun') %boundary
        continue
    end
    if strcmp(ext.(field_name{kfn}).quantity,'dischargebnd')
        kubc=kubc+1;
        ubc(kubc).locationfile=fullfile(fdir_ext,ext.(field_name{kfn}).locationfile);
        ubc(kubc).forcingfile=fullfile(fdir_ext,ext.(field_name{kfn}).forcingfile);
    end
    
end

bc_u=struct('Name','','Contents','','Location','','TimeFunction','','ReferenceTime',[],'TimeUnit','','Interpolation','','Parameter',struct(),'Data',[]);
nubc=numel(ubc);
for kubc=1:nubc
    bc_o=D3D_io_input('read',ubc(kubc).forcingfile);
    [~,bc_name]=fileparts(ubc(kubc).locationfile);
    bc_name_num=sprintf('%s_0001',bc_name); %possible error if varying along polyline
    idx_table=find_str_in_cell({bc_o.Table.Location},{bc_name_num});
    bc_u=[bc_u,bc_o.Table(idx_table)];
end
bc_u=bc_u(2:end);

if numel(bc_u)>1
    error('do')
    %read all pli and put together (now we use <ubc(kubc).forcingfile>)
    %check all timeseries are the same
    %...
end

%% read q at boundary

[ismor,~,~]=D3D_is(fpath_map);
[~,~,tend,~]=D3D_results_time(fpath_map,ismor,NaN);
% q1=EHY_getMapModelData(fpath_map,'varName','mesh2d_q1','t0',tend,'tend',tend,'disp',0,'pliFile',fpath_us_pli);
u=EHY_getMapModelData(fpath_map,'varName','mesh2d_ucmag','t0',tend,'tend',tend,'disp',0,'pliFile',fpath_pli);
h=EHY_getMapModelData(fpath_map,'varName','mesh2d_waterdepth','t0',tend,'tend',tend,'disp',0,'pliFile',fpath_pli);
s=u.Scen;
q=u.val.*h.val;

%% modify

q_tot=sum(q,'omitnan');
q_frac=q./q_tot; %fraction of discharge
F=griddedInterpolant(s_m,f_m);
f_m_atsim=F(s);
q_fm=q_frac.*f_m_atsim';
q_frac_m=q_fm/sum(q_fm,'omitnan');
q_m=q_tot.*q_frac_m; %unnormalize

%% write per cell

fpath_us_pli=ubc.forcingfile;
idx_nn=~isnan(q_m);
q_m_nn=q_m(idx_nn);
nu=sum(idx_nn);
us_pli=D3D_io_input('read',fpath_us_pli);
us_xy_parts=increaseCoordinateDensity(us_pli.val{1,1},nu);

[fdir,fname,fext]=fileparts(fpath_us_pli);

for ku=1:nu
    %write pli
    pli_name=sprintf('%s_p%03d',fname,ku);
    fpath_pli_us_loc=fullfile(fdir,sprintf('%s.%s',pli_name,fext));
    xy=us_xy_parts(ku:ku+1,:);
    
    pli_loc.name=pli_name;
    pli_loc.xy=xy;
    D3D_io_input('write',fpath_pli_us_loc,pli_loc);
    
    %fill bc
    bc_mod(ku).name=pli_name;
    bc_mod(ku).function=bc_u.Location;
    bc_mod(ku).time_interpolation=bc_u.Interpolation;
    bc_mod(ku).quantity={bc_u.Parameter.Name};
    bc_mod(ku).unit={bc_u.Parameter.Unit};
    bc_mod(ku).val=[bc_u.Data(:,1),q_m_nn(ku).*ones(size(bc_u.Data(:,1)))];
end

[fdir_bc,fnam_bc,fext_bc]=fileparts(ubc(kubc).forcingfile);
fpath_bc_mod=fullfile(fdir_bc,sprintf('%s_mod%s',fnam_bc,fext_bc));
D3D_io_input('write',fpath_bc_mod,bc_mod);

%% PLOT

figure
hold on
hanp(1)=plot(s,q,'b-*');
hanp(2)=plot(s,q_m,'r-*');
% hanp(1)=plot(s,q_frac,'b-*');
% hanp(2)=plot(s,f_m_atsim,'r-*');
legend(hanp,{'original','modified'})