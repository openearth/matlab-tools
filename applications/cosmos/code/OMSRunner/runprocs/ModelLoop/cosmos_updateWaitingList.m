function [hm,WaitingList]=cosmos_updateWaitingList(hm)

j=0;

for i=1:hm.nrModels
    if strcmpi(hm.models(i).status,'waiting') && hm.models(i).priority>0 && hm.models(i).run
        if ~hm.models(i).flowNested && ~hm.models(i).waveNested
            j=j+1;
            tmplist(j)=i;
            priority(j)=hm.models(i).priority;
        else
            if hm.models(i).flowNested
                mmf=hm.models(i).flowNestModelNr;
                statf=hm.models(mmf).status;
            else
                statf='finished';
            end
            if hm.models(i).waveNested
                mmw=hm.models(i).waveNestModelNr;
                statw=hm.models(mmw).status;
            else
                statw='finished';
            end
            if strcmpi(statf,'finished') && strcmpi(statw,'finished')
                j=j+1;
                tmplist(j)=i;
                priority(j)=hm.models(i).priority;
            end
            if strcmpi(statf,'failed') || strcmpi(statw,'failed')
                hm.models(i).status='failed';
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
