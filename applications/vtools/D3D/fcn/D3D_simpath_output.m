%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Gets as output the path to each file type
%
%INPUT
%   -path_results = path to the folder containg the output
%
%TODO:
%   -change to dirwalk

function [file,err]=D3D_simpath_output(path_results,runid)

err=0;
partitions=0;
dire_res=dir(path_results);
nfr=numel(dire_res)-2;
for kflr=1:nfr
    kf=kflr+2; %. and ..
    if dire_res(kf).isdir==0 %it is not a directory
    [~,~,ext]=fileparts(dire_res(kf).name); %file extension
    switch ext
        case '.nc'
            if strcmp(dire_res(kf).name(end-5:end-3),'map')
                if ~contains(dire_res(kf).name,'merge')
                    file.map=fullfile(dire_res(kf).folder,dire_res(kf).name);
                    partitions=partitions+1;
                    
                    %check we are not missing
                    num_part=file.map;
                    num_part=strrep(num_part,path_results,'');
                    num_part=strrep(num_part,runid,'');
                    num_part=strrep(num_part,'_map.nc','');
                    num_part=strrep(num_part,filesep,'');
                    num_part=str2double(num_part);
%                     num_part=str2double(file.map(end-10:end-10+3));
                    if ~isnan(num_part) && num_part~=partitions-1
                        err=1;
                    end
                end
            end
            if strcmp(dire_res(kf).name(end-5:end-3),'his')
                file.his=fullfile(dire_res(kf).folder,dire_res(kf).name);
            end
        case '.dia'
            file.dia=fullfile(dire_res(kf).folder,dire_res(kf).name);
%                 case '.shp'
%                     tok=regexp(dire_res(kf).name,'_','split');
%                     file.shp.(tok{1,1}{end})=fullfile(dire_res(kf).folder,dire_res(kf).name);
    end
    else %directory in results directory
        dire_res2=dir(fullfile(dire_res(kf).folder,dire_res(kf).name));
        nfr2=numel(dire_res2)-2;
        for kflr2=1:nfr2
            kf=kflr2+2; %. and ..
            if dire_res2(kf).isdir==0 %it is not a directory
                [~,~,ext]=fileparts(dire_res2(kf).name); %file extension
                ext_nodot=ext(2:end);
                switch ext 
                    case '.shp' %specify the ones to save
                        tok=regexp(dire_res2(kf).name,'_','split');
                        str_name=strrep(tok{1,end},ext,'');
                        fname=fullfile(dire_res2(kf).folder,dire_res2(kf).name);
                        if ~isfield(file,ext_nodot) || ~isfield(file.(ext_nodot),str_name)
                            file.(ext_nodot).(str_name)={fname};
                        else
                            file.(ext_nodot).(str_name)=cat(1,file.(ext_nodot).(str_name),fname);
                        end
                end %ext
            end %if no dir 2
        end %kflr2
    end %if no dir
end %kflr

if err==1
    messageOut(NaN,sprintf('Missing map files here: %s',path_results));    
end

file.partitions=partitions;

end %function