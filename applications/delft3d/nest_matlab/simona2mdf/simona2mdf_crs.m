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
            index(end + 1) = simona2mdf_getpntnr(curves.C,chkpoints.(stat{ivar}).C(istat));
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
            cross.m(icrs,iside)   =  points.P(pntnr).M;
            cross.n(icrs,iside)   =  points.P(pntnr).N;
        end
        cross.namst(icrs,:) = crs.NAME;
    end

    %
    % Write
    %

    mdf.filcrs = [name_mdf '.crs'];
    delft3d_io_crs('write',mdf.filcrs,cross);
    mdf.filcrs = simona2mdf_rmpath(mdf.filcrs);
end
