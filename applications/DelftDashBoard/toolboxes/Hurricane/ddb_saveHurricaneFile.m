function ddb_saveHurricaneFile(handles,filename1,filename2)

fid = fopen(filename1,'w');

% time=clock;
datestring=datestr(datenum(clock),31);

usrstring='- Unknown user';
usr=getenv('username');

if size(usr,1)>0
    usrstring=[' - File created by ' usr];
end

txt=['# ddb_hurricaneToolbox - DelftDashBoard v' handles.delftDashBoardVersion usrstring ' - ' datestring];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

txt=['Name              "' handles.Toolbox(tb).Input.name '"'];
fprintf(fid,'%s \n',txt);

txt=['InputOption       ' num2str(handles.Toolbox(tb).Input.holland)];
fprintf(fid,'%s \n',txt);

txt=['InitialEyeSpeed   ' num2str(handles.Toolbox(tb).Input.initSpeed)];
fprintf(fid,'%s \n',txt);

txt=['InitialEyeDir     ' num2str(handles.Toolbox(tb).Input.initDir)];
fprintf(fid,'%s \n',txt);

txt=['NrPoint           ' num2str(handles.Toolbox(tb).Input.nrPoint)];
fprintf(fid,'%s \n',txt);

for i=1:handles.Toolbox(tb).Input.nrPoint
   txt=['TrackData         ' datestr(handles.Toolbox(tb).Input.date(i),'yyyymmdd HHMMSS') ' ' ...
                     num2str(handles.Toolbox(tb).Input.trY(i),'%6.2f') ' ' num2str(handles.Toolbox(tb).Input.trX(i),'%6.2f') ' ' ...
                     num2str(handles.Toolbox(tb).Input.par1(i),'%5.1f') ' ' num2str(handles.Toolbox(tb).Input.par2(i),'%5.1f')];

   fprintf(fid,'%s \n',txt);
end

fclose(fid);

% SaveWesOldTrackFile(handles,filename2)
% SaveWesInputfile(handles,filename2)
%SaveDefaultGrid(handles)

