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

function gdm_movie_paths(fid_log,flg_loc,time_dnum_loc,fpath_file)

%% PARSE

flg_loc=isfield_default(flg_loc,'do_movie',0);

%% CALC

[nplot,nt,~,~]=size(fpath_file);
if flg_loc.do_movie && nt>1

    for kplot=1:nplot
        %Do not check on the first time. It is empty for diff_t. 
        fpath_t=fpath_file(kplot,:,1,1);
        bol_t=cellfun(@(X)~isempty(X),fpath_t);
        if any(bol_t)
            if sum(bol_t)==1
                messageOut(fid_log,'Cannot make a movie with only one time.')
                return
            end
            fpath_t_noempty=fpath_file(:,bol_t,:,:);    
            fpath_lim_1=squeeze(fpath_t_noempty(kplot,1,:,1)); %here the first time always exists
            bol_lim_1=cellfun(@(X)~isempty(X),fpath_lim_1);
            nlim_1=sum(bol_lim_1);
            for klim1=1:nlim_1
                fpath_lim_2=squeeze(fpath_t_noempty(kplot,1,klim1,:));
                bol_lim_2=cellfun(@(X)~isempty(X),fpath_lim_2);
                nlim_2=sum(bol_lim_2);
                for klim2=1:nlim_2
                    fpath_mov=fpath_t_noempty(kplot,:,klim1,klim2);
                    fpath_mov=reshape(fpath_mov,[],1);
                    gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum_loc);   
                end
            end
        end 
    end %kplot

end %movie

end %function