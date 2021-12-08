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
% addOptional(parin,'cartesiusComputer','cartesius.surfsara.nl');
addOptional(parin,'cartesiusComputer','snellius.surf.nl');

parse(parin,varargin{:});

user_cartesius=parin.Results.cartesiusUser;
cartesius_project_folder_lin=parin.Results.cartesiusProject;
computer_cartesius=parin.Results.cartesiusComputer;

path_disp=sprintf('scp %s %s@%s:%s',linuxify(path_win),user_cartesius,computer_cartesius,cartesify(cartesius_project_folder_lin,path_win));

end
