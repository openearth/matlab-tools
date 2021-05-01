%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function [tim_val,val,bol_g]=add_variable_to_plot(rmm_mea,tzone_plot,location_clear_token,grootheid_token,bemonsteringshoogte_token)
                
switch location_clear_token
    case 'sumQ HIJ 1'
        bol_gou=cell2mat(cellfun(@(X)strcmp(X,'Gouda'),{rmm_mea.location_clear},'UniformOutput',false));
        bol_wai=cell2mat(cellfun(@(X)strcmp(X,'Waaiersluis'),{rmm_mea.location_clear},'UniformOutput',false));
        bol_q  =cell2mat(cellfun(@(X)strcmp(X,'Q'),{rmm_mea.grootheid},'UniformOutput',false));
        bol_g=(bol_gou | bol_wai) & bol_q;
        [tim_val,val]=add_values(bol_g,rmm_mea,tzone_plot);
    case 'sumQ HIJ 2'
        bol_kgm=cell2mat(cellfun(@(X)contains(X,'KGM-'),{rmm_mea.location_clear},'UniformOutput',false));
        bol_mpn=cell2mat(cellfun(@(X)contains(X,'MPN-'),{rmm_mea.location_clear},'UniformOutput',false));
        bol_q  =cell2mat(cellfun(@(X)strcmp(X,'Q'),{rmm_mea.grootheid},'UniformOutput',false));
        bol_g=(bol_kgm|bol_mpn) & bol_q;
        [tim_val,val]=add_values(bol_g,rmm_mea,tzone_plot);
    otherwise
        
        [~,bol1]=find_str_in_cell({rmm_mea.location_clear},{location_clear_token});

        [~,bol2]=find_str_in_cell({rmm_mea.grootheid},{grootheid_token});

        bol3=true(size(bol1));
        if ~isnan(bemonsteringshoogte_token)
        bol3=[rmm_mea.bemonsteringshoogte]==bemonsteringshoogte_token;
        end

        bol_g=bol1 & bol2 & bol3;
        if any(bol_g)
            val=rmm_mea(bol_g).waarde;
            tim_val=rmm_mea(bol_g).time;
            tim_val.TimeZone=tzone_plot;
        else
            val=NaN;
            tim_val=NaN;
        end

end %switch

end %function

%%
%% FUNCTIONS
%%

function [tim_val,val]=add_values(bol_g,rmm_mea,tzone_plot)

idx_g=find(bol_g);
ng=sum(bol_g);
tt_all=cell(ng,1);
for kg=1:ng
    tim=rmm_mea(idx_g(kg)).time;
    tim.TimeZone=tzone_plot;
    val=rmm_mea(idx_g(kg)).waarde;

    data_tt=timetable(tim,val);
    tt_all{kg,1}=data_tt;
end
tt=synchronize(tt_all{:});
%         data_tt=rmmissing(data_tt);
%         data_tt=sortrows(data_tt);
%         tim_u=unique(data_tt.tim);
%         data_tt=retime(data_tt,tim_u,'mean'); 
data_tt=retime(tt,'regular','linear','TimeStep',minutes(5));
tim_val=data_tt.tim;
val=sum(data_tt.Variables,2);   

end