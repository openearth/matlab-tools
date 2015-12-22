function [PRNdata]=relativePRN(PRNdata,PRNdataREF,Xlimits,Tlimits)
%relativePRN computes the impact with respect to a reference by substracting a reference PRNdata structure from the PRNdata.
%
%   Syntax:
%     function [PRNdata]=relativePRN(PRNdata)
% 
%   Input:
%     PRNdata              data structure that has been read with readPRN.m (either a single or multiple data structure or cell, i.e. PRNdata(ii).x etc)
%     PRNdataREF           reference data structure that has been read with readPRN.m
%     Xlimits              (optional) provide xlimits of model [distance in meter along the coast]
%     Tlimits              (optional) provide time limits [year w.r.t. model reference time]
%  
%   Output:
%     PRNdata              structure with PRNdata (with flipped x-direction)
%
%   Example:
%     PRNdata    = readPRN('example.PRN');
%     PRNdataREF = readPRN('exampleREF.PRN');
%     Xlimits    = [0,12000];
%     Tlimits    = [0,10];
%     [PRNdata2] = relativePRN(PRNdata,PRNdataREF)
%
%   See also 
%     readPRN

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: flipPRN.m 8631 2013-05-16 14:22:14Z huism_b $
% $Date: 2013-05-16 16:22:14 +0200 (Thu, 16 May 2013) $
% $Author: huism_b $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/engines/flipPRN.m $
% $Keywords: $

    if nargin<3
    Xlimits=[];
    end
    if nargin<4
    Tlimits=[];
    end

    PRN2data=struct;

    for ii=1:length(PRNdata)
        %% COMPUTE IMPACT
        PRNdata2(ii).files       = [PRNdata(ii).files,'-',PRNdataREF(1).files];              % {'Com4m.prn'}
        PRNdata2(ii).timestep    = PRNdata(ii).timestep;                                     % [61x1 double]
        PRNdata2(ii).year        = PRNdata(ii).year;                                         % [61x1 double]
        PRNdata2(ii).no          = PRNdata(ii).no         -PRNdataREF(1).no         ;        % [304x61 double]
        PRNdata2(ii).x           = repmat(PRNdata(ii).x(:,1),[1,size(PRNdata(ii).x,2)]) + PRNdata(ii).x-PRNdataREF(1).x;        % [304x61 double]
        PRNdata2(ii).y           = repmat(PRNdata(ii).y(:,1),[1,size(PRNdata(ii).y,2)]) + PRNdata(ii).y-PRNdataREF(1).y;        % [304x61 double]
        PRNdata2(ii).z           = PRNdata(ii).z          -PRNdataREF(1).z          ;        % [304x61 double]
        PRNdata2(ii).zminz0      = PRNdata(ii).zminz0     -PRNdataREF(1).zminz0     ;        % [304x61 double]
        PRNdata2(ii).sourceyear  = PRNdata(ii).sourceyear -PRNdataREF(1).sourceyear ;        % [304x61 double]
        PRNdata2(ii).sourcetotal = PRNdata(ii).sourcetotal-PRNdataREF(1).sourcetotal;        % [304x61 double]
        PRNdata2(ii).stored      = PRNdata(ii).stored     -PRNdataREF(1).stored     ;        % [304x61 double]
        PRNdata2(ii).ray         = PRNdata(ii).ray;                                          % [305x61 double]
        PRNdata2(ii).alfa        = PRNdata(ii).alfa;                                         % [305x61 double]
        PRNdata2(ii).alfaDIFF    = PRNdata(ii).alfa       -PRNdataREF(1).alfa       ;        % [305x61 double]
        PRNdata2(ii).transport   = PRNdata(ii).transport  -PRNdataREF(1).transport  ;        % [305x61 double]
        PRNdata2(ii).volume      = PRNdata(ii).volume     -PRNdataREF(1).volume     ;        % [305x61 double]
        PRNdata2(ii).xdist       = PRNdata(ii).xdist;                                        % [305x1 double]
        PRNdata2(ii).xdist2      = PRNdata(ii).xdist2;                                       % [304x1 double]

        %% FILTER X-LOCATIONS
        if ~isempty(Xlimits)
        XID2 = find(PRNdata2(ii).xdist2>=Xlimits(1) & PRNdata2(ii).xdist2<=Xlimits(2));
        XID1 = unique([XID2;XID2+1]);
        PRNdata2(ii).no          = PRNdata2(ii).no(XID2,:);           % [304x61 double]
        PRNdata2(ii).x           = PRNdata2(ii).x(XID2,:);            % [304x61 double]        
        PRNdata2(ii).y           = PRNdata2(ii).y(XID2,:);            % [304x61 double]         
        PRNdata2(ii).z           = PRNdata2(ii).z(XID2,:);            % [304x61 double]
        PRNdata2(ii).zminz0      = PRNdata2(ii).zminz0(XID2,:);       % [304x61 double]
        PRNdata2(ii).sourceyear  = PRNdata2(ii).sourceyear(XID2,:);   % [304x61 double]
        PRNdata2(ii).sourcetotal = PRNdata2(ii).sourcetotal(XID2,:);  % [304x61 double]
        PRNdata2(ii).stored      = PRNdata2(ii).stored(XID2,:);       % [304x61 double]
        PRNdata2(ii).ray         = PRNdata2(ii).ray(XID1,:);           % [305x61 double]  
        PRNdata2(ii).alfa        = PRNdata2(ii).alfa(XID1,:);          % [305x61 double]
        PRNdata2(ii).alfaDIFF    = PRNdata2(ii).alfaDIFF(XID1,:);      % [305x61 double]
        PRNdata2(ii).transport   = PRNdata2(ii).transport(XID1,:);     % [305x61 double]
        PRNdata2(ii).volume      = PRNdata2(ii).volume(XID1,:);        % [305x61 double]
        PRNdata2(ii).xdist       = PRNdata2(ii).xdist(XID1,:);         % [305x1 double]
        PRNdata2(ii).xdist2      = PRNdata2(ii).xdist2(XID2,:);       % [304x1 double]
        end
        
        %% FILTER TIME-IDS
        if ~isempty(Tlimits)
        TID = find(PRNdata2(ii).year>=Tlimits(1) & PRNdata2(ii).year<=Tlimits(2));
        PRNdata2(ii).timestep    = PRNdata2(ii).timestep(TID);       % [61x1 double]
        PRNdata2(ii).year        = PRNdata2(ii).year(TID);           % [61x1 double]
        PRNdata2(ii).no          = PRNdata2(ii).no(:,TID);           % [304x61 double]
        PRNdata2(ii).x           = PRNdata2(ii).x(:,TID);            % [304x61 double]
        PRNdata2(ii).y           = PRNdata2(ii).y(:,TID);            % [304x61 double]
        PRNdata2(ii).z           = PRNdata2(ii).z(:,TID);            % [304x61 double]
        PRNdata2(ii).zminz0      = PRNdata2(ii).zminz0(:,TID);       % [304x61 double]
        PRNdata2(ii).sourceyear  = PRNdata2(ii).sourceyear(:,TID);   % [304x61 double]
        PRNdata2(ii).sourcetotal = PRNdata2(ii).sourcetotal(:,TID);  % [304x61 double]
        PRNdata2(ii).stored      = PRNdata2(ii).stored(:,TID);       % [304x61 double]
        PRNdata2(ii).ray         = PRNdata2(ii).ray(:,TID);          % [305x61 double]  
        PRNdata2(ii).alfa        = PRNdata2(ii).alfa(:,TID);         % [305x61 double]
        PRNdata2(ii).alfaDIFF    = PRNdata2(ii).alfaDIFF(:,TID);     % [305x61 double]
        PRNdata2(ii).transport   = PRNdata2(ii).transport(:,TID);    % [305x61 double]
        PRNdata2(ii).volume      = PRNdata2(ii).volume(:,TID);       % [305x61 double]    
        end
    end

end