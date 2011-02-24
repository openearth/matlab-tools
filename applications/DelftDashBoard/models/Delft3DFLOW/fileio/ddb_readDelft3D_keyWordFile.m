function s=ddb_readDelft3D_keyWordFile(fname)
s=[];
fid=fopen(fname,'r');
while 1
    str=fgetl(fid);
    if str==-1
        break
    end
    str=deblank(str);
    if str(1)=='[' && str(end)==']';
        % New field
        fld=lower(str(2:end-1));
        if isfield(s,fld)
            % Field already exist
            ifld=ifld+1;
        else
            ifld=1;
        end
    else
        isf=find(str=='=');
        keyword=str(1:isf-1);
        keyword=strrep(keyword,' ','');
        keyword=lower(keyword);
        v=str(isf+1:end);
        val = strread(v,'%s','delimiter',' ');
        val=val{1};
        val=strrep(val,'#','');
        if ~isnan(str2double(val))
            val=str2double(val);
        end
        s.(fld)(ifld).(keyword)=val;
        
%    [a,b] = strread(str,'%s%s','delimiter','=')
    end
end
