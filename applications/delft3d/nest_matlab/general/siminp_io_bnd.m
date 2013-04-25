function bnd=siminp_io_bnd(filename)

%
%  get the bnd_struc (Delft3D-flow form) from a siminp file
%

bnd = [];
ibnd = 0;

%
% Read siminp file
%
[P,N,E] = fileparts(filename);
filename = [N E];

exclude = {true;true};
S = readsiminp(P,filename,exclude);
S = all_in_one(S);

%
% Parse Boundary data
%

nesthd_dir = getenv('nesthd_path');

%
% get information out of struc
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'POINTS'});
points  = siminp_struc.ParsedTree.MESH.POINTS;
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'BOUNDARIES' 'OPENINGS'});
opendef  = siminp_struc.ParsedTree.MESH.BOUNDARIES.OPENINGS;
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS' 'BOUNDARIES'});
bnddef = siminp_struc.ParsedTree.FLOW.FORCINGS.BOUNDARIES;

for iopen = 1: length(bnddef.B)
   if strcmpi(deblank(bnddef.B(iopen).BTYPE),'wl')     || strcmpi(deblank(bnddef.B(iopen).BTYPE),'vel') || ...                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if strcmpi(B(iopen).BDEF,'wl'     )|| strcmpi(B(iopen).BDEF,'vel') || ...
      strcmpi(deblank(bnddef.B(iopen).BTYPE),'Riemann')
       if strcmpi(deblank(bnddef.B(iopen).BDEF),'series')

          %
          % Time serie for water levels, velocities or Riemann ==> Nest this boundary
          %

          ibnd     = ibnd + 1;

          %
          % Fill bndtype
          %
          bnd.DATA(ibnd).datatype = 'T';

          if strcmpi (deblank(bnddef.B(iopen).BTYPE),'wl')
             bnd.DATA(ibnd).bndtype = 'z';
          elseif strcmpi (deblank(bnddef.B(iopen).BTYPE),'vel')
             bnd.DATA(ibnd).bndtype = 'c';
          elseif strcmpi (deblank(bnddef.B(iopen).BTYPE),'Riemann')
             bnd.DATA(ibnd).bndtype = 'r';
          end

          %
          % Get the opening number of the boundary
          %

          OpenNr  = bnddef.B(iopen).OPEN;

          %
          % Find the correct opening
          %

          for iline = 1: length(opendef.OPEN)
              if opendef.OPEN(iline).SEQNR == OpenNr
                  iopennr = iline;
              end
          end

          bnd.DATA(ibnd).name = opendef.OPEN(iopennr).LINE.NAME;
          ipoint(1)= opendef.OPEN(iopennr).LINE.P(1);
          ipoint(2)= opendef.OPEN(iopennr).LINE.P(2);

          for iside = 1: 2
             for ipnt = 1: length(points.P)
                if points.P(ipnt).SEQNR  == ipoint(iside)
                   bnd.m(ibnd,iside)     = points.P(ipnt).M;
                   bnd.n(ibnd,iside)     = points.P(ipnt).N;
                   bnd.pntnr(ibnd,iside) = ipoint(iside);
                end
             end
          end
       end
   end
end
