function ddb_NestingToolbox_nestHD1(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('nestingpanel.nesthd1');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'nesthd1'}
            nestHD1;
    end    
end

%%
function nestHD1

handles=getHandles;

fid=fopen('nesthd1.inp','wt');
fprintf(fid,'%s\n',handles.Model(md).Input(ad).grdFile);
fprintf(fid,'%s\n',handles.Model(md).Input(ad).encFile);
fprintf(fid,'%s\n',handles.Toolbox(tb).Input.grdFile);
fprintf(fid,'%s\n',handles.Toolbox(tb).Input.encFile);
fprintf(fid,'%s\n',handles.Toolbox(tb).Input.bndFile);
fprintf(fid,'%s\n',handles.Toolbox(tb).Input.admFile);
fprintf(fid,'%s\n','ddtemp.obs');
fclose(fid);

system([handles.Toolbox(tb).miscDir 'nesthd1 < nesthd1.inp']);

[name,m,n] = textread('ddtemp.obs','%21c%f%f');

nr=handles.Model(md).Input(ad).nrObservationPoints;
k=0;
for i=1:length(m)
    nm=deblank(name(i,:));
    ii=strmatch(nm,handles.Model(md).Input(ad).observationPointNames,'exact');
    if isempty(ii)
        k=k+1;
        handles.Model(md).Input(ad).observationPoints(k).name=nm;
        handles.Model(md).Input(ad).observationPoints(k).M=m(i);
        handles.Model(md).Input(ad).observationPoints(k).N=n(i);
        handles.Model(md).Input(ad).observationPoints(k).x=handles.Model(md).Input(ad).gridXZ(m(i),n(i));
        handles.Model(md).Input(ad).observationPoints(k).y=handles.Model(md).Input(ad).gridYZ(m(i),n(i));
        handles.Model(md).Input(ad).observationPointNames{k}=handles.Model(md).Input(ad).observationPoints(k).name;
    end
end
delete('nesthd1.inp');
try
    delete('ddtemp.obs');
end
handles.Model(md).Input(ad).nrObservationPoints=length(handles.Model(md).Input(ad).observationPoints);

handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints','domain',ad,'visible',1,'active',0);

setHandles(handles);
