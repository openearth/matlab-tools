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
%

function in_plot=create_mat_default_flags(in_plot)

%% defaults common to all

in_plot=isfield_default(in_plot,'lan','en');
in_plot=isfield_default(in_plot,'tag_serie','01');
in_plot=isfield_default(in_plot,'only_adhoc',0);

%% get the items which are not structure

fn=fieldnames(in_plot);
nf=numel(fn);
idx_def=NaN(nf,1);
for kf=1:nf
    if isstruct(in_plot.(fn{kf}))==0
        idx_def(kf)=kf;
    end
end
idx_def=idx_def(~isnan(idx_def));
ndef=numel(find(idx_def));

%% copy flags

for kf=1:nf
    if isstruct(in_plot.(fn{kf}))
        for kdef=1:ndef
            in_plot.(fn{kf}).(fn{idx_def(kdef)})=in_plot.(fn{idx_def(kdef)});
        end
    end
end

end %function