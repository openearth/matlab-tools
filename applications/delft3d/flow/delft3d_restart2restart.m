function varargout = delft3d_restart2restart(varargin)
% DELFT3D_RESTART2RESTART create flow restart-files for new grids, based on old restart-files
% << beta version! >>
% 
% Interpolates a restart file based on an old grid onto an adjusted new grid. 
% The function is also suitable for DD domains where the new domain overlaps 
% with multiple original domains. In that case, just load the restart- 
% files for all domains.
% 
% required files for the original domain(s):    restart file(s) 
%                                               mdf file(s)
%                                               grid file(s)
% required file for the new domain(s):          grid file(s)
% 
% --- Syntax ---
% DELFT3D_RESTART2RESTART
% simply invoke the function (no input or output arguments required) and 
% specify the requested input files through the user interface.
%
% DELFT3D_RESTART2RESTART('plot')
% An input argument 'plot' can be specified, in order to let the function 
% plot the original and the interpolated fields to the screen, to check the 
% results (press any key after each plot).
%
% [Out] = DELFT3D_RESTART2RESTART;
% Specify one output argument to obtain a structure 'Out' with all field
% data of the new restart files, for all new domains. The format of
% Out(domain_nr) resembles the format as obtained by the function
% delft3d_io_restart.
%
% [Out,Orig] = DELFT3D_RESTART2RESTART;
% Specify two output arguments in order to obtain the abovementioned
% structures ('Out' and 'Orig') for both the new and the original domains,
% respectively.
%
% --- Additional information ---
% The interpolation makes use of Delauney triangulation of the original 
% griddata. In case of multiple grids, the triangulation uses the combined 
% set of all original grids. (used function: TriScatteredInterp)
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
if nargin>0
    if strcmpi(varargin{1},'plot')
        makeplots = true;
    else
        error('Unknow input argument... Give keyword ''plot'', or simply give no input')
    end
else
    makeplots = false;
end
            

if isempty(which('wlgrid.m'))
    wlsettings;
end

%% load data from restart files for all ORIGINAL domain(s)
nOrig   = 0;
name    = 1;
xOrig   = [];
yOrig   = [];
while name~=0
    
    [name,pat]=uigetfile('tri-rst.*',['Load ORIGINAL restart file for DOMAIN-' num2str(nOrig+1)]);
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
        [name,pat]=uigetfile('*.mdf',['Load ORIGINAL mdf file for DOMAIN-' num2str(nOrig)]);
        if name==0
            disp(['Cannot find the mdf file for "tri-rst.' ID.origDomain{nOrig} '.' ID.dateID '.' ID.timeID '"'])
            disp('... user abort')
            return
        end
        mdfName = [pat name];
        D(nOrig) = delft3d_io_restart('read',rstName,mdfName);
        
        
        %%% load and read grid file for domain
        [name,pat]=uigetfile('*.grd',['Load ORIGINAL grid file for DOMAIN-' num2str(nOrig)]);
        if name==0
            disp(['Cannot find the grid file for "tri-rst.' ID.origDomain{nOrig} '.' ID.dateID '.' ID.timeID '"'])
            disp('... user abort')
            return
        end
        [G(nOrig).X, G(nOrig).Y] = wlgrid('read',[pat name]); 
        
        %%% prepare original grids for interpolation
        G(nOrig).Xcor   = center2corner(G(nOrig).X);
        G(nOrig).Ycor   = center2corner(G(nOrig).Y);
        
        %%% exclude cornerpoints of cornered grid: set these to nan
        mask            = false(size(G(nOrig).Xcor));
        mask(1,1)       = true; 
        mask(1,end)     = true; 
        mask(end,1)     = true; 
        mask(end,end)   = true;
        G(nOrig).Xcor(mask) = nan;
        G(nOrig).Ycor(mask) = nan;
        clear mask
        
        %%% combine grids into one vector for scattered interpolation
        G(nOrig).Xcor1D = reshape(G(nOrig).Xcor,[],1);
        G(nOrig).Ycor1D = reshape(G(nOrig).Ycor,[],1);
        xOrig = [xOrig; G(nOrig).Xcor1D]; 
        yOrig = [yOrig; G(nOrig).Ycor1D];
        
    end
    clear rstName mdfName
    
end
clear name pat

%%% exclude nans from interpolation coordinates
maskOrig    = ~isnan(xOrig);
xOrig       = xOrig(maskOrig);
yOrig       = yOrig(maskOrig);


%% load grids for OUPUT domain(s)
nOut    = 0;
name    = 1;
while name~=0
    
    [name,pat]=uigetfile('*.grd',['Load grid file for OUTPUT DOMAIN-' num2str(nOut+1)]);
    if name==0 & nOut==0
        disp('No output domain(s) specified, ... user abort')
        return
    end
     
    if name~=0
        nOut = nOut+1;
        
        [L(nOut).X, L(nOut).Y] = wlgrid('read',[pat name]);
        
        %%% prepare output grids for interpolation
        L(nOut).Xcor    = center2corner(L(nOut).X);
        L(nOut).Ycor    = center2corner(L(nOut).Y);
        
        %%% exclude cornerpoints of cornered grid: set these to nan
        mask            = false(size(L(nOut).Xcor));
        mask(1,1)       = true; 
        mask(1,end)     = true; 
        mask(end,1)     = true; 
        mask(end,end)   = true;
        L(nOut).Xcor(mask) = nan;
        L(nOut).Ycor(mask) = nan;
        clear mask
        
        %%% reshape into vectors for scattered interpolation
        L(nOut).Xcor1D  = reshape(L(nOut).Xcor,[],1);
        L(nOut).Ycor1D  = reshape(L(nOut).Ycor,[],1);
        L(nOut).mask    = ~isnan(L(nOut).Xcor1D);
        L(nOut).Xcor1D  = L(nOut).Xcor1D(L(nOut).mask);
        L(nOut).Ycor1D  = L(nOut).Ycor1D(L(nOut).mask);
        
        
        %%% store info on file name and location
        [dum,ID.outDomain{nOut},ext] = fileparts(name); 
        ID.defaultPath{nOut}         = pat;
        clear dum ext
    end
