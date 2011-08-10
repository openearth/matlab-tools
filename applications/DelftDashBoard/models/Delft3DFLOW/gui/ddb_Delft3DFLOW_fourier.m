function ddb_Delft3DFLOW_fourier(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    handles=getHandles;
    
    handles.Model(md).Input(ad).fourier.parameterList={'water level','velocity','discharge'};
    handles.Model(md).Input(ad).fourier.pList={'wl','uv','qf'};
    k=3;
    for i=1:handles.Model(md).Input(ad).salinity.include
        k=k+1;
        handles.Model(md).Input(ad).fourier.parameterList{k}='salinity';
        handles.Model(md).Input(ad).fourier.pList{k}='cs';
    end
    for i=1:handles.Model(md).Input(ad).temperature.include
        k=k+1;
        handles.Model(md).Input(ad).fourier.parameterList{k}='temperature';
        handles.Model(md).Input(ad).fourier.pList{k}='ct';
    end
    ncon=0;
    for i=1:handles.Model(md).Input(ad).nrTracers
        k=k+1;
        ncon=ncon+1;
        handles.Model(md).Input(ad).fourier.parameterList{k}=handles.Model(md).Input(ad).tracer(i).name;
        handles.Model(md).Input(ad).fourier.pList{k}=['c' num2str(ncon)];
    end
    for i=1:handles.Model(md).Input(ad).nrSediments
        k=k+1;
        ncon=ncon+1;
        handles.Model(md).Input(ad).fourier.parameterList{k}=handles.Model(md).Input(ad).sediment(i).name;
        handles.Model(md).Input(ad).fourier.pList{k}=['c' num2str(ncon)];
    end
    
    for k=1:handles.Model(md).Input(ad).KMax
        handles.Model(md).Input(ad).fourier.layerList{k}=num2str(k);
    end
        
    setHandles(handles);
    setUIElements('delft3dflow.output.outputpanel.fourier');
    
    
%     enab=ones(length(handles.Model(md).Input(ad).fourier.editTable.startTime),10);
%     for i=1:length(handles.Model(md).Input(ad).fourier.editTable.startTime)
%         if handles.Model(md).Input(ad).fourier.editTable.nrCycles(i)==0
%             enab(i,10)=0;
%         else
%             enab(i,8:9)=0;
%         end
%     end
%     h=findobj(gcf,'Tag','delft3dflow.output.outputpanel.fourier.fouriertable1');
%     table(h,'refresh','enable',enab);

%     enab=ones(length(handles.Model(md).Input(ad).fourier.generateTable.parameterNumber),6);
%     for i=1:length(handles.Model(md).Input(ad).fourier.generateTable.parameterNumber)
%         if handles.Model(md).Input(ad).fourier.generateTable.componentNumber(i)==1
%             % A0
%             enab(i,6)=0;
%         else
%             enab(i,4:5)=0;
%         end
%     end
%     h=findobj(gcf,'Tag','delft3dflow.output.outputpanel.fourier.fouriertable2');
%     table(h,'refresh','enable',enab);
   
else
    handles=getHandles;
    opt=varargin{1};
    switch(lower(opt))
        case{'changetable1'}
%             enab=ones(length(handles.Model(md).Input(ad).fourier.editTable.startTime),10);
%             for i=1:length(handles.Model(md).Input(ad).fourier.editTable.startTime)
%                 if handles.Model(md).Input(ad).fourier.editTable.nrCycles(i)==0
%                     enab(i,10)=0;
%                 else
%                     enab(i,8:9)=0;
%                 end
%             end
%             setUIElements('delft3dflow.output.outputpanel.fourier');
%             h=findobj(gcf,'Tag','delft3dflow.output.outputpanel.fourier.fouriertable1');
%             table(h,'refresh','enable',enab);
        case{'changetable2'}
%             enab=ones(length(handles.Model(md).Input(ad).fourier.generateTable.parameterNumber),6);
%             for i=1:length(handles.Model(md).Input(ad).fourier.generateTable.parameterNumber)
%                 if handles.Model(md).Input(ad).fourier.generateTable.componentNumber(i)==1
%                     % A0
%                     enab(i,6)=0;
%                 else
%                     enab(i,4:5)=0;
%                 end
%             end
%             setUIElements('delft3dflow.output.outputpanel.fourier');
%             h=findobj(gcf,'Tag','delft3dflow.output.outputpanel.fourier.fouriertable2');
%             table(h,'refresh','enable',enab);

        case{'maketable'}
            
            components={'M2','S2','N2','K2','K1','O1','P1','Q1'};
            
            handles.Model(md).Input(ad).fourier.generateTable.parameterNumber=[];
            handles.Model(md).Input(ad).fourier.generateTable.componentNumber=[];
            handles.Model(md).Input(ad).fourier.generateTable.layer=[];
            handles.Model(md).Input(ad).fourier.generateTable.fourier=[];
            handles.Model(md).Input(ad).fourier.generateTable.max=[];
            handles.Model(md).Input(ad).fourier.generateTable.min=[];
            handles.Model(md).Input(ad).fourier.generateTable.ellipse=[];
            
            tt=t_getconsts;
            names=tt.name;
            
            for i=1:size(names,1)
                cnsts{i}=deblank(names(i,:));
            end

            for i=1:length(components)                
                ii=strmatch(components{i},cnsts,'exact');
                handles.Model(md).Input(ad).fourier.generateTable.parameterNumber(i)=1;
                handles.Model(md).Input(ad).fourier.generateTable.componentNumber(i)=ii;
                handles.Model(md).Input(ad).fourier.generateTable.layer(i)=1;
                handles.Model(md).Input(ad).fourier.generateTable.fourier(i)=1;
                handles.Model(md).Input(ad).fourier.generateTable.max(i)=0;
                handles.Model(md).Input(ad).fourier.generateTable.min(i)=0;
                handles.Model(md).Input(ad).fourier.generateTable.ellipse(i)=0;
            end
            
            setHandles(handles);
            
            setUIElements('delft3dflow.output.outputpanel.fourier');

        case{'generateinput'}
            
            % Compute mean latitude of model
            xm=nanmean(nanmean(handles.Model(md).Input(ad).gridX));
            ym=nanmean(nanmean(handles.Model(md).Input(ad).gridY));
            cs.name='WGS 84';
            cs.type='Geographic';
            [xm,ym]=ddb_coordConvert(xm,ym,handles.screenParameters.coordinateSystem,cs);

            spinuptime=handles.Model(md).Input(ad).fourier.spinUpTime/1440;

            tt=t_getconsts;
            names=tt.name;
            freqs=tt.freq;
            
            for i=1:size(names,1)
                cnsts{i}=deblank(names(i,:));
            end

            handles.Model(md).Input(ad).fourier.editTable=[];

            k=0;
            
            for j=1:length(handles.Model(md).Input(ad).fourier.generateTable.componentNumber)
                
                % Find index of component
                ii=handles.Model(md).Input(ad).fourier.generateTable.componentNumber(j);
                
                freq=freqs(ii);

                % Compute argument based on argument at reference time and correction of the mean model time 
                [v,u,f]=t_vuf(0.5*(handles.Model(md).Input(ad).startTime+handles.Model(md).Input(ad).stopTime),ii,ym);
                [vref,uref,fref]=t_vuf(handles.Model(md).Input(ad).itDate,ii,ym);
                u=(vref+u)*360;
                u=mod(u,360);
                
                ttot=handles.Model(md).Input(ad).stopTime-handles.Model(md).Input(ad).startTime-spinuptime;
                
                if freq==0
                    period=ttot;
                else
                    period=1/freq/24;
                end
                
                ncyc=floor(ttot/period);
                dt=handles.Model(md).Input(ad).timeStep;
                ttot=ncyc*period;
                ntimesteps=round(1440*ttot/dt);
                tstart=handles.Model(md).Input(ad).stopTime-ntimesteps*dt/1440;
                tstop=handles.Model(md).Input(ad).stopTime;
                               
                nopt=0;
                optNr=[];
                if handles.Model(md).Input(ad).fourier.generateTable.fourier(j)
                    nopt=nopt+1;
                    optNr(nopt)=1;
                end
                if handles.Model(md).Input(ad).fourier.generateTable.max(j)
                    nopt=nopt+1;
                    optNr(nopt)=2;
                end
                if handles.Model(md).Input(ad).fourier.generateTable.min(j)
                    nopt=nopt+1;
                    optNr(nopt)=3;
                end
                if handles.Model(md).Input(ad).fourier.generateTable.ellipse(j)
                    nopt=nopt+1;
                    optNr(nopt)=4;
                end
                
                for n=1:nopt
                    k=k+1;
                    handles.Model(md).Input(ad).fourier.editTable.parameterNumber(k)=handles.Model(md).Input(ad).fourier.generateTable.parameterNumber(j);
                    handles.Model(md).Input(ad).fourier.editTable.period(k)=period;
                    handles.Model(md).Input(ad).fourier.editTable.startTime(k)=tstart;
                    handles.Model(md).Input(ad).fourier.editTable.startTime(k)=tstart;
                    handles.Model(md).Input(ad).fourier.editTable.stopTime(k)=tstop;
                    handles.Model(md).Input(ad).fourier.editTable.nrCycles(k)=ncyc;
                    handles.Model(md).Input(ad).fourier.editTable.nodalAmplificationFactor(k)=f;
                    handles.Model(md).Input(ad).fourier.editTable.astronomicalArgument(k)=u;
                    handles.Model(md).Input(ad).fourier.editTable.layer(k)=handles.Model(md).Input(ad).fourier.generateTable.layer(j);
                    handles.Model(md).Input(ad).fourier.editTable.option(k)=optNr(n);
                end
            end
            
            setHandles(handles);
            
            setUIElements('delft3dflow.output.outputpanel.fourier');            

        case{'savefoufile'}
            ddb_saveFouFile(handles,ad);
            
        case{'openfoufile'}
            
%            ddb_readFouFile(handles,id);
            
    end
end
