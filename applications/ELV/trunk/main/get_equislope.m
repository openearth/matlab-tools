%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16573 $
%$Date: 2020-09-08 16:03:40 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: get_equislope.m 16573 2020-09-08 14:03:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/main/get_equislope.m $
%
%get_equislope does this and that
%
%S = get_equislope(Qw,input,AL,Fk,X0)
%
%INPUT:
%   -input = input structure
%
%OUTPUT:
%   -
%
%HISTORY:
%161128
%   -L. Created for the first time
%

function S = get_equislope(Qw,input,AL,Fk,X0)
    if nargin<5
        X0 = 1e-4;
    end
    %input = add_sedflags(input);
    F = @(X)solve_nfbc([X Fk(1:end-1)],input,Qw,AL);
    S = fzero(F,X0);
    disp('Objective value of total sediment load (should be zero):');
    solve_nfbc([S Fk(1:end-1)],input,Qw,AL)
end
