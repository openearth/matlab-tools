function mdf = simona2mdf_area(S,mdf,name_mdf)

% simona2mdf_area : gets grid related quantities out of the parsed siminp tree

nesthd_dir = getenv('nesthd_path');


siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'GRID'});

%
% Get grid related information
%
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.GRID.CURVILINEAR.RGFFILE')
    mdf.filcco    = siminp_struc.ParsedTree.MESH.GRID.CURVILINEAR.RGFFILE;
    mdf.anglat    = siminp_struc.ParsedTree.MESH.GRID.AREA.LATITUDE;
elseif simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.GRID.GENERALIZED_SPHERICAL.RGFFILE')
       % CSM
    mdf.filcco    = siminp_struc.ParsedTree.MESH.GRID.GENERALIZED_SPHERICAL.RGFFILE;
else
    simona2mdf_warning('Recti-linear coordinates not implemented');
end

%
% copy grid file to Delft3D-directory
%

if ~isempty(mdf.filcco)
   copyfile([mdf.pathsimona filesep mdf.filcco],[mdf.pathd3d filesep simona2mdf_rmpath(mdf.filcco)]);
   mdf        = rmfield(mdf,'pathsimona');
   mdf        = rmfield(mdf,'pathd3d');
   mdf.filcco = simona2mdf_rmpath(mdf.filcco);
end

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.GRID.AREA')
   mdf.grdang    = siminp_struc.ParsedTree.MESH.GRID.AREA.ANGLEGRID;
   mdf.mnkmax(1) = siminp_struc.ParsedTree.MESH.GRID.AREA.MMAX;
   mdf.mnkmax(2) = siminp_struc.ParsedTree.MESH.GRID.AREA.NMAX;
   mdf.mnkmax(3) = siminp_struc.ParsedTree.MESH.GRID.AREA.KMAX;

   %
   % For now: assume uniform layer thicknesses  
   %  

   mdf.thick(1:mdf.mnkmax(3)) = 100./mdf.mnkmax(3);
end

%
% The enclosure
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'BOUNDARIES' 'ENCLOSURES'});

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.BOUNDARIES.ENCLOSURES.E')
    enc = siminp_struc.ParsedTree.MESH.BOUNDARIES.ENCLOSURES.E;

    MN = [];
    for i_enc = 1: length(enc)
        MN = [MN ; reshape(enc(i_enc).COORDINATES,2,[])'];
    end

    file_enc   = [name_mdf '.enc'];
    mdf.filgrd = file_enc;
    enclosure ('write',file_enc,MN);
    mdf.filgrd = simona2mdf_rmpath(mdf.filgrd);
end

