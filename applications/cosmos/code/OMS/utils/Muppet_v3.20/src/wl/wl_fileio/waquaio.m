function varargout=waquaio(sds,exper,field,varargin)
%WAQUAIO Read SIMONA SDS file.
%   [...]=WAQUAIO(SDS,'Exp','Field',TStep,Station,M,N,K)
%   supported fields and associated output arguments
%
%   * grid     : x,y (depth points)
%                -->  dgrid, zgrid, ugrid, vgrid (DP,ZETA,U,V points)
%   * zgrid3d  : x,y,z (waterlevel points)
%                -->  zgrid3d, ugrid3d, vgrid3d (ZETA,U,V points)
%   * drywet   : udam,vdam ((temporary) thindams)
%
%   * depth    : bed level (positive down)
%   * height   : bed level (positive up)
%
%   * wlvl     : water level, time
%   * wdepth   : water depth, time
%   * head     : head (energie hoogte), time
%   * xyveloc  : u,v,time or u,v,w,time
%                (U,V components in X,Y direction)
%   * xyudisch : qu,qv,time (qu=u*hu, qv=v*hv)
%                (QU,QV components in X,Y direction)
%   * veloc    : u,v,time or u,v,w,time
%                (U,V components in KSI,ETA direction in waterlevel points)
%   * veloc0   : unprocessed velocities in velocity points
%   * udisch   : unit discharge (u*H): qu,qv,time or qu,qv,w,time
%                (qu,qv components in KSI,ETA direction in waterlevel points)
%   * udisch0  : unprocessed unit discharges in velocity points
%   * disch    : Qu,Qv,time or Qu,Qv,w,time
%                (QU,QV components in KSI,ETA direction in waterlevel points)
%   * disch0   : unprocessed discharges in velocity points
%   * dischpot : QP,time (discharge potential)
%   * chezy    : chezy-u,chezy-v
%
%   * energy   : turbulent kinetic energy
%   * dissip   : energy dissipation
%
%   * subst:<substance name>  : substance field, time
%
%   * weirs    : udam,vdam,uhgh,vhgh: locations and heights of weirs
%
%   * flowstat-wl : waterlevel station names
%   * wlstat      : waterlevel at station
%   * flowstat-cur: current station names
%   * flowcrs-u   : u-discharge crosssection names
%   * flowcrs-v   : v-discharge crosssection names
%
%   * substances  : substance names,substance units
%   * transtat    : concentration station names
%   * trancrs-u   : u-transport crosssection names
%   * trancrs-v   : v-transport crosssection names

%   Copyright 2000-2008 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

if nargin<3
    error('Not enough input arguments.')
end

%
% Obtain experiment name when it was not specified by the user.
%
if isempty(exper)
    if length(sds.Experiment)==1
        exper = sds.Experiment.Name;
    else
        error('Missing experiment name.')
    end
end

%
% Retrieve all relevant dimensions from MESH_IDIMEN array.
%
dimen=waqua('readsds',sds,exper,'MESH_IDIMEN');
%  1: NDIM 1,2,3
%  2: MMAX
%  3: NMAX
%  4: MNMAX = max(NMAX,MMAX)
%  5: MNMAXK = 1 + NumComputationalPoints
%  6: NENCLO = NumEnclosurePoints
%  7: LDAM = NumThinDams
%  8: NOCOLS = NumGridCols
%  9: NOROCO = NumGridRows+NumGridCols
% 10: NOROWS = NumGridRows
% 11: NSLU = NumUBarrier
% 12: NSLUV = NumUVBarrier
% 13: NSLV = NumVBarrier
% 14: NTO = TotalNumTideOpening
% 15: IADLND = AddressInactivePoint
% 16: KURFLG = 0 (Rect), 1 (Curv), 2 (Sphe)
% 17: NROU = NumWeirs
% 18: KMAX
% 19: --
% 20: IDEPO = 0 (pos.down), 1 (pos.up)
% 21: IRLFLG = 0 (no duplic.spher), 1 (duplic.spher)
% 22: NBARU = NumUBarrierPoints
% 23: NBARV = NumVBarrierPoints
% 24: NBARUV = NumBarrierPoints
% 25: NTOPT = NumOpeningPoints
dim.nmax=dimen(3);
dim.mmax=dimen(2);
dim.num_irogeo_rows=dimen(10);
dim.nsluv=dimen(12);
dim.inact=dimen(15);
curvl=dimen(16);
dim.sph_dupl=0; %dimen(21); % do not use the second grid, it is just
% counting grid points (ref: DCSM98a)
dim.kmax=dimen(18);
dim.sz=[dim.nmax dim.mmax];
dim.npnt=dimen(5);

%
% Switch name of data field to lower case
%
field=lower(field);

%
% If non-curvilinear, simplify xyveloc to veloc
%
if curvl~=1 & strcmp(field,'xyveloc')
    field='veloc';
end

%
% Determine whether we are dealing with a 2D or 3D array or a variable at a
% station. But first, handle the special cases ...
%
if isequal(field,'curvl')
    varargout = {curvl};
    return
