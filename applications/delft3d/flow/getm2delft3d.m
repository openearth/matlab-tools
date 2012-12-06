function MDF = getm2delft3d(varargin)
%getm2delft3d convert GETM grid, depth and boundary conditions input to Delft3D input
%
%  getm2delft3d(<keyword,value>) where required keywords are:
%
% GETM:
% * topo           - name of GETM netCDF topo file
% * bdyinfo        - name of GETM ascii boundary definitions
% * bdy            - name of GETM netCDF boundary condition values
%
% Delft3D:
% * mdf            - empty settings file for Delft3D input
% * reference_time - reference time for Delft3D input
% * points_per_bnd - stride for converting GETM bdy values to Delft3D segments:
%                    is at least 2 because Delft3D has boundary segments that
%                    connect 2 endpoints, whereas GETM has seperate boundary points
%
%See also: delft3d

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id$
%  $Date$
%  $Author$
%  $Revision$
%  $HeadURL$
%  $Keywords: $

   OPT.inp            = '*.inp'; % fortran namelist, not yet xml
   OPT.topo           = '*.nc';
  %OPT.topoc          = '*.nc';
   OPT.bdyinfo        = '*.dat';
   OPT.bdy            = '*.nc';
   OPT.riverinfo      = '*.dat';
   OPT.river          = '*.nc';

   OPT.reference_time = datenum(2003,1,1); % overwrites on in mdf, used for *.bct and *.dis
   OPT.mdf            = '*.mdf';
   OPT.points_per_bnd = 2;
   OPT.ntmax          = Inf; % fro debugging save only so many boundary time points
   OPT.workdir        = '';
   OPT.RUNID          = mfilename;
   
   OPT = setproperty(OPT,varargin);
   
%% 

   if ~isempty(OPT.inp)
      getm = fortran_namelist2struct(OPT.inp)
   else
   % initialize getm with flow defaults
      getm.param.title             = '';
      getm.param.runid             = OPT.RUNID;
      getm.time.start              = [];
      getm.time.stop               = [];
      getm.domain.vel_depth_method = 0;
      getm.domain.longitude        = [];
      getm.domain.latitude         = [];
      getm.domain.f_plane          = 0;
      getm.domain.crit_depth       = .3;
      getm.domain.min_depth        = .1;
      getm.domain.kdum             = 1;
      getm.m2d.Am                  = 1;
      getm.m2d.An_const            = 1;
      getm.m3d.avmback             = 1e-6;
      getm.m3d.avhback             = 1e-6;
      getm.temp.temp_const         = 15;
      getm.salt.salt_const         = 31;
      getm.rivers.use_river_salt   = 1; % delft3d cannot neglect it
      getm.rivers.use_river_temp   = 1; % delft3d cannot neglect it
   end
   
   MDF  = delft3d_io_mdf('new');
   MDF.keywords.runtxt = getm.param.title;
   MDF.keywords.tstart = (datenum(getm.time.start,'yyyy-mm-dd hh:MM:ss') - OPT.reference_time)*24*60;
   MDF.keywords.tstop  = (datenum(getm.time.stop ,'yyyy-mm-dd hh:MM:ss') - OPT.reference_time)*24*60;
   MDF.keywords.anglon  = getm.domain.longitude;
   MDF.keywords.anglat  = getm.domain.latitude;
   MDF.keywords.dryflc  = getm.domain.min_depth;
   MDF.keywords.vicouv  = getm.m2d.Am;
   MDF.keywords.dicouv  = getm.m2d.An_const;
   MDF.keywords.vicoww  = getm.m3d.avmback;
   MDF.keywords.dicoww  = getm.m3d.avhback;
   MDF.keywords.thick   = repmat(100/getm.domain.kdum,[getm.domain.kdum 1]);
   if getm.m3d.calc_salt; MDF.keywords.sub1(1) = 'S';MDF.keywords.s0 = repmat(getm.salt.salt_const,size(MDF.keywords.thick));end % calc_* means it solves the equation (d3d has no ...
   if getm.m3d.calc_temp; MDF.keywords.sub1(2) = 'T';MDF.keywords.t0 = repmat(getm.temp.temp_const,size(MDF.keywords.thick));;end % ... diagnostic mode, getm.param.runtype is irrelevant)
   
   switch getm.domain.vel_depth_method
   case 0, MDF.keywords.dpuopt = 'mean';
   case 1, MDF.keywords.dpuopt = 'min';
   case 2, MDF.keywords.dpuopt = 'upw';
   end
   MDF.keywords.dpuopt  = 'MIN'; % required in combination with depth at centers


