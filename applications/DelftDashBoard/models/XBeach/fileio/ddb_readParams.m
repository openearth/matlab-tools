function handles=ddb_readParams(handles,filename,id)

fid=fopen(filename);

Par=[];

for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%s','delimiter','=');
        if length(v0)>1
            if length(v0)==2
                if ~isempty(str2num(v0{2}))
                    Par=setfield(Par,v0{1},str2num(v0{2}));
                else
                    Par=setfield(Par,v0{1},v0{2});
                end
                ActiveField=v0{1};
            end
        end
    else
        v0='';
    end
end

fclose(fid);

names=fieldnames(Par);
for i=1:length(names)
    p=getfield(Par,names{i});
    handles.Model(handles.ActiveModel.Nr).Input(id)=setfield(handles.Model(handles.ActiveModel.Nr).Input(id),names{i},p);
end
handles.Model(handles.ActiveModel.Nr).Input(handles.ActiveDomain).ParamsFile=filename;
Par;
% mmax=handles.Model(handles.ActiveModel.Nr).Input(id).mmax;
% bbb=handles.Model(handles.ActiveModel.Nr).Input(id)

