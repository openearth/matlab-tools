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
%This functions finds the indices in a cell array in which a string is found. 
%
%E.g. 
%
%data={'a','a','b','a'};
%str2find={'a'};
%idx=[1,2,4];


function [idx,bol]=find_str_in_cell(data,str2find,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'first',false)

parse(parin,varargin{:})

do_first=parin.Results.first;

if ~iscell(str2find)
    error('Second input must be cell array')
end

%% CALC

ns=numel(str2find);
idx=[];
bol=false(size(data));
for ks=1:ns
    %check exact agreement
    idx_rkm=find(contains(data,str2find(ks)));
    na=numel(idx_rkm);
    if do_first
        na=1;
    end
    for ka=1:na
        if strcmp(data{idx_rkm(ka)},str2find(ks))
            idx=cat(2,idx,idx_rkm(ka));
        end
    end
end %ns

bol(idx)=true;

if isempty(idx)
    idx=NaN;
end

end %function

