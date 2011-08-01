function struct2xml(filename,s)
% Writes Matlab structure s to xml file
%
% e.g.
%
% s.name.value='csm';
% s.name.type='char';
% s.size.value=4;
% s.size.type='int';
% s.stations(1).station.name.value='hallo!';
% s.stations(1).station.name.type='char';
% s.stations(1).station.lon.value=58;
% s.stations(1).station.lon.type='real';
% s.stations(2).station.name.value='haha';
% s.stations(2).station.name.type='char';
% s.stations(2).station.lon.value=53;
% s.stations(2).station.lon.type='real';
% struct2xml('test.xml',s);

nindent=1;

fid=fopen(filename,'wt');
fprintf(fid,'%s\n','<?xml version="1.0"?>');
fprintf(fid,'%s\n','<root>');
splitstruct(fid,s,1,nindent);
fprintf(fid,'%s\n','</root>');
fclose(fid);

%%
function splitstruct(fid,s,ilev,nindent)
try
fnames=fieldnames(s);
catch
    shite=1
end
for k=1:length(fnames)
    if isfield(s.(fnames{k}),'value')
        write2xml(fid,s,fnames{k},ilev,nindent)
    else
        fprintf(fid,'%s\n',[repmat(' ',1,ilev*nindent) '<' fnames{k} '>']);
        ilev=ilev+1;
        for j=1:length(s.(fnames{k}))
            splitstruct(fid,s.(fnames{k})(j),ilev,nindent);
        end
        ilev=ilev-1;
        fprintf(fid,'%s\n',[repmat(' ',1,ilev*nindent) '</' fnames{k} '>']);
    end
end

%%
function write2xml(fid,s,fldname,ilev,nindent)
v=s.(fldname).value;
fldnames=fieldnames(s.(fldname));
attstr='';
for j=1:length(fldnames)
    if ~strcmpi(fldnames{j},'value')
        attstr=[attstr ' ' fldnames{j} '="' s.(fldname).(fldnames{j}) '"'];        
    end
end
tp=s.(fldname).type;
str1=[repmat(' ',1,ilev*nindent) '<' fldname attstr '>'];
switch lower(tp)
    case{'char'}
        str2=v;
    case{'int'}
        str2=num2str(v);
    case{'real'}
        str2=num2str(v);
    case{'date'}
        str2=datestr(v,'yyyymmdd HHMMSS');
end
str3=['</' fldname '>'];
fprintf(fid,'%s%s%s\n',str1,str2,str3);
