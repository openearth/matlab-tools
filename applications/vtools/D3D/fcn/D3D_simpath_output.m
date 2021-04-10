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

function file=D3D_simpath_output(path_results)

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
                switch ext
                    case '.shp'
                        tok=regexp(dire_res2(kf).name,'_','split');
                        str_name=strrep(tok{1,end},'.shp','');
                        file.shp.(str_name)=fullfile(dire_res2(kf).folder,dire_res2(kf).name);
                end
            end %if no dir 2
        end %kflr2
    end %if no dir
end %kflr

file.partitions=partitions;

end %function