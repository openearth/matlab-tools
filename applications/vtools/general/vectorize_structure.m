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
%All arrays in a structure are turned into a column vector. 

function stru_out=vectorize_structure(stru_in)

%% PARSE

if ~isstruct(stru_in)
    error('Input is not a structure.')
end

%% CALC

stru_out=stru_in;
fn=fieldnames(stru_out);
nf=numel(fn);
for kf=1:nf
    if isnumeric(stru_out.(fn{kf}))
        stru_out.(fn{kf})=reshape(stru_out.(fn{kf}),1,[]);
    end
end

end %function