%% grid and depth and dry
%  chop fully dry part from grid vertices (4 surrounding dry points)
%  to exclude it from computational domain

  [D,M] = nc2struct(OPT.topo,'exclude',{'latc','lonc','convc'});
  
  [D.cor.x,D.cor.y]=meshgrid(D.xx(2:end-1),D.yx(2:end-1));
   D.cor.mask = corner2centernan(isnan(D.bathymetry));

   D.cor.lat = corner2center(nc_varget(OPT.topo,'latc'));
   D.cor.lon = corner2center(nc_varget(OPT.topo,'lonc'));

   D.cor.x  (D.cor.mask==1)=nan; % mask is 0|.25|.5|.75|1
   D.cor.y  (D.cor.mask==1)=nan;
   D.cor.lat(D.cor.mask==1)=nan; % mask is 0|.25|.5|.75|1
   D.cor.lon(D.cor.mask==1)=nan;
   
   D.cor.z = corner2center(D.bathymetry);
   
   if getm.domain.f_plane
   MDF.keywords.filcco  = [filename(OPT.topo),'_cartesian.grd'];
   filcc2               = [filename(OPT.topo),'_spherical.grd'];
%--wlgrid('write','FileName',[OPT.workdir,MDF.keywords.filcco],'X',D.cor.x'  ,'Y',D.cor.y'  ,'CoordinateSystem','Cartesian');
%--wlgrid('write','FileName',[OPT.workdir,             filcc2],'X',D.cor.lon','Y',D.cor.lat','CoordinateSystem','Spherical');
   else
   MDF.keywords.filcco  = [filename(OPT.topo),'_spherical.grd'];
   filcc2               = [filename(OPT.topo),'_cartesian.grd'];
