% RESTART2RESTART create rst-files for new grids, based on old rst-files
% << beta version! >>
% 
% Interpolates a restart file based on an old grid onto an adjusted new grid. 
% The function is also suitable for DD domains where the new domain overlaps 
% with multiple original domains. In that case, just load the restart 
% files for all domains.
% 
% required from the original domain(s):   restart file(s) 
%                                         mdf file(s)
%                                         grid file(s)
% required from the new domain(s):        grid file(s)
% 
% syntax:
% simply invoke the function and specify the requested input files through
% the user interface.
%
% The interpolation makes use of Delauney triangulation of the original 
% grid points. In case of multiple grids, the triangulation uses the
% combined set of all original grids. (used function: TriScatteredInterp)
%
% The best results are achieved when the new domain is entirely covered by 
% the original domain(s) and when the resolution is comparable (or lower). 
% In areas where the new domain is not covered by the original domain(s), 
% the value from the nearest grid-point on the old domain(s) will be used.
% 
% Note that, when using these newly generated files, some additional spinup 
% time will still be required in the flow-computation, since there can still 
% be (small) interpolation errors, especially near domain boundaries
%
% see also: delft3d_io_restart

% TO DO: add option to check the generated fields in plots
% TO DO: don't ask for <overwrite> when delft3d_io_restart is called from
% within this function (needs to be adjusted in delft3d_io_restart.m)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Claire van Oeveren Theeuwes
%
%       claire.vanoeveren@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 3 Aug 2010
% Created with Matlab version: 7.10.0 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $


%%
if isempty(which('wlgrid.m'))
    wlsettings;
end

%% load data from restart files for all ORIGINAL domain(s)
nOrig   = 0;
name    = 1;
xOrig   = [];
yOrig   = [];
while name~=0
    
    [name,pat]=uigetfile('tri-rst.*',['Load original restart file for domain' num2str(nOrig+1)]);
    if name==0 & nOrig==0
        return
    end
    
    
    if name~=0
        nOrig = nOrig+1;
        
        %%% get name-information of restart file
        [dum,rest]                  = strtok(name,'.');
        [ID.origDomain{nOrig},rest] = strtok(rest,'.');
        [ID.date,ID.time]           = strtok(rest,'.');
        ID.time                     = strtok(ID.time,'.');
        ID.origPath{nOrig}          = pat;
        clear dum rest
        
        %%% load mdf file for domain and create restart data-structure
        rstName = [pat name];
        [name,pat]=uigetfile('*.mdf',['Load original mdf file for domain' num2str(nOrig)]);
        if name==0
            disp(['Cannot find the mdf file for "tri-rst.' ID.origDomain{nOrig} '.' ID.dateID '.' ID.timeID '"'])
            disp('... user abort')
            return
        end
        mdfName = [pat name];
        D(nOrig) = delft3d_io_restart('read',rstName,mdfName);
        
        
        %%% load and read grid file for domain
        [name,pat]=uigetfile('*.grd',['Load original grid file for domain' num2str(nOrig)]);
        if name==0
            disp(['Cannot find the grid file for "tri-rst.' ID.origDomain{nOrig} '.' ID.dateID '.' ID.timeID '"'])
            disp('... user abort')
            return
        end
        [G(nOrig).X, G(nOrig).Y] = wlgrid('read',[pat name]); 
        
        
        %%% prepare original grids for interpolation
        G(nOrig).Xcen   = center2corner(G(nOrig).X);
        G(nOrig).Ycen   = center2corner(G(nOrig).Y);
        G(nOrig).Xcen1D = reshape(G(nOrig).Xcen,[],1);
        G(nOrig).Ycen1D = reshape(G(nOrig).Ycen,[],1);
        
        %%% combine grids into one vector for all original domains
        xOrig = [xOrig; G(nOrig).Xcen1D]; 
        yOrig = [yOrig; G(nOrig).Ycen1D];
        
    end
    clear rstName mdfName
    
end
clear name pat

%%% remove nans from interpolation coordinates
maskOrig    = ~isnan(xOrig);
xOrig       = xOrig(maskOrig);
yOrig       = yOrig(maskOrig);


