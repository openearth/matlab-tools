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

function feature_struct=D3D_read_snapped(simdef,feature_tok,read_val)

tok=regexp(simdef.file.shp.(feature_tok),sprintf('(\\w*)_\\d{4}_snapped_%s',feature_tok),'tokens');
sim_name=tok{1,1}{1,1};
[ffolder_shp,~,fext_shp]=fileparts(simdef.file.shp.fxw);
npart=simdef.file.partitions;
if read_val
    feature_struct=struct('xy',[],'val',[]);
else
    feature_struct=struct('xy',[]);
end
for kpart=1:npart
    fname_shp=fullfile(ffolder_shp,sprintf('%s_%04d_snapped_%s%s',sim_name,kpart-1,feature_tok,fext_shp));
    feature_struct_loc=shp2struct(fname_shp,'read_val',false);
    feature_struct.xy=cat(1,feature_struct.xy,feature_struct_loc.xy.XY);
    messageOut(NaN,sprintf('file read %4.2f %% %s',kpart/npart*100,fname_shp))
end
% switch feature_tok
%     case 'fxw' %all have 4 numbers
%         cell2mat(feature_struct.xy)
% end
