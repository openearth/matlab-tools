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
%Writes all the initial composition files. I.e., writes the main file and
%the files for each layer and fraction. 
%
%INPUT:
%   -simdef.mor.frac_xy = coordinates [-]; [np,2]
%   -simdef.mor.frac = volume fraction content [-]; [np,nl,nf]
%   -simdef.mor.thk = layer thickness [-]; [np,nl]
%   -simdef.D3D.dire_sim = full path to the folder where to write the main file [-]; 
%
%E.G.
%
% np=10; %number of points
% x=linspace(1,1000,np); %x vector
% y=2.*x; %y vector
% frac_xy=[x',y']; %coordinates matrix
% 
% nl=3; %number of layers
% thk=0.25.*ones(np,nl); %thickness matrix
% 
% nf=2; %number of fractions
% frac=NaN(np,nl,nf); %fractions matrix
% frac(:,:,1)=0.1.*ones(np,nl); %fraction 1
% frac(:,:,2)=0.9.*ones(np,nl); %fraction 2
% 
% simdef.mor.frac_xy=frac_xy;
% simdef.mor.thk=thk;
% simdef.mor.frac=frac;
% 
% simdef.D3D.dire_sim='c:\Users\chavarri\Downloads\'; %folder to write data
%
% D3D_morini_all(simdef)

function D3D_morini_all(simdef,varargin)

D3D_morini(simdef);
D3D_morini_files(simdef,varargin{:});

end