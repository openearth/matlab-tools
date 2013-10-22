function ddb_saveDFlowFM(opt)
%DDB_SAVEDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveDFlowFM(opt)
%
%   Input:
%   opt =
%
%
%
%
%   Example
%   ddb_saveDFlowFM
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
handles=getHandles;

switch lower(opt)
    
    case{'save'}
        inp=handles.Model(md).Input(ad);
        if ~isfield(handles.Model(md).Input(ad),'mduFile')
            handles.Model(md).Input(ad).mduFile=[handles.Model(md).Input(ad).runid '.mdu'];
        end
        ddb_saveMDU(handles.Model(md).Input(ad).mduFile,inp);

    case{'saveas'}
        [filename, pathname, filterindex] = uiputfile('*.mdu', 'Select MDU File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.mdu');
            handles.Model(md).Input(ad).runid=filename(1:ii-1);
            handles.Model(md).Input(ad).mduFile=filename;
            ddb_saveMDU(filename,handles.Model(md).Input(ad));
        end
        
    case{'saveall'}
    
        if ddb_check_write_extfile(handles)
            if isempty(handles.Model(md).Input.extforcefile)
                [filename, pathname, filterindex] = uiputfile('*.ext', 'Save external focing file','');
                if ~isempty(pathname)
                    curdir=[lower(cd) '\'];
                    if ~strcmpi(curdir,pathname)
                        filename=[pathname filename];
                    end
                    handles.Model(md).Input.extforcefile=filename;
                else
                    return
                end
            end
            ddb_DFlowFM_saveExtFile(handles);

            % And now for the boundaries
            
            for iac=1:handles.Model(md).Input.nrboundaries
                
                % Save pli file
                x=handles.Model(md).Input.boundaries(iac).x;
                y=handles.Model(md).Input.boundaries(iac).y;
                landboundary('write',handles.Model(md).Input.boundaries(iac).filename,x,y);
                
                % Save component files
                for jj=1:length(x)
                    if handles.Model(md).Input.boundaries(iac).nodes(jj).cmp
                        ddb_DFlowFM_saveCmpFile(handles.Model(md).Input.boundaries,iac,jj);
                    end
                    if handles.Model(md).Input.boundaries(iac).nodes(jj).tim
                        ddb_DFlowFM_saveTimFile(handles.Model(md).Input.boundaries,iac,jj,handles.Model(md).Input.refdate);
                    end
                end
            end

            
            
        end
        
        % obs
        if handles.Model(md).Input.nrobservationpoints>0
            if isempty(handles.Model(md).Input.obsfile)
                [filename, pathname, filterindex] = uiputfile('*.xyn', 'Save observation points file','');
                if ~isempty(pathname)
                    curdir=[lower(cd) '\'];
                    if ~strcmpi(curdir,pathname)
                        filename=[pathname filename];
                    end
                    handles.Model(md).Input.obsfile=filename;
                else
                    return
                end
            end
            ddb_DFlowFM_saveObsFile(handles,ad);
        end

        % Crs
        if handles.Model(md).Input.nrcrosssections>0
            if isempty(handles.Model(md).Input.crsfile)
                [filename, pathname, filterindex] = uiputfile('*.xyn', 'Save cross sections file','');
                if ~isempty(pathname)
                    curdir=[lower(cd) '\'];
                    if ~strcmpi(curdir,pathname)
                        filename=[pathname filename];
                    end
                    handles.Model(md).Input.crsfile=filename;
                else
                    return
                end
            end
            ddb_DFlowFM_saveCrsFile(handles.Model(md).Input.crsfile,handles.Model(md).Input.crosssections);
        end
        
        inp=handles.Model(md).Input(ad);
        if ~isfield(handles.Model(md).Input(ad),'mduFile')
            handles.Model(md).Input(ad).mduFile=[handles.Model(md).Input(ad).runid '.mdu'];
        end
        ddb_saveMDU(handles.Model(md).Input(ad).mduFile,inp);
        
end

setHandles(handles);
