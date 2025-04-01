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
%WRITE:
%   pli:
%       -pli.name: name of the polyline (char) or number of the polyline (double)
%       -pli.xy: coordinates
%
%READ:
%   OPTIONAL INPUT
%       -shp:
%           -'read_val' = true: read values; false (default): only read xy.
%           -'xy_only' = true: only read xy coordinates in matrix form; false (default): only read xy coordinates in cell form.
%       -pli:
%           -'ver' = version. Use 2 in general (default). Use 4 when you want to plot all of them. 
%               - 1 = pli [struct(1,1)]   ; pli.name [cell(1,npol)]; pli.val [cell(1,npol)]
%               - 2 = pli [struct(1,npol)]; pli(kpol).name [char]  ; pli(kpol).xy [double(1,np)]
%               - 3 = pli [double(npol*npp,2]
%
%E.G. Read and write D3D4 grd and dep
% dep=D3D_io_input('read',fdep,fgrd,'location','cen','dummy',false); %typical in morpho. Althought there are dummy values, set to false and will read all values.
% dep=D3D_io_input('read',fdep,fgrd,'location','cor');
% D3D_io_input('write','c:\Users\chavarri\Downloads\trial.dep',dep,'location','cor','dummy',false,'format','%15.13e');
%
%E.G. Interpolating bed level to D3D4 grid:
%
% dep=D3D_io_input('read',fpath_dep);
% grd=D3D_io_input('read',fpath_grd_d3d4,'location','cor');
% 
% F=scatteredInterpolant(dep(:,1),dep(:,2),dep(:,3));
% dep_int=F(grd.cend.x,grd.cend.y);
% 
% grd.cor.dep=-dep_int(1:end-1,1:end-1);
% 
% D3D_io_input('write',fpath_dep_out,grd,'location','cor');
%
%E.G. Delft3D 4 obs and crs files
% obs=D3D_io_input('read',fobs,fgrd);
% crs=D3D_io_input('read',fcrs,fgrd);
%
function varargout=D3D_io_input(what_do,fname,varargin)

%% cell 

if iscell(fname)
    F=@(X)fileparts_ext(X);
    ext_c=cellfun(F,fname,'UniformOutput',false);
    idx_ext=find_str_in_cell(ext_c,ext_c(1));
    nf=numel(fname);
    if numel(idx_ext)~=nf
        error('Not all files in the cell array have the same extension')
    end
    
    kf=1;
    stru_out_all=D3D_io_input(what_do,fname{kf},varargin{:});
    for kf=2:nf
        stru_out_loc=D3D_io_input(what_do,fname{kf},varargin{:});
        if isstruct(stru_out_loc)
%             if numel(stru_out_loc)==1
%                 error('do concatenation of variables')
%             else %concatenation of structures
                stru_out_all=[stru_out_all;stru_out_loc];
%             end
            
        end
        
    end
    varargout{1,1}=stru_out_all;
    return
end

%% char
if ~ischar(fname)
    error('fname should be char')
end
[~,~,ext]=fileparts(fname);

%% globals 
global INIFILE_GENERAL INIFILE_CRSDEF INIFILE_CRSLOC

% inifiletype
INIFILE_GENERAL = 1; 
INIFILE_CRSDEF = 2; 
INIFILE_CRSLOC = 3; 

switch what_do
    %%
    %% READ
    %%
    case 'read'
        if exist(fname,'file')~=2
            error('File does not exist: %s',fname)
        end
        switch deblank(ext)
            case '.mdf'
                stru_out=delft3d_io_mdf('read',fname);
            case {'.mdu','.md1d'}
                stru_out=dflowfm_io_mdu('read',fname);
            case {'.sed','.mor'}
                stru_out=delft3d_io_sed(fname);
            case {'.pli','.pliz','.pol','.ldb'}
                stru_out=D3D_read_polys(fname,varargin{:});
            case '.ini'
                stru_out=delft3d_io_sed(fname);
                inifiletype=parse_ini(stru_out);
                if ~isnan(inifiletype) && inifiletype ~= INIFILE_GENERAL
                    [~,stru_out]=S3_read_crosssectiondefinitions(fname,'file_type',inifiletype);
                end
            case '.grd'
                OPT.nodatavalue=NaN;
                stru_out=delft3d_io_grd('read',fname,OPT);
            case '.dep'
                OPT.nodatavalue=NaN;
                G=delft3d_io_grd('read',varargin{1},OPT);
                stru_out=delft3d_io_dep('read',fname,G,varargin(2:end));
%                 G=wlgrid('read',varargin{1});
%                 stru_out=wldep('read',fname,G);
            case {'.bct','.bc','.bcm'}
                stru_out=bct_io('read',fname);
                for kT=1:stru_out.NTables
                    if strcmp(stru_out.Table(kT).Contents,'timeseries')
                        tim_dtim=read_time_from_table(stru_out.Table(kT));
                        stru_out.Table(kT).Time=tim_dtim;
                    end
                end
            case '.xyz'
%                 stru_out=dflowfm_io_xydata('read',fname); %extremely slow
                stru_out=readmatrix(fname,'FileType','text');
                if size(stru_out,2)>3
                    messageOut(NaN,'The file seems to have a weir delimiter and cannot read it properly. Trying in a different way.')
                    [xyz_all,err]=read_xyz(fname);
                    if err~=1
                        stru_out=xyz_all;
                    end
                end

            case '.xyn'
                stru_out=D3D_read_xyn(fname,varargin{:});
            case '.ext'
                stru_out=delft3d_io_sed(fname); %there are repeated blocks, so we cannot use dflowfm_io_mdu
                if isfield(stru_out,'x')==1 %old external file format
                    stru_out=D3D_read_ext(fname); %there are repeated blocks, so we cannot use dflowfm_io_mdu
                end
            case '.sob'
                a=readcell(fname,'FileType','text');
                aux2=cellfun(@(X)datetime(X,'InputFormat','yyyy/MM/dd;HH:mm:ss'),a(:,1));
                val=cell2mat(a(:,2));
                stru_out.tim=aux2;
                stru_out.val=val;
%                 figure; hold on; plot(aux2,val)
            case '.shp'
                stru_out=shp2struct(fname,varargin{:});
            case '.tim'
                if nargin~=3
                    error('You need to specify the reference date as input')
                end
                tim=readmatrix(fname,'filetype','text');
                stru_out.tim=varargin{1}+minutes(tim(:,1));
                stru_out.val=tim(:,2:end);
            case '.sub'
                %%
                ksub=0;
                kpar=0;
                fid=fopen(fname);
                while ~feof(fid)
                    lin=fgetl(fid);
                    if strcmp(lin(1:3),'sub')
                        ksub=ksub+1;
                        tok=regexp(lin,'''','split');
                        stru_out.substance(ksub).name=tok{1,2};
                    end
                    if strcmp(lin(1:3),'par')
                        kpar=kpar+1;
                        tok=regexp(lin,'''','split');
                        stru_out.parameter(kpar).name=tok{1,2};
                        lin=fgetl(fid);
                        while ~strcmp(lin(1:13),'end-parameter')
                            lin=deblankstart(lin);
                            tok=regexp(lin,'''','split');
                            if numel(tok)>1 %char
                                stru_out.parameter(kpar).(deblank(tok{1,1}))=tok{1,2};
                            else
                                tok=regexp(lin,' ','split');
                                stru_out.parameter(kpar).(deblank(tok{1,1}))=str2double(tok{1,end});
                            end
                            lin=fgetl(fid);
                        end
                    end
                end
                fclose(fid);
            case 'thd'
                stru_out=delft3d_io_thd('read',fname);
            case '.obs'
                G=delft3d_io_grd('read',varargin{1});
                stru_out=D3D_read_obs(fname,G,varargin{2:end});
            case '.crs'
                G=delft3d_io_grd('read',varargin{1},'nodatavalue',NaN);
                stru_out=D3D_read_crs(fname,G,varargin{2:end});
            otherwise
                error('Extension %s in file %s not available for reading',ext,fname)
        end %ext
        varargout{1}=stru_out;
    %%
    %% WRITE
    %%
    case 'write'
        stru_in=varargin{1};
        switch ext
            case {'.mdu','.mor','.sed','.ext','.ini'}
                if strcmp(ext,'.ini')
                    inifiletype=NaN;
                    if isfield(stru_in,'id') %cross-sectional type of structure. It may not be strong enough.
                        if isfield(stru_in,'chainage')
                            inifiletype=INI_CRSLOC;
                        else
                            inifiletype=INIFILE_CRSDEF;
                        end
                    end
                    if ~isnan(inifiletype)
                        [fdir,fname,fext]=fileparts(fname);
                        simdef.D3D.dire_sim=fdir;
                        switch inifiletype
                            case INIFILE_CRSDEF %definition
                                simdef.csd=stru_in;
                                D3D_crosssectiondefinitions(simdef,'fname',sprintf('%s%s',fname,fext),varargin{2:end});
                            case INI_CRSLOC %location
                                simdef.csl=stru_in;
                                D3D_crosssectionlocation(simdef,'fname',sprintf('%s%s',fname,fext),varargin{2:end});
                        end
                    else
                        dflowfm_io_mdu('write',fname,stru_in);
                    end
                else
                    dflowfm_io_mdu('write',fname,stru_in);
                end
            case {'.mdf'}
                delft3d_io_mdf('write',fname,stru_in.keywords);
            case {'.pli','.ldb','.pol','.pliz'}
%                 stru_in(kpol).name: double or string
%                 stru_in(kpol).xy: [np,2] array with x-coordinate (:,1) and y-coordinate (:,2)
                D3D_write_polys(fname,stru_in);
            case '.dep'
                delft3d_io_dep('write',fname,stru_in,varargin(2:end));
            case '.bct'
                stru_in.file.bct=fname;
                D3D_bct(stru_in);
            case '.bc'
% stru_in.name
% stru_in.function
% stru_in.time_interpolation
% stru_in.quantity
% stru_in.unit
% stru_in.val
                if isfield(stru_in,'Check') %read from 
                    stru_in=D3D_table_d3d4_to_FM(stru_in);
                end
                D3D_write_bc(fname,stru_in)
            case '.xyz'
%                 D3D_io_input('write',xyz)
%                 xyz(:,1) = x-coordinate
%                 xyz(:,2) = y-coordinate
%                 xyz(:,3) = z-coordinate
                fid=fopen(fname,'w');
                ndep=size(stru_in,1);
                for kl=1:ndep
                    fprintf(fid,' %14.7f %14.7f %14.13f \n',stru_in(kl,1),stru_in(kl,2),stru_in(kl,3));
                end
                fclose(fid);
                
            case '.xyn'
                fid=fopen(fname,'w');
                ndep=numel(stru_in);
                for kl=1:ndep
                    fprintf(fid,' %14.7f %14.7f %s \n',stru_in(kl).x,stru_in(kl).y,stru_in(kl).name);
                end
                fclose(fid);
%                 messageOut(NaN,sprintf('File written: %s',fname));
            case '.shp'
                shapewrite(fname,'polyline',{stru_in.xy},{})  
%                 messageOut(NaN,sprintf('File written: %s',fname));
            case '' %writing a series of tim files
%                 D3D_io_input('write',dire_out,stru_in,reftime);
%                 dire_out = folder to write  
%                 stru_in = same structure as for bc
%                 reftime = datetime of the mdu file
                ref_date=varargin{2}; %all time series must have the reference date of the mdu
                ns=numel(stru_in);
                for ks=1:ns
                    idx_all=1:1:numel(stru_in(ks).quantity);
                    [idx_tim,bol_tim]=find_str_in_cell(stru_in(ks).quantity,{'time'});
                    idx_val=idx_all(~bol_tim);
                    str_tim=stru_in(ks).unit{idx_tim};
                    [t0,unit]=read_str_time(str_tim);
                    tim_val=stru_in(ks).val(:,idx_tim);
                    switch unit
                        case 'seconds'
                            data_loc(ks).tim=t0+seconds(tim_val);
                        case 'minutes'
                            data_loc(ks).tim=t0+minutes(tim_val);
                        otherwise
                            error('add')
                    end
                    data_loc(ks).val=stru_in(ks).val(:,idx_val);
                    data_loc(ks).quantity=stru_in(ks).quantity;
                end
                fname_tim_v={stru_in.name};
                %not sure if needed
%                 if nargin<6
%                     D3D_write_tim_2(data_loc,fname,fname_tim_v,ref_date)
%                 else
                    D3D_write_tim_2(data_loc,fname,fname_tim_v,ref_date,varargin{3:end})
%                 end
            case 'thd'
                delft3d_io_thd('write',fname,stru_in); %only D3D4 format. Need to be added for FM
            case '.obs'
                D3D_write_obs(fname,stru_in,varargin{2:end});
            case '.crs'
                D3D_write_crs(fname,stru_in,varargin{2:end});
            otherwise
                error('Extension %s in file %s not available for writing',ext,fname)
        end
        messageOut(NaN,sprintf('File written: %s',fname));
        varargout{1}=stru_in;
end

end %function

%%
%%
%%

function ext=fileparts_ext(fname)

[~,~,ext]=fileparts(fname);

end %function

%%

function inifiletype=parse_ini(stru_out)
global INIFILE_GENERAL INIFILE_CRSDEF INIFILE_CRSLOC

inifiletype=NaN;
fns = fieldnames(stru_out);
idx_gen = find(strcmp(lower(fns),'general')); 
if ~isempty(idx_gen);
    inifiletype=INIFILE_GENERAL;
    str_gen = fns{idx_gen};
end
if ~isnan(inifiletype)
    if isfield(stru_out.(str_gen),'fileType') %maybe also non-capital? we need a general way of dealing with it
        switch stru_out.(str_gen).fileType
            case 'crossDef'
                inifiletype=INIFILE_CRSDEF;
            case 'crossLoc'
                inifiletype=INIFILE_CRSLOC;
        end
    else
        inifiletype=NaN;
        messageOut(NaN,'It is an ini-file, but I cannot find the <fileType>')
    end
end
                
end %function

%%

function tim_dtim=read_time_from_table(stru_out)

idx_tim=find_str_in_cell({stru_out.Parameter.Name},{'time'});
if isnan(idx_tim)
    error('Time not found')
end

%try read time as string
str_time=stru_out.Parameter(idx_tim).Unit;
[tim_ref_dtim,units,~,~]=read_str_time(str_time);

%if it fails, try reading directly from table
if isnat(tim_ref_dtim)
    tim_ref=num2str(stru_out.ReferenceTime(1));
    tim_ref_dtim=datetime(str2double(tim_ref(1:4)),str2double(tim_ref(5:6)),str2double(tim_ref(7:8)));
    units=stru_out.TimeUnit;
end

tim_data=stru_out.Data(:,idx_tim);
switch units
    case 'seconds'
        tim_un=seconds(tim_data);
    case 'minutes'
        tim_un=minutes(tim_data);
    otherwise
        error('add')
end
tim_dtim=tim_ref_dtim+tim_un;

end %function