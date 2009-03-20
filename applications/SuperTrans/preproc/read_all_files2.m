clear all;close all;
ccpars=[];
a=dir('*.csv');

% a={'area.csv','coordinate_operation.csv','coordinate_operation_parameter_value.csv','coordinate_reference_system.csv','datum.csv', ...
%     'ellipsoid.csv','coordinate_operation_method.csv','coordinate_operation_parameter.csv','coordinate_system.csv', ...
%     'coordinate_axis.csv','coordinate_axis_name.csv','deprecation.csv'};

for i=18:length(a)
%for i=2:2
    fname=a(i).name
    fid=fopen(fname);
    trf=[];
    tx0=fgets(fid);
%     if ~ischar(tx0)
%         break
%     end
    names=strread(tx0,'%q','delimiter',',');
    for jj=1:length(names)
        names{jj}=strrep(names{jj},' ','_');
    end
    k=0;
    for i=1:100000
        i;
        tx0=fgets(fid);
        if ~ischar(tx0)
            break
        end
        v0=strread(tx0,'%q','delimiter',',');
        for ii=1:length(v0)
            trf=setfield(trf,{i},names{ii},v0{ii});
        end
    end
    fclose(fid);
    fld=fieldnames(trf);
    for i=1:length(trf)
        i;
        for j=1:length(fld)
            ns=getfield(trf,{i},fld{j});
            if ~isempty(ns)
                ntmp=str2double(ns);
                if ~isempty(ntmp) & ~isnan(ntmp)
                    trf=setfield(trf,{i},fld{j},ntmp);
                end
            else
                if length(lower(fld{j}))>=4
                    if strcmp(lower(fld{j}(end-3:end)),'code')
                        trf=setfield(trf,{i},fld{j},NaN);
                    end
                end
            end
        end
    end
    
    ff=fname(1:end-4);
    
    save([ff '.mat'],'trf'); 
%    ccpars=setfield(ccpars,ff,trf);
end

%save ccpars3.mat ccpars

