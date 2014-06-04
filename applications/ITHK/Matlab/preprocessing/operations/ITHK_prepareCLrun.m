function ITHK_prepareCLrun

global S

fprintf('ITHK preprocessing : Preparing phasing of UNIBEST in time\n');

%% write a Unibest CL-run specification file
CLRfileName      = [S.settings.outputdir S.userinput.name,'.CLR'];
time             = [2005+S.userinput.phases 2005+S.userinput.duration];
phaseunit        = 'year';
timesteps        = 20; % computational timesteps (number / phase) (single value)
output_step      = 20; % output per number of computational timesteps (single value, every n-th timestep)

for ii=1:length(S.userinput.phases)
    GKLfiles{ii} = 'BASIS';
    BCOfiles{ii} = 'BASIS';
    GROfiles{ii} = strtok(S.userinput.phase(ii).GROfile,'.');
    SOSfiles{ii} = strtok(S.userinput.phase(ii).SOSfile,'.');
    REVfiles{ii} = strtok(S.userinput.phase(ii).REVfile,'.');
    OBWfiles{ii} = 'BASIS';
    BCIfiles{ii} = 'BASIS';
end
CL_filenames     = {GKLfiles,BCOfiles,GROfiles,SOSfiles,REVfiles,OBWfiles,BCIfiles};
ITHK_io_writeCLR(CLRfileName, time, phaseunit, timesteps, output_step, CL_filenames);

%% write a batch file
batchfileName='computeClrIT.bat';

fid = fopen([S.settings.outputdir batchfileName],'wt');
fprintf(fid,'%s %s\n','call clrun',[S.userinput.name,'.CLR']);
fclose(fid);

%% Save filenames to be transfered to output dir
for ii=1:length(S.userinput.phases)
    GKLfiles{ii} = 'BASIS.GKL';
    BCOfiles{ii} = 'BASIS.BCO';
    GROfiles{ii} = S.userinput.phase(ii).GROfile;
    SOSfiles{ii} = S.userinput.phase(ii).SOSfile;
    REVfiles{ii} = S.userinput.phase(ii).REVfile;
    OBWfiles{ii} = 'BASIS.OBW';
    BCIfiles{ii} = 'BASIS.BCI';
end
CL_fullfilenames = {GKLfiles,BCOfiles,GROfiles,SOSfiles,REVfiles,OBWfiles,BCIfiles};
for ii=1:length(CL_fullfilenames)
    S.PP.output.CL_fullfilenames{ii} = unique(CL_fullfilenames{ii});
end