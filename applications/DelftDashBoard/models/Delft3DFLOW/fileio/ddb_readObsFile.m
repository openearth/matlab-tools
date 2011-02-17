function handles=ddb_readObsFile(handles)

m=[];
n=[];
name=[];

[name,m,n] = textread(handles.Model(md).Input(ad).obsFile,'%21c%f%f');


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
            handles.Model(md).Input(ad).observationPoints(nobs).name=deblank(name(i,:));
            handles.Model(md).Input(ad).observationPoints(nobs).M=m(i);
            handles.Model(md).Input(ad).observationPoints(nobs).N=n(i);
            handles.Model(md).Input(ad).observationPoints(i).x=handles.Model(md).Input(ad).gridXZ(m(i),n(i));
            handles.Model(md).Input(ad).observationPoints(i).y=handles.Model(md).Input(ad).gridYZ(m(i),n(i));
            Names{nobs}=deblank(name(i,:));
        end
    end
end

% for i=1:length(m)
%     handles.Model(md).Input(ad).observationPoints(i).Name=deblank(name(i,:));
%     handles.Model(md).Input(ad).observationPoints(i).M=m(i);
%     handles.Model(md).Input(ad).observationPoints(i).N=n(i);
%     handles.Model(md).Input(ad).observationPoints(i).x=handles.Model(md).Input(ad).GridXZ(m(i),n(i));
%     handles.Model(md).Input(ad).observationPoints(i).y=handles.Model(md).Input(ad).GridYZ(m(i),n(i));
% end

handles.Model(md).Input(ad).nrObservationPoints=nobs;