%--wlgrid('write','FileName',[OPT.workdir,MDF.keywords.filcco],'X',D.cor.lon','Y',D.cor.lat','CoordinateSystem','Spherical');
%--wlgrid('write','FileName',[OPT.workdir,             filcc2],'X',D.cor.x'  ,'Y',D.cor.y'  ,'CoordinateSystem','Cartesian');
   end
  %wlgrid('write','FileName',[OPT.workdir,MDF.keywords.filcco],'X',D.xx(2:end-1),'Y',D.yx(2:end-1)); % this would keep land cells defined and thus yield too many dry points

   MDF.keywords.filgrd  = [filename(OPT.topo),'.enc'           ];
   MDF.keywords.fildep  = [filename(OPT.topo),'_at_centers.dep'];
   MDF.keywords.fildry  = [filename(OPT.topo),'.dry'           ];
   MDF.keywords.dpsopt  = 'DP';
   MDF.keywords.mnkmax  = [fliplr(size(D.bathymetry)) getm.domain.kdum];


   D.enclosure = enclosure('extract',D.cor.x',D.cor.y');
   enclosure('write',        [OPT.workdir,MDF.keywords.filgrd],D.enclosure);

   wldep ('write',           [OPT.workdir,MDF.keywords.fildep],'',D.bathymetry'); % includes 2 dummy rows/cols
   wldep ('write',strrep(OPT.topo,'.nc','_at_corners.dep'),'',addrowcol(D.cor.z',1,1,nan)); % includes 2 dummy rows/cols

%% dry points: those not yet excluded by removing vertices
%  all inactive T-cells with 4 real vertices: (i) a square, (ii) a c or u shape, or (iii) a ||-shape.
%  In contrast: -shape or | shapes are aready switched off in vertices.
   
   D.cen.mask = isnan(D.bathymetry(2:end-1,2:end-1))&... % z is nan
               (corner2center(~isnan(D.cor.x))==1); % and all surrouning corners are real which can be: 
   
   [n,m] = find(D.cen.mask);
   %pcolorcorcen(D.cen.mask);
   %plot(m,n,'ko');
   delft3d_io_dry('write',[OPT.workdir,MDF.keywords.fildry],m+1,n+1);
   
%% save mask for ascii diff comparison with supplied GETM mask

   fid = fopen([OPT.workdir,'mask.txt'],'w');
   for row=size(D.bathymetry,1):-1:1
      fprintf(fid,'%1d ',~isnan(D.bathymetry(row,1:end-1)));
      fprintf(fid,'%1d' ,~isnan(D.bathymetry(row,  end  ))); % no trailing space
      fprintf(fid,'\n');
   end
   fclose(fid);
   
%% boundary locations and conditions
%  boundary positions not truly generic yet, should be via az matrix to get remove 
%  internal corners at connections of vertical e/w and horizontal n/s boundaries
   
   B = nc2struct(OPT.bdy,'include',{'elev','time'});
   B.minutes = (B.datenum-OPT.reference_time)*24*60;

%  tmask = 1:min(length(B.minutes),OPT.ntmax);
   
   tmask = find(B.datenum >= datenum(getm.time.start,'yyyy-mm-dd hh:MM:ss') & ...
                B.datenum <= datenum(getm.time.stop ,'yyyy-mm-dd hh:MM:ss'));
                
   disp(length(tmask))                
   disp(length(B.minutes))                
   
   nsub = getm.m3d.calc_salt + getm.m3d.calc_temp;
   
   for dseg = 2:max(OPT.points_per_bnd,2); % we recommend 2 for best preventing unnecesarry duplication in bct columns

      fid       = fopen(OPT.bdyinfo,'r');
      nbnd      = 0;
      sidenames = {'west', 'north', 'east', 'south'};
      bndtype   = {'N','','Z',''}; % ZERO_GRADIENT,SOMMERFELD,CLAMPED,FLATHER_ELEV
      
      nseg = 0;
      for iside = 1:4 % compass directions
         rec = fgetl_no_comment_line(fid,'#!');
         n   = str2num(strtok(rec));
         for i=1:n
            nbnd = nbnd + 1;
            rec  = fgetl_no_comment_line(fid,'#!');
            vals = str2num(rec);
      
            if odd(iside)
      
            % vertical boundaries: East + West
                mn = [vals(1) vals(2) vals(1) vals(3)];
      
                % remove 'corners'
                mn(2) = max(mn(2),     2);
                mn(4) = min(mn(4),MDF.keywords.mnkmax(2)-1);
                n  = mn(2):mn(4);
                m  = repmat(mn(1),size(n));
      
            else
      
            % horizontal boundaries: North + South
                mn = [vals(2) vals(1) vals(3) vals(1)];
      
                % remove 'corners'
                mn(1) = max(mn(1),     2);
                mn(3) = min(mn(3),MDF.keywords.mnkmax(1)-1);
                m  = mn(1):mn(3);
                n  = repmat(mn(2),size(m));

            end % odd
      
            % all grid cells per segment for quick overview
            % and ASCII comparison of GETM bdyinfo file with Delft3D bnd file
            Bnd0.DATA(nbnd).name         = [sidenames{iside},num2str(i)];
            Bnd0.DATA(nbnd).bndtype      = bndtype{vals(4)}; %'{Z} | C | N | Q | T | R'
            Bnd0.DATA(nbnd).datatype     = 'T';              %'{A} | H | Q | T'
            Bnd0.DATA(nbnd).mn           = mn;
            Bnd0.DATA(nbnd).alfa         = 0;
      
            % multiple grid cells per segment: as bct has two columns, we recommend
            % to merge at least 2 seperate GETM points into one 2-point Delft3D segment
            nseg  = ceil(length(m)./dseg);
            tmp.m = pad(m,nseg*dseg,m(end)); % make array artificially somewhat larger if dseg does not fit integer # times in boundary.
            tmp.n = pad(n,nseg*dseg,n(end));

            for j = 1:nseg
            ind0 = (j-1)*dseg+1; % indices into overall bct indices from GETM
            ind1 = (j  )*dseg;   % indices into overall bct indices from GETM
      
            Bnd.DATA(j).name               = [sidenames{iside},'_',num2str(i),'_',num2str(j)];
            Bnd.DATA(j).bndtype            = bndtype{vals(4)}; %'{Z} | C | N | Q | T | R'
            Bnd.DATA(j).datatype           = 'T';              %'{A} | H | Q | T'
            Bnd.DATA(j).mn                 = [tmp.m(ind0) tmp.n(ind0) tmp.m(ind1) tmp.n(ind1)];
            Bnd.DATA(j).alfa               = 0;
      
            Bxt.Table(1).Name               = ['Boundary Section : ',num2str(j)];
            Bxt.Table(1).Contents           = 'Uniform';
            Bxt.Table(1).Location           = [sidenames{iside},'_',num2str(i),'_',num2str(j)];
            Bxt.Table(1).TimeFunction       = 'non-equidistant';
            Bxt.Table(1).ReferenceTime      = str2num(datestr(OPT.reference_time,'yyyymmdd'));
            Bxt.Table(1).TimeUnit           = 'minutes';
            Bxt.Table(1).Interpolation      = 'linear';
            Bxt.Table(1).Parameter(1).Name  = 'time';
            Bxt.Table(1).Parameter(1).Unit  = '[min]';
            Bxt.Table(1).Data               = [];
            Bxt.Table(1).Format             = '';

            Bct.Table(j)                   = Bxt.Table;
            Bct.Table(j).Parameter(2).Name = 'water elevation (z)  end A';
            Bct.Table(j).Parameter(2).Unit = '[m]';
            Bct.Table(j).Parameter(3).Name = 'water elevation (z)  end B';
            Bct.Table(j).Parameter(3).Unit = '[m]';
            Bct.Table(j).Data              = ([B.minutes(tmask),B.elev(tmask,ind0),B.elev(tmask,ind1)]);
            Bct.Table(j).Format            = '% 6g % .3f % .3f'; % time int in minutes, waterlevel float in mm
      
            if getm.m3d.calc_salt
            js = (j-1)*nsub+1;
            Bcc.Table(js)                   = Bxt.Table;
            Bcc.Table(js).Parameter(2).Name = 'Salinity             end A uniform';
            Bcc.Table(js).Parameter(2).Unit = '[ppt]';
            Bcc.Table(js).Parameter(3).Name = 'Salinity             end B uniform';
            Bcc.Table(js).Parameter(3).Unit = '[ppt]';
            Bcc.Table(js).Data              = ([MDF.keywords.tstart MDF.keywords.s0(1) MDF.keywords.s0(1);MDF.keywords.tstop MDF.keywords.s0(1) MDF.keywords.s0(1);]);
            Bcc.Table(js).Format            = '% 6g % .3f % .3f'; % time int in minutes, waterlevel float in mm
            end
      
            if getm.m3d.calc_temp
            jt = (j-1)*nsub+1+getm.m3d.calc_salt;
            Bcc.Table(jt)                   = Bxt.Table;
            Bcc.Table(jt).Parameter(2).Name = 'Temperature          end A uniform';
            Bcc.Table(jt).Parameter(2).Unit = '[°C]';
            Bcc.Table(jt).Parameter(3).Name = 'Temperature          end B uniform';
            Bcc.Table(jt).Parameter(3).Unit = '[°C]';
            Bcc.Table(jt).Data              = ([MDF.keywords.tstart MDF.keywords.t0(1) MDF.keywords.t0(1);MDF.keywords.tstop MDF.keywords.t0(1) MDF.keywords.t0(1);]);
            Bcc.Table(jt).Format            = '% 6g % .3f % .3f'; % time int in minutes, waterlevel float in mm
            end

            end % j = 1:nseg
            
            BND.NTables = length(Bnd.DATA);
            
         end % i=1:n

      end % iside
      
      fclose(fid);
      
      MDF.keywords.filbnd  = [filename(OPT.bdyinfo), '_',num2str(dseg),'.bnd'];
      MDF.keywords.filbct  = [filename(OPT.bdyinfo), '_',num2str(dseg),'.bct'];
      MDF.keywords.filbcc  = [filename(OPT.bdyinfo), '_',num2str(dseg),'.bcc'];
      MDF.keywords.commnt  = [filename(OPT.bdyinfo),                 '_0.bnd'];
 
      delft3d_io_bnd('write',[OPT.workdir,MDF.keywords.commnt],Bnd0);
      delft3d_io_bnd('write',[OPT.workdir,MDF.keywords.filbnd],Bnd);
      bct_io        ('write',[OPT.workdir,MDF.keywords.filbct],Bct);
      bct_io        ('write',[OPT.workdir,MDF.keywords.filbcc],Bcc);
      
      clear Bct Bcc Bnd

   end % dseg

   MDF.keywords.rettis  = repmat(MDF.keywords.rettis,[BND.NTables 1]);
   MDF.keywords.rettib  = repmat(MDF.keywords.rettib,[BND.NTables 1]);
   
%% discharge locations

      fid      = fopen(OPT.riverinfo,'r');
      rec      = fgetl(fid);
      nriver = str2num(strtok(rec));

      rec    = fgetl(fid);
      ipnt = 0;
      name0  = '';
      
      while ~(isnumeric(rec)|isempty(strtok(rec)))
         [m   ,rec] = strtok(rec);
         [n   ,rec] = strtok(rec);
         [name,rec] = strtok(rec);

          ipnt = ipnt + 1;
          R(ipnt).getm_name     = name; % for access of netCDF file
          R(ipnt).name          = name;
          R(ipnt).interpolation = 'Y';
          R(ipnt).m             = str2num(m);
          R(ipnt).n             = str2num(n);
          R(ipnt).k             = 0;

         %if ~strcmpi(name,name0);
         %   a = iriver + 1;
         %   R(iriver).m    = [];
         %   R(iriver).n    = [];
         %   R(iriver).name = name;
         %end
         %R(iriver).m(end+1)    = str2num(m);
         %R(iriver).n(end+1)    = str2num(n);
         %name0 = name;

         rec      = fgetl(fid);
      end
      
      fclose(fid);
      
     [Dis.station_names,~,Dis.station_indices] = unique({R.name});
     
      for i=1:length(Dis.station_names)
         ind = find(Dis.station_indices==i);
         for j=1:length(ind)
         R(ind(j)).ipeer = j;
         R(ind(j)).npeer = length(ind);
         R(ind(j)).peers = ind;
         if R(ind(j)).npeer > 1
         R(ind(j)).name  = [R(ind(j)).name,'_',num2str(R(ind(j)).ipeer)]; % unique names required in Delft3D
         end
         end
      end
      
      MDF.keywords.filsrc = [filename(OPT.riverinfo),'.src'];
      MDF.keywords.fildis = [filename(OPT.river)    ,'.dis'];
      delft3d_io_src('write',[OPT.workdir,MDF.keywords.filsrc],R);

%% discharge data 

for iq=2:-1:1
    
   if iq==2
      getm0 = getm;
      getm.m3d.calc_temp  = 0;
      getm.m3d.calc_salt  = 0;
      MDF.keywords.fildis = [filename(OPT.river)    ,'_Q_only.dis'];
   end

   Q.time      = ncread   (OPT.river,'time');
   Q.timeunits = ncreadatt(OPT.river,'time','units');
   Q.datenum   = udunits2datenum(Q.time,Q.timeunits);
   Q.minutes   = (Q.datenum - OPT.reference_time)*24*60;

   for ipnt=1:length(R)

      Q.Q             = ncread(OPT.river,R(ipnt).getm_name)./R(ipnt).npeer; % distribute evenly over peers
      Q.Q(isnan(Q.Q)) = 0;

      Dis.Table(ipnt).Name             = ['Discharge:',num2str(ipnt),' ',R(ipnt).name,' (',num2str(R(ipnt).ipeer),'/',num2str(R(ipnt).npeer),')'];
      Dis.Table(ipnt).Contents         = 'regular';
      Dis.Table(ipnt).Location         = R(ipnt).name;
      Dis.Table(ipnt).TimeFunction     = 'non-equidistant';
      Dis.Table(ipnt).ReferenceTime    = str2num(datestr(OPT.reference_time,'yyyymmdd'));
      Dis.Table(ipnt).TimeUnit         = 'minutes';
      Dis.Table(ipnt).Interpolation    = 'linear';
      Dis.Table(ipnt).Parameter(1)     = struct('Name','time'               ,'Unit','[min]');
      Dis.Table(ipnt).Parameter(2)     = struct('Name','flux/discharge rate','Unit','[m3/s]');

      if getm.m3d.calc_salt;
         Dis.Table(ipnt).Parameter(end+1) = struct('Name','Salinity'        ,'Unit','[ppt]');
         if ~(getm.rivers.use_river_salt)
         Q.salt = Q.Q.*0;
         else
         Q.salt = Q.Q.*0;
         warning('river salinity from file not implemented yet')
         end
      else
         Q.salt = [];
      end

      if getm.m3d.calc_temp;
         Dis.Table(ipnt).Parameter(end+1) = struct('Name','Temperature'     ,'Unit','[°C]');
         if ~(getm.rivers.use_river_temp)
         Q.temp = Q.Q.*0 + MDF.keywords.t0(1);
         else
         Q.temp = Q.Q.*0;
         warning('river temperature from file not implemented yet')
         end
      else
         Q.temp = [];
      end
      
      Dis.Table(ipnt).Data          = [Q.minutes, Q.Q, Q.salt, Q.temp];
      Dis.Table(ipnt).Format        = '%d %g';
   
   end
   
   bct_io('write',[OPT.workdir,MDF.keywords.fildis],Dis);
   
   if iq==2;getm = getm0; end % restore
   
end   

B.minutes(tmask(  1))
B.minutes(tmask(end))   

MDF.keywords.tstart
MDF.keywords.tstop 

%% save new mdf with all links to new delft3d include files

   if isempty(MDF.keywords.tstart)
      MDF.keywords.tstart =  B.minutes(tmask(  1));
      MDF.keywords.tstop  =  B.minutes(tmask(end));
   else
      if MDF.keywords.tstart < B.minutes(tmask(  1)); error('start time before first boundary data');end
      if MDF.keywords.tstop  > B.minutes(tmask(end)); error('start time after  last  boundary data');end
   end

   MDF.keywords.itdate = datestr(OPT.reference_time,'yyyy-mm-dd');
   MDF.keywords.flmap  = [MDF.keywords.tstart 120  MDF.keywords.tstop];
   MDF.keywords.flhis  = [MDF.keywords.tstart  10  MDF.keywords.tstop];
                          %123456789012345678901234567890
   MDF.keywords.runtxt = ['GETM converted to Delft3D from',...
                          filenameext(OPT.inp      ),'.',...
                          filenameext(OPT.topo     ),',',...
                          filenameext(OPT.bdyinfo  ),',',...
                          filenameext(OPT.bdy      ),',',...
                          filenameext(OPT.riverinfo),',',...
                          filenameext(OPT.river    ),'.',...
                          '$Revision$ ',...
                          '$HeadURL$'];
                      
   delft3d_io_mdf('write',[OPT.workdir,OPT.RUNID,'.mdf'],MDF.keywords);

%% save config file for ready-start linux simulation

   fid = fopen([OPT.workdir,'config_flow2d3d.ini'],'w');
   fprintf(fid,'%s \n', '[FileInformation]');
   fprintf(fid,'%s \n', '   FileCreatedBy    = $Id$');
   t = now;[d,w]=weekday(now);
   fprintf(fid,'%s \n',['   FileCreationDate = ',w, datestr(t,' mmm dd HH:MM:SS yyyy')]);
   fprintf(fid,'%s \n', '   FileVersion      = 00.01');
   fprintf(fid,'%s \n', '[Component]');
   fprintf(fid,'%s \n', '   Name    = flow2d3d');
   fprintf(fid,'%s \n',['   MDFfile = ',OPT.RUNID]);
   fclose(fid);
