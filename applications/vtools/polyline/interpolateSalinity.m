%Interpolates simulation 2D (vertical) results at measurement locations.
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%200929
%
%INPUT
%   -t_sim: simulation time [nT,1]
%   -z_sim: simulation elevation [nT,nl]
%   -v_sim: simulation values [nT,nl]
%   -t_mea: measurements time [nt,1]
%   -z_mea: measurements elevation [nt,1]
%

function v_sim_atmea=interpolateSalinity(t_sim,z_sim,v_sim,t_mea,z_mea)

nl=size(z_sim,2); %number of flow layers
x_sim_m=repmat(t_sim,1,nl); %[nt,nl]
idx_t=1:1:numel(t_sim);
nt=numel(t_mea); %number of measured times
v_sim_atmea=NaN(nt,1);

for kt=1:nt

    %closest smaller or equal time
    bol_xtl=t_sim<=t_mea(kt);
    idx_xtl=idx_t(bol_xtl);                                    
    [~,idx_min_t]=min(abs(t_mea(kt)-t_sim(bol_xtl)));
    idx_xtmin=idx_xtl(idx_min_t);

    %closest larger in time
    bol_xtl=t_sim>t_mea(kt);
    idx_xtl=idx_t(bol_xtl);
    [~,idx_max_t]=min(abs(t_mea(kt)-t_sim(bol_xtl)));
    idx_xtmax=idx_xtl(idx_max_t);

    if isempty(idx_xtmin) %the point is smaller than first sample
        idx_xtmin=idx_xtmax+1;
    end

    if isempty(idx_xtmax) %the point is larger than last sample
        idx_xtmax=idx_xtmin-1;
    end

    x_lx=x_sim_m(idx_xtmin,:);
    y_lx=z_sim(idx_xtmin,:);
    v_lx=v_sim(idx_xtmin,:);

    x_ux=x_sim_m(idx_xtmax,:);
    y_ux=z_sim(idx_xtmax,:);
    v_ux=v_sim(idx_xtmax,:);
    
    %removenans
    idx_nnan_1=~isnan(y_lx);
    idx_nnan_2=~isnan(y_ux);

    %interpolate
%     F=scatteredInterpolant([x_lx(idx_nnan_1),x_ux(idx_nnan_2)]',[y_lx(idx_nnan_1),y_ux(idx_nnan_2)]',[v_lx(idx_nnan_1),v_ux(idx_nnan_2)]','linear','linear');
    
    F=scatteredInterpolant([x_lx(idx_nnan_1),x_ux(idx_nnan_2)]',[y_lx(idx_nnan_1),y_ux(idx_nnan_2)]',[v_lx(idx_nnan_1),v_ux(idx_nnan_2)]','linear','linear');

    v_sim_atmea(kt,1)=F(t_mea(kt),z_mea(kt));

%     fprintf('Query interpolation %4.2f %% \n',kt/nt*100);
end
                            
end %function

%%
%% REMEMBER
%%

%It has been very painful to get to this function. Do not forget that
%direct scatteredInterpolant fails becuase it uses Delaunay triangulation,
%which makes a mess when data is not really scattered (in our case, the
%x-vector is time, which is the same for all vertical coordinates).

%% Example

% kl=9:10;
% kt=58:59;
% x_sim_m_r=x_sim_m(kt,kl);
% y_sim_m_r=y_sim_m(kt,kl);
% v_sim_m_r=v_sim_m(kt,kl);
% DT = delaunayTriangulation([x_sim_m_r(:),y_sim_m_r(:)]);
% F3=scatteredInterpolant(x_sim_m_r(:),y_sim_m_r(:),v_sim_m_r(:),'linear','linear');
% F3(734815.4028,-2.5)
% 
% figure
% hold on
% triplot(DT)
% scatter3(x_sim_m_r(:),y_sim_m_r(:),v_sim_m_r(:),10,v_sim_m_r(:),'filled')
% scatter3(x_mea,y_mea,v_mea,10,v_mea,'s')
% scatter(734815.4028,-2.5,'r')
% xlim([734815.37,734815.43])

%% KEEP FOR NOT FORGETTING

                                    %
%                                     figure
%                                     hold on
%                                     scatter3(xyv_u(:,1),xyv_u(:,2),xyv_u(:,3),10,xyv_u(:,3),'filled')
%                                     scatter(x_ux,y_ux,10,'k')
%                                     scatter(x_lx,y_lx,10,'k')
%                                     scatter(x_mea(kt),y_mea(kt),10,'r')
%                                 %%
                                
% 
%                                 bol_ux=x_mea(kt)>x_t;
% %                                 bol_ly=y_mea(kt)<=xyv_u(:,2);
% %                                 bol_uy=y_mea(kt)>xyv_u(:,2);
% 
%                                 idx_aux_v{1,1}=idx_v(bol_lx);
%                                 idx_aux_v{1,2}=idx_v(bol_ux);
% %                                 idx_aux_v{1,3}=idx_v(bol_ux & bol_ly);
% %                                 idx_aux_v{1,4}=idx_v(bol_ux & bol_uy);
% %                                 idx_aux_v{1,1}=idx_v(bol_lx & bol_ly);
% %                                 idx_aux_v{1,2}=idx_v(bol_lx & bol_uy);
% %                                 idx_aux_v{1,3}=idx_v(bol_ux & bol_ly);
% %                                 idx_aux_v{1,4}=idx_v(bol_ux & bol_uy);
%                                 npi=numel(idx_aux_v);
%                                 idx_cc=NaN(1,npi);
%                                 for kpi=1:npi
%                                     idx_aux=idx_aux_v{1,kpi};
%                                     dist=sqrt((x_mea(kt)-xyv_u(idx_aux,1)).^2+(y_mea(kt)-xyv_u(idx_aux,2)).^2);
%                                     [~,min_idx]=min(abs(dist));
%                                     idx_get=idx_aux(min_idx);
%                                     if ~isempty(idx_get)
%                                         idx_cc(1,kpi)=idx_get;
%                                     end
%                                 end
%                                 
%                                 idx_nn=~isnan(idx_cc);
%                                 if sum(idx_nn)<3 %it is outside, full interpolant
%                                     idx_int=idx_v;
% %                                     idx_out=cat(1,idx_out
%                                 else
%                                     idx_int=idx_cc(idx_nn);
%                                     F=scatteredInterpolant(xyv_u(idx_int,1),xyv_u(idx_int,2),xyv_u(idx_int,3),'linear','linear');
%                                     v_sim_atmea(kt,1)=F(x_mea(kt),y_mea(kt));
% 
%                                 end