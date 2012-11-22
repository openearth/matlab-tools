function ncfile = prob_MCresult2netcdf(MCresult, varargin)
%PROB_MCRESULT2NETCDF  write Monte Carlo result to netcdf file.
%
%   Write the results of a Monte Carlo run, generated with the function MC,
%   to a netcdf file.
%
%   Syntax:
%   ncfile = prob_MCresult2netcdf(MCresult, varargin)
%
%   Input:
%   MCresult =
%   varargin =
%
%   Output:
%   ncfile   =
%
%   Example
%   prob_MCresult2netcdf
%
%   See also MC

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 15 Apr 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT = struct(...
    'ncfile', fullfile(cd, 'MCresult.nc'),...
    'title', 'Monte Carlo results',...
    'history', ['Created on ' datestr(now)],...
    'globalattributes', {{}},...
    'run_id', 0);

OPT = setproperty(OPT, varargin{:});

%%
if ~isscalar(MCresult)
    nMCresult = length(MCresult);
    for iMCresult = 1:nMCresult
        ncfile = prob_MCresult2netcdf(MCresult(iMCresult), varargin{:});
    end
    return
end

ncfile = OPT.ncfile;
n_variables = length(MCresult.Input);
n_samples = MCresult.settings.NrSamples;
n_limitstates = size(MCresult.Output.z,2);
stringsize = 100;

%%
if ~exist(ncfile, 'file')
    % create new file
    nc_create_empty(OPT.ncfile)
    
    % add global atributes
    nc_attput(OPT.ncfile, nc_global, 'title', OPT.title);
    nc_attput(OPT.ncfile, nc_global, 'history', OPT.history);
    % add additional global attributes
    nga = length(OPT.globalattributes);
    for iga = 1:2:nga
        nc_attput(OPT.ncfile, nc_global, OPT.globalattributes{iga}, OPT.globalattributes{iga+1});
    end
    
    % add dimensions
    nc_add_dimension(OPT.ncfile, 'n_variables', n_variables)
    
    nc_add_dimension(OPT.ncfile, 'n_samples', n_samples)
    
    n_params = max(cellfun(@length, {MCresult.Input.Params}));
    nc_add_dimension(OPT.ncfile, 'n_params', n_params)
    
    nc_add_dimension(OPT.ncfile, 'stringsize', stringsize);
    
    nc_add_dimension(OPT.ncfile, 'scalar', 1);
    
    nc_add_dimension(OPT.ncfile, 'n_limitstates', n_limitstates);
    
    nc_add_dimension(OPT.ncfile, 'n_run', 0);
    
    %% add variables
    s = struct(...
        'Name', 'run_id',...
        'Nctype', nc_int,...
        'Dimension', {{'n_run'}},...
        'Attribute', struct(...
        'Name', {'long_name'}, ...
        'Value', {'identifier of run'})...
        );
    nc_addvar(OPT.ncfile, s);

    s = struct(...
        'Name', 'variable_name',...
        'Nctype', nc_char,...
        'Dimension', {{'n_variables' 'stringsize'}},...
        'Attribute', struct(...
        'Name', {'long_name'}, ...
        'Value', {'name of stochastic variable'})...
        );
    nc_addvar(OPT.ncfile, s);
    
    s = struct(...
        'Name', 'probability_distribution',...
        'Nctype', nc_char,...
        'Dimension', {{'n_variables' 'stringsize'}},...
        'Attribute', struct(...
        'Name', {'long_name'}, ...
        'Value', {'probability distribution of stochastic variable'})...
        );
    nc_addvar(OPT.ncfile, s);
    
    s = struct(...
        'Name', 'u',...
        'Nctype', nc_double,...
        'Dimension', {{'n_run', 'n_samples', 'n_variables'}},...
        'Attribute', struct(...
        'Name', {'long_name'}, ...
        'Value', {'coordinate in normal probability space'})...
        );
    nc_addvar(OPT.ncfile, s);
    
    s = struct(...
        'Name', 'P',...
        'Nctype', nc_double,...
        'Dimension', {{'n_run', 'n_samples', 'n_variables'}},...
        'Attribute', struct(...
        'Name', {'long_name'}, ...
        'Value', {'probability value for each variable'})...
        );
    nc_addvar(OPT.ncfile, s);
    
    s = struct(...
        'Name', 'x',...
        'Nctype', nc_double,...
        'Dimension', {{'n_run', 'n_samples', 'n_variables'}},...
        'Attribute', struct(...
        'Name', {'long_name'}, ...
        'Value', {'actual value for each variable'})...
        );
    nc_addvar(OPT.ncfile, s);
    
    s = struct(...
        'Name', 'z',...
        'Nctype', nc_double,...
        'Dimension', {{'n_run', 'n_samples', 'n_limitstates'}},...
        'Attribute', struct(...
        'Name', {'long_name'}, ...
        'Value', {'distance to limit state'})...
        );
    nc_addvar(OPT.ncfile, s);

        s = struct(...
        'Name', 'P_f',...
        'Nctype', nc_double,...
        'Dimension', {{'n_run', 'n_limitstates'}},...
        'Attribute', struct(...
        'Name', {'long_name'}, ...
        'Value', {'probability of failure'})...
        );
    nc_addvar(OPT.ncfile, s);

    %% put variables
    var_names = {MCresult.Input.Name};
    var_blanks = stringsize - cellfun(@length, var_names);
    nvar = length(var_names);
    for ivar = 1:nvar
        var_str(ivar,:) = [var_names{ivar} blanks(var_blanks(ivar))];
    end
    
    nc_varput(OPT.ncfile, 'variable_name', var_str);
    nc_varput(OPT.ncfile, 'probability_distribution', char(cellfun(@char, {MCresult.Input.Distr}, 'UniformOutput', false)));
    
    start_3d = [0 0 0];
else
    % append to existing file
    start_3d = [length(nc_varget(ncfile, 'run_id')) 0 0];
end

count_3d = [length(MCresult) n_samples n_variables];

% derive run_id
if OPT.run_id == 0
    run_id = start_3d(1)+1:start_3d(1)+count_3d(1);
elseif length(OPT.run_id) == count_3d(1)
    run_id = OPT.run_id;
else
    error
end

nc_varput(OPT.ncfile, 'run_id', run_id, start_3d(1), count_3d(1));
nc_varput(OPT.ncfile, 'u', MCresult.Output.u, start_3d, count_3d);
nc_varput(OPT.ncfile, 'P', MCresult.Output.P, start_3d, count_3d);
nc_varput(OPT.ncfile, 'x', MCresult.Output.x, start_3d, count_3d);
nc_varput(OPT.ncfile, 'z', MCresult.Output.z, [start_3d(1:2) 0], [count_3d(1:2) n_limitstates]);
nc_varput(OPT.ncfile, 'P_f', MCresult.Output.P_f, [start_3d(1) 0], [count_3d(1) n_limitstates]);