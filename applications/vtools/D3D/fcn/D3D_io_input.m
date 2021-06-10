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
%e.g.
% dep=D3D_io_input('read',fdep,fgrd,'location','cor');
% D3D_io_input('write','c:\Users\chavarri\Downloads\trial.dep',dep,'location','cor','dummy',false,'format','%15.13e');

function varargout=D3D_io_input(what_do,fname,varargin)

[~,~,ext]=fileparts(fname);

switch what_do
    case 'read'
        switch ext
            case '.mdf'
                stru_out=delft3d_io_mdf('read',fname);
            case '.mdu'
                stru_out=dflowfm_io_mdu('read',fname);
            case {'.sed','.mor'}
                stru_out=delft3d_io_sed(fname);
            case {'.pli','.pliz','.pol'}
                tek=tekal('read',fname,'loaddata');
                stru_out.name={tek.Field.Name};
                stru_out.val={tek.Field.Data};
            case '.ini'
                stru_out=delft3d_io_sed(fname);
            case '.grd'
                stru_out=delft3d_io_grd('read',fname);
            case '.dep'
                G=delft3d_io_grd('read',varargin{1});
                stru_out=delft3d_io_dep('read',fname,G,varargin(2:3));
%                 G=wlgrid('read',varargin{1});
%                 stru_out=wldep('read',fname,G);
            case '.bct'
                stru_out=bct_io('read',fname);
            otherwise
                error('Extension %s in file %s not available for reading',ext,fname)
        end %ext
        varargout{1}=stru_out;
    case 'write'
        stru_in=varargin{1};
        switch ext
            case {'.mdu','.mor','.sed'}
                dflowfm_io_mdu('write',fname,stru_in);
            case {'.mdf'}
                delft3d_io_mdf('write',fname,stru_in.keywords);
            case '.pli'
                D3D_write_poly(stru_in.name,stru_in.xy,fname);
            case '.dep'
                delft3d_io_dep('write',fname,stru_in,varargin(2:end));
            case '.bct'
                stru_in.file.bct=fname;
                D3D_bct(stru_in);
            otherwise
                error('Extension %s in file %s not available for writing',ext,fname)
        end
end

end %function

