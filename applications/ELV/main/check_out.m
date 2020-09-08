%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 157 $
%$Date: 2017-07-27 17:53:42 +0200 (Thu, 27 Jul 2017) $
%$Author: V $
%$Id: check_out.m 157 2017-07-27 15:53:42Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/check_out.m $
%
%check_input is a function that checks that the input is enough and makes sense
%
%input_out=check_input(input,path_file_input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -input = variable containing the input [struct] e.g. input
%
%HISTORY:
%170720
%   -V & Pepijn. Created for the first time.

function input_out=check_out(input,fid_log)

order_result=0;
if     any(strcmp(input.mdv.output_var,'u'))
    order_result=order_result+input.mdv.nx;
elseif any(strcmp(input.mdv.output_var,'h'))
    order_result=order_result+input.mdv.nx;
elseif any(strcmp(input.mdv.output_var,'etab'))
    order_result=order_result+input.mdv.nx;
elseif any(strcmp(input.mdv.output_var,'La'))
    order_result=order_result+input.mdv.nx;
elseif any(strcmp(input.mdv.output_var,'Cf'))
    order_result=order_result+input.mdv.nx;    
elseif any(strcmp(input.mdv.output_var,'ell_idx'))
    order_result=order_result+input.mdv.nx;    
elseif any(strcmp(input.mdv.output_var,'Mak'))
    order_result=order_result+input.mdv.nx*input.mdv.nef;    
elseif any(strcmp(input.mdv.output_var,'msk'))
    order_result=order_result+input.mdv.nx*input.mdv.nsl*input.mdv.nef;    
elseif any(strcmp(input.mdv.output_var,'Ls'))
    order_result=order_result+input.mdv.nx*input.mdv.nsl*input.mdv.nef;        
elseif any(strcmp(input.mdv.output_var,'qbk'))
    order_result=order_result+input.mdv.nx*input.mdv.nef;        
end
   
order_result=order_result*input.mdv.nT;

max_order_result=1e7;
warning_time=10; %[s]

warning('off','backtrace');
if order_result>max_order_result
    for ktw=warning_time:-1:0
        warning('Results file has %4.2e values, your computer may freeze. I will continue in %d seconds',order_result,ktw)
        pause(1)
    end
end
warning('on','backtrace');

%% OUTPUT 

input_out=input;