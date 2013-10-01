function varargout = simona2mdu_genext(filmdu,varargin)

% Simona2mdu_genext: writes the externul forcing file for unstruc

%% initialisation
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
OPT.Filedy  = '';
OPT.Filwnd  = '';
OPT                   = setproperty(OPT,varargin);
mdu         = OPT.mdu;

[path_mdu,name_mdu,~] = fileparts(filmdu);

%% If external forcing is present
if ~isempty(OPT.Filbnd) || ~isempty(OPT.Filrgh) || ~isempty(OPT.Filedy) || ~isempty(OPT.Filwnd)
    fid = fopen([filmdu '.ext'],'w+');

    % Write the header (comment lines)
    if ~isempty(OPT.Filcomments)
        comments = simona2mdu_csvread(OPT.Filcomments);
        for i_com = 1: length(comments)
            fprintf(fid,'%s \n',comments{i_com});
        end
    end

    %% write the boundary definition
    if ~isempty(OPT.Filbnd)
        for i_bnd=1:length(OPT.Filbnd);
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
                tlinecell     = textscan(tline,'%s%s%s%s%s');
                tlinestr      = cell2mat(tlinecell{3});
                switch tlinestr;
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
            fprintf(fid,['QUANTITY='  ,type,'\n']);
            fprintf(fid,['FILENAME='  ,file,'\n']);
            fprintf(fid,['FILETYPE=9'      ,'\n']);
            fprintf(fid,['METHOD=3'        ,'\n']);
            fprintf(fid,['OPERAND=O'       ,'\n']);
            fprintf(fid,' \n');
        end
    end

    %% Write initial conditions for salinity

    if ~isempty(OPT.Filini)

    end

    %% write space varying roughness
    if ~isempty(OPT.Filrgh)


    end

    %% write space varying viscosity

    if ~isempty(OPT.Filedy)

        mdu = rmfield(mdu,'Filedy');

    end

    %% write wind
    if ~isempty(OPT.Filwnd)

        mdu = rmfield(mdu,'Filwnd');

    end

    fclose (fid);

    %% Clean up mdu structure (if passed on) and set name of the external forcing file in the mdu structure

    if ~isempty(mdu)
        if isfield(mdu,'Filbnd') mdu = rmfield(mdu,'Filbnd');end
        if isfield(mdu,'Filrgh') mdu = rmfield(mdu,'Filrgh');end
        if isfield(mdu,'Filedy') mdu = rmfield(mdu,'Filedy');end
        if isfield(mdu,'Filwnd') mdu = rmfield(mdu,'Filwnd');end
        if isfield(mdu,'Filini') mdu = rmfield(mdu,'Filini');end
        mdu.external_forcing.ExtForceFile = [name_mdu '.ext'];
        varargout{1} = mdu;
    end

end
