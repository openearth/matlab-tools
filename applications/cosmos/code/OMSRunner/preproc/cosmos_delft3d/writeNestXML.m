function writeNestXML(fname,inpdir,runid,datafolder,dataname,wlbndfile,wlbcafile,curbndfile,curbcafile,wlconst)

opt.bctTimeStep=10;
opt.bccTimeStep=30;
opt.inputFolder=inpdir;
opt.runid=runid;

opt.waterLevel.bc.source='file+astro';
opt.waterLevel.bc.dataFolder=datafolder;
opt.waterLevel.bc.dataName=dataname;
opt.waterLevel.bc.bndFile=wlbndfile;
opt.waterLevel.bc.bcaFile=wlbcafile;
opt.waterLevel.bc.constant=wlconst;
opt.waterLevel.ic.source='file';
opt.waterLevel.ic.dataFolder=datafolder;
opt.waterLevel.ic.dataName=dataname;
opt.waterLevel.ic.constant=wlconst;

opt.current.bc.source='file+astro';
opt.current.bc.dataFolder=datafolder;
opt.current.bc.dataName=dataname;
opt.current.bc.bndFile=curbndfile;
opt.current.bc.bcaFile=curbcafile;
opt.current.ic.source='file';
opt.current.ic.dataFolder=datafolder;
opt.current.ic.dataName=dataname;

opt.salinity.bc.source='file';
opt.salinity.bc.dataFolder=datafolder;
opt.salinity.bc.dataName=dataname;
opt.salinity.ic.source='file';
opt.salinity.ic.dataFolder=datafolder;
opt.salinity.ic.dataName=dataname;

opt.temperature.bc.source='file';
opt.temperature.bc.dataFolder=datafolder;
opt.temperature.bc.dataName=dataname;
opt.temperature.ic.source='file';
opt.temperature.ic.dataFolder=datafolder;
opt.temperature.ic.dataName=dataname;

xml_save(fname,opt,'off');
