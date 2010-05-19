function txt=ReadTextFile(FileName)
 
fid=fopen(FileName);
 
k=0;
for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
    else
        v0='';
    end
    if size(v0,1)>0
        if strcmp(tx0(1),'#')==0
            v=strread(tx0,'%q');
            nowords=size(v,1);
            for j=1:nowords
                k=k+1;
                txt{k}=v{j};
            end
            clear v;
        end
    end
end
 
fclose(fid);
