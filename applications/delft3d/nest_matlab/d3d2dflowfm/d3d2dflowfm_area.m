function mdu = d3d2dflowfm_area(mdf,mdu,~)

% d3d2dflowfm : Writes AREA information (ANGLAT)  unstruc input files

mdu.geometry.AngLat     = mdf.anglat;
mdu.geometry.BedlevType = 3;
