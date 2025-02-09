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
%writes initial composition files. For a given matrix 'frac_xy' containing x
%and y coordinates of 'np' points, it writes the files corresponding to
%'nl' layers and 'nf' fractions given in 'frac'. The first layer (i.e.,
%frac(:,1,:) is the active layer. Similarly for the thickness. 
%
%INPUT:
%   -simdef.mor.frac_xy = coordinates [-]; [np,2]
%   -simdef.mor.frac = volume fraction content [-]; [np,nl,nf]
%   -simdef.mor.thk = layer thickness [-]; [np,nl]

function D3D_morini_files(simdef,varargin)

%% PARSE

if isfield(simdef.mor,'folder_out')==0
    simdef.mor.folder_out='gsd';
end

%dir out
if isfield(simdef,'D3D')
    fdir_out=fullfile(simdef.D3D.dire_sim,simdef.mor.folder_out);
else
    fdir_out=simdef.mor.folder_out;
end
mkdir_check(fdir_out);

%rename input
frac=simdef.mor.frac;
frac_xy=simdef.mor.frac_xy;
thk=simdef.mor.thk;

%size
nf=size(frac,3);
nl=size(frac,2);
ng=size(frac,1);

%% round

% [row,col] = find(thk==0);
% frac(row,col,1) = 1; 
% frac(row,col,2:nf) = 0; 

%check_Fak(frac);

prec=10;

frac_cum = cumsum(flip(frac,3),3); % get cumulative content (order is flipped such that in case of too little sediment the finest sediment gets it)
frac_cum(:,:,end) = 1; % set total to 1.
frac_cum = min(frac_cum,1); % more than 1 is not allowed
frac_cum = max(frac_cum,0); % less than 0 is not allowed
frac_cum = round(frac_cum,prec); % round to desired precision
frac_rn = diff(cat(3,zeros(ng,nl,1),frac_cum),1,3); % get fraction per thickness
frac_rn = flip(frac_rn,3); %reorder to original order 
frac_rn = round(frac_rn,prec); % round to desired precision

check_Fak(frac_rn);

%% write
for kl=1:nl
    file_name=fullfile(fdir_out,sprintf('lyr%02d_thk.xyz',kl));
    outmat=[frac_xy(:,1),frac_xy(:,2),thk(:,kl)];
    write_2DMatrix(file_name,outmat,varargin{:})
    for kf=1:nf
        file_name=fullfile(fdir_out,sprintf('lyr%02d_frac%02d.xyz',kl,kf));
        outmat=[frac_xy(:,1),frac_xy(:,2),frac_rn(:,kl,kf)];
        write_2DMatrix(file_name,outmat,varargin{:})
        messageOut(NaN,sprintf('file written layer %4.2f %% fraction %4.2f %%: %s',kl/nl*100,kf/nf*100,file_name));
    end
end

end %function

%%
%% FUNCTIONS
%%

function check_Fak(fractions_var_mod)

tol=1e-9;
if ~isempty(find(fractions_var_mod>1+tol, 1)) || ~isempty(find(fractions_var_mod<-tol, 1))
     warning('ups')
end

tol_sum=1e-9;
sum_frac=sum(fractions_var_mod,3);
idx_1=find(sum_frac>1+tol_sum,1);
idx_0=find(sum_frac<1-tol_sum,1);
if ~isempty(idx_1)
    warning('Warning: volume fraction content = %0.15e',sum_frac(idx_1))
end
if ~isempty(idx_0)
    warning('Warning: volume fraction content = %0.15e',sum_frac(idx_0))
end

end %function
