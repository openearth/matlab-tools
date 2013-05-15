function bch = simona2bnd_bch(S,bnd)

% simona2mdf_bch : gets harmonic (fourier) data out of the siminp

bch      = [];
ibnd_bch = 0;

%
% Harmonic forcing data
%

nesthd_dir = getenv('nesthd_path');

%
% get information out of struc
%

%siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS'});
%if ~isempty (siminp_struc.ParsedTree.FLOW.FORCINGS.FOURIER)
%    fourier      = siminp_struc.ParsedTree.FLOW.FORCINGS.HARMONIC;

    %
    % cycle over all open boundaries
    %

    for ibnd = 1: length(bnd.DATA)

        %
        % Type of boundary out of the bndstruc, for astronomical data continue
        %

        if strcmpi(bnd.DATA(ibnd).datatype,'H');

            ibnd_bch = ibnd_bch + 1;
        end
    end


%
% Warning
%

if ibnd_bch > 0
   simona2mdf_warning('Conversion of HARMONIC boundary forcing not implemented yet');
end
