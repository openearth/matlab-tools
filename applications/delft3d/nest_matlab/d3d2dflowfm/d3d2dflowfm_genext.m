function varargout = d3d2dflowfm_genext(filmdu,varargin)

% d3d2dflowfm_genext: writes the external forcing file for D-Flow FM

%% initialisation
ext_force   = [];
nesthd_path = getenv('nesthd_path');
if ~isempty (nesthd_path)
   OPT.Filcomments = [nesthd_path filesep 'bin' filesep 'extcomments.csv'];
else
   OPT.Filcomments = '';
end

OPT.mdu     = [];
OPT.Filbnd  = '';
OPT.Filini  = '';
OPT.Filrgh  = '';
OPT.Filvico = '';
OPT.Fildico = '';
OPT.Filwnd  = '';
OPT                   = setproperty(OPT,varargin);
mdu         = OPT.mdu;

[path_mdu,name_mdu,~] = fileparts(filmdu);

%% Fill the ext_force structure
i_force = 0;

%% first the boundary definition
if ~isempty(OPT.Filbnd)
    for i_bnd=1:length(OPT.Filbnd);
        i_force = i_force + 1;
        file              = OPT.Filbnd{i_bnd};
        if     strcmp(file(end-7:end-4),'_tem');
            type  = 'temperaturebnd';                    % not supported by FM
        elseif strcmp(file(end-7:end-4),'_sal');
            type  = 'salinitybnd';
        else
            fid2          = fopen([path_mdu filesep file],'r');
            for i_row=1:3;
                tline     = fgetl(fid2);
            end
            fclose (fid2);
            index         = d3d2dflowfm_decomposestr(tline);
            type_bnd      = strtrim(tline(index(3):index(4) - 1));
            switch type_bnd
                case 'Z';
                    type  = 'waterlevelbnd';
                case 'C';
                    type  = 'velocitybnd';
                case 'N';
                    type  = 'neumannbnd';
                case 'Q';
                    type  = 'dischargepergridcellbnd';   % not supported by FM
                case 'T';
                    type  = 'dischargebnd';
                case 'R';
                    type  = 'riemannbnd';
            end
        end
        ext_force(i_force).quantity = type;
        ext_force(i_force).filename = file;
        ext_force(i_force).filetype = 9;
        ext_force(i_force).method   = 3;
        ext_force(i_force).operand  = 'O';
    end
end

%% Write initial conditions for salinity

if ~isempty(OPT.Filini)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'initialsalinity';
    ext_force(i_force).filename = mdu.Filini;
    ext_force(i_force).filetype = 7;
    ext_force(i_force).method   = 4;
    ext_force(i_force).operand  = 'O';
end

%% write space varying roughness
if ~isempty(OPT.Filrgh)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'frictioncoefficient';
    ext_force(i_force).filename = mdu.Filrgh;
    ext_force(i_force).filetype = 7;
    ext_force(i_force).method   = 4;
    ext_force(i_force).operand  = 'O';
end

%% write space varying viscosity
if ~isempty(OPT.Filvico)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'horizontaleddyviscositycoefficient';
    ext_force(i_force).filename = mdu.Filvico;
    ext_force(i_force).filetype = 7;
    ext_force(i_force).method   = 4;
    ext_force(i_force).operand  = 'O';
end

%% write space varying diffusivity
if ~isempty(OPT.Fildico)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'horizontaleddydiffusivitycoefficient';
    ext_force(i_force).filename = mdu.Fildico;
    ext_force(i_force).filetype = 7;
    ext_force(i_force).method   = 4;
    ext_force(i_force).operand  = 'O';
end

%% write wind
if ~isempty(OPT.Filwnd)
end

%% write the external forcing structure to the external forcing file
if ~isempty(ext_force)
    if ~isempty(OPT.Filcomments)
        dflowfm_io_extfile('write',[filmdu '.ext'],'Filcomments',OPT.Filcomments);
    end
    dflowfm_io_extfile('write',[filmdu '.ext'],'ext_force',ext_force);
end

%% Clean up mdu structure (if passed on) and set name of the external forcing file in the mdu structure

if ~isempty(mdu)
    if isfield(mdu,'Filbnd' ) mdu = rmfield(mdu,'Filbnd') ;end
    if isfield(mdu,'Filini' ) mdu = rmfield(mdu,'Filini') ;end
    if isfield(mdu,'Filrgh' ) mdu = rmfield(mdu,'Filrgh') ;end
    if isfield(mdu,'Filvico') mdu = rmfield(mdu,'Filvico');end
    if isfield(mdu,'Fildico') mdu = rmfield(mdu,'Fildico');end
    if isfield(mdu,'Filwnd' ) mdu = rmfield(mdu,'Filwnd') ;end
    mdu.external_forcing.ExtForceFile = [name_mdu '.ext'];
    varargout{1} = mdu;
end
