function MDF=ddb_readMDFText(filename)

MDF=ddb_initializeMDF;

fid=fopen(filename);

k=0;
n=1;
for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%s','delimiter','=');
        % nn=length(v0);
        % concatenate strings containing =
        % still to be implemented
        switch lower(v0{1}),
            case{'comment','commnt'}
            otherwise
                if ~isnan(str2double(v0{1})) && length(v0)==1
                    n=n+1;
                    val=MDF.(ActiveField);
                    val(n)=str2double(v0{1});
                    MDF.(ActiveField)=val;
                elseif isnan(str2double(v0{1})) && length(v0)==1
                    % Description
                    n=n+1;
                    if n==2
                        vl=MDF.(ActiveField);
                        val=[];
                        val{1}=vl;
                        MDF.(ActiveField)=val;
                        val=[];
                    end
                    val=MDF.(ActiveField);
                    strtmp=strread(v0{1},'%s','delimiter','#','whitespace','');
                    val{n}=strtmp{2};
                    MDF.(ActiveField)=val;
                else
                    n=1;
                    if length(v0)==2
                        ActiveField=deblank(v0{1});
                        if ~isnan(str2double(v0{2}))
                            MDF.(ActiveField)=str2double(v0{2});
                        else
                            strtmp=strread(v0{2},'%s','delimiter','#','whitespace','');
                            if length(strtmp)>1
                                MDF.(ActiveField)=strtmp{2};
                            end
                        end
%                        ActiveField=deblank(v0{1});
                    end
                end
        end
    else
        v0='';
    end
end

fclose(fid);