elseif isequal(field,'substances')
    if waqua('exists',sds,exper,'CONTROL_TRANS_ICONTA');
        iconta=waqua('readsds',sds,exper,'CONTROL_TRANS_ICONTA');
        %  1: NOPOW = num discharge sources power stations
        %  2: NSRC = num discharge sources
        %  3: NOPOL = num constituent stations
        %  4: NTRA = num u-transp. cross
        %  5: NTRAV = num v-transp. cross
        %  6: NTOPT = num opening points
        %  7: NOTTID = num times in opening data
        %  8: NOTDIS = num times in disch. data
        %  9: NOTCDI = num times in conc. data at disch. sources
        % 10: NOTQNR = num times in incoming flux data
        % 11: NOTDRY = num times in dry air bulb data
        % 12: NOTRHU = num times in rel. humidity data
        % 13: NOTTWM = num times in background water temp data
        % 14: NOTQSC = num times in solar rad. data
        % 15: IBLHIT = 1 (blocked transport history data present), 0 (not present)
        % 16: NUTHBT = num time instances in blocked hist. data
        nsrc=iconta(2);

        icontb=waqua('readsds',sds,exper,'CONTROL_TRANS_ICONTB');
        %  1: KTEMP = temperature model type (1: rad.according to model,
        %                                2: rad. time series, 3:excess temp.)
        %  2: LMAX = num constituents
        %  3: LSAL = const num salinity
        %  4: LTEMP = const num temperature
        %  5: LERG = 0 (no energy), L>0 (energy in computation)
        %  6: LEPS = 0 (no dissip), L>0 (dissip in computation)
        %  7: LDIFCO = 1 (yes) / 0 (no) constant vert. eddy visc
        %  8: IFLVAL = flag fall velocities user specified
        %  9: LTUR = num turbulence variables
        % 10: NWRTUR = write flag turb. quantities SDS file (1 = yes)
        lmax=icontb(2);

        data=waqua('readsds',sds,exper,'PROBLEM_TRANS_NAMPRB');
        nams=data(1+nsrc+(1:lmax))';
        unt=data(1+nsrc+lmax+(1:lmax))';
        varargout={nams unt};
    else
        varargout={{} {}};
    end
    return
elseif ismember(field,{'transtat','trancrs-u','trancrs-v', ...
        'flowstat-wl','flowstat-cur','flowcrs-u','flowcrs-v', ...
        'wlstat','wl-stat','u-stat','v-stat','uv-stat','w-stat', ...
        'mq-stat','cq-stat','z-stat','z-sbstat','wl-xy'})
    stationdata = 1;
elseif length(field)>8 & strcmp(field(1:8),'stsubst:')
    stationdata = 1;
else
    stationdata = 0;
end

%
% Read reference date ...
%
names=waqua('readsds',sds,exper,'PROBLEM_FLOW_NAMPRB');
%  1: ITDATE
%  2: NAMDIS = discharge source names
itdate=names{1};
[day,r]=strtok(itdate);
day=str2num(day);
[month,r]=strtok(r);
month=ustrcmpi(month,{'jan','feb','mar','apr','may','jun','jul', ...
    'aug','sep','oct','nov','dec'});
[year,r]=strtok(r);
year=str2num(year);
if ~(isempty(day) | isempty(month) | isempty(year))
    refdate=datenum(year,month,day);
else
    refdate=1;
end

%
% If station data ...
%
if stationdata
    [varargout{1:nargout}] = waqua_get_station(sds,exper,field,dim,refdate,varargin);
else
    [varargout{1:nargout}] = waqua_get_spatial(sds,exper,field,dim,refdate,varargin);
end

