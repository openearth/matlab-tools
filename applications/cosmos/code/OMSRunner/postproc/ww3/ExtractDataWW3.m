function ExtractDataWW3(hm,m)

Model=hm.Models(m);

%% Maps

% tout=Model.TWaveStart;
% 
% nt=(Model.TStop-tout)*24+1;
% 
outdir=[Model.Dir 'lastrun' filesep 'output' filesep];
% 
% fid=fopen([Model.Dir 'lastrun' filesep 'output' filesep 'gx_outf.inp'],'wt');
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
% [status,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'gx_outf.exe'],outdir,'f');
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
ii=strmatch(Model.UseMeteo,hm.MeteoNames,'exact');
dt=hm.Meteo(ii).TimeStep;
data = extractMeteoData([hm.ScenarioDir 'meteo' filesep Model.UseMeteo filesep],Model,dt,par);
times = data.Time;
s=[];
s.Parameter=par;
s.X=data.X;
s.Y=data.Y;

ifirst=find(times==hm.Cycle);

if ~isempty(ifirst)
    s.Time=times(ifirst:end);
else
    s.Time=times;
end

fout=[Model.ArchiveDir hm.CycStr filesep 'maps' filesep par '.mat'];

        if ndims(data.XComp)==3
            s.U=data.XComp(ifirst:end,:,:);
            s.V=data.YComp(ifirst:end,:,:);
        else
            s.U=data.XComp;
            s.V=data.YComp;
        end
        %                s.Mag=sqrt(s.U.^2+s.V.^2);
        %                save(fout,'-struct','s','Parameter','Time','X','Y','U','V','Mag');
        save(fout,'-struct','s','Parameter','Time','X','Y','U','V');


delete('ww3.ctl');
delete('ww3.grads');

%% Time Series

if Model.NrStations>0

%     outdir=[Model.Dir 'lastrun' filesep 'output' filesep];
%     [status,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'ww3_outp.exe'],outdir,'f');
%     outtime=Model.TWaveStart;
% 
%     nt=(Model.TStop-outtime)*24+1;
%     ip=1:Model.NrStations;
%     WriteWW3Outp([outdir 'ww3_outp.inp'],ip,outtime,3600,nt,2);
%     curdir=pwd;
%     cd(outdir);
%     system('ww3_outp.exe');
%     cd(curdir);
%     delete([outdir 'ww3_outp.exe']);
%     delete([outdir 'ww3_outp.inp']);
    [t,hs,tp,wavdir]=ReadTab33(hm,m,[outdir 'tab33.ww3']);
    
    archdir=[Model.ArchiveDir 'appended' filesep 'timeseries' filesep];

    tstart=Model.TWaveOkay;

    for i=1:Model.NrStations

        st=Model.Stations(i).Name;

        % Hs
        fname=[archdir 'hs.' st '.mat'];

        s.Time=[];
        s.Val=[];
        if exist(fname,'file')
            s=load(fname);
%            n1=find(s.Time<Model.TOutputStart);
            n1=find(s.Time<tstart);
            if ~isempty(n1)
                n1=n1(end);
                s.Time=s.Time(1:n1);
                s.Val=s.Val(1:n1);
            else
                s.Time=[];
                s.Val=[];
            end
        end
        
        s2.Val=hs(:,i);
        s2.Time=t;

%        n2=find(s2.Time>=Model.TOutputStart);
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
        fname=[Model.ArchiveDir hm.CycStr filesep 'timeseries' filesep 'hs.' st '.mat'];
        save(fname,'-struct','s3','Parameter','Time','Val');
        
        % Tp
        fname=[archdir 'tp.' st '.mat'];

        s.Time=[];
        s.Val=[];
        if exist(fname,'file')
            s=load(fname);
            n1=find(s.Time<Model.TOutputStart);
            if ~isempty(n1)
                n1=n1(end);
                s.Time=s.Time(1:n1);
                s.Val=s.Val(1:n1);
            else
                s.Time=[];
                s.Val=[];
            end
        end

        % wave heights
        s2.Val=tp(:,i);
        s2.Time=t;
        
        n2=find(s2.Time>=Model.TOutputStart);
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
        fname=[Model.ArchiveDir hm.CycStr filesep 'timeseries' filesep 'tp.' st '.mat'];
        save(fname,'-struct','s3','Parameter','Time','Val');
        
    end

end


