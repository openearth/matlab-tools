%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18279 $
%$Date: 2022-08-02 16:45:02 +0200 (Tue, 02 Aug 2022) $
%$Author: chavarri $
%$Id: absmintol.m 18279 2022-08-02 14:45:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absmintol.m $
%
%Compute whether there is color (perturbation) in a figure.
%
%INPUT:
%
%OUTPUT:
%   -pert

function pert=perturbation_from_figure(fpath_fig)

thresh=240; %255=white;

im=imread(fpath_fig);
im_bw=rgb2gray(im);
pert=false(size(im_bw));
pert(im_bw<thresh)=true;

% figure
% surf(pert.*1,'edgecolor','none')
end %function