%==========================================================================
% STATION DATA
%==========================================================================
%
% TIMEHISTORIES_FLOW_TIMHIS:
% ZWL   : NOWL         (waterlevel)
% ZCUR  : NOCUR,KMAX   (vel.mag.)
% ZCURU : NOCUR,KMAX   (u vel.)
% ZCURV : NOCUR,KMAX   (v vel.)
% CTR   : NTRA         (disch u dir.)
% FLTR  : NTRA         (cumm. disch u dir.)
% CTRV  : NTRAV        (disch v dir.)
% FLTRV : NTRAV        (cumm. disch v dir.)
% BARQ  : NSLUV        (transp at barrier)
% BASEPA: NSLUV        (waterlevel low M/N)
% BASEPB: NSLUV        (waterlevel high M/N)
% BAVELA: NSLUV        (velocity low M/N)
% BAVELB: NSLUV        (velocity high M/N)
% ZCURW:  NOCUR,KMAX+1 (omega vel, TRIWAQ only)
% ZCURWP: NOCUR,KMAX   (phys.w vel, TRIWAQ only)
% ZKCUR:  NOCUR,KMAX+1 (layer interface, TRIWAQ only)
%
% TIMEHISTORIES_TRANS:
% GRO:    LMAX,NOPOL,KMAX   (constit stat)
% ADTR:   LMAX,NTRA         (total const u-cross)
% ATR:    LMAX,NTRA         (total advec const u-cross)
% DTR:    LMAX,NTRA         (total diff.mass transp u-cross)
% ADTRV:  LMAX,NTRAV        (total const v-cross)
% ATRV:   LMAX,NTRAV        (total advec const v-cross)
% DTRV:   LMAX,NTRAV        (total diff.mass transp v-cross)
% ZKPOL:  NOPOL,KMAX+1      (layer interface, TRIWAQ only)
% GRKE:   LTUR,NOPOL,KMAX+1 (turb.quant., TRIWAQ only)
%
%==========================================================================
%
function varargout = waqua_get_station(sds,exper,field,dim,refdate,argin)
kmax = dim.kmax;
nsluv = dim.nsluv;
switch field
    %
    % -------------------------------------------------------------------
    %
    case {'transtat','trancrs-u','trancrs-v'}
        iconta=waqua('readsds',sds,exper,'CONTROL_TRANS_ICONTA');
        % ref. "substances"
        nopol=iconta(3);
        ntra=iconta(4);
        ntrav=iconta(5);

        data=waqua('readsds',sds,exper,'CHECKPOINTS_TRANS_NAMCHK');
        switch field
            case 'transtat'
                data=data(1:nopol);
            case 'trancrs-u'
                data=data(nopol+(1:ntra));
            case 'trancrs-v'
                data=data(nopol+ntra+(1:ntrav));
        end
        data=data';
        varargout={data};

    case {'flowstat-wl','flowstat-cur','flowcrs-u','flowcrs-v','wlstat', ...
            'wl-stat','u-stat','v-stat','uv-stat','w-stat','mq-stat', ...
            'cq-stat','z-stat','z-sbstat','wl-xy'}
        [tstep,stationi,k]=local_argin(argin);
        iconta=waqua('readsds',sds,exper,'CONTROL_FLOW_ICONTA');
        %  1: NOPOW = num discharge sources power stations
        %  2: NSRC = num discharge sources
        %  3: NTOF = num Fourier openings
        %  4: NTOT = num tide openings
        %  5: KC = num Fourier comp
        %  6: NOWL = num waterlevel stat
        %  7: NOCUR = num current stat
        %  8: NTRA = num u-transp cross
        %  9: NTRAV = num v-transp cross
        % 10: NOTBAR = num times in barrier data
        % 11: NOTTID = num times in open bound data
        % 12: NOTDIS = num times in disch data
        % 13: NTOQH = num QH rel. driven bound
        % 14: NTOQAD = num disch, bound with autom. distrib.
        % 15: NUMQHP = num QH pairs for QH rels
        % 16: IBLHIF = 1 (blocked flow history data present), 0 (not present)
        % 17: NUTHBF = num time instances in blocked hist. data
        % 18: NIKURA = Nikuradse roughness active (1) or not (0)
        % 19: NARU = size AREAU table
        % 20: NARV = size AREAV table
        % 21: NROUGHK = size ROUGK table
        % 22-23: KALMAN param.
        nowl=iconta(6);
        nocur=iconta(7);
        ntra=iconta(8);
        ntrav=iconta(9);

        ARRAY='TIMEHISTORIES_FLOW_TIMHIS';
        switch field
            case {'wlstat','wl-stat','wl-xy'}
                stoffset=0;
                krange=1;
            case 'umag-stat'
                stoffset=nowl;
                krange=1+(0:kmax-1)*nocur;
            case {'u-stat','uv-stat'}
                stoffset=nowl+nocur*kmax;
                krange=1+(0:kmax-1)*nocur;
            case 'v-stat'
                stoffset=nowl+nocur*kmax*2;
                krange=1+(0:kmax-1)*nocur;
            case 'mq-stat'
                stoffset=nowl+nocur*kmax*3;
                krange=1;
                if stationi>ntra
                    % ntra instant, ntra cum, ntrav instant, ntrav cum
                    %^ current offset location
                    %                        ^ offset for stationi-ntra
                    % the instaneous v cross-sections follow after the
                    % cumulative u cross-sections. The stationi offset includes
                    % ntra offset, so, only shift by ntra needed.
                    stoffset=stoffset+ntra;
                end
            case 'cq-stat'
                stoffset=nowl+nocur*kmax*3+ntra;
                krange=1;
                if stationi>ntra
                    % ntra instant, ntra cum, ntrav instant, ntrav cum
                    %              ^ current offset location
                    %              offset for stationi-ntra ^
                    % the cumulative v cross-sections follow after the
                    % instaneous v cross-sections. The stationi offset includes
                    % ntra offset, so, only shift by ntrav needed.
                    stoffset=stoffset+ntrav;
                end
            case 'w-stat'
                stoffset=nowl+nocur*kmax*3+ntra*2+ntrav*2+nsluv*5+nocur*(kmax+1);
                krange=1+(0:kmax-1)*nocur;
            case 'z-stat'
                stoffset=nowl+nocur*kmax*3+ntra*2+ntrav*2+nsluv*5+nocur*(2*kmax+1);
                krange=1+(0:kmax)*nocur;
            case 'z-sbstat'
                iconta=waqua('readsds',sds,exper,'CONTROL_TRANS_ICONTA');
                icontb=waqua('readsds',sds,exper,'CONTROL_TRANS_ICONTB');
                % ref. "substances"
                nopol=iconta(3);
                ntra=iconta(4);
                ntrav=iconta(5);
                lmax=icontb(2);
                %
                ARRAY='TIMEHISTORIES_TRANS';
                stoffset=lmax*(nopol*kmax+3*ntra+3*ntrav);
                krange=1+(0:kmax)*nopol;
        end
        if strcmpi(field(end-1:end),'xy')
            ARRAY='CHECKPOINTS_FLOW_IWLPT';
        end
        switch field
            % nowl       : waterlevels
            % nocur*k    : velocity mag, u comp., v comp.
            % ntra       : ctr, fltr
            % ntrav      : ctrv, fltrv
            % nsluv      : barq, basepa, basepb, bavela, bavelb
            % nocur*(k+1): zcurw
            % nocur*k    : zcurwp
            % nocur*(k+1): zkcur
            case {'wl-xy'}
                stationi=local_argin(argin);
                MN=waqua('readsds',sds,exper,ARRAY);
                MN=reshape(MN,[length(MN)/2 2]);
                MN=MN(stationi,:);
                [zgx,zgy]=waqua_get_spatial(sds,exper,'zgrid',dim,refdate,{});
                mn = sub2ind(size(zgx),MN(:,2),MN(:,1));
                varargout={zgx(mn) zgy(mn)};
            case {'wlstat','wl-stat','umag-stat','u-stat','v-stat', ...
                    'mq-stat','cq-stat','w-stat','z-stat','z-sbstat'}
                data=waqua('readsds',sds,exper,ARRAY,tstep);
                varargout={data.Data(:,stoffset+(stationi-1)+krange(k)) refdate+data.SimTime/1440};
            case {'uv-stat'}
                data=waqua('readsds',sds,exper,'TIMEHISTORIES_FLOW_TIMHIS',tstep);
                varargout={data.Data(:,stoffset+(stationi-1)+krange(k)) ...
                    data.Data(:,stoffset+nocur*kmax+(stationi-1)+krange(k)) refdate+data.SimTime/1440};
            otherwise
                stationi=local_argin(argin);
                sts=waqua('readsds',sds,exper,'CHECKPOINTS_FLOW_NAMCHK');
                switch field
                    case {'flowstat-wl','wlstat','wl-stat','wl-xy'}
                        sts=sts(1:nowl);
                    case {'flowstat-cur','umag-stat','u-stat','v-stat','uv-stat'}
                        sts=sts(nowl+(1:nocur));
                    case 'flowcrs-u'
                        sts=sts(nowl+nocur+(1:ntra));
                    case 'flowcrs-v'
                        sts=sts(nowl+nocur+ntra+(1:ntrav));
                end
                sts=sts';
                varargout={sts(stationi)};
        end

    otherwise
        if length(field)>8 & strcmp(field(1:8),'stsubst:')
            Subs=lower(waquaio(sds,exper,'substances'));
            sbs=field(9:end);
            s=strmatch(sbs,Subs,'exact');
            if isempty(s)
                s=strmatch(sbs,Subs);
            end
            if isequal(size(s),[1 1])
                iconta=waqua('readsds',sds,exper,'CONTROL_TRANS_ICONTA');
                icontb=waqua('readsds',sds,exper,'CONTROL_TRANS_ICONTB');
                % ref. "substances"
                nopol=iconta(3);
                lmax=icontb(2);
                %
                [tstep,stationi]=local_argin(argin);
                %
                stoffset=(stationi-1)*lmax+(s-1);
                krange=1+(0:kmax-1)*nopol*lmax;
                %
                data=waqua('readsds',sds,exper,'TIMEHISTORIES_TRANS',tstep);
                varargout={data.Data(:,stoffset+krange) refdate+data.SimTime/1440};
            else
                error(sprintf('Invalid substance name: %s',sbs))
            end
        else
            error(sprintf('Unknown field: %s',field))
        end
