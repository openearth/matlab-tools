function ddb_saveTsunamiFile(handles,filename)

fid = fopen(filename,'w');

time=clock;
datestring=datestr(datenum(clock),31);

usrstring='- Unknown user';
usr=getenv('username');

if size(usr,1)>0
    usrstring=[' - File created by ' usr];
end

txt=['# ddb_tsunamiToolbox - DelftDashBoard v' handles.delftDashBoardVersion usrstring ' - ' datestring];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

txt=['Magnitude      ' num2str(handles.Toolbox(tb).Input.Magnitude)];
fprintf(fid,'%s \n',txt);

txt=['DepthFromTop   ' num2str(handles.Toolbox(tb).Input.DepthFromTop)];
fprintf(fid,'%s \n',txt);

if handles.Toolbox(tb).Input.RelatedToEpicentre
    txt=['RelatedToEpicentre   yes'];
    fprintf(fid,'%s \n',txt);
    txt=['Latitude       ' num2str(handles.Toolbox(tb).Input.Latitude)];
    fprintf(fid,'%s \n',txt);
    txt=['Longitude      ' num2str(handles.Toolbox(tb).Input.Longitude)];
    fprintf(fid,'%s \n',txt);
else
    txt=['RelatedToEpicentre   no'];
    fprintf(fid,'%s \n',txt);
end

txt=['NrSegments     ' num2str(handles.Toolbox(tb).Input.NrSegments)];
fprintf(fid,'%s \n',txt);
for i=1:handles.Toolbox(tb).Input.NrSegments
    txt=['Segment        ' num2str(handles.Toolbox(tb).Input.Dip(i)) ' ' num2str(handles.Toolbox(tb).Input.SlipRake(i))];
    fprintf(fid,'%s \n',txt);
end
for i=1:handles.Toolbox(tb).Input.NrSegments+1
    txt=['Vertex         ' num2str(handles.Toolbox(tb).Input.FaultX(i)) ' ' num2str(handles.Toolbox(tb).Input.FaultY(i))];
    fprintf(fid,'%s \n',txt);
end

fclose(fid);
