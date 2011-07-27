function [hm,WaitingList]=cosmos_updateWaitingList(hm)

j=0;

for i=1:hm.NrModels
    if strcmpi(hm.Models(i).Status,'waiting') && hm.Models(i).Priority>0 && hm.Models(i).Run
        if ~hm.Models(i).FlowNested && ~hm.Models(i).WaveNested
            j=j+1;
            tmplist(j)=i;
            priority(j)=hm.Models(i).Priority;
        else
            if hm.Models(i).FlowNested
                mmf=hm.Models(i).FlowNestModelNr;
                statf=hm.Models(mmf).Status;
            else
                statf='finished';
            end
            if hm.Models(i).WaveNested
                mmw=hm.Models(i).WaveNestModelNr;
                statw=hm.Models(mmw).Status;
            else
                statw='finished';
            end
            if strcmpi(statf,'finished') && strcmpi(statw,'finished')
                j=j+1;
                tmplist(j)=i;
                priority(j)=hm.Models(i).Priority;
            end
            if strcmpi(statf,'failed') || strcmpi(statw,'failed')
                hm.Models(i).Status='failed';
            end
        end
    end
end

if j>0
    [y,ii]=sort(priority,'descend');
    WaitingList=tmplist(ii);
else
    WaitingList=[];
end
