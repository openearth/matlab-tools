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
%OUTPUT:


function [tgen,version,tim_ver,source]=D3D_version(simdef,varargin)

tgen=NaT;
version='';
tim_ver=NaT;
source='';

[fpath_dia,structure]=D3D_simdef_2_dia(simdef);

switch structure
    case 1
        % *** Deltares, FLOW2D3D Version 6.04.01.141160M, May 17 2022, 10:52:54
        [kl_ver,fline_ver]=D3D_search_dia(fpath_dia,'*** Deltares, flow2d3d  ',1);
        if isnan(kl_ver)
           [kl_ver,fline_ver]=D3D_search_dia(fpath_dia,'*** Deltares, FLOW2D3D Version',1); 
        end
        if ~isnan(kl_ver)
            tok=regexp(fline_ver{end},',','split');
            str_tim=cat(2,tok{1,3},tok{1,4});
            tim_ver=datetime(str_tim,'InputFormat','MMM d yyyy HH:mm:ss');
            version=strrep(tok{1,2},' FLOW2D3D Version ', '');

            % ***           built from : <source>
            [~,fline_source]=D3D_search_dia(fpath_dia,'***           built from : ',kl_ver(end));
            if ~isempty(fline_source)
                source=strrep(fline_source{1},'***           built from : ', '');
            end

            % ***           date,time  : yyyy-mm-dd, HH:MM:SS
            [~,fline_tgen]=D3D_search_dia(fpath_dia,'***           date,time  :',kl_ver(end));
            if ~isempty(fline_tgen)
                tok=regexp(fline_tgen{1},'***           date,time  : (\d{4})-(\d{2})-(\d{2}), (\d{2}):(\d{2}):(\d{2})','tokens');
                if ~isempty(tok)
                    tok_num=str2double(tok{1,1});
                    tgen=datetime(tok_num(1),tok_num(2),tok_num(3),tok_num(4),tok_num(5),tok_num(6));
                end
            end
        end

    case 2
        % # Generated on 10:34:36, 01-04-2022
        [kl_gen,fline_gen]=D3D_search_dia(fpath_dia,'# Generated on ',1);
        if ~isnan(kl_gen)
            tok=regexp(fline_gen{1},'# Generated on (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
            if ~isempty(tok)
                tok_num=str2double(tok{1,1});
                tgen=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
            end

            % Source line for boundary and extraction
            [kl_source,fline_source]=D3D_search_dia(fpath_dia,'# Source:',kl_gen(1));

            % Version line (SVN/GIT variants)
            [~,fline_ver]=D3D_search_dia(fpath_dia,'# Deltares',kl_gen(1));
            if isempty(fline_ver)
                [kl_ver,fline_ver]=D3D_search_dia(fpath_dia,'# ',kl_gen(1));
                if ~isnan(kl_ver)
                    if ~isnan(kl_source)
                        iok=find(kl_ver < kl_source(1),1,'first');
                    else
                        iok=1;
                    end
                    if ~isempty(iok)
                        fline_ver={fline_ver{iok}};
                    else
                        fline_ver={};
                    end
                end
            end
            if ~isempty(fline_ver)
                tok=regexp(fline_ver{1},',','split');
                if numel(tok)==1
                    % GIT
                    version=strtrim(strrep(tok{1,1},'#',''));
                    tim_ver=NaT;
                else
                    % SVN
                    version=strrep(tok{1,2},' D-Flow FM Version ', '');
                    str_tim=strcat(tok{1,3},tok{1,4});
                    tim_ver=datetime(str_tim,'InputFormat','MMM d yyyy HH:mm:ss');
                end
            end

            % # Source:https://...
            if ~isempty(fline_source)
                source=strrep(fline_source{1},'# Source:','');
            end
        end
end

end %function

%%
% tok_tim=regexp(str_tim,'(\w{3}) (\d{2}) (\d{4}) (\d{2}):(\d{2}):(\d{2})','tokens');
%             month_num=month(datetime(tok_tim{1,1}{1,1},'InputFormat','MMM'));
%             tok_num=str2double(tok_tim{1,1});
%             tgen=datetime(tok_num(3),month_num,tok_num(2),tok_num(4),tok_num(5),tok_num(6));