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
%bnd file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bnd_pli_ds(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;
B=simdef.grd.B;

%% FILE

kl=1;
switch simdef.grd.type
    case 1
        L=simdef.grd.L;
        data{kl, 1}=        'Downstream'; kl=kl+1;
        data{kl, 1}=        '    2    2'; kl=kl+1;
        data{kl, 1}=sprintf('%0.7E  %0.7E Downstream_0001',L,B); kl=kl+1;
        data{kl, 1}=sprintf('%0.7E  0     Downstream_0002',L); %kl=kl+1;
    case 3
        kun=1;
        grd=wlgrid('read',fullfile(simdef.D3D.dire_sim,'grd.grd'));
        cords(:,:,kun)=[grd.X(end,1),grd.Y(end,1);grd.X(end,end),grd.Y(end,end)];

%         R=simdef.mdf.R;
%         L1=simdef.grd.L1;
%         dy=simdef.grd.dy;
%         %watch out with this ad hoc!
%         data{kl, 1}=        'Downstream'; kl=kl+1;
%         data{kl, 1}=        '    2    2'; kl=kl+1;
%         if B<1.75 %Struiksma83_2
%             data{kl, 1}=sprintf('%0.7E  %0.7E Downstream_0001',-1.68377303563189040e+01,-2.30946850805377580e-01); kl=kl+1;
%             data{kl, 1}=sprintf('%0.7E  %0.7E Downstream_0002',-1.56886636916404360e+01,-1.19512826533518710e+00); %kl=kl+1;
%         else
%             data{kl, 1}=sprintf('%0.7E  %0.7E Downstream_0001',-1.68377303563189040e+01,-2.30946850805377580e-01); kl=kl+1;
%             data{kl, 1}=sprintf('%0.7E  %0.7E Downstream_0002',-1.53056414700809460e+01,-1.51652207017845700e+00); %kl=kl+1;
%         end

        data{kl, 1}=        'Downstream'; kl=kl+1;
        data{kl, 1}=        '    2    2'; kl=kl+1;
        data{kl, 1}=sprintf('%0.7E  %0.7E Downstream_0001',cords(1,1,kun),cords(1,2,kun)); kl=kl+1;
        data{kl, 1}=sprintf('%0.7E  %0.7E Downstream_0002',cords(2,1,kun),cords(2,2,kun)); %kl=kl+1;
    otherwise
        error('rtfm!')
end

%% WRITE

file_name=fullfile(dire_sim,'Downstream.pli');
writetxt(file_name,data)