% %------------------------------------------------------
% function SaveWesOldTrackFile(handles,filename2)
% fid = fopen(filename2,'w');
% 
% % time=clock;
% datestring=datestr(datenum(clock),31);
% 
% usrstring='- Unknown user';
% usr=getenv('username');
% 
% if size(usr,1)>0
%     usrstring=[' - File created by ' usr];
% end
% 
% txt=['* ddb_hurricaneToolbox - DelftDashBoard v' handles.delftDashBoardVersion usrstring ' - ' datestring];
% fprintf(fid,'%s \n',txt);
% 
% txt = '*year MM DD HH  LAT  LON      Dm     Vm      MaxW   R100  R50    R35    B      A     Pdrop';
% fprintf(fid,'%s \n',txt);
% txt = '*    (UTC)                    deg.  (kts)    (kts) (nm)  (nm)   (nm)                    (Pa)';
% fprintf(fid,'%s \n',txt);
% 
% if handles.Toolbox(tb).Input.Date(1)<handles.Model(md).Input(ad).ItDate
%     GiveWarning('Warning','First time hurricane data is smaller than Delft3D reference time!');
% %     for ii=handles.Toolbox(tb).Input.NrPoint+1:2
% %         handles.Toolbox(tb).Input.Date(ii)=handles.Toolbox(tb).Input.Date(ii-1);
% %         handles.Toolbox(tb).Input.TrX(ii)=handles.Toolbox(tb).Input.TrX(ii-1);
% %         handles.Toolbox(tb).Input.TrY(ii)=handles.Toolbox(tb).Input.TrY(ii-1);
% %         handles.Toolbox(tb).Input.Par1(ii)=handles.Toolbox(tb).Input.Par1(ii-1);
% %         handles.Toolbox(tb).Input.Par2(ii)=handles.Toolbox(tb).Input.Par2(ii-1);
% %     end
% %     handles.Toolbox(tb).Input.Date(1)=handles.Model(md).Input(ad).ItDate;
% %     handles.Toolbox(tb).Input.TrX(1)=handles.Toolbox(tb).Input.TrX(2);
% %     handles.Toolbox(tb).Input.TrY(1)=handles.Toolbox(tb).Input.TrY(2);
% %     handles.Toolbox(tb).Input.Par1(1)=handles.Toolbox(tb).Input.Par1(2);
% %     handles.Toolbox(tb).Input.Par2(1)=handles.Toolbox(tb).Input.Par2(2);
% %     handles.Toolbox(tb).Input.NrPoint=handles.Toolbox(tb).Input.NrPoint+1;
% end
% 
% if handles.Toolbox(tb).Input.Date(end)<handles.Model(md).Input(ad).StopTime
%     GiveWarning('Warning','Last time hurricane data is smaller than Delft3D stop time!');
% %     n=handles.Toolbox(tb).Input.NrPoint;
% %     handles.Toolbox(tb).Input.Date(n+1)=handles.Model(md).Input(ad).StopTime;
% %     handles.Toolbox(tb).Input.TrX(n+1)=handles.Toolbox(tb).Input.TrX(n);
% %     handles.Toolbox(tb).Input.TrY(n+1)=handles.Toolbox(tb).Input.TrY(n);
% %     handles.Toolbox(tb).Input.Par1(n+1)=handles.Toolbox(tb).Input.Par1(n);
% %     handles.Toolbox(tb).Input.Par2(n+1)=handles.Toolbox(tb).Input.Par2(n);
% %     handles.Toolbox(tb).Input.NrPoint=handles.Toolbox(tb).Input.NrPoint+1;
% end
% 
% if handles.Toolbox(tb).Input.Date(1)>handles.Model(md).Input(ad).ItDate
%     n=handles.Toolbox(tb).Input.NrPoint;
%     handles.Toolbox(tb).Input.Date(2:n+1)=handles.Toolbox(tb).Input.Date(1:end);
%     handles.Toolbox(tb).Input.TrX(2:n+1)=handles.Toolbox(tb).Input.TrX(1:end);
%     handles.Toolbox(tb).Input.TrY(2:n+1)=handles.Toolbox(tb).Input.TrY(1:end);
%     handles.Toolbox(tb).Input.Par1(2:n+1)=handles.Toolbox(tb).Input.Par1(1:end);
%     handles.Toolbox(tb).Input.Par2(2:n+1)=handles.Toolbox(tb).Input.Par2(1:end);
%     handles.Toolbox(tb).Input.Date(1)=handles.Model(md).Input(ad).ItDate;
%     handles.Toolbox(tb).Input.TrX(1)=handles.Toolbox(tb).Input.TrX(2);
%     handles.Toolbox(tb).Input.TrY(1)=handles.Toolbox(tb).Input.TrY(2);
%     handles.Toolbox(tb).Input.Par1(1)=handles.Toolbox(tb).Input.Par1(2);
%     handles.Toolbox(tb).Input.Par2(1)=handles.Toolbox(tb).Input.Par2(2);
%     handles.Toolbox(tb).Input.NrPoint=n+1;
% end
% 
% if handles.Toolbox(tb).Input.Holland > 0
%    for i=1:handles.Toolbox(tb).Input.NrPoint
% %      [YY MM DD] = datevec(handles.Toolbox(tb).Input.Date{i});
% %      dattim     = [ num2str(YY,'%04d') ' ' num2str(MM,'%02d') ' ' ...
% %                     num2str(DD,'%02d') ' ' num2str(handles.Toolbox(tb).Input.Time{i},'%02d')];
%                 
%      dattim=datestr(handles.Toolbox(tb).Input.Date(i),'yyyy mm dd HH');
%      if i==1
%        txt=[ dattim ' ' ...
%              num2str(handles.Toolbox(tb).Input.TrY(i),'%6.2f') ' ' num2str(handles.Toolbox(tb).Input.TrX(i),'%6.2f') '  ' ...
%              num2str(handles.Toolbox(tb).Input.InitDir,'%5.1f')   '     ' ...
%              num2str(handles.Toolbox(tb).Input.InitSpeed,'%5.1f') '    '  ...
%              '  1e30  1e30  1e30  1e30 ' ...
%              num2str(handles.Toolbox(tb).Input.Par1(i),'%5.1f') ' ' num2str(handles.Toolbox(tb).Input.Par2(i),'%5.1f') ...
%              ' 1e30 '];
%      else
%        txt=[ dattim ' ' ...
%              num2str(handles.Toolbox(tb).Input.TrY(i),'%6.2f') ' ' num2str(handles.Toolbox(tb).Input.TrX(i),'%6.2f') ...
%              '                       1e30  1e30  1e30  1e30 ' ...
%              num2str(handles.Toolbox(tb).Input.Par1(i),'%5.1f') ' ' num2str(handles.Toolbox(tb).Input.Par2(i),'%5.1f') ...
%              ' 1e30 '];
%      end
%      fprintf(fid,'%s \n',txt);
%    end  
% else
%    for i=1:handles.Toolbox(tb).Input.NrPoint
% %      [YY MM DD] = datevec(handles.Toolbox(tb).Input.Date{i});
% %      dattim     = [ num2str(YY,'%04d') ' ' num2str(MM,'%02d') ' ' ...
% %                     num2str(DD,'%02d') ' ' num2str(handles.Toolbox(tb).Input.Time{i},'%02d')];
%      dattim=datestr(handles.Toolbox(tb).Input.Date(i),'yyyy mm dd HH');
%      if i==1
%        txt=[ dattim ' ' ...
%              num2str(handles.Toolbox(tb).Input.TrY(i),'%6.2f') ' ' num2str(handles.Toolbox(tb).Input.TrX(i),'%6.2f') '  ' ...
%              num2str(handles.Toolbox(tb).Input.InitDir,'%5.1f')   '     ' ...
%              num2str(handles.Toolbox(tb).Input.InitSpeed,'%5.1f') '    '  ...
%              num2str(handles.Toolbox(tb).Input.Par1(i),'%5.1f') '  1e30  1e30  1e30  1e30   1e30  ' ...             
%              num2str(handles.Toolbox(tb).Input.Par2(i),'%5.1f')];
%      else
%        txt=[ dattim ' ' ...
%              num2str(handles.Toolbox(tb).Input.TrY(i),'%6.2f') ' ' num2str(handles.Toolbox(tb).Input.TrX(i),'%6.2f') ...
%              '                     ' ...
%              num2str(handles.Toolbox(tb).Input.Par1(i),'%5.1f') '  1e30  1e30  1e30  1e30   1e30  '... 
%              num2str(handles.Toolbox(tb).Input.Par2(i),'%5.1f')];
%      end
%      fprintf(fid,'%s \n',txt);
%    end  
% end
% 
% fclose(fid);
% 
% %------------------------------------------------------
% function SaveWesInputfile(handles,filename2)
% 
% fout= fopen('wes.inp','w');
% 
% fprintf(fout,'%s\n','COMMENT             = WES run');
% fprintf(fout,'%s\n','COMMENT             = Grid: none');
% fprintf(fout,'%s\n','BACKGROUND_WIND     = NO');
% fprintf(fout,'%s\n','LAT,LON_LEFT_DOWN   =  -8.75  95.00 dummy values');
% fprintf(fout,'%s\n','LAT,LON_TOP_RIGHT   =  25.00 126.25 dummy values');
% fprintf(fout,'%s\n','RESOLUTION_(DEGREE) =   1.25   1.25 dummy values');
% fprintf(fout,'%s\n','FILE_TYPE           = NO');
% fprintf(fout,'%s\n','GRIB_FILE_NAME      = ');
% fprintf(fout,'%s\n','CYCLONE_DATA        = YES');
% fprintf(fout,'%s\n','CYCLONE_PAR._FILE   = wes_old.trk ');
% fprintf(fout,'%s\n','SPIDERS_WEB_DIMENS. = 100  36');
% fprintf(fout,'%s\n','RADIUS_OF_CYCLONE   = 400000.000');
% fprintf(fout,'%s\n','WIND CONVERSION FAC = 1.00');
% fprintf(fout,'%s\n','WIND CONV. FAC (TRK)= 1.00');
% itdat=datestr(handles.Model(md).Input(ad).ItDate,'yyyymmdd HHMM');
% %stdat=datestr(handles.Model(md).Input(ad).ItDate,'yyyymmdd HHMM');
% fprintf(fout,'%s%s%s\n','D3D_START_DATE      = ',itdat,'  UTC');
% %tim=(handles.Model(md).Input(ad).StopTime-handles.Model(md).Input(ad).StartTime)*1440;
% %tim=max(tim,handles.Toolbox(tb).Input.Date(end)-handles.Toolbox(tb).Input.Date(1));
% %tim=(handles.Toolbox(tb).Input.Date(end)-handles.Toolbox(tb).Input.Date(1))*1440;
% tim=(handles.Toolbox(tb).Input.Date(end)-handles.Model(md).Input(ad).ItDate)*1440;
% fprintf(fout,'%s%10.1f%s\n','D3D_SIM._PERIOD     = ',tim,'  MINUTES');
% fprintf(fout,'%s\n','D3D_GRID_FILE_TYPE  = GRD');
% %fprintf(fout,'%s\n','D3D_GRID_FILE_NAME  = default.grd ');
% fprintf(fout,'%s\n',['D3D_GRID_FILE_NAME  = ' handles.Model(md).Input(ad).GrdFile]);
% %fprintf(fout,'%s\n','D3D_GRID_DIMENSION  = 400     400');
% mmax=handles.Model(md).Input(ad).MMax-1;
% nmax=handles.Model(md).Input(ad).NMax-1;
% fprintf(fout,'%s\n',['D3D_GRID_DIMENSION  = ' num2str(mmax) ' ' num2str(nmax)]);
% fprintf(fout,'%s\n','D3D_COORDINATES     = Spherical');
% fprintf(fout,'%s\n','NO._OF_OBS._DATA    = 0');
% fprintf(fout,'%s\n','OBS._DATA_FILE_NAME =');
% fprintf(fout,'%s\n','SVWP OUTPUT TYPE    = NO');  
% fprintf(fout,'%s\n','MERGE_WINDS_&_PRES. = NO');
% 
% % fin = fopen('wes_default.inp','r');
% % fout= fopen('wes.inp','w');
% % for i=1:24
% %   hhh = fgets(fin);
% %   txt = hhh;
% %      if size(strfind(hhh,'#TRACKFILE#')) > 0
% % %       txt = strrep(hhh,'#TRACKFILE#',handles.Toolbox(tb).Input.trk_file);
% %        txt = strrep(hhh,'#TRACKFILE#',filename2);
% %      elseif size(strfind(hhh,'#D3D_START#')) > 0
% %        txt = strrep(hhh,'#D3D_START#',[handles.Toolbox(tb).Input.D3d_start '    ' num2str(handles.Toolbox(tb).Input.D3d_sttime)]);
% %      elseif size(strfind(hhh,'#D3D_SIMPER#')) > 0;
% %        txt = strrep(hhh,'#D3D_SIMPER#',num2str(handles.Toolbox(tb).Input.D3d_simper,'%25.12d'));
% %      elseif size(strfind(hhh,'#DEFAULT.GRD#')) > 0;
% %        txt = strrep(hhh,'#DEFAULT.GRD#','default.grd     ');
% %      elseif size(strfind(hhh,'#MMAX,NMAX#')) > 0;
% %        txt = strrep(hhh,'#MMAX,NMAX#','400   400');
% %      end
% %    fprintf(fout,'%s',txt);
% % end
% % 
% % fclose(fin);
% fclose(fout);
% 
% %------------------------------------------------------
% function SaveDefaultGrid(handles)
% 
% xmin = single( int16(handles.Toolbox(tb).Input.TrX(1)-20) );
% ymin = single( int16(handles.Toolbox(tb).Input.TrY(1)-20) );
% if xmin < -180
%    xmin = -180;
% end
% if ymin < -70
%    ymin = -70;
% end
% if ymin > 30
%    ymin = 30;
% end
% 
% dxdy = 0.1;
% 
% X(1,1) = xmin+180;
% Y(1,1) = ymin;
% for i=2:400
%    X(i,1) = X(i-1,1)+dxdy;
%    Y(i,1) = Y(i-1,1);
% end
% 
% for j=2:400
%    for i=1:400
%       X(i,j) = X(i,j-1);
%       Y(i,j) = Y(i,j-1) + dxdy;
%    end
% end 
% ddb_wlgrid('write','default.grd',X,Y,'default.enc');
% 
