%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: linuxify.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/linuxify.m $
%
%

function path_disp=scpfy(path_win,varargin)

parin=inputParser;

addOptional(parin,'cartesiusProject','/projects/0/hisigem/');
addOptional(parin,'cartesiusUser','pr1n0147');

parse(parin,varargin{:});

user_cartesius=parin.Results.cartesiusUser;
cartesius_project_folder_lin=parin.Results.cartesiusProject;

path_disp=sprintf('scp %s %s@cartesius.surfsara.nl:%s',linuxify(path_win),user_cartesius,cartesify(cartesius_project_folder_lin,path_win));

end
