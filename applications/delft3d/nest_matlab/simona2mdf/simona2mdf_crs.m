function mdf = simona2mdf_obs(S,mdf,name_mdf)

% simona2mdf_obs : gets observation stations out of the parsed siminp tree

nesthd_dir = getenv('nesthd_path');

curves = [];

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH'});
if ~isempty(siminp_struc.ParsedTree.MESH.CURVES)
   curves       = siminp_struc.ParsedTree.MESH.CURVES;
end
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'CHECKPOINTS'});
chkpoints    = siminp_struc.ParsedTree.FLOW.CHECKPOINTS;

%
% Get curve numbers
%

index = [];
stat{1} = 'USECTIONS';
stat{2} = 'VSECTIONS';

for ivar = 1: length(stat)
    if ~isempty(chkpoints.(stat{ivar}))
        for istat = 1: length(chkpoints.(stat{ivar}).C)
            pntnr = simona2mdf_getpntnr(curves.C,chkpoints.(stat{ivar}).C(istat));
            if ~isempty(pntnr)
                index(end + 1) = simona2mdf_getpntnr(curves.C,chkpoints.(stat{ivar}).C(istat));
            else
                simona2mdf_warning({['Outpunt ruquested for C' num2str(chkpoints.(stat{ivar}).C(istat),'%4.4i')]; ...
                                    ' However, not defined as CURVE. SKIPPED!'});
            end
        end
    end
end

%
% Find support points of the curves
%

index = unique(index);

if ~isempty(index)
    siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'POINTS'});
    points       = siminp_struc.ParsedTree.MESH.POINTS;
    for icrs = 1: length(index)
        crs = curves.C(index(icrs)).LINE;
        for iside = 1: 2
            pntnr = simona2mdf_getpntnr(points.P,crs.P(iside));
            if ~isempty(pntnr)
                cross.m(icrs,iside)   =  points.P(pntnr).M;
                cross.n(icrs,iside)   =  points.P(pntnr).N;
                cross.namst(icrs,(1:length(crs.NAME)))   = crs.NAME;
            else
                simona2mdf_warning({['Outpunt ruquested for P' num2str(chkpoints.(stat{ivar}).P(istat),'%4.4i')]; ...
                                    ' However, not defined as POINT. NaN written to crs file!'});
                cross.m(icrs,iside)   =  NaN;
                cross.n(icrs,iside)   =  NaN;
                cross.namst(icrs,(1:length(crs.NAME)))   = crs.NAME;
            end
        end
    end

    %
    % Write
    %

    mdf.filcrs = [name_mdf '.crs'];
    delft3d_io_crs('write',mdf.filcrs,cross);
    mdf.filcrs = simona2mdf_rmpath(mdf.filcrs);
end
