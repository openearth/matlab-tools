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
%Thin dams file

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.D3D.grd = folder the grid files are [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\files\grd\'
%
%OUTPUT:
%   -a .enc file compatible with D3D is created in folder_out
%
%ATTENTION:
%   -
%
%HISTORY:
%   -161110 V. Creation of the grid files itself

function D3D_thd(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% CALC

switch simdef.D3D.structure
    case 1
        %The idea would be to read spatial data and convert to MN coordinates. 
        %see how it is done in `D3D_convert_...`

        %if it is empty, we do not have thin dams
        if ~isempty(simdef.file.thd)
            fname_destiny=simdef.file.thd;
            %check if the file already exists
            if check_existing && exist(fname_destiny,'file')>0
                error('You are trying to overwrite a file!')
            end
            fname=fullfile(pwd,now_chr);
            delft3d_io_thd('write',fname,simdef.thd);
            copyfile_check(fname,fname_destiny);
        end
    case 2
        if ~isempty(simdef.file.thd)
            error('do')
        end
end %switch

end %function


