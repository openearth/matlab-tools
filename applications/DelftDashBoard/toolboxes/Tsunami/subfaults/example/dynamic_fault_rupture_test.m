clear variables;close all;

xlower = 135;
xupper = 150;
ylower = 30;
yupper = 45;
refdate=datenum(2015,10,9);

subfaultfile='ucsb_subfault_2011_03_11_v3.cfg';

dynamic_fault_rupture('subfaultfile',subfaultfile,'xlim',[xlower xupper],'ylim',[ylower yupper],'dx',180,'dt',6,'grdfile','japan.grd','sdufile','japan01.sdu','refdate',refdate,'inifile','japan01.ini');

