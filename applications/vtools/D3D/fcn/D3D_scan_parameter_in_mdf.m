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
%Scans for a parameter in a folder with one simulations in it. 

function D3D_scan_parameter_in_mdf(fpath_mdf,param)

mdf=D3D_io_input('read',fpath_mdf);

fn=fieldnames(mdf);
ng=numel(fn);
for kg=1:ng
    fn2=fieldnames(mdf.(fn{kg}));
    nf2=numel(fn2);
    for kg2=1:nf2
        if strcmpi(fn2{kg2},param)
            val=mdf.(fn{kg}).(fn2{kg2});
            if ischar(val)
                fprintf('%s = %s, %s \n',param,val,fpath_mdf);
            else
                fprintf('%s = %f, %s \n',param,val,fpath_mdf);
            end
        end
    end
end

end %function

%%
%% FUNCTIONS
%%

