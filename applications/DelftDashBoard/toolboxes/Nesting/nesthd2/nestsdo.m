inpdir='F:\USGS_Tijuana\sandiego\newgrid\newt8_05\';
runid1='sdo';
datadir='F:\USGS_Tijuana\southerncalifornia\coarse\sigma_tan\socaldd\nodens_saltemp\';
runid2='sdodd';
nestadm='F:\USGS_Tijuana\southerncalifornia\nesting2\nest_sdodd.adm';
z0=0;
opt='both'; % Can also be hydro or transport
nesthd2(inpdir,runid1,datadir,runid2,nestadm,z0,opt);
