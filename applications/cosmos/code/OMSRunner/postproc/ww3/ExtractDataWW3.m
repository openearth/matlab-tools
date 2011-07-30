function ExtractDataWW3(hm,m)

model=hm.models(m);

%% Maps

% tout=model.tWaveStart;
% 
% nt=(model.tStop-tout)*24+1;
% 
outdir=[model.dir 'lastrun' filesep 'output' filesep];
% 
% fid=fopen([model.dir 'lastrun' filesep 'output' filesep 'gx_outf.inp'],'wt');
% fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
% fprintf(fid,'%s\n','$ WAVEWATCH III Grid output post-processing ( GrADS )                  $');
% fprintf(fid,'%s\n','$--------------------------------------------------------------------- $');
% fprintf(fid,'%s\n','$ Time, time increment and number of outputs.');
% fprintf(fid,'%s\n','$');
% fprintf(fid,'%s\n',['  ' datestr(tout,'yyyymmdd') ' ' datestr(tout,'HHMMSS') '   3600. ' num2str(nt)]);
% fprintf(fid,'%s\n','$');
% fprintf(fid,'%s\n','$ Request flags identifying fields as in ww3_shel input and');
% fprintf(fid,'%s\n','$ section 2.4 of the manual.');
% fprintf(fid,'%s\n','$');
% fprintf(fid,'%s\n','  F F T F F  T F F F F  T T F F F  F F F');
% fprintf(fid,'%s\n','$');
% fprintf(fid,'%s\n','$ Grid range in discrete counters IXmin,max, IYmin,max');
% fprintf(fid,'%s\n','$');
% fprintf(fid,'%s\n','  0 999 0 999');
% fprintf(fid,'%s\n','$');
% fprintf(fid,'%s\n','$ NOTE : In the Cartesian grid version of the code, X and Y are');
% fprintf(fid,'%s\n','$        converted to longitude and latitude assuming that 1 degree');
% fprintf(fid,'%s\n','$        equals 100 km if th maximum of X or Y is larger than 1000km.');
% fprintf(fid,'%s\n','$        For maxima between 100 and 1000km 1 degree is assumed to be');
% fprintf(fid,'%s\n','$        10km etc. Adjust labels in GrADS scripts accordingly.');
% fprintf(fid,'%s\n','$');
% fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
% fprintf(fid,'%s\n','$ End of input file                                                    $');
% fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
% fclose(fid);
% 
curdir=pwd;
% 
% [status,message,messageid]=copyfile([hm.exeDir 'gx_outf.exe'],outdir,'f');
% 
% cd(outdir);
% 
% system('gx_outf.exe');
% delete('gx_outf.exe');
% delete('gx_outf.inp');
% 
% cd(curdir);

[status,message,messageid]=copyfile([outdir 'ww3.ctl'],curdir,'f');
[status,message,messageid]=copyfile([outdir 'ww3.grads'],curdir,'f');

ExtractGrads(hm,m);

par='windvel';
ii=strmatch(model.useMeteo,hm.meteoNames,'exact');
dt=hm.meteo(ii).timeStep;
data = extractMeteoData([hm.scenarioDir 'meteo' filesep model.useMeteo filesep],model,dt,par);
times = data.Time;
s=[];
s.Parameter=par;
s.X=data.X;
s.Y=data.Y;

ifirst=find(times==hm.cycle);

if ~isempty(ifirst)
    s.Time=times(ifirst:end);
else
    s.Time=times;
end

fout=[model.archiveDir hm.cycStr filesep 'maps' filesep par '.mat'];

if ndims(data.XComp)==3
    s.U=data.XComp(ifirst:end,:,:);
    s.V=data.YComp(ifirst:end,:,:);
else
    s.U=data.XComp;
    s.V=data.YComp;
end
%                s.mag=sqrt(s.U.^2+s.V.^2);
%                save(fout,'-struct','s','Parameter','Time','X','Y','U','V','Mag');
save(fout,'-struct','s','Parameter','Time','X','Y','U','V');

delete('ww3.ctl');
delete('ww3.grads');

%% Time Series

if model.nrStations>0

%     outdir=[model.dir 'lastrun' filesep 'output' filesep];
%     [status,message,messageid]=copyfile([hm.exeDir 'ww3_outp.exe'],outdir,'f');
%     outtime=model.tWaveStart;
% 
%     nt=(model.tStop-outtime)*24+1;
%     ip=1:model.nrStations;
%     WriteWW3Outp([outdir 'ww3_outp.inp'],ip,outtime,3600,nt,2);
%     curdir=pwd;
%     cd(outdir);
%     system('ww3_outp.exe');
%     cd(curdir);
%     delete([outdir 'ww3_outp.exe']);
%     delete([outdir 'ww3_outp.inp']);
    [t,hs,tp,wavdir]=ReadTab33(hm,m,[outdir 'tab33.ww3']);
    
    archdir=[model.archiveDir 'appended' filesep 'timeseries' filesep];

    tstart=model.tWaveOkay;

    for i=1:model.nrStations

        st=model.stations(i).name;

        % Hs
        fname=[archdir 'hs.' st '.mat'];

        s.Time=[];
        s.Val=[];
        if exist(fname,'file')
            s=load(fname);
%            n1=find(s.time<model.tOutputStart);
            n1=find(s.Time<tstart);
            if ~isempty(n1)
                n1=n1(end);
                s.Time=s.time(1:n1);
                s.Val=s.Val(1:n1);
            else
                s.Time=[];
                s.Val=[];
            end
        end
        
        s2.Val=hs(:,i);
        s2.Time=t;

%        n2=find(s2.time>=model.tOutputStart);
        n2=find(s2.Time>=tstart);
        n2=n2(1)+1;

        s2.Time=s2.Time(n2:end);
        s2.Val=s2.Val(n2:end);

        s.Time=[s.Time;s2.Time];
        s.Val=[s.Val;s2.Val];
        
        s.Parameter='hs';
        fname=[archdir 'hs.' st '.mat'];
        save(fname,'-struct','s','Parameter','Time','Val');

        s3.Parameter='hs';
        s3.Val=hs(:,i);
        s3.Time=t;
        fname=[model.archiveDir hm.cycStr filesep 'timeseries' filesep 'hs.' st '.mat'];
        save(fname,'-struct','s3','Parameter','Time','Val');
        
        % Tp
        fname=[archdir 'tp.' st '.mat'];

        s.Time=[];
        s.Val=[];
        if exist(fname,'file')
            s=load(fname);
            n1=find(s.Time<model.tOutputStart);
            if ~isempty(n1)
                n1=n1(end);
                s.Time=s.time(1:n1);
                s.Val=s.Val(1:n1);
            else
                s.Time=[];
                s.Val=[];
            end
        end

        % wave heights
        s2.Val=tp(:,i);
        s2.Time=t;
        
        n2=find(s2.Time>=model.tOutputStart);
        n2=n2(1)+1;
        
        s2.Time=s2.Time(n2:end);
        s2.Val=s2.Val(n2:end);

        s.Time=[s.Time;s2.Time];
        s.Val=[s.Val;s2.Val];

        s.Parameter='tp';
        fname=[archdir 'tp.' st '.mat'];
        save(fname,'-struct','s','Parameter','Time','Val');

        s3.Parameter='tp';
        s3.Val=tp(:,i);
        s3.Time=t;
        fname=[model.archiveDir hm.cycStr filesep 'timeseries' filesep 'tp.' st '.mat'];
        save(fname,'-struct','s3','Parameter','Time','Val');
        
    end

end


