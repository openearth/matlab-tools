function D3D_grd_corner2center(fpath_net,varargin)
%D3D_grd_corner2center Based on cell-corner bed level, compute the cell-centre bed level

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
if exist(fpath_net,'file')~=2
    error('grid file does not exist: %s',fpath_net)
end
[fdir,fname,~]=fileparts(fpath_net);

parin=inputParser;

addOptional(parin,'fpath_out',fullfile(fdir,sprintf('%s.xyz',fname)));
addOptional(parin,'add_header',0)

parse(parin,varargin{:});

fpath_out=parin.Results.fpath_out;
add_header=parin.Results.add_header;


%% READ

gridInfo=EHY_getGridInfo(fpath_net,{'XYcor','Z'});

%% CALC

%% FILTER

bol_n=isnan(gridInfo.Zcor);

%% WRITE
[~,fname_out,fext]=fileparts(fpath_out);
fpath_out_loc=fullfile(pwd,sprintf('%s%s',fname_out,fext));
writematrix([gridInfo.Xcor(~bol_n),gridInfo.Ycor(~bol_n),gridInfo.Zcor(~bol_n)],fpath_out_loc,'FileType','text', 'delimiter', ' ');

if ~strcmp(fpath_out_loc, fpath_out)
    copyfile_check(fpath_out_loc,fpath_out);
    delete(fpath_out_loc)
end
%% PLOT

% figure
% hold on
% scatter(gridInfo.Xcen,gridInfo.Ycen,10,Zcen)
% colorbar

end %function