function ddb_saveCycloneFile(handles,filename)

fid = fopen(filename,'w');

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

txt=['SpiderwebRadius   ' num2str(handles.Toolbox(tb).Input.radius)];
fprintf(fid,'%s \n',txt);

txt=['NrPoints          ' num2str(handles.Toolbox(tb).Input.nrTrackPoints)];
fprintf(fid,'%s \n',txt);

for i=1:handles.Toolbox(tb).Input.nrTrackPoints
   txt=['TrackData         ' datestr(handles.Toolbox(tb).Input.trackT(i),'yyyymmdd HHMMSS') ' ' ...
                     num2str(handles.Toolbox(tb).Input.trackY(i),'%6.2f') ' ' num2str(handles.Toolbox(tb).Input.trackX(i),'%6.2f') ' ' ...
                     num2str(handles.Toolbox(tb).Input.par1(i),'%5.1f') ' ' num2str(handles.Toolbox(tb).Input.par2(i),'%5.1f')];

   fprintf(fid,'%s \n',txt);
end

fclose(fid);
