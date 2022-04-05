%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17937 $
%$Date: 2022-04-05 13:43:41 +0200 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_is_done.m 17937 2022-04-05 11:43:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_is_done.m $
%
%OUTPUT:


function [tim_dur,t0,tf]=D3D_computation_time(simdef,varargin)

[fpath_dia,structure]=D3D_simdef_2_dia(simdef);

fid=fopen(fpath_dia,'r');
while ~feof(fid)
    
    switch structure
        case 1
            error('do')
        case 2
            % ** INFO   : Computation started  at: 10:34:36, 01-04-2022
            % ** INFO   : Computation finished at: 23:51:49, 01-04-2022    
            fline=fgetl(fid);
            tok=regexp(fline,'** INFO   : Computation started  at: (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
            if ~isempty(tok)
                tok_num=str2double(tok{1,1});
                t0=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
                fline=fgetl(fid);
                tok=regexp(fline,'** INFO   : Computation finished at: (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
                tok_num=str2double(tok{1,1});
                tf=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
                tim_dur=tf-t0;
                break
            end
%             kl=search_text_ascii(simdef.file.dia,'** INFO   : Computation finished at:',1);
    end

end %while

fclose(fid);

end %function