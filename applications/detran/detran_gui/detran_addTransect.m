function detran_addTransect
%DETRAN_ADDTRANSECT Detran GUI function to add a transect
%
%   See also detran

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
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

[but,fig]=gcbo;

set(findobj(fig,'tag','detran_plotTransectBox'),'Value',1);
detran_plotTransArbCS;

data=get(fig,'userdata');
ldb=data.transects;

if isempty(data.edit)
    return
end

if ~isempty(data.transectHandles)
    p=data.transectHandles{1};
    h1=data.transectHandles{2};
    t1=data.transectHandles{3};
    CS=data.transectData(:,1);
    PlusCS=data.transectData(:,2);
    MinCS=data.transectData(:,3);
else
    p=[];
    h1=[];
    t1=[];
    CS=[];
    PlusCS=[];
    MinCS=[];
end
vecSc=str2num(get(findobj(fig,'tag','detran_vecScaling'),'String'));

[xClick, yClick,b]=ginput(2);
if b~=1
    return
elseif b==1
    edit=data.edit;
    strucNames=fieldnames(edit);
    for ii=1:length(strucNames)
        eval([strucNames{ii} '=edit.' strucNames{ii} ';']);
    end
    period=detran_getPeriod;
    pores=detran_getPoreVolume;
    labelFac=str2num(get(findobj(fig,'tag','detran_transLabelFactor'),'String'));
    ldb=[ldb; xClick(1) yClick(1) xClick(2) yClick(2)];
    [xt,yt]=detran_uvData2xyData(yatu,yatv,alfa);
    [CS(end+1,1), PlusCS(end+1,1), MinCS(end+1,1)]=detran_TransArbCSEngine(xcor,ycor,xt,yt,ldb(end,1:2),ldb(end,3:4));
    [p(:,end+1),h1(:,end+1),t1(:,end+1)]=detran_plotTransportThroughTransect(ldb(end,1:2),ldb(end,3:4),labelFac.*period.*CS(end)./(1-pores),vecSc);
    data.transects=ldb;
    data.transectData=[CS PlusCS MinCS];
    data.transectHandles={p,h1,t1};
end
set(fig,'userdata',data);
set(findobj(fig,'tag','detran_plotTransectBox'),'Value',1);