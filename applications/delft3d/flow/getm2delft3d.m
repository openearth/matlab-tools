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
   
   MDF = delft3d_io_mdf('read',OPT.mdf);
   MDF.keywords.commnt  = [filename(OPT.topo),'_cartesian.grd' ];
   MDF.keywords.filcco  = [filename(OPT.topo),'_spherical.grd' ];
   MDF.keywords.filgrd  = [filename(OPT.topo),'.enc'           ];
   MDF.keywords.fildep  = [filename(OPT.topo),'_at_centers.dep'];
   MDF.keywords.fildry  = [filename(OPT.topo),'.dry'           ];
   MDF.keywords.dpsopt  = 'DP';
   MDF.keywords.dpuopt  = 'MIN'; % required in combination with depth at centers

   MDF.keywords.mnkmax  = [fliplr(size(D.bathymetry)) 1];
   MDF.keywords.anglat  = D.proj_lat;

   wlgrid('write','FileName',MDF.keywords.commnt,'X',D.cor.x'  ,'Y',D.cor.y'  ,'CoordinateSystem','Cartesian');
   wlgrid('write','FileName',[OPT.workdir,MDF.keywords.filcco],'X',D.cor.lon','Y',D.cor.lat','CoordinateSystem','Spherical');
  %wlgrid('write','FileName',[OPT.workdir,MDF.keywords.filcco],'X',D.xx(2:end-1),'Y',D.yx(2:end-1)); % this would keep land cells in and gives too many dry points

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

   fid = fopen('mask.txt','w');
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
   B.minutes = (B.datenum-OPT.reference_time).*24.*60;
   tmask = 1:min(length(B.minutes),OPT.ntmax);
   
   for dseg = 2:max(OPT.points_per_bnd,2); % we recommend 2 for best preventing unnecesarry duplication in bct columns

      fid       = fopen(OPT.bdyinfo,'r');
      nbnd      = 0;
      sidenames = {'west', 'north', 'east', 'south'};
      bndtype   = {'N','','Z',''}; % ZERO_GRADIENT,SOMMERFELD,CLAMPED,FLATHER_ELEV
      
      nseg = 0;
      iseg = 0;
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
            iseg  = iseg+nseg;
            nseg  = ceil(length(m)./dseg);
            tmp.m = pad(m,nseg*dseg,m(end));
            tmp.n = pad(n,nseg*dseg,n(end));
            for j = 1:nseg
            ind0 = (j-1)*dseg+1;
            ind1 = (j  )*dseg;
      
            Bnd.DATA(iseg+j).name               = [sidenames{iside},'_',num2str(i),'_',num2str(j)];
            Bnd.DATA(iseg+j).bndtype            = bndtype{vals(4)}; %'{Z} | C | N | Q | T | R'
            Bnd.DATA(iseg+j).datatype           = 'T';              %'{A} | H | Q | T'
            Bnd.DATA(iseg+j).mn                 = [tmp.m(ind0) tmp.n(ind0) tmp.m(ind1) tmp.n(ind1)];
            Bnd.DATA(iseg+j).alfa               = 0;
      
            Bct.Table(iseg+j).Name              = ['Boundary Section : ',num2str(iseg+j)];
            Bct.Table(iseg+j).Contents          = 'Uniform';
            Bct.Table(iseg+j).Location          = [sidenames{iside},'_',num2str(i),'_',num2str(j)];
            Bct.Table(iseg+j).TimeFunction      = 'non-equidistant';
            Bct.Table(iseg+j).ReferenceTime     = str2num(datestr(OPT.reference_time,'yyyymmdd'));
            Bct.Table(iseg+j).TimeUnit          = 'minutes';
            Bct.Table(iseg+j).Interpolation     = 'linear';
            Bct.Table(iseg+j).Parameter(1).Name = 'time';
            Bct.Table(iseg+j).Parameter(1).Unit = '[min]';
            Bct.Table(iseg+j).Parameter(2).Name = 'water elevation (z)  end A';
            Bct.Table(iseg+j).Parameter(2).Unit = '[m]';
            Bct.Table(iseg+j).Parameter(3).Name = 'water elevation (z)  end B';
            Bct.Table(iseg+j).Parameter(3).Unit = '[m]';
            Bct.Table(iseg+j).Data              = ([B.minutes(tmask),B.elev(tmask,ind0),B.elev(tmask,ind1)]);
            Bct.Table(iseg+j).Format            = '% 6g % .3f % .3f'; % time int in minutes, waterlevel float in mm
      
            end % iseg
            
         end % i

      end % iside
      
      fclose(fid);
      
      MDF.keywords.filbnd  = [filename(OPT.bdyinfo), '_',num2str(dseg),'.bnd'];
      MDF.keywords.filbct  = [filename(OPT.bdyinfo), '_',num2str(dseg),'.bct'];

      delft3d_io_bnd('write',[filename(OPT.bdyinfo),                 '_0.bnd'],Bnd0);
      delft3d_io_bnd('write',[OPT.workdir,MDF.keywords.filbnd],Bnd);
      bct_io        ('write',[OPT.workdir,MDF.keywords.filbct],Bct);
      
      clear Bct Bnd

   end % dseg

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
      
      MDF.keywords.filsrc = [filename(OPT.riverinfo),'.src'];
      MDF.keywords.fildis = [filename(OPT.river)    ,'.dis'];
      
      delft3d_io_src('write',[OPT.workdir,MDF.keywords.filsrc],R);
     %% 
     [Dis.station_names,~,Dis.station_indices] = unique({R.name});
     
     for i=1:length(Dis.station_names)
         ind = find(Dis.station_indices==i);
         for j=1:length(ind)
         R(ind(j)).ipeer = j;
         R(ind(j)).npeer = length(ind);
         R(ind(j)).peers = ind;
         end
     end
      
