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
%read snapped features

function feature_struct=D3D_read_snapped(simdef,feature_tok,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'read_val',false);
addOptional(parin,'xy_only',false);

parse(parin,varargin{:});

read_val=parin.Results.read_val;
xy_only=parin.Results.xy_only;

%% CALC

if simdef.file.partitions==1
    tag_read=sprintf('(\\w*)_snapped_%s',feature_tok);
else
    tag_read=sprintf('(\\w*)_\\d{4}_snapped_%s',feature_tok);
end
tok=regexp(simdef.file.shp.(feature_tok){1,1},tag_read,'tokens'); %the amount of {} is causing trouble...
sim_name=tok{1,1}{1,1};
[ffolder_shp,~,fext_shp]=fileparts(simdef.file.shp.fxw);
npart=simdef.file.partitions;
if read_val
    feature_struct=struct('xy',[],'val',[]);
else
    feature_struct=struct('xy',[]);
end
for kpart=1:npart
    if simdef.file.partitions==1
        fname_shp=fullfile(ffolder_shp,sprintf('%s_snapped_%s%s',sim_name,feature_tok,fext_shp));
    else
        fname_shp=fullfile(ffolder_shp,sprintf('%s_%04d_snapped_%s%s',sim_name,kpart-1,feature_tok,fext_shp));
    end

    feature_struct_loc=D3D_io_input('read',fname_shp,'read_val',read_val,'xy_only',xy_only);
%     feature_struct.xy=cat(1,feature_struct.xy,feature_struct_loc.xy.XY);

    if xy_only
        feature_struct.xy=cat(1,feature_struct.xy,feature_struct_loc);
    else
        feature_struct.xy=cat(1,feature_struct.xy,feature_struct_loc.xy.XY);
    end
    messageOut(NaN,sprintf('file read %4.2f %% %s',kpart/npart*100,fname_shp))
end

% switch feature_tok
%     case 'fxw' %all have 4 numbers
%         cell2mat(feature_struct.xy)
% end

% fpath_shp=simdef.file.shp.fxw;
% npart=simdef.file.partitions;
% [fdir,fname,fext]=fileparts(fpath_shp);
% nmdf=numel(simdef.file.mdfid);
% %number is after mdf/u name. It is better not to use `regexp` or similar
% %because the mdf/u name may have a number. 
% idx_part=nmdf+2:nmdf+2+3; %fname(idx_part) %e.g.: '0003'
% shp_loc=[];
% for kpart=npart
%     fname_loc=fname;
%     fname_loc(idx_part)=sprintf('%04d',kpart-1);
%     fpath_loc=fullfile(fdir,sprintf('%s%s',fname_loc,fext));
%     shp_loc=cat(1,shp_loc,D3D_io_input('read',fpath_loc,'xy_only',1));
% end

end %function