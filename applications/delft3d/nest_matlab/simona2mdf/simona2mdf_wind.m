function mdf = simona2mdf_wind (S,mdf,name_mdf)

% simona2mdf_wind : gets (uniform) wind information out of the parsed siminp tree

%
% Check for wind
%

nesthd_dir   = getenv('nesthd_path');
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'GENERAL'});

if ~isempty(siminp_struc.ParsedTree.GENERAL.WIND)
    wind = siminp_struc.ParsedTree.GENERAL.WIND;
    
    %
    % Wind Stress coefficient
    %
    
    if wind.VARIABLE_CD
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
    
    if ~isempty(wind.SERIES)
        if strcmpi(wind.SERIES,'regular')
            times  = wind.FRAME(1):wind.FRAME(2):wind.FRAME(3);
            values = reshape(wind.VALUES,2,[])';
            wnd.minutes   = times;
            wnd.speed     = values(:,1)*wind.WCONVERSIONF;
            wnd.direction = values(:,2);
            mdf.filwnd    = [name_mdf '.wnd'];
            delft3d_io_wnd('write',mdf.filwnd,wnd);
            mdf.filwnd    = simona2mdf_rmpath(mdf.filwnd);
         else
            simona2mdf_warning('TIME_AND_VALUE (wind series) not implemented yet');
        end
    end
    
    %
    % CHARNOCK
    %
    
    if ~isempty(wind.CHARNOCK)
         simona2mdf_warning({'CHARNOCK wind stress formulation not implemented in Delft3D-Flow'; ...
                             'Asuming Smith and Banke formulation'});
    end
end

