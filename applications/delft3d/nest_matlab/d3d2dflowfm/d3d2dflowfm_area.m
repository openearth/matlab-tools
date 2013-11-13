function mdu = d3d2dflowfm_area(mdf,mdu,~)

% d3d2dflowfm : Writes AREA information (ANGLAT)  unstruc input files

if simona2mdf_fieldandvalue(mdf,'anglat')
   mdu.geometry.AngLat     = mdf.anglat;
else
   mdu.geometry.AngLat     = -999.999;
end

mdu.geometry.BedlevType = 3;
