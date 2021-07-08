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
%   -read mdf file structured as when unstructured

function simdef=D3D_simpath(simdef)


%% file paths of the files to analyze

dire=dir(simdef.D3D.dire_sim);
nf=numel(dire)-2;

%% identify D3D-4 or FM or sobek3
whatis=false(1,3);
for kf1=1:nf
    kf=kf1+2; %. and ..
    [~,~,ext]=fileparts(dire(kf).name);
    switch ext
        case '.mdf'
            simdef.D3D.structure=1;
            whatis(1)=true;
        case '.mdu'
            simdef.D3D.structure=2;
            whatis(2)=true;
        case '.md1d'
            simdef.D3D.structure=3;
            whatis(3)=true;
    end
end

simdef.err=0;
if sum(whatis)==0
%     error('I cannot find the main file in this folder: %s',simdef.D3D.dire_sim)
    fprintf('I cannot find the main file in this folder: %s \n',simdef.D3D.dire_sim);
    simdef.err=1;
    return
elseif sum(whatis)>1
    fprintf('In this folder there are main files of several software systems: %s \n',simdef.D3D.dire_sim);
    simdef.err=2;
    return
end

%% load
switch simdef.D3D.structure
%     case 1
% 
%         %% structured
%         
% %         D3D_io_input('read',
% for kf1=1:nf
%     kf=kf1+2; %. and ..
%     if dire(kf).isdir==0 %it is not a directory
%     [~,~,ext]=fileparts(dire(kf).name); %file extension
%     switch ext
%         case '.mdf'
%             file.mdf=fullfile(dire(kf).folder,dire(kf).name);
%         case '.sed'
%             file.sed=fullfile(dire(kf).folder,dire(kf).name);
%         case '.mor'
%             file.mor=fullfile(dire(kf).folder,dire(kf).name);
%         case '.tra'
%             file.tra=fullfile(dire(kf).folder,dire(kf).name);
%         case '.wr'
%             file.wr=fullfile(dire(kf).folder,dire(kf).name);
%         case '.grd'
%             file.grd=fullfile(dire(kf).folder,dire(kf).name);
%         case '.dat'
%             if strcmp(dire(kf).name(1:4),'trim')
%                 file.map=fullfile(dire(kf).folder,dire(kf).name);
%             end
%             if strcmp(dire(kf).name(1:4),'trih')
%                 file.his=fullfile(dire(kf).folder,dire(kf).name);
%             end
%         case []
%             file.runid=fullfile(dire(kf).folder,dire(kf).name);
%     end
%     end %isdir
% end    
    %% unstructured
    case {1,2}

kmdf=1;
for kf1=1:nf
    kf=kf1+2; %. and ..
    if dire(kf).isdir==0 %it is not a directory
        [~,~,ext]=fileparts(dire(kf).name); %file extension
        switch ext
            case {'.mdu','.mdf'}
                mdf_aux{kmdf}=fullfile(dire(kf).folder,dire(kf).name);
                kmdf=kmdf+1;
        end
    end %isdir
end

if exist('mdf_aux','var')~=1
    error('This folder has no mdu or mdf file file.')
end
nstring=cellfun(@(X)numel(X),mdf_aux);
[~,idx]=min(nstring);
file.mdf=mdf_aux{idx};
switch simdef.D3D.structure
    case 1
        simdef_aux=D3D_simpath_mdf(file.mdf);
    case 2
        simdef_aux=D3D_simpath_mdu(file.mdf);
end
file=simdef_aux.file;

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
    simdef.file=file;
else
    fprintf('simulation folder: \n %s \n',simdef.D3D.dire_sim);
    error('It seems that the folder you have specified has no simulation results')
end
