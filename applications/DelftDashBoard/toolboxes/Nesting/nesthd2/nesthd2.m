function Flow=nesthd2(Flow,outdir,hisfile,nestadm,z0,stride,opt)

%Flow.InputDir=inpdir;
% Flow.OutputDir=outdir;
%Flow.Runid=runid1;
%Flow=readInput(Flow);
Flow.DataFile=hisfile;
s=readnestadmin(nestadm);

disp('Reading data overall model ...');
%nest=getnestseries(Flow,s,stride,opt);
nest=getNestSeries(hisfile,t0,t1,stride,s,opt);

switch lower(opt)
    case{'hydro','both'}
        disp('Generating hydrodynamic boundary conditions ...');
        Flow=nesthd2_hydro(Flow,s,nest,z0);
%        disp('Saving bct file');
%        SaveBctFile(Flow);
end

switch lower(opt)
    case{'transport','both'}
        disp('Generating transport boundary conditions ...');
        Flow=nesthd2_transport(Flow,s,nest);
%        disp('Saving bcc file');
%        SaveBccFile(Flow);
end
