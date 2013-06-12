function src=simona2mdf_src(S)

% simona2mdf_src : gets efinition of discahrge points out of siminp file

src = [];

%
% Parse Boundary data
%

nesthd_dir = getenv('nesthd_path');

%
% get information out of struc
%

points  = [];
sources = [];

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'POINTS'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.POINTS')
    points    = siminp_struc.ParsedTree.MESH.POINTS;
end

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.FORCINGS.DISCHARGES.SOURCE')
    sources   = siminp_struc.ParsedTree.FLOW.FORCINGS.DISCHARGES.SOURCE;
end

for isrc = 1: length(sources)
    for ipnt = 1: length(points.P)
        if points.P(ipnt).SEQNR == sources(isrc).P
            no_pnt = ipnt;
            break
        end
    end
    src(isrc).interpolation = 'Y';
    src(isrc).name          = points.P(no_pnt).NAME;
    src(isrc).m             = points.P(no_pnt).M;
    src(isrc).n             = points.P(no_pnt).N;
    if simona2mdf_fieldandvalue(sources(isrc),'LAYER')
        src(isrc).k = sources(isrc).LAYER;
    else
        src(isrc).k = 1;
    end
    src(isrc).type         = '';
end