end
clear name


%% first initiate (empty) new structure for the restart-data
fields = fieldnames(D(1).data);
for idomain = 1:nOut
    for ifield = 1:length(fields)
        N(idomain).data.(fields{ifield}) = [];
    end
end     
        
        
%% interpolate restart-data to output grid(s)
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
        %%% also make a filter for any remaining -999 values!
        zOrig       = zOrig(maskOrig);
        mask999     = (zOrig==-999);
                
        %%% Determine the (scattered) interpolation structures
        TriLinear   = TriScatteredInterp(xOrig(~mask999),yOrig(~mask999),zOrig(~mask999));
        TriNearest  = TriScatteredInterp(xOrig(~mask999),yOrig(~mask999),zOrig(~mask999),'nearest');
        clear zOrig mask999
        
        %%% interpolate zOrig onto the output grid(s), 
        %%% first, determine the linear interpolation for the output grid(s)
        %%% then, fill up remaining gaps with nearest values
        for idomain = 1:nOut
            fprintf('   %s.grd,',ID.outDomain{idomain});
            Zk = zeros(size(L(idomain).Xcor));
            
            linint  = TriLinear(L(idomain).Xcor1D,L(idomain).Ycor1D);
            nearint = TriNearest(L(idomain).Xcor1D,L(idomain).Ycor1D);
            linint(isnan(linint)) = nearint(isnan(linint));
            
            Zk(L(idomain).mask) = linint;
            
            %%% copy data into new restart-structure
            N(idomain).data.(fields{ifield})(:,:,k) = Zk;
            clear Zk linint nearint
        end
        fprintf('\n');
    end
end



%% make plots to check results
if makeplots
    scrsz = get(0,'ScreenSize');
    figure('Position',[scrsz(3)/5 scrsz(4)/5 3*scrsz(3)/5 3*scrsz(4)/5])
    
    for ifield = 1:length(fields)
        if length(size(D(1).data.(fields{ifield})))>2
            nlayers = size(D(1).data.(fields{ifield}),3);
        else
            nlayers = 1;
        end, clear tmp
        
        for k = 1:nlayers
            
            %%% plot original domain(s)
            subplot(1,2,1)
            xlims = [nan nan]; ylims = [nan nan]; zlims = [nan nan];
            for idomain = 1:nOrig
                Z = squeeze(D(idomain).data.(fields{ifield})(:,:,k));
                pcolor(G(idomain).Xcor,G(idomain).Ycor,Z), hold on, axis equal, shading flat
                xlims = [nanmin([xlims(1),minmin(G(idomain).Xcor)])   nanmax([xlims(2),maxmax(G(idomain).Xcor)])];
                ylims = [nanmin([ylims(1),minmin(G(idomain).Ycor)])   nanmax([ylims(2),maxmax(G(idomain).Ycor)])];
                zlims = [nanmin([zlims(1),minmin(Z)])                 nanmax([zlims(2),maxmax(Z)])];
                clear Z
            end
            xlim(xlims), ylim(ylims), caxis(zlims)
            pos = get(gca,'position'); colorbar('EastOutside'); set(gca,'position',pos); clear pos
            title({[fields{ifield} ', k = ' num2str(k)];'original domains '})
            
            %%% plot output domain(s)
            subplot(1,2,2)
            for idomain = 1:nOrig
                Z = squeeze(N(idomain).data.(fields{ifield})(:,:,k));
                pcolor(L(idomain).Xcor,L(idomain).Ycor,Z), hold on, axis equal, shading flat
                clear Z
            end
            xlim(xlims), ylim(ylims), caxis(zlims)
            pos = get(gca,'position'); colorbar('EastOutside'); set(gca,'position',pos); clear pos
            title({[fields{ifield} ', k = ' num2str(k)];'new domains '})
            
            disp('press any key to continue...')
            pause()
            clf
        end % for k = 1:nlayers
        
    end % for ifield = 1:length(fields)
    close(gcf)
    
end % if makeplots



%% write new restart file(s)

for idomain = 1:nOut
    
    [name,pat]=uiputfile('tri-rst.*','Save X,Y annotation file',['tri-rst.' ID.outDomain{idomain} '.' ID.date '.' ID.time '.']);
    if name==0
        name = ['tri-rst.' ID.outDomain{idomain} '.' ID.date '.' ID.time];
        pat  = ID.defaultPath{idomain};
    end
    
    delft3d_io_restart('write',[pat name],N(idomain).data);
    clear pat name
end
    
    
%% return output

if nargout==1
    varargout{1} = N;
elseif nargout==2
    varargout{1} = N;
    varargout{2} = D;
end
    
    
    
    

    
