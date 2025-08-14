%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20235 $
%$Date: 2025-07-07 14:32:25 +0200 (Mon, 07 Jul 2025) $
%$Author: chavarri $
%$Id: D3D_gdm.m 20235 2025-07-07 12:32:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Read FLORIS FUNIN file. 

function [csd,csd_add]=floris_to_fm_read_funin(fpath_funin,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log; 

%% CHECK FILE

messageOut(fid_log,'Start processing FUNIN.')

if isempty(fpath_funin)
    messageOut(fid_log,sprintf('No funin file.'))
    return
end
if ~exist(fpath_funin,'file')==2
    messageOut(fid_log,sprintf('File does not exist: %s',fpath_funin))
end

%% CALC

fid=fopen(fpath_funin,'r');

idx_crs=0; %index of cross-section
inside_crs_block=false; %true if inside a cross-section block
inside_block_values=false; %true if inside a values block (i.e., not header)

while ~feof(fid)
    line=strtrim(fgetl(fid)); %get line

    %skip empty lines and comments
    if isempty(line) || startsWith(line, '/') || startsWith(line, '//')
        continue;
    end

    %if the line has `values`, we have already looped through the header.
    %Variable `inside_block_values` will always be true.
    if strcmpi(line, 'values')
        if inside_block_values && ~inside_crs_block
            %if the line has `values` and we are not inside a crs block, we
            %are starting a new crs block. 
            inside_crs_block=true;
        end
        inside_block_values = true;
        continue;
    end

    %if not in `values` block, we are in the header.
    if ~inside_block_values
        continue
    end

    %get first number of the line
    tokens = regexp(line, '([-+]?\d*\.?\d+)|,', 'match');
    tokens = cellfun(@(x) strtrim(x), tokens, 'uni', 0);
    tokens(strcmp(tokens, ',')) = {''};

    tokens_num=str2double(tokens);
    num_ident=tokens_num(1); %this identifies the type of line
    switch num_ident
        case 1
            %top definition of friction
            %1.00 0.15 38. 15. , , 38.  /

            %DO SOMETHING WITH IT
            %nums=str2double(tokens);
        case 20
            %cross-section location
            %20 '2223000' -2223.000 0. , , , , 412571.38 520292.5 412799.59 520218.7 /
            tokens=regexp(line,'''[^'']*''|[-+]?\d*\.?\d+','match');

            idx_crs=idx_crs+1; %new cross-section

            id_token=tokens{2};
            id=strrep(id_token,'''','');
            
            %data for d3d cross-sections
            csd(idx_crs).id=id;
            csd(idx_crs).type='yz';
            csd(idx_crs).singleValuedZ='yes';
            csd(idx_crs).yzCount=0;
            csd(idx_crs).yCoordinates=[];
            csd(idx_crs).zCoordinates=[];
            csd(idx_crs).conveyance='lumped'; %segmented, lumped
            csd(idx_crs).sectionCount=1; %number of roughness cross-section
            % csd(idx_crs).frictionPositions=1; 
            % csd(idx_crs).frictionIds=1; 
            % csd(idx_crs).frictionTypes=1;
            % csd(idx_crs).frictionValues=1;

            %other data
            csd_add(idx_crs).rkm=tokens_num(3);
            csd_add(idx_crs).x_left=tokens_num(9);
            csd_add(idx_crs).y_left=tokens_num(10);
            csd_add(idx_crs).x_right=tokens_num(11);
            csd_add(idx_crs).y_right=tokens_num(12);

        case 21
            %cross-section definition
            %21 5.910 290.697 /
            csd(idx_crs).yzCount=csd(idx_crs).yzCount+1;
            csd(idx_crs).yCoordinates=cat(1,csd(idx_crs).yCoordinates,tokens_num(2));
            csd(idx_crs).zCoordinates=cat(1,csd(idx_crs).zCoordinates,tokens_num(3));
        case 99
            %end of cross-section definition
            inside_crs_block=false;
            continue
    end %switch

end %while

end %function