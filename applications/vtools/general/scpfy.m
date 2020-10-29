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

function path_disp=scpfy(path_win,varargin)

parin=inputParser;

addOptional(parin,'cartesiusProject','/projects/0/hisigem/');
addOptional(parin,'cartesiusUser','pr1n0147');

parse(parin,varargin{:});

user_cartesius=parin.Results.cartesiusUser;
cartesius_project_folder_lin=parin.Results.cartesiusProject;

path_disp=sprintf('scp %s %s@cartesius.surfsara.nl:%s',linuxify(path_win),user_cartesius,cartesify(cartesius_project_folder_lin,path_win));

end
