function mdf = simona2mdf_th (S,bnd,mdf)

% simona2mdf_th : Get thatcher Harleman time lags and set in the mdf struct

nesthd_dir = getenv('nesthd_path');
mdf.rettis(1:length(bnd.DATA)) = NaN;
mdf.rettib(1:length(bnd.DATA)) = NaN;

%
% get information out of struc
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'TRANSPORT'});


if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT.PROBLEM.SALINITY')

    th    = siminp_struc.ParsedTree.TRANSPORT.FORCINGS.BOUNDARIES.RETURNTIME.CRET;

    %
    % cycle over all open boundaries
    %

    for ibnd = 1: length(bnd.DATA)

        %
        % Get seriesnr
        %

        for ipnt = 1: length(th)
             if th(ipnt).P == bnd.pntnr(ibnd,1) 
                  pntnr = ipnt;
                  break
             end
        end
            
        mdf.rettis(ibnd) = th(pntnr).TCRETA;
        mdf.rettib(ibnd) = th(pntnr).TCRETA;
       
    end
end

