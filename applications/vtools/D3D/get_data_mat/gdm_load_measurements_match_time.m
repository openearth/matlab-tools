%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%

function [plot_mea,data_mea]=gdm_load_measurements_match_time(flg_loc,time_dnum_plot,var_str_save,kpli,stat,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'type','t');

parse(parin,varargin{:});

results_type=parin.Results.type;

%%

flg_loc=isfield_default(flg_loc,'tol_time_measurements',30);
flg_loc=isfield_default(flg_loc,'do_rkm',0);

data_mea.x=[];
data_mea.y=[];
plot_mea=false;

if isfield(flg_loc,'measurements') && ~isempty(flg_loc.measurements) &&  ~isempty(flg_loc.measurements{kpli,1})
    sb_pol_loc=flg_loc.measurements(kpli,:);
    ispol=cellfun(@(X)~isempty(X),sb_pol_loc);
    npol=sum(ispol);
    for kpol=1:npol
        switch results_type
            case 't'
                data_mea(1,kpol)=gdm_load_measurements(NaN,flg_loc.measurements{kpli,kpol},'tim',time_dnum_plot,'var',var_str_save,'stat',stat,'tol',flg_loc.tol_time_measurements,'do_rkm',flg_loc.do_rkm);
            case 'x'
                data_mea(1,kpol)=gdm_load_measurements(NaN,flg_loc.measurements{kpli,kpol},'x',time_dnum_plot,'var',var_str_save,'stat',stat,'tol',flg_loc.tol_time_measurements,'do_rkm',flg_loc.do_rkm);
            otherwise
                error('Type can only be time or space.')
        end
        if ~isempty(data_mea(kpol).x)
            plot_mea=true;
        end
    end
end

end %function