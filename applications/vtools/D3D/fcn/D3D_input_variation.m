%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%This function has the input of the variation

function [input_m,vari_tag]=D3D_input_variation(path_runs_folder,paths_input_folder,path_input_folder_refmdf,F_inp)%,path_ref_mor,path_ref_sed)

path_input_folder_refmdf=strrep(path_input_folder_refmdf,'\','/');
if ~isempty(path_input_folder_refmdf) && path_input_folder_refmdf(end)~='/'
    path_input_folder_refmdf(end+1)='/';
end

%%

input_m=struct();

%% colums

[fn,allvari,variation_str]=F_inp(path_input_folder_refmdf);

%% ADD TO MATRIX

nsim=size(allvari,1);
nf=numel(fn);
sim_0=1;

for ksim=1:nsim
    
    for kf=1:nf
        input_m(ksim).(fn{kf})=allvari(ksim,kf);
        if ~isempty(variation_str{kf})
            if iscell(variation_str{kf})
                if numel(variation_str{kf}(input_m(ksim).(fn{kf})))>1
                    error('The input is cell but there is more than one element.')
                end
                input_m(ksim).(fn{kf})=variation_str{kf}{input_m(ksim).(fn{kf})};
            else
                input_m(ksim).(fn{kf})=variation_str{kf}(input_m(ksim).(fn{kf}));
            end
        end
    end
    
    %% RUN INFO
    
    %adhoc which to run
    dorun=1;
%     if bol_get(ksim)==0
%         dorun=0;
%     end
%     if input_m.sim(ksim).MorFac<2
%         dorun=0;
%     end

    sim_num=sim_0+ksim-1;
    
    input_m(ksim).dorun=dorun;
    
    sim_id=sprintf('r%03d',sim_num);
    
    input_m(ksim).runid__num=sim_num;
    input_m(ksim).runid__name=sim_id;
    
    input_m(ksim).D3D__dire_sim=fullfile(path_runs_folder,sim_id);
    
end

end %function 

%%
%% FUNCTIONS
%%

