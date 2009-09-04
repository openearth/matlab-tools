function UCIT_saveDataUS(d)
%UCIT_SAVEDATAUS  saves data of gui into matfile
%
%
%   See also plotAlongshore

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
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
%   --------------------------------------------------------------------clear selecteditems;clc;

hf=findobj('tag','mapWindow');
if isempty(hf)
    errordlg('Make Transect overview figure first')
    return
end

par=findobj('tag','par');
if ~isempty(par)
    close(par)
end


if ~isempty(get(findobj('Tag','beginTransect'),'value'))

    %     d = DBGetTableEntryRaw('transect','datatypeinfo','Lidar Data US','year','2002');

    fh = findobj('tag','mapWindow');
    d=get(fh,'UserData');

    beginTransect = d(get(findobj('Tag','beginTransect'),'value')).transectID;
    endTransect = d(get(findobj('Tag','endTransect'),'value')).transectID;
    
    if str2num(beginTransect)==str2num(endTransect)
        warning('Begintransect is equal to endtransect')
    end

    if str2num(beginTransect)>str2num(endTransect)
        x=findobj('Tag','beginTransect');
        t=get(findobj('Tag','beginTransect'),'value');
        set(x,'value',get(findobj('Tag','endTransect'),'value'));
        y=findobj('Tag','endTransect');
        set(y,'value',t);
        beginTransect = d(get(findobj('Tag','beginTransect'),'value')).transectID;
        endTransect = d(get(findobj('Tag','endTransect'),'value')).transectID;
    end

    d = SelectTransectsUS('Lidar Data US','2002',beginTransect,endTransect);

else
    d = SelectTransectsUS;
end

[FileName,PathName] = uiputfile('d:\*.mat','Save transects to mat-file', 'Saved_transects.mat');
if FileName==0 & PathName==0
    return
else

save([PathName,FileName],'d')

end



