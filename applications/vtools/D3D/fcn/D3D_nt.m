%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 11:17:04 +0200 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: NC_nt.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_nt.m $
%
%

function nt=D3D_nt(fpath_res,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'res_type','map');

parse(parin,varargin{:});

res_type=parin.Results.res_type;

%% 

if isfolder(fpath_res)
        fdir_output=fullfile(fpath_res,'output');
        dire=dir(fdir_output);
        nf=numel(dire)-2-1; %already the number of the files, which start at 0
        nt=0;
        for kf=0:1:nf
            fdir_loc=fullfile(fdir_output,num2str(kf));
            simdef.D3D.dire_sim=fdir_loc;
            simdef=D3D_simpath(simdef);
            fpath_nc=simdef.file.(res_type);
            nt=nt+NC_nt(fpath_nc);
                        
%             messageOut(NaN,sprintf('Joined time %4.2f %%',kf/nf*100));
        end
else
    
    [~,~,ext]=fileparts(fpath_res);
    switch ext
        case '.nc'
            nt=NC_nt(fpath_res);
        case '.dat'
            NFStruct=vs_use(fpath_res,'quiet');
            ITMAPC=vs_let(NFStruct,'map-info-series','ITMAPC','quiet'); %results time vector
            nt=numel(ITMAPC); %there must be a better way... ask Bert!

    end %ext
    
end %is

end %function