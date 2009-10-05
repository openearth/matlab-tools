function UCIT_plotLandboundary(datatypeinfo,dummy)
%PLOTLANDBOUNDARY   plots a landboundary for a given <datatypeinfo>
%
%   This routine finds a landboundary given <datatypeinfo>
%
%   syntax:
%   plotLandboundary(datatypeinfo,landcolor)
%
%   input:
%       datatypeinfo = datatype info from McDatabase
%
%

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl
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

if ismember(datatypeinfo,{...
        'Jarkus Data',...
        'Kaartblad Jarkus', ...
        'Kaartblad Monitoring', ...
        'Kaartblad Vaklodingen'})
    ldb = landboundary('read',which(['Netherlands_inclBelGer_RD.ldb']));
    axis_settings = 1E5*[-0.282042339266554   2.324770614179054   3.720482792355521   6.461840930495095];
    [X,Y]=landboundary('read',which(['Netherlands_inclBelGer_RD.ldb']));

elseif strcmp(datatypeinfo,'Lidar Data US');
    area = UCIT_getInfoFromPopup('TransectsArea');
    switch area
        case {'Oregon'}
            [X,Y] = landboundary('read',which(['OR_coast_UTM5.ldb']));
            ldb2=landboundary('read',which(['ref20OR.ldb'])); % this is their reference line
            axis_settings = 1E6*[0.3382    0.4796    4.6537    5.1275];
        case {'Washington'}
            [X,Y] = landboundary('read',which(['WA_coast1_UTM.ldb']));
            axis_settings = 1E6*[0.367164048997129   0.446396990873151   5.125163267511952   5.370968814517868];
    end
end
fillpolygon([X,Y],'k',[1 1 0.6],100,-100); hold on;
% shph = plot(X,Y,'k','linewidth',1);

if exist('ldb2')
    plot(ldb2(:,1),ldb2(:,2),'color','r','linewidth',2);
end
axis equal;
axis([axis_settings])
set(gca,'color',[0.4 0.6 1])