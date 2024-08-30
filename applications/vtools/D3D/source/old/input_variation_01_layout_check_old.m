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

function [input_m,vari_tag]=input_variation_01(path_runs_folder,paths_input_folder,path_input_folder_refmdf)%,path_ref_mor,path_ref_sed)

path_input_folder_refmdf=strrep(path_input_folder_refmdf,'\','/');
if ~isempty(path_input_folder_refmdf) && path_input_folder_refmdf(end)~='/'
    path_input_folder_refmdf(end+1)='/';
end

%%

input_m=struct();

%% colums

%same name as in <simdef> (with '__' where there is substructure). 
%Same order as in <allvari_add>.
fn={'nf','D3D__structure','tra__IFORM'}; 

%% initialize

allvari=[];

%% test 1

% variation_c{1}=[2]; 
% variation_c{2}=[1];
% variation_c{3}=[-4];
% 
% allvari=apply_variation(allvari,variation_c);

%% test all

% variation_c{1}=[0,16]; 
% variation_c{2}=[1,2];
% variation_c{3}=[-4,-3,1];
% 
% allvari=apply_variation(allvari,variation_c);

%% variation

variation_c{1}=[0,1,2,4,8,16]; 
variation_c{2}=[1,2];
variation_c{3}=[-4,-3,1];

allvari=apply_variation(allvari,variation_c);

%% repeat each of them 

allvari=repmat(allvari,5,1);

%% ADD TO MATRIX

nsim=size(allvari,1);
nf=numel(fn);
sim_0=1;

for ksim=1:nsim
    
    for kf=1:nf
        input_m(ksim).(fn{kf})=allvari(ksim,kf);
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

function allvari=apply_variation(allvari,variation_c)

allvari_add=allcomb(variation_c{:});
% allvari_add=allcomb(noise_seed_v,Tstop_v,MorFac_v,CFL_v);

allvari=cat(1,allvari,allvari_add);

end