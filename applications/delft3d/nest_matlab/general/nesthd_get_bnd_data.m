function bnd=get_bnd_data(filename)

% get_bnd_data : Gets the boundary definition

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
end

%
% Reduce the bnd structure  to timeseries only
%

hulp   = [];
ibnd_T =  0;
for ibnd = 1: length(bnd.DATA)
    if strcmpi(bnd.DATA(ibnd).datatype,'T')
        ibnd_T       = ibnd_T + 1;
        hulp.DATA(ibnd_T)     = bnd.DATA(ibnd);
        hulp.m    (ibnd_T,:)  = bnd.m     (ibnd,:);
        hulp.n    (ibnd_T,:)  = bnd.n     (ibnd,:);
        hulp.pntnr(ibnd_T,:)  = bnd.pntnr (ibnd,:);      
    end
end

clear bnd
bnd = hulp;
