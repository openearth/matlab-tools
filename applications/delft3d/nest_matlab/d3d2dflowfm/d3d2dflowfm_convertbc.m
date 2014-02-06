function d3d2dflow_convertbc(filinp,filpli,path_output,varargin)

%% Determine type of forcing for which conversion is requested,
%% First check the additional input arguments, secondly by using the file extension
OPT.Astronomical = false;
OPT.Harmonic     = false;
OPT.Series       = false;
OPT.Salinity     = false;

if ~isempty(varargin)
    OPT = setproperty(OPT,varargin);
else
    if ~isempty(filinp)
        [~,~,extension] = fileparts(filinp);
        if strcmp(extension,'.bca') OPT.Astronomical = true; end
        if strcmp(extension,'.bch') OPT.Harmonic     = true; end
        if strcmp(extension,'.bct') OPT.Series       = true; end
        if strcmp(extension,'.bcc')
            OPT.Series       = true;
            OPT.Salinity     = true;
        end
    end
end

%% Read the forcing data
if OPT.Astronomical bca    = delft3d_io_bca('read',filinp);end
if OPT.Harmonic     bch    = delft3d_io_bch('read',filinp);end
if OPT.Series       bct    = ddb_bct_io    ('read',filinp);end

if OPT.Harmonic
    freq    = bch.frequencies(2:end);
    freq    = 60*360./freq;            % Convert from degrees/hr ==> minutes
    no_freq = length(freq);
    a0      = bch.a0;
    amp     = bch.amplitudes;
    phases  = bch.phases;
end

%% cycle over the pli's
for i_pli = 1: length(filpli)
    LINE = dflowfm_io_xydata('read',filpli{i_pli});
    for i_pnt = 1: size(LINE.DATA,1)
        %% Get the type of forcing for this point
        index =  d3d2dflowfm_decomposestr(LINE.DATA{i_pnt,3});
        if OPT.Salinity
            b_type  = 't';
        else
            b_type = lower(strtrim(LINE.DATA{i_pnt,3}(index(2):index(3) - 1)));
        end

        switch b_type

            %% Astronomical boundary forcing
            case 'a'
                if OPT.Astronomical
                    %% Open file with astronomical bc
                    filename = [path_output filesep LINE.Blckname '_' num2str(i_pnt,'%0.4d') '.cmp'];
                    fid      = fopen(filename,'wt');

                    %% Write the general information
                    fprintf(fid,['* COLUMNN=3','\n']);
                    fprintf(fid,['* COLUMN1=Astronomical Componentname','\n']);
                    fprintf(fid,['* COLUMN2=Amplitude (ISO)','\n']);
                    fprintf(fid,['* COLUMN3=Phase (deg)','\n']);
                    pntname  = strtrim(LINE.DATA{i_pnt,3}(index(3):index(4) - 1));

                    %% Find correct label and write names, amplitudes and phases
                    for i_bca=1:length(bca.DATA);
                        if strcmp(pntname,bca.DATA(i_bca).label);
                            for i_cmp=1:length(bca.DATA(i_bca).names);
                                information  = sprintf('%-8s %12.4f %12.4f',bca.DATA(i_bca).names{i_cmp}, ...
                                    bca.DATA(i_bca).amp(i_cmp)  , ...
                                    bca.DATA(i_bca).phi(i_cmp)  );
                                fprintf(fid,[information,'\n']);
                            end
                            fclose(fid);
                            break
                        end
                    end
                end

            %% Harmonic boundary forcing
            case 'h'
                if OPT.Harmonic
                    %% Open file with harmonic bc
                    filename = [path_output filesep LINE.Blckname '_' num2str(i_pnt,'%0.4d') '.cmp'];
                    fid      = fopen(filename,'wt');

                    %% Write some general information
                    fprintf(fid,['* COLUMNN=3','\n']);
                    fprintf(fid,['* COLUMN1=Period (min)','\n']);
                    fprintf(fid,['* COLUMN2=Amplitude (ISO)','\n']);
                    fprintf(fid,['* COLUMN3=Phase (deg)','\n']);

                    %% find harmonic boundary number and side

                    i_harm = str2num(LINE.DATA{i_pnt,3}(index(3):index(3) + 3));
                    if strcmpi      (LINE.DATA{i_pnt,3}(end     :end         ),'a');
                        i_side = 1;
                    else
                        i_side = 2;
                    end

                    %% Write harmonic data to forcing file
                    string  = sprintf('%12.4f %12.4f %12.4f', 0.0, a0(i_side,i_harm),0.0);
                    fprintf(fid,[string '\n']);

                    for i_freq = 1:no_freq
                        string = sprintf('%12.4f %12.4f %12.4f', freq(i_freq)                  , ...
                                                                 amp (i_side,i_harm,i_freq)    , ...
                                                                 phases (i_side,i_harm,i_freq) ) ;
                        fprintf(fid,[string '\n']);
                    end
                    fclose(fid);
                end
            %% Time series forcing data
            case 't'
                if OPT.Series
                    filename = [path_output filesep LINE.Blckname '_' num2str(i_pnt,'%0.4d') '.tim'];

                    %% find Time series table number
                    bndname = LINE.DATA{i_pnt,3}(index(3):end-5); 
                    for i_table = 1: bct.NTables
                        name_bct = bct.Table(i_table).Location;
                        name_bct (name_bct == ' ') = '';
                        if strcmp(strtrim(bndname),strtrim(name_bct))
                            nr_table = i_table;
                        end
                    end

                    %% Fill series array
                    %  First: Time in minutes
                    SERIES.Values(:,1) = bct.Table(nr_table).Data(:,1);

                    % Then: Values (for now only depth averaged values)
                    if strcmpi      (LINE.DATA{i_pnt,3}(end     :end         ),'a'); %end A
                        SERIES.Values(:,2) = bct.Table(nr_table).Data(:,2);
                    else                                                             %end B
                        SERIES.Values(:,2) = bct.Table(nr_table).Data(:,3);
                    end

                    %% General Comments
                    SERIES.Comments{1} = '* COLUMNN=2';
                    SERIES.Comments{2} = '* COLUMN1=Time (min) since ITDATE?';
                    SERIES.Comments{3} = '* COLUMN2=Value';

                    dflowfm_io_series('write',filename,SERIES);

                    clear SERIES
                end
        end
     end
end
