function [c_ini c_end] = aggregation_get_coastline_Delft3D_4(map_file,varargin)

%   Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Freek Scheel
%
%       Freek.Scheel@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------
%
% This tool is developed as part of the research cooperation between
% Deltares and the Korean Institute of Science and Technology (KIOST).
% The development is funded by the CoMIDAS project of the South Korean
% government and the Deltares strategic research program Coastal and
% Offshore Engineering. This financial support is highly appreciated.

OPT.z_level   = 0;
OPT.time_inds = [];
[OPT] = setproperty(OPT,varargin);

d3d_handle = qpfopen(map_file);

if isempty(OPT.time_inds)
    OPT.time_inds = [1 length(get_d3d_output_times(d3d_handle))];
end

bed_levels = qpread(d3d_handle,'bed level in water level points','griddata',[OPT.time_inds(1) OPT.time_inds(2)]);

fig = figure('visible','off');
[c_ini,~]  = contour(bed_levels.X,bed_levels.Y,squeeze(bed_levels.Val(1,:,:)),[OPT.z_level OPT.z_level]);
[c_end,~]  = contour(bed_levels.X,bed_levels.Y,squeeze(bed_levels.Val(2,:,:)),[OPT.z_level OPT.z_level]);
close(fig);
c_ini = c_ini';
c_end = c_end';
c_ini(find(min(abs(c_ini),[],2)==0),:)=NaN;
c_end(find(min(abs(c_end),[],2)==0),:)=NaN;
% Remove start and trailing NaN's:
if ~isempty(find(find(isnan(c_ini(:,1))) == 1))
    c_ini = c_ini(2:end,:);
end
if ~isempty(find(find(isnan(c_ini(:,1))) == size(c_ini,1)))
    c_ini = c_ini(2:end,:);
end
if ~isempty(find(find(isnan(c_end(:,1))) == 1))
    c_end = c_end(2:end,:);
end
if ~isempty(find(find(isnan(c_end(:,1))) == size(c_end,1)))
    c_end = c_end(2:end,:);
end

end