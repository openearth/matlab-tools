clear variables;close all;

fname='ddb_editD3DFlowBathymetry.m';

fid=fopen(fname,'r');
i=0;
while 1
    str=fgetl(fid);
    if ischar(str)
%         if ~isempty(str)
%             deb=deblank(str);
%             if ~strcmpi(deb(1),'%')
                i=i+1;
                s{i}=str;
%             end
    else
        break
    end
end
nlines=i;

%% find uicontrols
nuic=0;
for i=1:nlines
    str=s{i};
    if ~isempty(str)
        deb=deblank(str);
        if ~strcmpi(deb(1),'%')
            ic=strfind(str,'uicontrol');
            if ~isempty(ic)
                nuic=nuic+1;

                str1=(str(1:ic-1));
                str2=(str(ic:end));

                ib1=strfind(str2,'(')+1;
                ib1=ib1(1);
                ib2=strfind(str2,')')-1;
                ib2=ib2(end);
                
                parstr=str2(ib1:ib2);
                par = strread(parstr,'%s','delimiter',',');
                
                for j=1:length(par)
                    if strcmpi(par{j}(1),'''')
                        par{j}=par{j}(2:end);
                    end
                    if strcmpi(par{j}(end),'''')
                        par{j}=par{j}(1:end-1);
                    end
                end
                
                % Style
                ip=strmatch('style',lower(par),'exact');
                val=lower(par{ip+1})
                uic(nuic).style=val;
                
                % Position
                ip=strmatch('position',lower(par),'exact');
                val=lower(par{ip+1}(2:end-1))
                uic(nuic).position=str2num(val);
                
            end
        end
    end
    
end
