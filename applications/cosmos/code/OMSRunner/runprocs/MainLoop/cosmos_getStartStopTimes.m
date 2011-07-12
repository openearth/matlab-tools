function hm=cosmos_getStartStopTimes(hm)

if strcmp(datestr(hm.Cycle,'mm-dd'),'01-01') == 1
    y=num2str(str2num(datestr(hm.Cycle,'yyyy'))-1);
else
    y=datestr(hm.Cycle,'yyyy');
end
hm.RefTime=datenum(['01/01/' y]);

for i=1:hm.NrModels
    t0(i)=hm.Cycle;
end


for i=1:hm.NrModels
    hm.Models(i).TFlowStart=t0(i)+hm.Models(i).StartTime/24;
    hm.Models(i).TOutputStart=hm.Cycle+hm.Models(i).StartTime/24;
    hm.Models(i).TWaveStart=t0(i)+hm.Models(i).StartTime/24;
    if hm.Models(i).RunTime==0
        hm.Models(i).RunTime=hm.RunTime*60;
    else
        hm.Models(i).RunTime=min(hm.Models(i).RunTime*60,hm.RunTime*60);
    end
    hm.Models(i).TStop=hm.Cycle+hm.Models(i).StartTime/24+hm.Models(i).RunTime/1440;
    hm.Models(i).RefTime=hm.RefTime;
    hm.Models(i).RstInterval=hm.RunInterval*60;
    hm.Models(i).FlowRstFile=[];
    hm.Models(i).WaveRstFile=[];
    hm.Models(i).TFlowOkay=t0(i);
    hm.Models(i).TWaveOkay=t0(i);
end

for i=1:hm.NrModels

    nf=hm.Models(i).NestedFlowModels;
    nw=hm.Models(i).NestedWaveModels;

    if isempty(nf) && isempty(nw)

        % No nesting in this model
        tfok=t0(i)+hm.Models(i).StartTime/24;
        twok=t0(i)+hm.Models(i).StartTime/24;
        nested=1;
        m=i;

        % Start climbing through model tree
        while nested
            
            if hm.Models(m).RunSimulation
               
                hm.Models(m).TOutputStart=t0(m);

                % WAVE
                wspinup=hm.Models(m).WaveSpinUp/24;
                hm.Models(m).TWaveStart=min(twok,hm.Models(m).TWaveStart);
                switch lower(hm.Models(m).Type)
                    case{'ww3'}
                        [rstw,rstfil]=cosmos_checkForRestartFile(hm,m,hm.Models(m).TWaveStart,wspinup,'ww3');
                    case{'delft3dflowwave'}
                        [rstw,rstfil]=cosmos_checkForRestartFile(hm,m,hm.Models(m).TWaveStart,wspinup,'delft3dwave');
                    otherwise
                        rstw=[];
                        rstfil=[];
                end

                if ~isempty(rstw)
                    % Restart from restart file
                    hm.Models(m).TWaveStart=rstw;
                    hm.Models(m).TWaveOkay=hm.Models(m).TWaveStart;
                else
%                    if hm.Models(m).TWaveStart+wspinup>twok
                        hm.Models(m).TWaveStart=min(twok-wspinup,hm.Models(m).TWaveStart);
%                    end
                    hm.Models(m).TWaveOkay=hm.Models(m).TWaveStart+wspinup;
                end
                hm.Models(m).WaveRstFile=rstfil;

                % FLOW
                fspinup=hm.Models(m).FlowSpinUp/24;
                hm.Models(m).TFlowStart=min(tfok,hm.Models(m).TFlowStart);
                % Flow always starts before wave
%                 tfstartnowaves=hm.Models(m).TFlowStart;
                hm.Models(m).TFlowStart=min(hm.Models(m).TWaveStart,hm.Models(m).TFlowStart);
                switch lower(hm.Models(m).Type)
                    case{'delft3dflowwave','delft3dflow'}
                        [rstf,rstfil]=cosmos_checkForRestartFile(hm,m,hm.Models(m).TFlowStart,fspinup,'delft3dflow');
                    otherwise
                        rstf=[];
                        rstfil=[];
                end
                if ~isempty(rstf)
                    % Restart from restart file
                    hm.Models(m).TFlowStart=rstf;
                    hm.Models(m).TFlowOkay=hm.Models(m).TFlowStart;
                else
%                    hm.Models(m).TFlowStart=max(hm.Models(m).TFlowStart,tfstartnowaves)-fspinup;
                    hm.Models(m).TFlowStart=min(tfok-fspinup,hm.Models(m).TFlowStart);
%                    hm.Models(m).TFlowStart=min(hm.Models(m).TWaveStart,hm.Models(m).TFlowStart);
                    hm.Models(m).TFlowOkay=hm.Models(m).TFlowStart+fspinup;
                end
                hm.Models(m).FlowRstFile=rstfil;

                tfok=hm.Models(m).TFlowStart;
                twok=hm.Models(m).TWaveStart;

            end

            nested=hm.Models(m).FlowNested || hm.Models(m).WaveNested;

            m0=m;
            
            if hm.Models(m0).FlowNested
                m=hm.Models(m0).FlowNestModelNr;
            end

            if hm.Models(m0).WaveNested
                m=hm.Models(m0).WaveNestModelNr;
            end

        end
    end

end

