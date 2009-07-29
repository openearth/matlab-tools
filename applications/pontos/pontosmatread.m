function data = pontosmatread(matfilename)
%PONTOSMATREAD reads the output data from a PonTos mat file and puts them
% in a struct (ALPHA RELEASE, UNDER CONSTRUCTION)
%
%   PonTos is an integrated conceptual model for Shore Line Management,
%   developed to assess the long-term and large-scale development
%   of coastal stretches. It is originally based on the multi-layer model
%   that was used to predict the development of the Dutch Wadden coast
%   [Steetzel, 1995].
%
%   The output of the PonTos-model for a specific case is gathered in a
%   file Case.MAT. This is a TEGAGX formatted ASCII file that has no
%   relation with Matlab mat files.
%
%   Syntax:
%   data = pontosmatread(matfilename)
%
%   Input:
%   matfilename  = filename of the Pontos mat files
%
%   Output:
%   data = struct containing PonTos output blocks
%
%   Example
%   matfilename =
%   'l:\A1367_Planstudie-Delflandse-kust\PonTos\Results\Run_t_Sch_PBU1n_50.mat';
%   data = pontosmatread(matfilename);
%
%   See also tekal.m from the Delft3D matlab toolbox

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Alkyon Hydraulic Consultancy & Research
%       Bart Grasmeijer
%
%       bart.grasmeijer@alkyon.nl
%
%       P.O. Box 248
%       8300 AE Emmeloord
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Jul 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: oettemplate.m 688 2009-07-15 11:46:33Z damsma $
% $Date: 2009-07-15 13:46:33 +0200 (Wed, 15 Jul 2009) $
% $Author: damsma $
% $Revision: 688 $
% $HeadURL: https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab/general/oet_template/oettemplate.m $
% $Keywords: $

%%


fid = fopen(matfilename);
tline = fgetl(fid);
while ischar(tline)
    tline = fgetl(fid);
    if findstr(tline,'active layers');                                      % find number of active layers
        tmpline = tline;
        tmpline(findstr(tline,'active layers'):end) = [];
        tmpline(1) = [];
        nroflayers = str2double(tmpline);
    end

    if findstr(tline,'specific sections active');                           % find number of active sections
        tmpline = tline;
        tmpline(findstr(tline,'specific sections active'):end) = [];
        tmpline(1) = [];
        nrofsections = str2double(tmpline);
    end
    
    if findstr(tline,'groyne(s) active');                                   % find number of active groynes
        tmpline = tline;
        tmpline(findstr(tline,'groyne(s) active'):end) = [];
        tmpline(1) = [];
        nrofgroynes = str2double(tmpline);
    end
    
    if findstr(tline,'output intervals');                                   % find number of active layers
        tmpline = tline;
        tmpline(findstr(tline,'output intervals'):end) = [];
        tmpline(1) = [];
        outputintervals = str2double(tmpline);
        tline = fgetl(fid);
        tmpline = tline;
        tmpline(1:12) = [];
        tmpline(findstr(tmpline,'-'):end) = [];
        tstart = str2double(tmpline);
        tmpline = tline;
        tmpline(1:findstr(tmpline,'-')) = [];
        tmpline(findstr(tmpline,'yr'):end) = [];
        tstop = str2double(tmpline);
    end
end
fclose(fid);

outputtimes = tstart:(tstop-tstart)/(outputintervals-1):tstop;

SGi = NaN(nrofgroynes,1);                                                   % Structure - Groyne
SBi = NaN(nrofsections,1);                                                  % Section boundarues
NLSi = NaN(outputintervals-1,1);                                            % Distribution of Layer Auto-Nourished Volumes per section
NLXi = NaN(outputintervals-1,1);                                            % Longshore distribution of Layer Auto-Nourished Volumes
QTi = NaN(outputintervals,1);                                               % Total yearly Tide-induced longshore transport rate

FileInfo = tekal('open',matfilename);

for i = 1:length(FileInfo.Field)
    for j = 1:outputintervals
        if strcmp(FileInfo.Field(i).Name,['NLS',sprintf('%02.0f',j)])
            NLSi(j) = i;
        end
        if strcmp(FileInfo.Field(i).Name,['NLX',sprintf('%02.0f',j)])
            NLXi(j) = i;
        end
        if strcmp(FileInfo.Field(i).Name,['QT',sprintf('%02.0f',j)])
            QTi(j) = i;
        end
    end
    for j = 1:nrofgroynes
        if strcmp(FileInfo.Field(i).Name,['SG',sprintf('%02.0f',j)])
            SGi(j) = i;
        end
    end
    if strcmp(FileInfo.Field(i).Name,'SGA')
        SGAi = i;
    end
    for j = 1:nrofsections+1
        if strcmp(FileInfo.Field(i).Name,['SB',sprintf('%02.0f',j)])
            SBi(j) = i;
        end
    end
end

for j = 1:nrofgroynes
    data.SG(j).values = tekal('read',FileInfo,SGi(j));                      % Structure - Groyne; Outline of structure dimensions
end

data.SGA.values = tekal('read',FileInfo,SGAi);                              % Structure - All groynes; Outline of structure dimensions

for j = 1:nrofsections+1
    data.SB(j).values = tekal('read',FileInfo,SBi(j));                      % Section boundaries
end

for j = 1:outputintervals-1
    data.NLS(j).years = outputtimes(j+1);                                   % Distribution of Layer Auto-Nourished Volumes per section
    data.NLS(j).values = tekal('read',FileInfo,NLSi(j));
    data.NLX(j).years = outputtimes(j+1);                                   % Longshore distribution of Layer Auto-Nourished Volumes
    data.NLX(j).values = tekal('read',FileInfo,NLXi(j));
end

for j = 1:outputintervals
    data.QT(j).years = outputtimes(j);                                      % Total yearly Tide-induced longshore transport rate
    data.QT(j).values = tekal('read',FileInfo,QTi(j));
end



