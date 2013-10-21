function bcc = simona2bnd_bcc(S,bnd,mdf)

% simona2mdf_bcc : gets time-series transport forcing (for now only salinity)

bcc      = [];
ibnd_bcc = 0;

%
% Time series forcing data (salinity only)
%

nesthd_dir = getenv('nesthd_path');

%
% get information out of struc
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'TRANSPORT'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT.PROBLEM.SALINITY')

    constnr = siminp_struc.ParsedTree.TRANSPORT.PROBLEM.SALINITY.CO;

    series       = siminp_struc.ParsedTree.TRANSPORT.FORCINGS.BOUNDARIES.TIMESERIES.TS;

    %
    % cycle over all open boundaries
    %

    for ibnd = 1: length(bnd.DATA)

        %
        % For all boundaries
        %

        ibnd_bcc = ibnd_bcc + 1;

        for iside = 1: 2

            %
            % Get seriesnr
            %

            for ipnt = 1: length(series)
                 if series(ipnt).P == bnd.pntnr(ibnd,iside) && series(ipnt).CO == constnr
                      pntnr = ipnt;
                      break
                 end
            end
            %
            % Get the time series data
            %
            if simona2mdf_fieldandvalue(series(ipnt),'SERIES')
                 [times(iside,:),values(iside,:,1)] = simona2mdf_getseries(series(pntnr));
            else
                 times(iside,1)    = mdf.tstart;
                 times(iside,2)    = mdf.tstop;
                 values(iside,1,1) = series(pntnr).CINIT;
                 values(iside,2,1) = series(pntnr).CINIT;
            end
        end

        %
        % Check if times are correct
        %

        if ~isequal(times(1,:),times(2,:))
             simona2mdf_message('Times for timeseries SIDE A and SIDE B must be identical','Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
        end

        %
        % Fill the bcc (INFO) structure
        %

        quant   ='Salinity             ';
        unit    ='[ppt]';
        profile = 'uniform';

        bcc.NTables=ibnd_bcc;
        bcc.Table(ibnd_bcc).Name=['Boundary Section : ' num2str(ibnd)];
        bcc.Table(ibnd_bcc).Contents=profile;
        bcc.Table(ibnd_bcc).Location=bnd.DATA(ibnd).name;
        bcc.Table(ibnd_bcc).TimeFunction='non-equidistant';
        bcc.Table(ibnd_bcc).ReferenceTime=str2num(datestr(datenum(mdf.itdate,'yyyy-mm-dd'),'yyyymmdd'));
        bcc.Table(ibnd_bcc).TimeUnit='minutes';
        bcc.Table(ibnd_bcc).Interpolation='linear';
        bcc.Table(ibnd_bcc).Parameter(1).Name='time';
        bcc.Table(ibnd_bcc).Parameter(1).Unit='[min]';

        bcc.Table(ibnd_bcc).Parameter(2).Name=[quant 'End A'];
        bcc.Table(ibnd_bcc).Parameter(2).Unit=unit;
        bcc.Table(ibnd_bcc).Parameter(3).Name=[quant 'End B'];
        bcc.Table(ibnd_bcc).Parameter(3).Unit=unit;

        %
        % Fill bnd structure with time series
        %

        bcc.Table(ibnd_bcc).Data(:,1) = times(1,:);
        bcc.Table(ibnd_bcc).Data(:,2) = values(1,:,1);
        bcc.Table(ibnd_bcc).Data(:,3) = values(2,:,1);
    end
end

