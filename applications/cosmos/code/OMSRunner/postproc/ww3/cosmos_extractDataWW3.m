function cosmos_extractDataWW3(hm,m)

model=hm.models(m);

%% Maps

outdir=[model.dir 'lastrun' filesep 'output' filesep];

curdir=pwd;

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

save(fout,'-struct','s','Parameter','Time','X','Y','U','V');

delete('ww3.ctl');
delete('ww3.grads');

%% Time Series

if model.nrStations>0
    
    [t,hs,tp,wavdir]=ReadTab33(hm,m,[outdir 'tab33.ww3']);
    
    archdir=[model.archiveDir 'appended' filesep 'timeseries' filesep];
    
    tstart=model.tWaveOkay;
    
    for istat=1:model.nrStations

        st=model.stations(istat).name;

        for i=1:model.stations(istat).nrDatasets
                        
            % Hs
            fname=[archdir 'hs.' st '.mat'];
            
            s.Time=[];
            s.Val=[];
            if exist(fname,'file')
                s=load(fname);
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
end


