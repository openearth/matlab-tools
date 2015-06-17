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
   case 'siminp'
      [P,N,E] = fileparts(filename);
      filename = [N E];

      exclude = {true;true};
      S = readsiminp(P,filename,exclude);
      S = all_in_one(S);

      bnd = simona2mdf_bnddef(S);
    case {'pli','ext','mdu'}
        bnd = dflowfm_io_bnd('read',filename);
end

%
% Reduce the bnd structure  to timeseries only
% Test_tk get rid of boundaries with begin and end,
% use points
%

if ~strcmp(filetype,'ext') && ~strcmp(filetype,'pli') && ~strcmp(filetype,'mdu')
    if ~isempty(bnd)
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
                        % New structure based on names!
                        hulp.Name {i_pnt_T}  = nesthd_convertmn2string(bnd.m(ibnd,i_side),bnd.n(ibnd,i_side));
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
                    for i_side = 1: 2
                        hulp.m    (ibnd_T,i_side)  = bnd.m     (ibnd,i_side);
                        hulp.n    (ibnd_T,i_side)  = bnd.n     (ibnd,i_side);
                        hulp.Name {ibnd_T,i_side}  = nesthd_convertmn2string(bnd.m(ibnd,i_side),bnd.n(ibnd,i_side));
                    end
                    if strcmpi(filetype,'siminp')
                        hulp.pntnr(ibnd_T,:)  = bnd.pntnr (ibnd,:);
                    end
                end
            end
        end
    end
    if isempty(hulp)
        simona2mdf_message({'No time series boundaries specified'},'Window','Nesthd Error','Close',true,'n_sec',10);
    end

    clear bnd
    bnd = hulp;
end
