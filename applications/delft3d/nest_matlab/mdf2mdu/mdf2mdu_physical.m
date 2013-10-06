function mdu = mdf2mdu_physical(mdf, mdu, ~)

% mdf2mdu_physical : Get physical information out of the mdf structure and set in the mdu structure

mdu.physics.Ag      = mdf.ag;
mdu.physics.Rhomean = mdf.rhow;
if strcmpi(mdf.sub1(1),'S') mdu.physics.Salinity = true; end