%% discharge data 

   Q.time      = ncread   (OPT.river,'time');
   Q.timeunits = ncreadatt(OPT.river,'time','units');
   Q.datenum   = udunits2datenum(Q.time,Q.timeunits);
   Q.minutes   = (Q.datenum - OPT.reference_time)*24*60;
   clear Dis
   for ipnt=1:length(R)

      Dis.Table(ipnt).Name          = ['Discharge:',num2str(ipnt),' ',R(ipnt).name,' (',num2str(R(ipnt).ipeer),'/',num2str(R(ipnt).npeer),')'];
      Dis.Table(ipnt).Contents      = 'regular';
      Dis.Table(ipnt).Location      = R(ipnt).name;
      Dis.Table(ipnt).TimeFunction  = 'non-equidistant';
      Dis.Table(ipnt).ReferenceTime = str2num(datestr(OPT.reference_time,'yyyymmdd'));
      Dis.Table(ipnt).TimeUnit      = 'minutes';
      Dis.Table(ipnt).Interpolation = 'linear';
      Dis.Table(ipnt).Parameter(1)  = struct('Name','time','Unit','[min]');
      Dis.Table(ipnt).Parameter(2)  = struct('Name','flux/discharge rate','Unit','[m3/s]');
      Q.Q                           = ncread(OPT.river,R(ipnt).name)./R(ipnt).npeer; % distribute evenly over peers
      Q.Q(isnan(Q.Q))               = 0;
      Dis.Table(ipnt).Data          = [Q.minutes,Q.Q];
      Dis.Table(ipnt).Format        = '%d %g';
   
   end
   
   bct_io('write',[OPT.workdir,MDF.keywords.fildis],Dis);
   
%% save new mdf with all links to new delft3d include files

   MDF.keywords.itdate = datestr(OPT.reference_time,'yyyy-mm-dd');
   MDF.keywords.tstart =  B.minutes(tmask(  1));
   MDF.keywords.tstop  =  B.minutes(tmask(end));
   MDF.keywords.flmap  = [B.minutes(tmask(  1)) 120  B.minutes(tmask(end))];
   MDF.keywords.flhis  = [B.minutes(tmask(  1))  10  B.minutes(tmask(end))];
                          %123456789012345678901234567890
   MDF.keywords.runtxt = ['GETM converted to Delft3D from',...
                          filenameext(OPT.topo   ),',',...
                          filenameext(OPT.bdyinfo),',',...
                          filenameext(OPT.bdy    ),'.',...
                          '$Id$ ',...
                          '$HeadURL$'];
                      
   delft3d_io_mdf('write',[OPT.workdir,OPT.RUNID,'.mdf'],MDF.keywords);
