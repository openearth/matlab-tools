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
%dimension 1 of <data.val> must be faces.

function data=gdm_order_dimensions(fid_log,data,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'structure',1);

parse(parin,varargin{:});

structure=parin.Results.structure;

%% CALC

if isfield(data,'dimensions') %read from EHY
    str_sim_c=strrep(data.dimensions,'[','');
    str_sim_c=strrep(str_sim_c,']','');
    tok=regexp(str_sim_c,',','split');
    idx_f=find_str_in_cell(tok,{'mesh2d_nFaces'});
    dim=1:1:numel(tok);
    dimnF=dim;
    dimnF(dimnF==idx_f)=[];
    if ~isempty(dimnF) 
        data.val=permute(data.val,[idx_f,dimnF]);
        %reconstruct dimensions vector
        str_order=tok([idx_f,dimnF]);
        str_aux=sprintf('%s,',str_order{:});
        str_aux=sprintf('[%s]',str_aux);
        str_aux=strrep(str_aux,',]',']');
        data.dimensions=str_aux;
    else
        %there is only <mesh2d_nFaces>
    end
else
    switch structure
        case {2,4}
            size_val=size(data.val);
            if size_val(1)==1 && size_val(2)>1
                data.val=data.val';
                messageOut(fid_log,'It seems faces are not in first dimension. I am permuting the vector.')
            end
        case {1,5}
            data.val=data.val(:);
    end
end


end %function