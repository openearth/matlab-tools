function varargout=dflowfm_io_obs(cmd,filgrd,filsta,obsfile,varargin)

% FLOWFM_IO_obs  read/write D-Flow FM observation points file
%
% See also: dflowfm_io_mdu dflowfm_io_xydata
%
%% Switch read/write

switch lower(cmd)
    
    case 'read'
        
        %
        %  to implement yet
        %
        
    case 'write'
        
        % Initialisation
        LINE      = [];
        
        % Open and read the D3D Files
        grid      = delft3d_io_grd('read',filgrd);
        xcoor     = grid.cend.x';
        ycoor     = grid.cend.y';
        sta       = delft3d_io_obs('read',filsta);
        
        % Fill LINE struct for writing to unstruc file
        for ista = 1:sta.NTables;
            LINE.DATA{ista,1} = xcoor(sta.m(ista),sta.n(ista));
            LINE.DATA{ista,2} = ycoor(sta.m(ista),sta.n(ista));
            LINE.DATA{ista,3} = strtrim(sta.namst(ista,:));
        end
        
        % Finally write to the unstruc thd file and fill in the name of the thd filw in the mdu_struct
        dflowfm_io_xydata('write',obsfile,LINE);
        
end
