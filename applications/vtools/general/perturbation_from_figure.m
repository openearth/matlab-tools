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