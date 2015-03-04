function bnd=get_bnd_data(filename,varargin)

% get_bnd_data : Gets the boundary definition

% Start nest DFLOWFM models: use points in stead of boundaries and sides

OPT.Points = false;
OPT = setproperty(OPT,varargin);

%
%  Determine file type
%

filetype = nesthd_det_filetype(filename);

%
% Use appropriate funtion to get the bnd data
%

switch filetype;
   case 'Delft3D'
      bnd = delft3d_io_bnd('read',filename);
   case 'DFLOWFM'
      bnd = delft3d_io_bnd('read',filename);
   case 'siminp'
      [P,N,E] = fileparts(filename);
      filename = [N E];

      exclude = {true;true};
      S = readsiminp(P,filename,exclude);
      S = all_in_one(S);

      bnd = simona2mdf_bnddef(S);
end

%
% Reduce the bnd structure  to timeseries only
% Test_tk get rid of boundaries with begin and end,
% use points
%

hulp   = [];
if OPT.Points
    %% Point structure
    i_pnt_T =  0;
    for ibnd = 1: length(bnd.DATA)
        if strcmpi(bnd.DATA(ibnd).datatype,'T')
            for i_side = 1: 2
                i_pnt_T       = i_pnt_T + 1;
                hulp.DATA (i_pnt_T)  = bnd.DATA(ibnd);
                hulp.m    (i_pnt_T)  = bnd.m     (ibnd,i_side);
                hulp.n    (i_pnt_T)  = bnd.n     (ibnd,i_side);
                if strcmpi(filetype,'siminp')
                    hulp.pntnr(i_pnt_T)  = bnd.pntnr (ibnd,i_side);
                end
            end
        end
    end
else
    %% Boundaries and sides structure
    ibnd_T =  0;
    for ibnd = 1: length(bnd.DATA)
        if strcmpi(bnd.DATA(ibnd).datatype,'T')
            ibnd_T       = ibnd_T + 1;
            hulp.DATA(ibnd_T)     = bnd.DATA(ibnd);
            hulp.m    (ibnd_T,:)  = bnd.m     (ibnd,:);
            hulp.n    (ibnd_T,:)  = bnd.n     (ibnd,:);
            if strcmpi(filetype,'siminp')
                hulp.pntnr(ibnd_T,:)  = bnd.pntnr (ibnd,:);
            end
        end
    end
end

if isempty(hulp)
    simona2mdf_message({'No time series boundaries specified'},'Window','Nesthd Error','Close',true,'n_sec',10);
end

clear bnd
bnd = hulp;
