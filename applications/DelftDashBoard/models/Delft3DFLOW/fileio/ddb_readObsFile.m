function handles=ddb_readObsFile(handles)

m=[];
n=[];
name=[];

[name,m,n] = textread(handles.Model(md).Input(ad).ObsFile,'%21c%f%f');


% Check for duplicates
Names{1}='';

nobs=length(m);

% for k=1:length(m)
%     Names{k}=deblank(name(k,:));
% end
nobs=0;
for i=1:length(m)
    if m(i)>0
        if isempty(strmatch(deblank(name(i,:)),Names,'exact'))
            nobs=nobs+1;
            handles.Model(md).Input(ad).ObservationPoints(nobs).Name=deblank(name(i,:));
            handles.Model(md).Input(ad).ObservationPoints(nobs).M=m(i);
            handles.Model(md).Input(ad).ObservationPoints(nobs).N=n(i);
            handles.Model(md).Input(ad).ObservationPoints(i).x=handles.Model(md).Input(ad).GridXZ(m(i),n(i));
            handles.Model(md).Input(ad).ObservationPoints(i).y=handles.Model(md).Input(ad).GridYZ(m(i),n(i));
            Names{nobs}=deblank(name(i,:));
        end
    end
end

% for i=1:length(m)
%     handles.Model(md).Input(ad).ObservationPoints(i).Name=deblank(name(i,:));
%     handles.Model(md).Input(ad).ObservationPoints(i).M=m(i);
%     handles.Model(md).Input(ad).ObservationPoints(i).N=n(i);
%     handles.Model(md).Input(ad).ObservationPoints(i).x=handles.Model(md).Input(ad).GridXZ(m(i),n(i));
%     handles.Model(md).Input(ad).ObservationPoints(i).y=handles.Model(md).Input(ad).GridYZ(m(i),n(i));
% end

handles.Model(md).Input(ad).NrObservationPoints=nobs;
