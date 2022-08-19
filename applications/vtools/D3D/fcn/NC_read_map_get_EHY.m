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

function val=NC_read_map_get_EHY(file_map,vartok,time_dnum,varargin)

OPT.varName=vartok;
if ~isempty(time_dnum)
    OPT.t0=time_dnum(1);
    OPT.tend=time_dnum(end);
end
OPT.disp=0;
OPT.bed_layers=0;
OPT.t=[];

OPT=setproperty(OPT,varargin{:});

map_data=EHY_getMapModelData(file_map,OPT);

% if numel(size(map_data.val))==2
%     val=map_data.val';
% else
%     val=map_data.val;
% end

data=gdm_order_dimensions(NaN,map_data); %put faces in first dimension
val=squeeze(data.val);


end