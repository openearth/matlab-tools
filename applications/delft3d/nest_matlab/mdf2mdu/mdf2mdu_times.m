function mdu = mdf2mdu_times(mdf,mdu,~)

% mdf2mdu_area: Writes TIMES information to the unstruc structure

mdu.time.RefDate = [mdf.itdate(1:4) mdf.itdate(6:7) mdf.itdate(9:10)];
mdu.time.Tunit   = 'S';
mdu.time.DtUser  = mdf.dt*60.;
mdu.time.DtMax   = mdf.dt*60.;
mdu.time.DtInit  = mdu.time.DtMax/10.;
mdu.time.TStart  = mdf.tstart*60.;
mdu.time.TStop   = mdf.tstop*60.;
