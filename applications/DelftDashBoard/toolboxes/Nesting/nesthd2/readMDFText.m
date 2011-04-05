function MDF=readMDFText(filename)

fid=fopen(filename);

MDF=[];

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
                if ~isempty(str2num(v0{1})) && length(v0)==1
                    n=n+1;
                    val=getfield(MDF,ActiveField);
                    val(n)=str2num(v0{1});
                    MDF=setfield(MDF,ActiveField,val);
                elseif isempty(str2num(v0{1})) && length(v0)==1
                    % Description
                    n=n+1;
                    if n==2
                        vl=getfield(MDF,ActiveField);
                        val=[];
                        val{1}=vl;
                        MDF=setfield(MDF,ActiveField,val);
                        val=[];
                    end
                    val=getfield(MDF,ActiveField);
                    strtmp=strread(v0{1},'%s','delimiter','#','whitespace','');
                    val{n}=strtmp{2};
                    MDF=setfield(MDF,ActiveField,val);
                else
                    n=1;
                    if length(v0)==2
                        if ~isempty(str2num(v0{2}))
                            MDF=setfield(MDF,v0{1},str2num(v0{2}));
                        else
                            strtmp=strread(v0{2},'%s','delimiter','#','whitespace','');
                            %                            MDF=setfield(MDF,v0{1},v0{2}());
                            if length(strtmp)>1
                                MDF=setfield(MDF,v0{1},strtmp{2});
                            end
                        end
                        ActiveField=v0{1};
                    end
                end
        end
    else
        v0='';
    end
end

fclose(fid);