end

%==========================================================================
% SPATIAL DATA
%==========================================================================
function varargout = waqua_get_spatial(sds,exper,field,dim,refdate,argin)
[nm,sact]=getspace(sds,exper,dim);
nmax = dim.nmax;
mmax = dim.mmax;
kmax = dim.kmax;
npnt = dim.npnt;
inact = dim.inact;
sph_dupl = dim.sph_dupl;
%
switch field
    case {'grid','dgrid','zgrid','ugrid','vgrid'}
        [n,m]=local_argin(argin);
        nm=nm(n,m);
        sznm=size(nm);
        %-----
        %conmsh=waqua('readsds',sds,exper,'MESH_CONMSH');
        %  1: DX = GridSize X dir.
        %  2: DY = GridSize Y dir.
        %  3: DKSI = GridSize Transformed Grid (=1.)
        %  4: ANGLAT = Latitude (Deg.)
        %  5: RLAMBD = East Longuitude Point(1,1) (Deg.)
        %  6: FI = Latitude Point(1,1) (Deg.)
        %  7: GRDANG = Clockwise Angle from Y to North (Deg.)
        %  8: DLAMBD = GridCellAngle X dir. (Deg.)
        %  9: DFI = GridCellAngle Y dir. (Deg.)
        % 10: REARTH = Radius of Earth

        data=waqua('readsds',sds,exper,'MESH_CURVIL');
        % CURVIL: GUU, GVV, XDEP, YDEP, XZETA, YZETA, XU, YU, XV, YV
        switch field
            case {'grid','dgrid'}
                offset=2;
            case 'zgrid'
                offset=4;
            case 'ugrid'
                offset=6;
            case 'vgrid'
                offset=8;
        end
        %
        x=data((sph_dupl*10+offset)*npnt+(1:npnt));
        y=data((sph_dupl*10+offset+1)*npnt+(1:npnt));
        x(inact)=NaN;
        y(inact)=NaN;
        x((x==0)&(y==0))=NaN;
        y(isnan(x))=NaN;
        X=x(nm); X=reshape(X,sznm);
        Y=y(nm); Y=reshape(Y,sznm);
        varargout={X Y};

    case {'zgrid3d','ugrid3d','vgrid3d'}
        [tstep,n,m,k]=local_argin(argin);
        nm=nm(n,m);
        sznm=size(nm);
        num_n = length(n);
        num_m = length(m);
        if ischar(k), k=1:kmax; end
        num_k = length(k);
        %-----
        %conmsh=waqua('readsds',sds,exper,'MESH_CONMSH');
        %  1: DX = GridSize X dir.
        %  2: DY = GridSize Y dir.
        %  3: DKSI = GridSize Transformed Grid (=1.)
        %  4: ANGLAT = Latitude (Deg.)
        %  5: RLAMBD = East Longuitude Point(1,1) (Deg.)
        %  6: FI = Latitude Point(1,1) (Deg.)
        %  7: GRDANG = Clockwise Angle from Y to North (Deg.)
        %  8: DLAMBD = GridCellAngle X dir. (Deg.)
        %  9: DFI = GridCellAngle Y dir. (Deg.)
        % 10: REARTH = Radius of Earth

        data=waqua('readsds',sds,exper,'MESH_CURVIL');
        % CURVIL: GUU, GVV, XDEP, YDEP, XZETA, YZETA, XU, YU, XV, YV
        switch field
            case 'zgrid3d'
                offset=4;
                zoffset=0;
            case 'ugrid3d'
                offset=6;
                zoffset=1;
            case 'vgrid3d'
                offset=8;
                zoffset=2;
        end
        x=data((sph_dupl*10+offset)*npnt+(1:npnt));
        y=data((sph_dupl*10+offset+1)*npnt+(1:npnt));
        x(inact)=NaN; y(inact)=NaN;
        X=x(nm);
        Y=y(nm);
        data=waqua('readsds',sds,exper,'LAYER_INTERFACES',tstep);
        if iscell(data.Data)
            if isempty(data.Data{1})
                error('LAYER_INTERFACES not available for requested time step.')
            else
                z=data.Data{1}(zoffset*npnt*(kmax+1)+(1:(npnt*(kmax+1))));
            end
        else
            z=data.Data(zoffset*npnt*(kmax+1)+(1:(npnt*(kmax+1))));
        end
        z(inact+(0:kmax)*npnt)=NaN;
        Z=zeros(num_n,num_m,num_k);
        for i=1:num_k
            ik = k(i);
            Z(:,:,i)=z(nm+(ik-1)*npnt);
        end
        X=repmat(X,[1 1 num_k]);
        Y=repmat(Y,[1 1 num_k]);
        varargout={X Y Z refdate+data.SimTime/1440};

    case {'depth','height','depth_wl_points'}
        [n,m]=local_argin(argin);
        nm=nm(n,m);
        sznm=size(nm);
        if strcmp(field,'depth_wl_points')
            %DPS_FLOW only for Waqua
            data=waqua('readsds',sds,exper,'DPS_FLOW');
            data(inact)=NaN; data(data==-999)=NaN;
            Dep=data(nm);
            Dep(~sact)=NaN;
        else
            sact = sact(n,m);
            dact = sact | sact([2:end end],:) | ...
                sact(:,[2:end end]) | sact([2:end end],[2:end end]);
            data=waqua('readsds',sds,exper,'MESH_H');
            data(inact)=NaN; data(data==-999)=NaN;
            Dep=data(nm);
            Dep(~dact)=NaN;
        end
        switch field
            case {'depth','depth_wl_points'}
                varargout={Dep};
            case 'height'
                varargout={-Dep};
        end

    case {'drywet'}
        [tstep,n,m]=local_argin(argin);
        nm=nm(n,m);
        sznm=size(nm);
        %-----
        thd=waqua('readsds',sds,exper,'SOLUTION_DRYWET',tstep);
        if ~isempty(thd.Data)
            THDu=thd.Data(1:npnt);
            THDu=THDu(nm);
            %THDu=reshape(THDu,sznm);
            THDv=thd.Data(npnt+(1:npnt));
            THDv=THDv(nm);
            %THDv=reshape(THDv,sznm);
        else
            THDu=[];
            THDv=[];
        end
        varargout={THDu THDv refdate+thd.SimTime/1440};

    case {'veloc','veloc0','disch','disch0','udisch','udisch0','dischpot'}
        [tstep,n,m,k]=local_argin(argin);
        nmfull=nm;
        nm=nm(n,m);
        num_n = length(n);
        num_m = length(m);
        if ischar(k), k=1:kmax; end
        num_k = length(k);
        sznm=size(nm);
        psznm=prod(sznm);
        sact=sact(n,m);
        %-----
        u=waqua('readsds',sds,exper,'SOLUTION_FLOW_UP',tstep);
        v=waqua('readsds',sds,exper,'SOLUTION_FLOW_VP',tstep);
        % SOLUTION_DRYWET (KHU,KHV: DRY/FLOODING VELOCITY POINTS)
        nmk=repmat(nm,[1 1 num_k]);
        for i=1:num_k
            ik = k(i);
            nmk(:,:,i)=nmk(:,:,i)+(ik-1)*npnt;
        end
        inact=inact+(0:kmax-1)*npnt;
        switch field
            case 'veloc0'
                U=u.Data;
                if ~isempty(U)
                    U(inact)=NaN;
                    U=U(nmk);
                else
                    U=[];
                end;
                V=v.Data;
                if ~isempty(V)
                    V(inact)=NaN;
                    V=V(nmk);
                else
                    V=[];
                end
            case {'disch0','disch','dischpot','udisch0','udisch'}
                if kmax>=2
                    error('Discharge not supported for kmax>=2')
                end
                data=waqua('readsds',sds,exper,'MESH_CURVIL');
                % CURVIL: GUU, GVV, XDEP, YDEP, XZETA, YZETA, XU, YU, XV, YV
                %
                % only for kmax==2
                %
                tmp=waqua('readsds',sds,exper,'SOLUTION_FLOW_HU',tstep);
                tmp=tmp.Data;
                switch field
                    case {'udisch','udisch0'}
                        UU=u.Data.*tmp; % U*HU
                    otherwise
                        UU=u.Data.*tmp.*(data((1:npnt)+(10*sph_dupl)*npnt)'); % U*HU*GUU
                end
                tmp=waqua('readsds',sds,exper,'SOLUTION_FLOW_HV',tstep);
                tmp=tmp.Data;
                switch field
                    case {'udisch','udisch0'}
                        VV=v.Data.*tmp; % V*HV
                    otherwise
                        VV=v.Data.*tmp.*(data((1:npnt)+(10*sph_dupl+1)*npnt)'); % V*HV*GVV
                end
                %
                % for all kmax
                %
                switch field
                    case {'disch0','udisch0'}
                        UU(inact)=NaN; VV(inact)=NaN;
                        U=UU(nm);
                        V=VV(nm);
                    case {'disch','udisch'}
                        UU(inact)=NaN; VV(inact)=NaN;
                        ndm=nm([1 1:(nmax-1)],:);
                        nmd=nm(:,[1 1:(mmax-1)]);
                        for i=1:num_k
                            ik = k(i);
                            nms=(ik-1)*npnt;
                            U(:,:,i)=.5*( UU(nm+nms) + UU(ndm+nms) );
                            V(:,:,i)=.5*( VV(nm+nms) + VV(nmd+nms) );
                        end
                    otherwise
                        U=UU(nm);
                        V=VV(nm);
                end
                U=reshape(U,[psznm num_k]); U(~sact,:)=NaN; U=reshape(U,[sznm num_k]);
                V=reshape(V,[psznm num_k]); V(~sact,:)=NaN; V=reshape(V,[sznm num_k]);
            case 'veloc'
                UU=u.Data;
                VV=v.Data;
                ndm=nmfull(max(1,n-1),m);
                nmd=nmfull(n,max(1,m-1));
                UU(inact)=NaN; VV(inact)=NaN;
                for i=1:num_k
                    ik=k(i);
                    nms=(ik-1)*npnt;
                    U(:,:,i)=.5*( UU(nm+nms) + UU(ndm+nms) );
                    V(:,:,i)=.5*( VV(nm+nms) + VV(nmd+nms) );
                end
                U=reshape(U,[psznm num_k]); U(~sact,:)=NaN; U=reshape(U,[sznm num_k]);
                V=reshape(V,[psznm num_k]); V(~sact,:)=NaN; V=reshape(V,[sznm num_k]);
        end
        if (nargout==4) & strcmp(field,'veloc')
            w=waqua('readsds',sds,exper,'SOLUTION_FLOW_WPHYS',tstep);
            W=w.Data;
            if ~isempty(W)
                W(inact)=NaN;
                W=W(nmk);
                W=reshape(W,[nmax*mmax num_k]); W(~sact,:)=NaN; W=reshape(W,nmax,mmax,num_k);
            else
                W=[];
            end
            varargout={U V W refdate+u.SimTime/1440};
        elseif strcmp(field,'dischpot')
            U(isnan(U))=0;
            V(isnan(V))=0;
            %
            % if boundary lies on gridline 1, we can use ...
            %
            %   offset=cumsum(V(1,:),2);
            %
            % else we have to do something like ...
            %
            [mmax,i]=max(sact,[],1);
            j=find(mmax~=0); i(mmax==0)=[];
            ind=sub2ind(size(sact),i,j);
            ind1=sub2ind(size(sact),i,max(j-1,1));
            offset=zeros([1 size(U,2)]);

            offset(j)=V(ind)+U(ind)-U(ind1);
            offset=cumsum(offset);
            %
            % compute discharge potential ...
            %
            data=cumsum(U,1)-repmat(offset,[size(U,1) 1]);
            %
            % the same result should be obtained when doing the
            % above in the alternate direction ...
            %
            %    data=cumsum(V,2)-repmat(cumsum(U(:,1),1),[1 size(V,2)]);
            %
            % finally, make sure dat the potential is positive ...
            %
            data=data-min(data(:));
            varargout={data refdate+u.SimTime/1440};
        else
            varargout={U V refdate+u.SimTime/1440};
        end

    case {'xyveloc','xyudisch'}
        [tstep,n,m,k]=local_argin(argin);
        if isequal(n,':')
            n = 1:dim.nmax;
        end
        if isequal(m,':')
            m = 1:dim.mmax;
        end
        nmfull=nm;
        nm=nmfull(n,m);
        num_n = length(n);
        num_m = length(m);
        if ischar(k), k=1:kmax; end
        num_k = length(k);
        sznm=[num_n num_m];
        psznm=prod(sznm);
        sact=sact(n,m);
        %-----
        u=waqua('readsds',sds,exper,'SOLUTION_FLOW_UP',tstep);
        v=waqua('readsds',sds,exper,'SOLUTION_FLOW_VP',tstep);
        if strcmp(field,'xyudisch')
            if kmax>=2
                error('Discharge not supported for kmax>=2')
            end
            tmp=waqua('readsds',sds,exper,'SOLUTION_FLOW_HU',tstep);
            UU=u.Data.*tmp.Data; % U*HU
            tmp=waqua('readsds',sds,exper,'SOLUTION_FLOW_HV',tstep);
            VV=v.Data.*tmp.Data; % V*HV
        else
            UU=u.Data;
            VV=v.Data;
        end
        if isempty(UU) | isempty(VV),
            varargout={[] [] u.SimTime};
            return
        end
        %
        inact=inact+(0:kmax-1)*npnt;
        UU(inact)=NaN; VV(inact)=NaN;
        %
        % Read geometry ...
        %
        data=waqua('readsds',sds,exper,'MESH_CURVIL');
        data(npnt*(0:(9+sph_dupl*10))+1)=NaN;
        % CURVIL: GUU, GVV, XDEP, YDEP, XZETA, YZETA, XU, YU, XV, YV
        %
        % Extend index range to get all relevant geometry information ...
        %
        n_ = [max(1,n(1)-1) n];
        m_ = [max(1,m(1)-1) m];
        nm_ = nmfull(n_,m_);

        xdep=data((sph_dupl*10+2)*npnt+nm_);
        ydep=data((sph_dupl*10+3)*npnt+nm_);

        guu=data(sph_dupl*10*npnt+nm_); guu(guu==0)=inf;
        ndm=nmfull(max(1,n_-1),m_);
        xdep1=data((sph_dupl*10+2)*npnt+ndm);
        ydep1=data((sph_dupl*10+3)*npnt+ndm);
        yut=(ydep-ydep1)./guu;
        xut=(xdep-xdep1)./guu;

        gvv=data((sph_dupl*10+1)*npnt+nm_); gvv(gvv==0)=inf;
        nmd=nmfull(n_,max(1,m_-1));
        xdep1=data((sph_dupl*10+2)*npnt+nmd);
        ydep1=data((sph_dupl*10+3)*npnt+nmd);
        yvt=(ydep-ydep1)./gvv;
        xvt=(xdep-xdep1)./gvv;
        %
        % Now generate the data for the range selected by the user ...
        %
        n1=1:length(n_)-1;
        n2=2:length(n_);
        m1=1:length(m_)-1;
        m2=2:length(m_);
        %
        ndm = nmfull(max(1,n-1),m);
        nmd = nmfull(n,max(1,m-1));
        %
        for i=1:num_k
            ik = k(i);
            nms=(ik-1)*npnt;
            U(:,:,i)=.5*(  yut(n2,m2).*UU(nm+nms) + yut(n2,m1).*UU(nmd+nms) ...
                - yvt(n2,m2).*VV(nm+nms) - yvt(n1,m2).*VV(ndm+nms));
            V(:,:,i)=.5*(- xut(n2,m2).*UU(nm+nms) - xut(n2,m1).*UU(nmd+nms) ...
                + xvt(n2,m2).*VV(nm+nms) + xvt(n1,m2).*VV(ndm+nms));
        end
        U=reshape(U,[psznm num_k]); U(~sact,:)=NaN; U=reshape(U,[sznm num_k]);
        V=reshape(V,[psznm num_k]); V(~sact,:)=NaN; V=reshape(V,[sznm num_k]);
        %
        if nargout==4
            w=waqua('readsds',sds,exper,'SOLUTION_FLOW_WPHYS',tstep);
            W=w.Data;
            if ~isempty(W)
                nmk=repmat(nm,[1 1 num_k]);
                for i=1:num_k
                    ik = k(i);
                    nmk(:,:,i)=nmk(:,:,i)+(i-1)*npnt;
                end
                %
                W(inact)=NaN;
                W=W(nmk);
                W=reshape(W,[psznm num_k]); W(~sact,:)=NaN; W=reshape(W,[sznm num_k]);
            else
                W=[];
            end
            varargout={U V W refdate+u.SimTime/1440};
        else
            varargout={U V refdate+u.SimTime/1440};
        end

    case {'wlvl','waterlevel','head','wdepth'}
        [tstep,n,m]=local_argin(argin);
        nm=nm(n,m);
        num_n = length(n);
        num_m = length(m);
        sznm=[num_n num_m];
        sact=sact(n,m);
        %-----
        wl=waqua('readsds',sds,exper,'SOLUTION_FLOW_SEP',tstep);
        WL=wl.Data;
        if strcmp(field,'wdepth')
            dps=waqua('readsds',sds,exper,'DPS_FLOW')';
            dps(dps>400)=NaN;
            WL = WL+dps;
        end
        if ~isempty(WL)
            WL(inact)=NaN;
            WL=WL(nm);
        else
            WL=[];
        end
        WL(~sact)=NaN;
        %WL=reshape(WL,sznm);
        if strcmp(field,'head')
            [U,V]=waqua_get_spatial(sds,exper,'veloc',dim,refdate,argin);
            WL=WL+(U.^2+V.^2)/(2*9.81);
        end
        varargout={WL refdate+wl.SimTime/1440};

    case {'weirs'}
        [n,m]=local_argin(argin);
        nm=nm(n,m);
        sznm=size(nm);
        sact=sact(n,m);
        %-----
        wp=waqua('readsds',sds,exper,'MESH_WEIPOS');
        wp=reshape(wp,[length(wp)/4 4]);
        udam=zeros(sznm);
        vdam=zeros(sznm);
        %
        indomain = ismember(wp(:,1),m) & ismember(wp(:,2),n);
        wp = wp(indomain,:);
        %
        minn = min(n)-1;
        minm = min(m)-1;
        uflg=wp(:,3)>0; uind=sub2ind(sznm,wp(uflg,2)-minn,wp(uflg,1)-minm);
        vflg=wp(:,4)>0; vind=sub2ind(sznm,wp(vflg,2)-minn,wp(vflg,1)-minm);
        udam(uind)=1;
        vdam(vind)=1;
        if nargout==2
            varargout={udam vdam};
        else
            wh=waqua('readsds',sds,exper,'COEFF_FLOW_WEIDIM');
            wh=reshape(wh,[length(wh)/6 6]);
            uhgh=zeros(sznm);
            vhgh=zeros(sznm);
            %
            wh = wh(indomain,:);
            %
            uhgh(uind)=-wh(uflg,1);
            vhgh(vind)=-wh(vflg,4);
            varargout={udam vdam uhgh vhgh};
        end

    case {'dissip','energy'}
        switch field
            case 'dissip'
                entry='SOLUTION_TURB_DISSIP';
            case 'energy'
                entry='SOLUTION_TURB_ENERGY';
        end
        %-----
        [tstep,n,m,k]=local_argin(argin);
        nm=nm(n,m);
        num_n = length(n);
        num_m = length(m);
        if ischar(k), k=1:kmax+1; end
        num_k = length(k);
        sznm=size(nm);
        sact=sact(n,m);
        %-----
        tke=waqua('readsds',sds,exper,entry,tstep);
        nmk=repmat(nm,[1 1 num_k]);
        for i=1:num_k
            ik = k(i);
            nmk(:,:,i)=nmk(:,:,i)+(ik-1)*npnt;
        end
        inact=inact+(0:kmax)*npnt;
        TKE=tke.Data;
        if ~isempty(TKE)
            TKE(inact)=NaN; TKE=TKE(nmk);
        else
            TKE=[];
        end
        TKE=reshape(TKE,[num_n*num_m num_k]); TKE(~sact,:)=NaN; TKE=reshape(TKE,num_n,num_m,num_k);
        varargout={TKE refdate+tke.SimTime/1440};

    case 'chezy'
        [tstep,n,m]=local_argin(argin);
        nm=nm(n,m);
        sznm=size(nm);
        sact=sact(n,m);
        %-----
        rcgenb=waqua('readsds',sds,exper,'COEFF_GENERAL_RCGENB');
        %  1: AG = gravity accel
        %  2: DAIR = air density (for wind force)
        %  3: DWAT = water density (for wind force)
        %  4: WCONV = wind conversion
        %  5: WSTR = wind speed-independent drag coefficient
        %  6: WSCDV1 = 1st wind speed
        %  7: WSCDV2 = 2nd wind speed
        %  8: CDV1 = lower bound linear drag
        %  9: CDV2 = upper bound linear drag
        % 10: DYNVIS = dynamic viscosity water
        ag=rcgenb(1);

        rconta=waqua('readsds',sds,exper,'CONTROL_FLOW_RCONTA');
        %  1: DTMIN = (full) integration step in minutes
        %  3: TSTART = simulation start time (min)
        %  4: TSTOP = simulation stop time (min)
        %  6: EPS = conv. crit. continuity
        %  7: -- (harm analysis)
        %  8: TICVAL = time interval Chezy comput.
        % 11: VAR = marginal depth (dry/flood) = TRSH
        % 12: EPS1 = accuracy Lagrangian time-integral
        % 13: DCO = dry/flood parameter
        % 23: TLFSMO = tide smooth time
        % 24-26: TFBAR,TIBAR,TLBAR = first, inc, last time barrier steering
        % 34: RHOM = density sea water surrounding model (kg/liter)
        % 35: ALPH0 = press. gradient coefficient salinity
        % 36: TEMPW = water temp. state equation
        % 37: SALW = salinity state equation
        % 42: VICO = hor. viscosity
        % 43: THETAC = weighing factor Chezy at weirs
        % 44: RFELAG = red.factor weir-type groynes
        % 45: RFELNG = red.factor weir-type not groynes
        % 46: HKRDUM = dummy overflow height
        % 51: DEFVIV = default vert. visc.
        % 52: Z0 = roughness height veloc. log prof.
        % 53: TETA = implicit coefficient Euler momentum
        % 54: CMUKL = fact. parab. eddy visc.
        % 55: RKAPPA = Von Karman
        % 56: ESMOOT = constant log-layer smooth walls
        % 57-61: CMU, SIGMAK, SIGMAE, CEPS1, CEPS2 = constants k-eps model
        % 62-63: ETA0, GAMMA = constants RNG k-eps model
        % 64: CEPS3 = constant extended k-eps model
        % 65: VTURB = 0 (stnd), 1 (RNG), 2 (ext) k-eps model
        dtmin=rconta(1);

        data=waqua('readsds',sds,exper,'SOLUTION_FLOW_CZ',tstep);
        czx=data.Data(1:npnt);
        czy=data.Data(npnt+(1:npnt));
        czx(inact)=NaN; czy(inact)=NaN;
        czx=sqrt((ag*dtmin*60/2)./czx);
        czy=sqrt((ag*dtmin*60/2)./czy);
        CZX=czx(nm);
        CZY=czy(nm);
        CZX(CZX>1e7)=NaN;
        CZY(CZY>1e7)=NaN;
        varargout={CZX CZY refdate+data.SimTime/1440};
    otherwise
        if length(field)>6 & strcmp(field(1:6),'subst:')
            Subs=lower(waquaio(sds,exper,'substances'));
            sbs=field(7:end);
            s=strmatch(sbs,Subs,'exact');
            if isempty(s)
                s=strmatch(sbs,Subs);
            end
            if isequal(size(s),[1 1])
                [tstep,n,m,k]=local_argin(argin);
                nm=nm(n,m);
                sznm=size(nm);
                sact=sact(n,m);
                num_n = length(n);
                num_m = length(m);
                if ischar(k), k=1:kmax; end
                num_k = length(k);
                %-----
                subs=waqua('readsds',sds,exper,'SOLUTION_TRANS',tstep);
                nmk=repmat(nm,[1 1 num_k]);
                for i=1:num_k
                    ik = k(i);
                    nmk(:,:,i)=nmk(:,:,i)+(ik-1)*npnt;
                end
                inact=inact+(0:kmax-1)*npnt;
                SUBS=subs.Data(npnt*(s-1)*kmax+(1:kmax*npnt));
                if ~isempty(SUBS)
                    SUBS(inact)=NaN;
                    SUBS=SUBS(nmk);
                    SUBS=reshape(SUBS,[num_n*num_m num_k]);
                    SUBS(~sact,:)=NaN;
                    SUBS=reshape(SUBS,num_n,num_m,num_k);
                else
                    SUBS=[];
                end
                varargout={SUBS refdate+subs.SimTime/1440};
            else
                error(sprintf('Invalid substance name: %s',sbs))
            end
        else
            error(sprintf('Unknown field: %s',field))
        end
end
%==========================================================================
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%==========================================================================


function varargout=local_argin(argin)
if nargout>length(argin)
    argin(1,length(argin)+1:nargout)={':'};
end
varargout=argin(1:nargout);


function [nm,sact]=getspace(sds,exper,dim)
%
nm=waqua('readsds',sds,exper,'MESH_LGRID');
nm=reshape(nm,dim.sz);
%
sact=logical(zeros(dim.sz));
irogeo=waqua('readsds',sds,exper,'MESH_IROGEO');
irogeo=reshape(irogeo,[3 length(irogeo)/3]);
for i=1:dim.num_irogeo_rows
    sact(irogeo(1,i),irogeo(2,i):irogeo(3,i))=1;
end
