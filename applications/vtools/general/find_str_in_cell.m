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


function [idx,bol]=find_str_in_cell(data,str2find)

%% all values
%useful for later select left and right

if ~iscell(str2find)
    error('Second input must be cell array')
end

ns=numel(str2find);
idx=[];
bol=false(size(data));
for ks=1:ns
    aux_where=strfind(data,str2find(ks));
    %check exact agreement
    idx_rkm=find(~cellfun(@isempty,aux_where));
    na=numel(idx_rkm);
    for ka=1:na
        if strcmp(data{idx_rkm(ka)},str2find(ks))
            idx=[idx,idx_rkm(ka)];
            
        end
    end
end %ns

bol(idx)=true;

if isempty(idx)
    idx=NaN;
end

%% one value 

% ns=numel(str2find);
% idx=NaN;
% for ks=1:ns
%     aux_where=strfind(data,str2find(ks));
%     %check exact agreement
%     idx_rkm=find(~cellfun(@isempty,aux_where));
%     na=numel(idx_rkm);
%     for ka=1:na
%         if strcmp(data{idx_rkm(ka)},str2find(ks))
%             idx=idx_rkm(ka);
%         end
%     end
% end %ns

% if isnan(idx)
%     warning('index not found')
% end
end %function

