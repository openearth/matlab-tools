function s=ddb_readDelft3D_keyWordFile(fname)
% Reads Delft3D keyword file into structure

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
        v=deblank2(v);
        val = strread(v,'%s','delimiter',' ');
        if strcmpi(val{1}(1),'#')
            val = strread(v,'%s','delimiter','#');
            val=val{2};
        else
            val=val{1};
        end
        if ~isnan(str2double(val))
            val=str2double(val);
        end
        s.(fld)(ifld).(keyword)=val;
    end
end
fclose(fid);
