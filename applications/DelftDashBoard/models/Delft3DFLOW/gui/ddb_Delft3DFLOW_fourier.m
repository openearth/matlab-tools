function ddb_Delft3DFLOW_fourier(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    handles=getHandles;
    handles.Model(md).Input(ad).fourier.parameterList={'wl','uv','qf'};
    
    tt=t_getconsts;
    handles.Model(md).Input(ad).fourier.astronomicalComponents=[];
    for i=1:size(tt.name,1)
        handles.Model(md).Input(ad).fourier.astronomicalComponents{i}=deblank(tt.name(i,:));
    end
    
    setHandles(handles);
    setUIElements('delft3dflow.output.outputpanel.fourier');
else
    handles=getHandles;
    opt=varargin{1};
    switch(lower(opt))
        case{'changetable1'}
            disp('Okay1')
        case{'changetable2'}
            disp('Okay2')
        case{'generateinput'}
            
            spinuptime=0.5;

            tt=t_getconsts;
            names=tt.name;
            freqs=tt.freq;
            
            for i=1:size(names,1)
                cnsts{i}=deblank(names(i,:));
            end

            for j=1:length(handles.Model(md).Input(ad).fourier.componentNumber)
                
                
                
                % Find index of component
                %ii=strmatch(lower(cnst{j}),lower(cnsts),'exact');
                ii=handles.Model(md).Input(ad).fourier.componentNumber(j);
                
                freq=freqs(ii);
                [v,u,f]=t_vuf(handles.Model(md).Input(ad).startTime,ii,32);
                
                period=1/freq/24;
                
                ttot=handles.Model(md).Input(ad).stopTime-handles.Model(md).Input(ad).startTime-spinuptime;
                
                ncyc=floor(ttot/period);
                dt=handles.Model(md).Input(ad).timeStep;
                ttot=ncyc*period;
                ntimesteps=round(1440*ttot/dt);
                tstart=handles.Model(md).Input(ad).stopTime-ntimesteps*dt/1440;
                tstop=handles.Model(md).Input(ad).stopTime;
                
                handles.Model(md).Input(ad).fourier.startTime(j)=tstart;
                handles.Model(md).Input(ad).fourier.stopTime(j)=tstop;
                handles.Model(md).Input(ad).fourier.nrCycles(j)=ncyc;
                handles.Model(md).Input(ad).fourier.nodalAmplificationFactor(j)=f;
                handles.Model(md).Input(ad).fourier.astronomicalArgument(j)=u;
                
            end
            
            setHandles(handles);
            
            setUIElements('delft3dflow.output.outputpanel.fourier');            
            
    end
end
