function bca = simona2bnd_bca(S,bnd)

% simona2mdf_bca : gets astronomical data out of the siminp

bca      = [];
ibnd_bca = 0;

%
% Astronomical forcing data
%

nesthd_dir = getenv('nesthd_path');

%
% get information out of struc
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS'});
if ~isempty (siminp_struc.ParsedTree.FLOW.FORCINGS.HARMONIC)
    harmonic     = siminp_struc.ParsedTree.FLOW.FORCINGS.HARMONIC;
    const        = harmonic.GENERAL.OMEGA;

    %
    % cycle over all open boundaries
    %

    for ibnd = 1: length(bnd.DATA)

        %
        % Type of boundary out of the bndstruc, for astronomical data continue
        %

        if strcmpi(bnd.DATA(ibnd).datatype,'A');
   
            ibnd_bca = ibnd_bca + 1;

            for iside = 1: 2
                pntnr = bnd.pntnr(ibnd,iside);
                for ipnt = 1: length(harmonic.CONSTANTS.S)
                    if harmonic.CONSTANTS.S(ipnt).P == pntnr
                        bca.DATA(ibnd_bca,iside).names{1} = 'A0';
                        for icons = 1: length(const)
                            bca.DATA(ibnd_bca,iside).names{icons+1} = const{icons}(2:end-1);
                        end
                        ampfas = harmonic.CONSTANTS.S(ipnt);
                        bca.DATA(ibnd_bca,iside).amp(1) = ampfas.AZERO;
                        bca.DATA(ibnd_bca,iside).phi(1) = -999.999;
                        bca.DATA(ibnd_bca,iside).amp(2:length(ampfas.AMPL)+1)  = ampfas.AMPL;
                        bca.DATA(ibnd_bca,iside).phi(2:length(ampfas.PHASE)+1) = ampfas.PHASE*360/(2*pi);
                        bca.DATA(ibnd_bca,iside).label = ['P' num2str(pntnr,'%4.4i')];
                        break
                    end
                end
            end
        end
    end
end


