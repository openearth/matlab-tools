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
%morphological initial file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.mor.ThTrLyr = active layer thickness [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.ThUnLyr = thickness of each underlayer [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.total_ThUnLyr = thickness of the entire bed [m] [double(1,1)] e.g. [1.5]
%   -simdef.ini.subs_frac = efective (total-1) number of fractions at the substrate [-] [double(nf-1)] e.g. [0.2,0.1]
%
%OUTPUT:
%   -a morphological .ini compatible with D3D is created in file_name

%150728->151104
%   -fractions at the active layer introduced

function D3D_mini(simdef)
%% RENAME

D3D_structure=simdef.D3D.structure;
nf=numel(simdef.sed.dk);

%% CALL

if nf>1
    if simdef.ini.subs_type==1 && simdef.ini.actlay_frac_type==1
        D3D_mini_const(simdef) %generate .ini
    else
        if D3D_structure==1
            D3D_mini_nconst_s(simdef) %generate .ini
            frc=D3D_mini_frc_s(simdef); %generate .frc
            D3D_mini_thk_s(simdef,frc) %generate .thk
        else
            %calling `D3D_morini_all` after creating the substrate with patch
            %or not may be better
            simdef=D3D_mini_frc_u_val(simdef);
            simdef=D3D_mini_lyr_u_val(simdef);
            D3D_morini_all(simdef);

            % D3D_mini_nconst_u(simdef) %generate .ini
            % D3D_mini_thk_u(simdef) %generate .thk
            % D3D_mini_frc_u(simdef) %generate .frc
        end
    end
end %nf

end %function

%%

function simdef=D3D_mini_frc_u_val(simdef)

%   -simdef.mor.frac_xy = coordinates [-]; [np,2]
%   -simdef.mor.frac = volume fraction content [-]; [np,nl,nf]

% L=simdef.grd.L;
% B=simdef.grd.B;

% dx=simdef.grd.dx;
% dy=simdef.grd.dy;

ThTrLyr=simdef.mor.ThTrLyr;
ThUnLyr=simdef.mor.ThUnLyr;
subs_frac=simdef.ini.subs_frac;
total_ThUnLyr=simdef.mor.total_ThUnLyr;
actlay_frac=simdef.ini.actlay_frac;

switch simdef.ini.actlay_frac_type
    case 2
        actlay_patch_x=simdef.ini.actlay_patch_x;
        actlay_patch_y=simdef.ini.actlay_patch_y;
        actlay_frac=simdef.ini.actlay_frac;
        actlay_patch_frac=simdef.ini.actlay_patch_frac;
end
switch simdef.ini.subs_type
    case 2
        subs_patch_frac=simdef.ini.subs_patch_frac;
        patch_x=simdef.ini.subs_patch_x; %x coordinate of the upper corners of the patch [m] [double(1,2)]
        patch_releta=simdef.ini.subs_patch_releta; %substrate depth of the upper corners of the patch [m] [double(1,1)]   
        eta_rel=[0,ThTrLyr:ThUnLyr:total_ThUnLyr];
        [~,eta_int_idx]=min(abs(eta_rel-patch_releta));
        patch_y=[0,simdef.grd.B];
end
    
%other
MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
nf=numel(simdef.sed.dk);
nef=nf-1; %effective number of fractions (total-1)
if nef==0
    nef=1;
end
ntl=MxNULyr+2; %number of total layers (active layer + substrate + large last layer)

actlay_frac=reshape(actlay_frac,nef,1); %reshape to avoid input issues
subs_frac=reshape(subs_frac,nef,1); %reshape to avoid input issues

%% CALC

tol=1e-3;

%this should be moved outside this function, as it is used also for the
%layers but we do not want to read again
fpath_netmap=fullfile(pwd,'tmpgrd_net.nc');
D3D_grd2map(simdef.file.grd,'fpath_map',fpath_netmap,'fpath_exe',simdef.file.exe_grd2map);
gridInfo=EHY_getGridInfo(fpath_netmap,{'XYcen','XYcor'});
delete(fpath_netmap);

Xtot=[gridInfo.Xcen;gridInfo.Xcor];
Ytot=[gridInfo.Ycen;gridInfo.Ycor];

frac_xy=[Xtot,Ytot];
np=numel(Xtot);
frac=NaN(np,ntl,nf);

%% active layer

kl=1; 

%all with constant value
for kf=1:nef
    frac(:,kl,kf)=actlay_frac(kf);
end

%add patch if requested
if simdef.ini.actlay_frac_type==2
    bol_patch=frac_xy(:,1)>actlay_patch_x(1)+tol & frac_xy(:,1)<actlay_patch_x(2)-tol & frac_xy(:,2)>actlay_patch_y(1)+tol & frac_xy(:,2)<actlay_patch_y(2)-tol;
    for kf=1:nef
        frac(bol_patch,kl,kf)=actlay_patch_frac(kf);
    end
end

%% substrate
for kl=2:ntl
    %all with constant value
    for kf=1:nef
        frac(:,kl,:)=subs_frac(kf);
    end
    
    %add patch if requested
    if simdef.ini.subs_type==2
        if kl>=eta_int_idx
            bol_patch=frac_xy(:,1)>patch_x(1)+tol & frac_xy(:,1)<patch_x(2)-tol & frac_xy(:,2)>patch_y(1)+tol & frac_xy(:,2)<patch_y(2)-tol;
            for kf=1:nef
                frac(bol_patch,kl,kf)=subs_patch_frac(kf);
            end
        end
    end
end %kl

frac(:,:,end)=1-sum(frac(:,:,1:end-1),3);

%%

simdef.mor.frac=frac;
simdef.mor.frac_xy=frac_xy;

end %function

%%

function simdef=D3D_mini_lyr_u_val(simdef)

%   -simdef.mor.thk = layer thickness [-]; [np,nl]

%% RENAME

% L=simdef.grd.L;
% B=simdef.grd.B;

ThTrLyr=simdef.mor.ThTrLyr;
ThUnLyr=simdef.mor.ThUnLyr;
total_ThUnLyr=simdef.mor.total_ThUnLyr;

%other
MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
ntl=MxNULyr+2; %number of total layers (active layer + substrate + large last layer)
np=size(simdef.mor.frac_xy,1);

%% CALCULATIONS

thk=NaN(np,ntl); %initial thickness with dummy values

%active layer
thk(:,1)=ThTrLyr;

%substrate
thk(:,2:end-1)=ThUnLyr;

%last layer
thk(:,end)=ThUnLyr*10;

%%

simdef.mor.thk=thk;

end %function