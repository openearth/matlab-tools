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

if ~ischar(fname)
    error('fname should be char')
end
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
            case {'.pli','.pliz','.pol','.ldb'}
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
            case {'.bct','.bc'}
                stru_out=bct_io('read',fname);
            case '.xyz'
%                 stru_out=dflowfm_io_xydata('read',fname); %extremely slow
                stru_out=readmatrix(fname,'FileType','text');
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
            case {'.pli','.ldb','.pol','.pliz'}
%                 stru_in(kpol).name: double or string
%                 stru_in(kpol).xy: [np,2] array with x-coordinate (:,1) and y-coordinate (:,2)
                D3D_write_polys(fname,stru_in);
            case '.dep'
                delft3d_io_dep('write',fname,stru_in,varargin(2:end));
            case '.bct'
                stru_in.file.bct=fname;
                D3D_bct(stru_in);
            case '.bc'
% stru_in.name
% stru_in.function
% stru_in.time_interpolation
% stru_in.quantity
% stru_in.unit
% stru_in.val
                D3D_write_bc(fname,stru_in)
            case '.xyz'
%                 D3D_io_input('write',xyz)
%                 xyz(:,1) = x-coordinate
%                 xyz(:,2) = y-coordinate
%                 xyz(:,3) = z-coordinate
                fid=fopen(fname,'w');
                ndep=size(stru_in,1);
                for kl=1:ndep
                    fprintf(fid,' %14.7f %14.7f %14.13f \n',stru_in(kl,1),stru_in(kl,2),stru_in(kl,3));
                end
                fclose(fid);
                messageOut(NaN,sprintf('File written: %s',fname));
            case '.shp'
                shapewrite(fname,'polyline',{stru_in.xy},{})
            case '' %writing a series of tim files
%                 D3D_io_input('write',dire_out,stru_in,reftime);
%                 dire_out = folder to write  
%                 stru_in = same structure as for bc
%                 reftime = datetime of the mdu file
                ref_date=varargin{2}; %all time series must have the reference date of the mdu
                ns=numel(stru_in);
                for ks=1:ns
                    idx_all=1:1:numel(stru_in(ks).quantity);
                    [idx_tim,bol_tim]=find_str_in_cell(stru_in(ks).quantity,{'time'});
                    idx_val=idx_all(~bol_tim);
                    str_tim=stru_in(ks).unit{idx_tim};
                    [t0,unit]=read_str_time(str_tim);
                    tim_val=stru_in(ks).val(:,idx_tim);
                    switch unit
                        case 'seconds'
                            data_loc(ks).tim=t0+seconds(tim_val);
                        case 'minutes'
                            data_loc(ks).tim=t0+minutes(tim_val);
                        otherwise
                            error('add')
                    end
                    data_loc(ks).val=stru_in(ks).val(:,idx_val);
                    data_loc(ks).quantity=stru_in(ks).quantity;
                end
                fname_tim_v={stru_in.name};
                D3D_write_tim_2(data_loc,fname,fname_tim_v,ref_date)
            otherwise
                error('Extension %s in file %s not available for writing',ext,fname)
        end
end

end %function

