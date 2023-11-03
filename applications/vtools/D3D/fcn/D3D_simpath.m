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
%   -simdef = path to the folder containg the simulation files
%
%OUTPUT
%   -simdef.D3D.structure
%       1: D3D4
%       2: FM
%       3: S3
%       4: SMT (FM)
%
%TODO:
%   -change to dirwalk
%   -read mdf file structured as when unstructured

function simdef=D3D_simpath(simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'break',1);

parse(parin,varargin{:})

do_break=parin.Results.break;

%% MAKE DIR

if isstruct(simdef)==0
    simdef_struct.D3D.dire_sim=simdef;
    simdef=D3D_simpath(simdef_struct,varargin{:});
    return
end

%%

simdef.err=0; %error flag

%% file paths of the files to analyze

if numel(simdef.D3D.dire_sim)==0
    fprintf('The simulation dir variable is empty: %s \n',simdef.D3D.dire_sim);
    simdef.err=1;
    throw_error(do_break,simdef.err)
    return
elseif isfolder(simdef.D3D.dire_sim)==0
    fprintf('There is no folder here: %s \n',simdef.D3D.dire_sim);
    simdef.err=1;
    throw_error(do_break,simdef.err)
    return
end
if strcmp(simdef.D3D.dire_sim(end),filesep)
    simdef.D3D.dire_sim(end)='';
end

dire=dir(simdef.D3D.dire_sim);
nf=numel(dire)-2;

%% identify 
whatis=false(1,5);
for kf1=1:nf
    kf=kf1+2; %. and ..
    [simdef,whatis]=structure_from_ext(simdef,dire(kf).name,whatis);
end

if sum(whatis)==0
    %try to see if it is a dimr folder and it has an mdu below
    [fpath_mdu,err]=search_4_mdu(dire);
    if err
        fprintf('I cannot find the main file in this folder: %s \n',simdef.D3D.dire_sim);
        simdef.err=1;
        throw_error(do_break,simdef.err)
        return
    else
%         fdir=fileparts(fpath_mdu);
        simdef=structure_from_ext(simdef,fpath_mdu,false(1,4));
    end
elseif sum(whatis)>1
    fprintf('In this folder there are main files of several software systems: %s \n',simdef.D3D.dire_sim);
    simdef.err=2;
    throw_error(do_break,simdef.err)
    return
end

%% load
switch simdef.D3D.structure
    %% D3D4 and FM
    case {1,2,4,5}

if simdef.D3D.structure==4 %we take the files from the first one for generic things
    fdir_mdu=fullfile(simdef.D3D.dire_sim,'output','0');
    dire=dir(fdir_mdu);
elseif simdef.D3D.structure==5 %we take the files from the first one for generic things
    fdir_output=fullfile(simdef.D3D.dire_sim,'output');
    tim_dir=D3D_SMTD3D4_sort_output(fdir_output);
    
    fdir_mdu=fullfile(fdir_output,sprintf('%d.min',tim_dir(1)));
else
    fdir_mdu=simdef.D3D.dire_sim;
end

if simdef.D3D.structure==5 %we take the files from the first one for generic things
    fpath_mdu=D3D_SMTD3D4_get_all_mdf(fdir_mdu);
else
    fpath_mdu=search_4_mdu(dire);
end

file.mdf=fpath_mdu;
switch simdef.D3D.structure
    case 1
        simdef_aux=D3D_simpath_mdf(file.mdf);
    case {2,4}
        simdef_aux=D3D_simpath_mdu(file.mdf);
        if simdef.D3D.structure==4 
            simdef_aux.file=adapt_paths_smt(simdef_aux.file); %the relative paths are relative to the layout mdu
        end
    case 5
        %get paths for each mdf
        ndd=numel(fpath_mdu);
        simdef_aux=D3D_simpath_mdf(fpath_mdu{1});
        runids=simdef_aux.D3D.runid; %we store it here to fill it automatically below
        fn=fieldnames(simdef_aux.file);
        nfn=numel(fn);
        for kdd=2:ndd
            simdef_aux_loc=D3D_simpath_mdf(fpath_mdu{kdd});
            for kfn=1:nfn
                %it will not work if not all fields are in all files. 
                simdef_aux.file.(fn{kfn})=cat(1,simdef_aux.file.(fn{kfn}),{simdef_aux_loc.file.(fn{kfn})});
            end
            runids=cat(1,runids,{simdef_aux_loc.D3D.runid});
        end
        simdef_aux.file.runids=runids;
        simdef_aux.file.partitions=ndd;
        simdef_aux.file.output_time=tim_dir;
end
    %% sobek 3
    case 3
        simdef_aux=D3D_simpath_md1d(fpath_mdu);        
end %simdef.D3D.structure

