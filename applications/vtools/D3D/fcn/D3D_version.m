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

[fpath_dia,structure]=D3D_simdef_2_dia(simdef);

fid=fopen(fpath_dia,'r');
while ~feof(fid)
    
    switch structure
        case 1
            error('do')
        case 2
            % # Generated on 10:34:36, 01-04-2022
            % # Deltares, D-Flow FM Version 1.2.136.140489, Dec 13 2021, 09:36:38
            % # Source:https://svn.oss.deltares.nl/repos/delft3d/branches/releases/140261/
            fline=fgetl(fid);
            tok=regexp(fline,'# Generated on (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
            if ~isempty(tok)
                tok_num=str2double(tok{1,1});
                tgen=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
                
                fline=fgetl(fid);
                tok=regexp(fline,',','split');
                version=strrep(tok{1,2},' D-Flow FM Version ','');
                str_tim=strcat(tok{1,3},tok{1,4});
                tim_ver=datetime(str_tim,'InputFormat','MMM d yyyy HH:mm:ss');
                
                fline=fgetl(fid);
                source=strrep(fline,'# Source:','');
                break
            end
    end

end %while

fclose(fid);

end %function
