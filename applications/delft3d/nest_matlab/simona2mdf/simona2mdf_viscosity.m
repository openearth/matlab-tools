function mdf=simona2mdf_viscosity(S,mdf,name_mdf)

% simona2mdf_viscosity : gets the iviscosity information (horizontal) out of the siminp file


%
% get information out of struc
%

nesthd_dir   = getenv('nesthd_path');
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'TURBULENCE_MODEL'});
turbulence   = siminp_struc.ParsedTree.TURBULENCE_MODEL;
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM'});
problem      = siminp_struc.ParsedTree.FLOW.PROBLEM;

%
% Check for HLES
%

if ~isempty(turbulence)
    if ~isempty(turbulence.HLES)
        siminp2mdf_warning('HLES not implemented yet');
    end
end

%
% Fill viscosity values/arrays and write (in case of space varying values)
%

if isempty(problem.VISCOSITY) && isempty(problem.HOR_VISCOSITY)
    mdf.vicouv = 10.0; % Insane default value
elseif ~isempty (problem.VISCOSITY)
    mdf.vicouv = problem.VISCOSITY.EDDYVISCOSIT;
else
    %
    % Space varying
    %
    mmax = mdf.mnkmax(1);
    nmax = mdf.mnkmax(2);
    vico(1:mmax,1:nmax) = 0.0;
    vico = simona2mdf_getglobaldata (problem.HOR_VISCOSITY.GLOBAL,vico);
    if isfield(problem.HOR_VISCOSITY.LOCAL,'BOX')
        vico = simona2mdf_getboxdata(problem.HOR_VISCOSITY.LOCAL.BOX,vico);
    end
    %
    % write file, fil dispersion with dummy values
    %
    dummy (1:mmax,1:nmax) = -999.999;
    edy(1).Data = vico;
    edy(2).Data = dummy;
    mdf.filedy = [name_mdf '.edy'];
    wldep ('write',mdf.filedy,edy);
    mdf.filedy = simona2mdf_rmpath(mdf.filedy);
end
