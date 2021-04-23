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
%write:
%   pli:
%       -pli.name: name of the polyline (char) or number of the polyline (double)
%       -pli.xy: coordinates

function varargout=D3D_io_input(what_do,fname,varargin)

[~,~,ext]=fileparts(fname);

switch what_do
    case 'read'
        switch ext
            case '.mdu'
                stru_out=dflowfm_io_mdu('read',fname);
            case {'.sed','.mor'}
                stru_out=delft3d_io_sed(fname);
            case {'.pli','.pliz'}
                tek=tekal('read',fname,'loaddata');
                stru_out.name={tek.Field.Name};
                stru_out.val={tek.Field.Data};
            case '.ini'
                stru_out=delft3d_io_sed(fname);
            otherwise
                error('Extension %s in file %s not available for readinf',ext,fname)
        end %ext
        varargout{1}=stru_out;
    case 'write'
        stru_in=varargin{1};
        switch ext
            case {'.mdu','.mor','.sed'}
                dflowfm_io_mdu('write',fname,stru_in);
            case '.pli'
                D3D_write_poly(stru_in.name,stru_in.xy,fname);
            otherwise
                error('Extension %s in file %s not available for writing',ext,fname)
        end
end

end %function

