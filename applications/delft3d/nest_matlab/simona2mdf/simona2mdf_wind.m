function mdf = simona2mdf_wind (S,mdf,name_mdf, varargin);

% simona2mdf_wind : gets (uniform) wind information out of the parsed siminp tree

%
% Check for wind
%

OPT.nesthd_path = getenv('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'GENERAL'});

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.GENERAL.WIND')
    wind = siminp_struc.ParsedTree.GENERAL.WIND;

    %
    % Wind Stress coefficient
    %

    if simona2mdf_fieldandvalue(wind,'VARIABLE_CD')
        mdf.wstres(1) = wind.CDA;
        mdf.wstres(2) = wind.WIND_CDA;
        mdf.wstres(3) = wind.CDB;
        mdf.wstres(4) = wind.WIND_CDB;
        mdf.wstres(5) = wind.CDB;
        mdf.wstres(6) = wind.WIND_CDB;
    else
        mdf.wstres(1) = wind.WSTRESSFACT;
        mdf.wstres(2) = 0.;
        mdf.wstres(3) = wind.WSTRESSFACT;
        mdf.wstres(4) = 100.;
        mdf.wstres(5) = wind.WSTRESSFACT;
        mdf.wstres(6) = 100.;
    end

    %
    % Get the wind series
    %

    if simona2mdf_fieldandvalue(wind,'SERIES')
        if strcmpi(wind.SERIES,'regular')
            times  = wind.FRAME(1):wind.FRAME(2):wind.FRAME(3);
            values = reshape(wind.VALUES,2,[])';
            wnd.minutes   = times;
            wnd.speed     = values(:,1)*wind.WCONVERSIONF;
            wnd.direction = values(:,2);
            mdf.filwnd    = [name_mdf '.wnd'];
            simona2mdf_io_wnd('write',mdf.filwnd,wnd);
            mdf.filwnd    = simona2mdf_rmpath(mdf.filwnd);
         else
            simona2mdf_message('TIME_AND_VALUE (wind series) not implemented yet','Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
        end
    end

    %
    % CHARNOCK
    %

    if simona2mdf_fieldandvalue(wind,'CHARNOCK')
         simona2mdf_message({'CHARNOCK wind stress formulation not implemented in Delft3D-Flow'; ...
                             'Assuming Smith and Banke formulation'},'Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
    end
end

