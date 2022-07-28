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


function [tim_dur,t0,tf]=D3D_computation_time(simdef,varargin)

[fpath_dia,structure]=D3D_simdef_2_dia(simdef);

fid=fopen(fpath_dia,'r');
kl=0;
while ~feof(fid)
    
    fline=fgetl(fid);
    kl=kl+1;
    switch structure
        case 1
            % ***           date,time  : 2022-07-27, 16:41:07
            
            tok=regexp(fline,'***           date,time  : (\d{4})-(\d{2})-(\d{2}), (\d{2}):(\d{2}):(\d{2})','tokens');
            if ~isempty(tok)
                %t0
                tok_num=str2double(tok{1,1});
                t0=datetime(tok_num(1),tok_num(2),tok_num(3),tok_num(4),tok_num(5),tok_num(6));
                %tf
                [~,fline]=search_text_ascii(fpath_dia,'***           date,time  :',kl);
                tok=regexp(fline,'***           date,time  : (\d{4})-(\d{2})-(\d{2}), (\d{2}):(\d{2}):(\d{2})','tokens');
                tok_num=str2double(tok{1,1});
                tf=datetime(tok_num(1),tok_num(2),tok_num(3),tok_num(4),tok_num(5),tok_num(6));
                %duration
                tim_dur=tf-t0;
            end
        case 2
            % ** INFO   : Computation started  at: 10:34:36, 01-04-2022
            % ** INFO   : Computation finished at: 23:51:49, 01-04-2022    
            
            tok=regexp(fline,'** INFO   : Computation started  at: (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
            if ~isempty(tok)
                %t0
                tok_num=str2double(tok{1,1});
                t0=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
                %tf
                fline=fgetl(fid);
                tok=regexp(fline,'** INFO   : Computation finished at: (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
                tok_num=str2double(tok{1,1});
                tf=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
                %duration
                tim_dur=tf-t0;
                break
            end
%             kl=search_text_ascii(simdef.file.dia,'** INFO   : Computation finished at:',1);
    end

end %while

fclose(fid);

end %function