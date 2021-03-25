%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17110 $
%$Date: 2021-03-10 12:59:30 +0100 (Wed, 10 Mar 2021) $
%$Author: chavarri $
%$Id: figure_layout.m 17110 2021-03-10 11:59:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
%

function varargout=D3D_io_input(what_do,fname,varargin)

[~,~,ext]=fileparts(fname);

switch what_do
    case 'read'
        switch ext
            case '.mdu'
                stru_out=dflowfm_io_mdu('read',fname);
            case {'.sed','.mor'}
                stru_out=delft3d_io_sed(fname);
            otherwise
                error('Extension not available')
        end %ext
        varargout{1}=stru_out;
    case 'write'
        stru_in=varargin{1};
        dflowfm_io_mdu('write',fname,stru_in);
end

end %function

