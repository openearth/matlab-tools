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
                    % Vertical layers
                    n=n+1;
                    val=MDF.(activeField);
                    val(n)=str2double(v0{1});
                    MDF.(activeField)=val;
                elseif isnan(str2double(v0{1})) && length(v0)==1
                    % Description, tidal forces
                    n=n+1;
                    if n==2
                        vl=MDF.(activeField);
                        val=[];
                        val{1}=vl;
                        MDF.(activeField)=val;
                        val=[];
                    end
                    val=MDF.(activeField);
                    strtmp=strread(v0{1},'%s','delimiter','#','whitespace','');
                    val{n}=strtmp{2};
                    MDF.(activeField)=val;
                else
                    n=1;
                    if length(v0)==2
                        activeField=lower(deblank(v0{1}));
                        if ~isnan(str2double(v0{2}))
                            MDF.(activeField)=str2double(v0{2});
                        elseif ~isnan(str2num(v0{2}))
                            MDF.(activeField)=str2num(v0{2});
                        else
                            strtmp=strread(v0{2},'%s','delimiter','#','whitespace','');
                            if length(strtmp)>1
                                MDF.(activeField)=strtmp{2};
                            end
                        end
%                        activeField=deblank(v0{1});
                    end
                end
        end
    else
        v0='';
    end
end

fclose(fid);
