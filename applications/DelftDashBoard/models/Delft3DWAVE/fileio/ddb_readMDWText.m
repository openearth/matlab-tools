function MDW=ddb_readMDWText(filename)

MDW=ddb_initializeMDW;

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
        v1 = num2str(cell2mat(v0(1)));
        if strcmp(v1(1),'[')~=1
        switch lower(v0{1}),
            case{'comment','commnt'}
            otherwise
                if ~isempty(str2num(v0{1})) && length(v0)==1
                    n=n+1;
                    val=getfield(MDW,ActiveField);
                    val(n)=str2num(v0{1});
                    MDW=setfield(MDW,ActiveField,val);
                elseif isempty(str2num(v0{1})) && length(v0)==1
                    % Description
                    n=n+1;
                    if n==2
                        vl=getfield(MDW,ActiveField);
                        val=[];
                        val{1}=vl;
                        MDW=setfield(MDW,ActiveField,val);
                        val=[];
                    end
                    val=getfield(MDW,ActiveField);
                    strtmp=strread(v0{1},'%s','delimiter','#','whitespace','');
                    val{n}=strtmp{2};
                    MDW=setfield(MDW,ActiveField,val);
                else
                    n=1;
                    if length(v0)==2
                        if ~isempty(str2num(v0{2}))
                            MDW=setfield(MDW,v0{1},str2num(v0{2}));
                        else
                            strtmp=strread(v0{2},'%s','delimiter','#','whitespace','');
                            %                            MDW=setfield(MDW,v0{1},v0{2}());
                            if length(strtmp)>1
                                MDW=setfield(MDW,v0{1},strtmp{2});
                            end
                        end
                        ActiveField=v0{1};
                    end
                end
        end
        end
    else
        v0=''
    end
end

fclose(fid);
