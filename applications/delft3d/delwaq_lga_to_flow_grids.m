function lga_indexes = delwaq_lga_to_flow_grids(lga_file,grd_files,varargin)
% When combining multiple Delft3D-FLOW grids to a single *.hyd file (to use
% with DELWAQ, e.g. when using a domain decomposition Delft3D-FLOW model)
% the separate gridded FLOW information gets both combined, vectorized and
% aggregated (last one if applied by the modeller).
%
% If DELWAQ results are to be plotted or referenced to the original Delft3D
% grids, excesssive processing is required. This script is aimed at just
% that. Therefore, it uses the combined DELWAQ grid input (*.LGA file)
% combined with all original Delft3D FLOW-grids (list of original files)
% that were used to construct this *.LGA file.
%
% SYNTAX (<> indicates optional in- or output):
%
% <lga_indexes> = delwaq_lga_to_flow_grids(lga_file,grid_files,<delwaq_output>)
%
% INPUT VARIABLES (REQUIRED):
%
% lga_file          Location of the *.lga file, specified in a single line
%                   character string. Can in- or exclude the complete path.
%                   Make sure that the associated *.cco file (equally
%                   named) is also available within the same path.
%
%                   Examples:
%
%                   (1) 'file.lga'
%                   (2) 'D:/tmp_model/some_lga_file.lga'
%
% grid_files        Cellstring of grid files associated with the lga_file
%                   (the grids that were used to construct the *.lga DELWAQ
%                   file). The cellstr can be of any shape, as long as all
%                   used grid-files are present.
%
%                   Examples:
%
%                   (1) {'grid1.grd','grid2.grd','D:/tmp_model/grid3.grd'}
%                   (2) grid_files (Cellstring, e.g. constructed from:
%                       [a,b] = uigetfile('*.grd','','multiselect','on')
%                       grid_files = cellstr([repmat(b,length(a),1) char(a')]);
%
% INPUT VARIABLES (OPTIONAL):
%
% delwaq_output     Location of the DELWAQ output (*.map file), specified
%                   in a single line character string. Can in- or exclude
%                   the complete path. When providing this optional input
%                   variable, the script will verify the relation between
%                   the *.LGA and *.map file.
%
%                   Examples:
%
%                   (1) 'file.map'
%                   (2) 'D:/tmp_model/some_DELWAQ_output_file.map'
%
% OUTPUT VARIABLES (OPTIONAL):
%
% lga_indexes       The output of the script can be stored in an output
%                   variable, in this case called lga_indexes. The output
%                   variable will contain the indices of the aggregated and
%                   vectorized DELWAQ output on each of the provided FLOW
%                   grids, stored in a {N,1} cell, with N the number of
%                   provided (input) FLOW grids.
%________________________________________________________________________
%
%Contact Freek Scheel (freek.scheel@deltares.nl) if bugs are encountered
%              
%See also: delwaq, wlgrid

%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
%       Freek Scheel
%       +31(0)88 335 8241
%       <freek.scheel@deltares.nl>;
%
%       Developed as part of the TO27 project at the Water Institute of the
%       Gulf, Baton Rouge, Louisiana. Please do not make any functional
%       changes to this script, as it is relied upon within this modelling
%       framework.
%
%       Please contact me if errors occur.
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------


lga_data = delwaq('open',lga_file);

if length(varargin)>0
    dwq_data = delwaq('open',varargin{1});

    if size(unique(lga_data.Index(find(lga_data.Index>0))),1) ~= dwq_data.NumSegm
        % Do these files match with eachother?
    end
end

% Remove gridpoints outside of the grid
lga_data.X(find(round(lga_data.X)==-1000)) = NaN;
lga_data.Y(find(round(lga_data.Y)==-1000)) = NaN;

grd_inds = NaN(size(lga_data.X));
for grd_id = 1:size(grd_files,1)
    disp(['Checking grid ' num2str(grd_id) ' out of ' num2str(size(grd_files,1))])
    grd_data{grd_id,1} = wlgrid('read',grd_files{grd_id,1});
    % Just to be sure,remove the area outside of the grid (should already been done) 
    grd_data{grd_id,1}.X(find(round(grd_data{grd_id,1}.X) == round(grd_data{grd_id,1}.MissingValue))) = NaN;
    grd_data{grd_id,1}.Y(find(round(grd_data{grd_id,1}.Y) == round(grd_data{grd_id,1}.MissingValue))) = NaN;
    if strcmp(grd_data{grd_id,1}.CoordinateSystem,'Cartesian')
        err_dist = 1; %Cart.
    else
        err_dist = 0.00001; %Deg.
    end
    for ii=1:size(grd_data{grd_id,1}.X,1)
        for jj=1:size(grd_data{grd_id,1}.X,2)
            if ~isnan(grd_data{grd_id,1}.X(ii,jj)) && ~isnan(grd_data{grd_id,1}.Y(ii,jj))
                [cur_inds_ii,cur_inds_jj] = find(sqrt(((lga_data.X - grd_data{grd_id,1}.X(ii,jj)).^2) + ((lga_data.Y - grd_data{grd_id,1}.Y(ii,jj)).^2)) == min(min(sqrt(((lga_data.X - grd_data{grd_id,1}.X(ii,jj)).^2) + ((lga_data.Y - grd_data{grd_id,1}.Y(ii,jj)).^2)))));
                cur_dist = sqrt(((lga_data.X(cur_inds_ii(1,1),cur_inds_jj(1,1)) - grd_data{grd_id,1}.X(ii,jj)).^2) + ((lga_data.Y(cur_inds_ii(1,1),cur_inds_jj(1,1)) - grd_data{grd_id,1}.Y(ii,jj)).^2));
                if cur_dist <= err_dist
                    % Point lies close enough, else just a NaN is given...:
                    if size(cur_inds_ii,1) == 1
                        % We have found 1 unique point that lies within both the combined and single (grd_ind) grid.
                        % We can use this point in combination with the current ii and jj indices as reference, to construct the grd_inds for grid grd_id.
                        grd_base_ii = cur_inds_ii - ii + 1;
                        grd_base_jj = cur_inds_jj - jj + 1;
                        grd_end_ii  = grd_base_ii+size(grd_data{grd_id,1}.X,1)-1;
                        grd_end_jj  = grd_base_jj+size(grd_data{grd_id,1}.X,2)-1;
                        % Ok, now set the grd_id values:
                        for ii2 = grd_base_ii:grd_end_ii
                            for jj2 = grd_base_jj:grd_end_jj
                                if ~isnan(grd_data{grd_id,1}.X(ii2-cur_inds_ii+ii,jj2-cur_inds_jj+jj)) && ~isnan(grd_data{grd_id,1}.Y(ii2-cur_inds_ii+ii,jj2-cur_inds_jj+jj))
                                    if ~isnan(grd_inds(ii2,jj2))
                                        Error('Unexpected error, please contact the script developer with code 34563489')
                                    end
                                    grd_inds(ii2,jj2) = grd_id;
                                end
                            end
                        end
                    end
                end
            end
            if ~isempty(find(grd_inds==grd_id))
                break
            end
        end
        if ~isempty(find(grd_inds==grd_id))
            break
        end
    end
    % Now for each flow grid, we have the indices of the lga file, lets now couple it to the delwaq output file with help of the index(es):
    lga_indexes{grd_id,1} = lga_data.Index(grd_base_ii:grd_end_ii,grd_base_jj:grd_end_jj);
    lga_indexes{grd_id,1}(find(lga_data.Index(grd_base_ii:grd_end_ii,grd_base_jj:grd_end_jj) < 1)) = NaN;
    
    % pcolor(grd_data{grd_id,1}.X,grd_data{grd_id,1}.Y,lga_indexes{grd_id,1})
end






