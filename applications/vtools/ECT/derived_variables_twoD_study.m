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
%Rework variables for plotting. 
%
%INPUT:
%
%
%OUTPUT:
%
%
%NOTES:
%   -`_v` size of input vector for creating all combinations
%   -`_p` size of all points in the analysis (product of the two input vectors for x and y)
%   -`_m` size of matrix to plot as mesh

function [kw_p,kwx_p,kwy_p,kwx_m,kwy_m,lwx_v,lwy_v,lwx_p,lwy_p,lwx_m,lwy_m,lambda_p,beta_p,tri,max_gr_p,max_gr_m,eig_r_p,c_morph_p,c_morph_m,tri_dim]=derived_variables_twoD_study(h,eig_r_p,eig_i_p,kwx_v,kwy_v,kw_p_input)

%% sizes

np1=numel(kwx_v);
np2=numel(kwy_v);
[nc,ne]=size(eig_r_p);

%% combinations

%there is a link between how the combinations are created and how the output
%vectors of the eigenvalues are reshaped. Here we check that there has been no 
%change in the method.

kw_p=allcomb(kwx_v,kwy_v);
if any(kw_p~=kw_p_input)
    error('Something is wrong.')
end

%% wavenumber and wavelength vectors

%input of combinations
lwx_v=2*pi./kwx_v;
lwy_v=2*pi./kwy_v;

%combination vectors
kwx_p=kw_p(:,1);
kwy_p=kw_p(:,2);
lwx_p=2*pi./kwx_p;
lwy_p=2*pi./kwy_p;

%% dimensionelss values

%Siviglia13
lambda_p=pi.*lwy_p./2./lwx_p;
lambda_v=pi.*lwy_v./2./lwx_v;
beta_p=lwy_p/4/h;
beta_v=lwy_v/4/h;

%% meshes

[kwx_m,kwy_m]=meshgrid(kwx_v,kwy_v);
[lwx_m,lwy_m]=meshgrid(lwx_v,lwy_v);

try %error due to colinear points
    tri=delaunay(lambda_p,beta_p);
    tri_dim=delaunay(lwx_p,lwy_p);
catch
    tri=NaN;
end

% lambda_m=reshape
% [lambda_m,beta_m]=meshgrid(lambda_v,beta_v);

%% maximum growth rate

eig_i_p(abs(eig_i_p)<1e-16)=NaN;
max_gr_p=max(eig_i_p,[],2,'omitnan');
max_gr_m=reshape(max_gr_p,np1,np2);

%% morphodynamic celerity

% eig_r_p(abs(eig_r_p)<1e-16)=NaN; %why?
[m_s,p_s]=sort(abs(eig_r_p),2);
eig_r_morph_p=NaN(size(eig_r_p,1),ne-3);
for kc=1:nc
    eig_r_morph_p(kc,:)=eig_r_p(kc,p_s(kc,1:ne-3));
end
c_morph_p=eig_r_morph_p./kwx_p;

%matrix form
c_morph_m=NaN(np1,np2,ne-3);
for ke=1:ne-3
    c_morph_m(:,:,ke)=reshape(eig_r_morph_p(:,ke),np1,np2)./kwx_m';
end

end %function