%% load grids for NEW domain(s)
nNew    = 0;
name    = 1;
while name~=0
    
    [name,pat]=uigetfile('*.grd',['Load grid file for new domain' num2str(nNew+1)]);
    if name==0 & nNew==0
        disp('No new domain(s) specified, ... user abort')
        return
    end
     
    if name~=0
        nNew = nNew+1;
        
        [L(nNew).X, L(nNew).Y] = wlgrid('read',[pat name]);
        
        %%% prepare new grids for interpolation
        L(nNew).Xcen    = center2corner(L(nNew).X);
        L(nNew).Ycen    = center2corner(L(nNew).Y);
        L(nNew).Xcen1D  = reshape(L(nNew).Xcen,[],1);
        L(nNew).Ycen1D  = reshape(L(nNew).Ycen,[],1);
        L(nNew).mask    = ~isnan(L(nNew).Xcen1D);
        L(nNew).Xcen1D  = L(nNew).Xcen1D(L(nNew).mask);
        L(nNew).Ycen1D  = L(nNew).Ycen1D(L(nNew).mask);
        
        %%% store info on file name and location
        [dum,ID.newDomain{nNew},ext] = fileparts(name); 
        ID.defaultPath{nNew}         = pat;
        clear dum ext
    end
end
clear name


%% first initiate (empty) new structure for the restart-data
fields = fieldnames(D(1).data);
for idomain = 1:nNew
    for ifield = 1:length(fields)
        N(idomain).data.(fields{ifield}) = [];
    end
end     
        
        
%% interpolate restart-data to new grid(s)
for ifield = 1:length(fields)
    
    %%% determine the number of layers in the field
    tmp     = D(1).data.(fields{ifield});
    if length(size(tmp))>2
        nlayers = size(tmp,3);
    else
        nlayers = 1;
    end, clear tmp
    
    
    for k = 1:nlayers
        fprintf('Now interpolating field %s, layer %i,...\n',fields{ifield},k);
        fprintf('\t... for domain(s):');
        %%% load data data per layer (from all original domains) into 1 vector
        zOrig   = [];
        for idomain = 1:nOrig
            tmp     = squeeze(D(idomain).data.(fields{ifield})(:,:,k));
            zOrig   = [zOrig; reshape(tmp,[],1)];
        end, clear idomain
        
        %%% remove values outside the grid (determined by nan-values in grid)
        %%% and determine the (scattered) interpolation structures
        zOrig       = zOrig(maskOrig);
        TriLinear   = TriScatteredInterp(xOrig,yOrig,zOrig);
        TriNearest  = TriScatteredInterp(xOrig,yOrig,zOrig,'nearest');
        clear zOrig
        
        %%% interpolate zOrig onto the new grid(s), 
        %%% first, determine the linear interpolation for the new grid(s)
        %%% then, fill up remaining gaps with nearest values
        for idomain = 1:nNew
            fprintf('   %s.grd,',ID.newDomain{idomain});
            Zk = zeros(size(L(idomain).Xcen));
            
            linint  = TriLinear(L(idomain).Xcen1D,L(idomain).Ycen1D);
            nearint = TriNearest(L(idomain).Xcen1D,L(idomain).Ycen1D);
            linint(isnan(linint)) = nearint(isnan(linint));
            
            Zk(L(idomain).mask) = linint;
            
            %%% copy data into new restart-structure
            N(idomain).data.(fields{ifield})(:,:,k) = Zk;
            clear Zk linint nearint
        end
        fprintf('\n');
    end
end


%% write new restart file(s)

for idomain = 1:nNew
    
    [name,pat]=uiputfile('tri-rst.*','Save X,Y annotation file',['tri-rst.' ID.newDomain{idomain} '.' ID.date '.' ID.time '.']);
    if name==0
        name = ['tri-rst.' ID.newDomain{idomain} '.' ID.date '.' ID.time];
        pat  = ID.defaultPath{idomain};
    end
    
    delft3d_io_restart('write',[pat name],N(idomain).data);
    clear pat name
end
    
    
    
    
    
    
    
    
