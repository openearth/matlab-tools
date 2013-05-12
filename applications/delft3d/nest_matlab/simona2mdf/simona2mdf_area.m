function mdf = simona2mdf_area(S,mdf,name_mdf)

% simona2mdf_area : gets grid related quantities out of the parsed siminp tree

nesthd_dir = getenv('nesthd_path');


siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'GRID'});

%
% Get grid related information
%
if isfield(siminp_struc.ParsedTree.MESH.GRID,'CURVILINEAR')
    if isfield(siminp_struc.ParsedTree.MESH.GRID.CURVILINEAR,'RGFFILE')
        mdf.filcco    = siminp_struc.ParsedTree.MESH.GRID.CURVILINEAR.RGFFILE;
        mdf.anglat    = siminp_struc.ParsedTree.MESH.GRID.AREA.LATITUDE;
    else
       % CSM
       mdf.filcco    = siminp_struc.ParsedTree.MESH.GRID.GENERALIZED_SPHERICAL.RGFFILE;
    end
end

mdf.grdang    = siminp_struc.ParsedTree.MESH.GRID.AREA.ANGLEGRID;

mdf.mnkmax(1) = siminp_struc.ParsedTree.MESH.GRID.AREA.MMAX;
mdf.mnkmax(2) = siminp_struc.ParsedTree.MESH.GRID.AREA.NMAX;
mdf.mnkmax(3) = siminp_struc.ParsedTree.MESH.GRID.AREA.KMAX;

%
% For now: assume uniform layer thicknesses
%

mdf.thick(1:mdf.mnkmax(3)) = 100./mdf.mnkmax(3);

%
% The enclosure
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'BOUNDARIES' 'ENCLOSURES'});

enc = siminp_struc.ParsedTree.MESH.BOUNDARIES.ENCLOSURES.E;

MN = [];
for i_enc = 1: length(enc)
    MN = [MN ; reshape(enc(i_enc).COORDINATES,2,[])'];
end

file_enc   = [name_mdf '.enc'];
mdf.filgrd = file_enc;
enclosure ('write',file_enc,MN);