file=simdef_aux.file;
simdef.err=simdef_aux.err;
if simdef.D3D.structure~=5
    [~,file.runid,~]=fileparts(file.mdf);
end
file.mdfid=file.runid; %runid may be rewriten in `D3D_gdm`

%I don't think this is necessary. For FM and D3D4 there is always <file>
%and for S3 I think so too because we have already checked that 
%there is an md1d-file
% if exist('file','var')>0
    simdef.file=file;
% else
%     fprintf('It seems that the folder you have specified has no simulation results: \n %s \n',simdef.D3D.dire_sim);
% end

%% type of simulation

if isfield(simdef.file,'map')
    [ismor,is1d,str_network1d,issus]=D3D_is(simdef.file.map);
else
    ismor=NaN;
    is1d=NaN;
    str_network1d='';
    issus=NaN;
end

simdef.D3D.ismor=ismor;
simdef.D3D.is1d=is1d;
simdef.D3D.str_network1d=str_network1d;
simdef.D3D.issus=issus;

%%

throw_error(do_break,simdef.err)

end %function

%%
%% FUNCTION
%%

function throw_error(do_break,err)

if do_break && err>0
    error('See messages above')
end

end %function

%%

function [fpath_mdu,err]=search_4_mdu(dire)

err=0;

nf=numel(dire);
kmdf=1;
mdf_aux={};
for kf=1:nf
    if strcmp(dire(kf).name,'.') || strcmp(dire(kf).name,'..'); continue; end
    fpath_loc=fullfile(dire(kf).folder,dire(kf).name);
    if dire(kf).isdir==0 %it is not a directory
        
        [~,~,ext]=fileparts(dire(kf).name); %file extension
        switch ext
            case {'.mdu','.mdf','.md1d'}
                mdf_aux{kmdf}=fpath_loc;
                kmdf=kmdf+1;
        end
    else %directory
%         fprintf('searching here %s \n',fpath_loc);
        if strcmp(fileparts(dire(kf).name),'figures'); continue; end
        dire_2=dir(fpath_loc);
        mdf_aux_out=search_4_mdu(dire_2);
        if ~isempty(mdf_aux) && ~isempty(mdf_aux_out)
            error('There are several mdu/mdf files in the main and subfolders');
        elseif ~isempty(mdf_aux_out)
            mdf_aux=mdf_aux_out;
        end
    end %isdir
end

if isempty(mdf_aux)
    err=1;
    fpath_mdu='';
elseif ischar(mdf_aux)
    fpath_mdu=mdf_aux;
else
    nstring=cellfun(@(X)numel(X),mdf_aux);
    [~,idx]=min(nstring);
    fpath_mdu=mdf_aux{idx};    
end


end %function

%%

function [simdef,whatis]=structure_from_ext(simdef,fpath_file,whatis)

[~,fname,ext]=fileparts(fpath_file);
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
    case '.yml'
        if strcmp(fname,'smt') %could it be another yml? too strong?
            simdef.D3D.structure=4;
            whatis(4)=true;
        else
            fprintf('Warning! There is a yml-file but not called smt: %s',fpath_file)
        end
    case ''
        if strcmp(fname,'Qseries') 
            simdef.D3D.structure=5;
            whatis(5)=true;
        end
end

end %function

%%

function simdef_aux_file=adapt_paths_smt(simdef_aux_file)

fn=fieldnames(simdef_aux_file);
nfn=numel(fn);
for kfn=1:nfn
    fi=simdef_aux_file.(fn{kfn});
    if ischar(fi)
        simdef_aux_file.(fn{kfn})=adapt_paths_smt_char(fi);
    elseif iscell(fi)
        nc=numel(fi);
        for kc=1:nc
            fi2=fi{kc};
            simdef_aux_file.(fn{kfn}){kc}=adapt_paths_smt_char(fi2);
        end
    end
end

end %function

%%

function fi=adapt_paths_smt_char(fi)

if ~(exist(fi,'file')==2) && ~isfolder(fi)
    idx = strfind(fi,[filesep,'..']);
    fi=[fi(1:idx-1),[filesep,'..'],fi(idx:end)];
    if exist(fi,'file')==2 || isfolder(fi)
        disp('Old style smt.yml simulation found')
    else
        error('File (%s) not found: ',fi)
    end
end

end

%%

function fpath_mdu=D3D_SMTD3D4_get_all_mdf(fdir_mdu)
    
%get all mdf's
dire=dir(fdir_mdu);
nf=numel(dire);
fpath_mdu={};
for kf=1:nf
    if dire(kf).isdir; continue; end
    [~,~,ext]=fileparts(dire(kf).name);
    if ~strcmp(ext,'.mdf'); continue; end
    fpath_mdu=cat(1,fpath_mdu,fullfile(dire(kf).folder,dire(kf).name));
end

end