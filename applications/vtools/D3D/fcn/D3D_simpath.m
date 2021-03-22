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
%   -simdef.D3D.dire_sim = path to the folder containg the simulation files
%
%TODO:
%   -change to dirwalk

function simdef=D3D_simpath(simdef)


%% file paths of the files to analyze

dire=dir(simdef.D3D.dire_sim);
nf=numel(dire)-2;

%% identify D3D-4 or FM or sobek3

for kf1=1:nf
    kf=kf1+2; %. and ..
    [~,~,ext]=fileparts(dire(kf).name);
    switch ext
        case '.mdf'
            simdef.D3D.structure=1;
        case '.mdu'
            simdef.D3D.structure=2;
        case '.md1d'
            simdef.D3D.structure=3;
    end
end

if isfield(simdef.D3D,'structure')==0
    warning('I cannot find the main file in this folder, I do not know which kinf of simulation this is.')
    simdef.D3D.structure=2; %default is FM
end

%% load
switch simdef.D3D.structure
    case 1

        %% structured
for kf1=1:nf
    kf=kf1+2; %. and ..
    if dire(kf).isdir==0 %it is not a directory
    [~,~,ext]=fileparts(dire(kf).name); %file extension
    switch ext
        case '.mdf'
            file.mdf=fullfile(dire(kf).folder,dire(kf).name);
        case '.sed'
            file.sed=fullfile(dire(kf).folder,dire(kf).name);
        case '.mor'
            file.mor=fullfile(dire(kf).folder,dire(kf).name);
        case '.tra'
            file.tra=fullfile(dire(kf).folder,dire(kf).name);
        case '.wr'
            file.wr=fullfile(dire(kf).folder,dire(kf).name);
        case '.grd'
            file.grd=fullfile(dire(kf).folder,dire(kf).name);
        case '.dat'
            if strcmp(dire(kf).name(1:4),'trim')
                file.map=fullfile(dire(kf).folder,dire(kf).name);
            end
            if strcmp(dire(kf).name(1:4),'trih')
                file.his=fullfile(dire(kf).folder,dire(kf).name);
            end
        case []
            file.runid=fullfile(dire(kf).folder,dire(kf).name);
    end
    end %isdir
end    
    %% unstructure
    case 2

partitions=0;
for kf1=1:nf
    kf=kf1+2; %. and ..
    if dire(kf).isdir==0 %it is not a directory
    [~,~,ext]=fileparts(dire(kf).name); %file extension
    switch ext
        case '.mdu'
            file.mdf=fullfile(dire(kf).folder,dire(kf).name);
        case '.sed'
            file.sed=fullfile(dire(kf).folder,dire(kf).name);
        case '.mor'
            file.mor=fullfile(dire(kf).folder,dire(kf).name);
        case '.nc'
            file.grd=char(fullfile(dire(kf).folder,dire(kf).name));
        case '.pol'
            tok=regexp(dire(kf).name,'_','split');
            str_name=strrep(tok{1,end},'.pol','');
            if strcmp(str_name,'part')
                file.(str_name)=fullfile(dire(kf).folder,dire(kf).name);
            end
    end
    else %it is results directory
        dire_res=dir(fullfile(dire(kf).folder,dire(kf).name));
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
                    end
                end %kflr2
            end
        end
    end %isdir
end

    %% sobek 3
    case 3
        
for kf1=1:nf
    kf=kf1+2; %. and ..
    if dire(kf).isdir==0 %it is not a directory
    [~,fname,ext]=fileparts(dire(kf).name); %file extension
    switch ext
        case '.md1d'
            file.mdf=fullfile(dire(kf).folder,dire(kf).name);
        case '.ini'
            switch fname
                case 'NetworkDefinition'
                    file.NetworkDefinition=fullfile(dire(kf).folder,dire(kf).name);
            end
        case '.bc'
            file.bc=fullfile(dire(kf).folder,dire(kf).name);
    end
    else %it is results directory
        dire_res=dir(fullfile(dire(kf).folder,dire(kf).name));
        nfr=numel(dire_res)-2;
        for kflr=1:nfr
            kf=kflr+2; %. and ..
            if dire_res(kf).isdir==0 %it is not a directory
            [~,fname,ext]=fileparts(dire_res(kf).name); %file extension
            switch ext
                case '.nc'
                    if strcmp(fname,'gridpoints')
                        file.map=fullfile(dire_res(kf).folder,dire_res(kf).name);
                    end
                    if strcmp(fname,'observations')
                        file.his=fullfile(dire_res(kf).folder,dire_res(kf).name);
                    end
                    if strcmp(fname,'reachsegments')
                        file.reach=fullfile(dire_res(kf).folder,dire_res(kf).name);
                    end
            end
            end
        end
    end %isdir
end

end

if exist('file','var')>0
    file.partitions=partitions;
    simdef.file=file;
else
    fprintf('simulation folder: \n %s \n',simdef.D3D.dire_sim)
    error('It seems that the folder you have specified has no simulation results')
end
