function mdu = mdf2mdu_numerical(mdf,mdu,~)

% mdf2mdu_numerical : Set numerical defaults to the mdu struct

mdu.geometry.Conveyance2D = 0;
mdu.numerics.CFLMax       = 0.7;
mdu.numerics.CFLWaveFrac  = -999; % not used so make clear it is not used!
mdu.numerics.AdvecType    = 3;
mdu.numerics.Limtypmom    = 4;
mdu.numerics.Limtypsa     = -999;
if mdu.physics.Salinity  mdu.numerics.Limtypsa     = 4; end
mdu.numerics.Icgsolver    = 4;
mdu.numerics.Maxdegree    = 6;
mdu.numerics.Tlfsmo       = mdf.tlfsmo;
mdu.numerics.Slopedrop2D  = 0.;
