function mdu = d3d2dflowfm_genext(mdu,filmdu,varargin)

% d3d2dflowfm_genext: writes the external forcing file for D-Flow FM

%% initialisation
ext_force   = [];

OPT.Comments  = false;
OPT.Filbnd    = '';
OPT.Filini_sal= '';
OPT.Filini_tem= '';
OPT.Filrgh    = '';
OPT.Filvico   = '';
OPT.Fildico   = '';
OPT.Filwnd    = '';
OPT.Filtem    = '';
OPT.Fileva    = '';
OPT.Filbc0    = '';
OPT.Filwsvp   =  [];
OPT           = setproperty(OPT,varargin);

nesthd_path = getenv('nesthd_path');
if ~isempty (nesthd_path) && OPT.Comments
   Filcomments = [nesthd_path filesep 'bin' filesep 'extcomments.csv'];
end

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

%% sea level anomalies through additional time series file

%% Write initial conditions for salinity
if ~isempty(OPT.Filini_sal)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'initialsalinity';
    ext_force(i_force).filename = OPT.Filini_sal;
    ext_force(i_force).filetype = 7;
    ext_force(i_force).method   = 4;
    ext_force(i_force).operand  = 'O';
end

%% Write initial conditions for temperature
if ~isempty(OPT.Filini_tem)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'initiatemperature';
    ext_force(i_force).filename = OPT.Filini_tem;
    ext_force(i_force).filetype = 7;
    ext_force(i_force).method   = 4;
    ext_force(i_force).operand  = 'O';
end

%% write space varying roughness
if ~isempty(OPT.Filrgh)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'frictioncoefficient';
    ext_force(i_force).filename = OPT.Filrgh;
    ext_force(i_force).filetype = 7;
    ext_force(i_force).method   = 4;
    ext_force(i_force).operand  = 'O';
end

%% write space varying viscosity
if ~isempty(OPT.Filvico)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'horizontaleddyviscositycoefficient';
    ext_force(i_force).filename = OPT.Filvico;
    ext_force(i_force).filetype = 7;
    ext_force(i_force).method   = 4;
    ext_force(i_force).operand  = 'O';
end

%% write space varying diffusivity
if ~isempty(OPT.Fildico)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'horizontaleddydiffusivitycoefficient';
    ext_force(i_force).filename = OPT.Fildico;
    ext_force(i_force).filetype = 7;
    ext_force(i_force).method   = 4;
    ext_force(i_force).operand  = 'O';
end

%% write wind
if ~isempty(OPT.Filwnd)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'windxy';
    ext_force(i_force).filename = OPT.Filwnd;
    ext_force(i_force).filetype = 2;
    ext_force(i_force).method   = 1;
    ext_force(i_force).operand  = 'O';
end

%% write temperature
if ~isempty(OPT.Filtem)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'humidity_airtemperature_cloudiness';
    ext_force(i_force).filename = OPT.Filtem;
    ext_force(i_force).filetype = 1;
    ext_force(i_force).method   = 1;
    ext_force(i_force).operand  = 'O';
end

%% write rain/evaporation
if ~isempty(OPT.Fileva)
    i_force = i_force + 1;
    ext_force(i_force).quantity = 'rainfall_mmperday';
    ext_force(i_force).filename = OPT.Fileva;
    ext_force(i_force).filetype = 1;
    ext_force(i_force).method   = 1;
    ext_force(i_force).operand  = 'O';
end

%% space varying wind and pressure
if ~isempty(OPT.Filwsvp)
    for i_param = 1:3
        if i_param == 1 quantity = 'atmosphericpressure'; end
        if i_param == 2 quantity = 'windx'              ; end
        if i_param == 2 quantity = 'windy'              ; end
        i_force = i_force + 1;
        ext_force(i_force).quantity = quantity;
        ext_force(i_force).filename = OPT.Filwsvp{i_param};
        ext_force(i_force).filetype = 4;
        ext_force(i_force).method   = 1;
        ext_force(i_force).operand  = 'O';
    end
end

%% write the external forcing structure to the external forcing file
if OPT.Comments
    dflowfm_io_extfile('write',[filmdu '.ext'],'Filcomments',Filcomments);
end

if ~isempty(ext_force)
    dflowfm_io_extfile('write',[filmdu '.ext'],'ext_force',ext_force);
    mdu.external_forcing.ExtForceFile = [name_mdu '.ext'];
end
