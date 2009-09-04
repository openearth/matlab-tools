function UCIT_clbPlotUSGS%(d)
%UCIT_CLBPLOTUSGS  callback of gui plotAlongshore
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

    % get data from userdata mapWindow
    fh = findobj('tag','UCIT_mainWin');
    d=get(fh,'UserData');

    % get begin and endtransect from d
    beginTransect = d.transectID(get(findobj('Tag','beginTransect'),'value'));
    endTransect = d.transectID(get(findobj('Tag','endTransect'),'value'));

    % if the selected end transect is smaller than the begin transect reverse the two
    if str2double(beginTransect) > str2double(endTransect)
        x=findobj('Tag','beginTransect');
        t=get(findobj('Tag','beginTransect'),'value');
        set(x,'value',get(findobj('Tag','endTransect'),'value'));
        y=findobj('Tag','endTransect');
        set(y,'value',t);
        beginTransect = d(get(findobj('Tag','beginTransect'),'value')).transectID;
        endTransect = d(get(findobj('Tag','endTransect'),'value')).transectID;
    end

    d = UCIT_SelectTransectsUS('Lidar Data US','2002',beginTransect,endTransect);

else
    d = UCIT_SelectTransectsUS;
end

USGSParameters      = {'Significant wave height','Peak wave period','Wave length (L0)','Shoreline position','Beach slope','Bias','Mean High Water Level'};
USGSParametersshort = {'H_s','T_p','L_0','Shoreline','\beta','Bias','Z_m_h_w'};
selecteditems       = get(findobj('Tag','Input'),'Value');

lat=get(findobj('tag','lattitude'),'value');
refline=get(findobj('tag','refline'),'value');

if lat==1 && refline==1
    errordlg('Select either lattitude or distance along reference line')
else

    sp4 = figure; ah4 = axes;
    set(sp4, 'visible','off', 'Units','normalized')
    set(sp4, 'tag','par','name','UCIT - Parameter selection');
    [sp4, ah] =  UCIT_prepareFigureN(2, sp4, 'UL', ah4);
    set(findobj('tag','par'), 'Position',UCIT_getPlotPosition('UL'));

    counter=0;
    
    for i=selecteditems;
        counter=counter+1;
        subplot(length(selecteditems),1,counter);
        x=str2double(d.transectID); 
        if lat==1
            x=(d.shoreLat);
        end
        if refline==1
            x=0:2:length(d.transectID)*2;
        end

        
       parameter = num2str(i);
        switch parameter
            case num2str(1)
                y=d.significant_wave_height ;
            case num2str(2)
                y=d.significant_wave_height ;
            case num2str(3)
                y=d.deep_water_wave_length;
            case num2str(4)
                y=d.shorepos;
            case num2str(5)
                y=d.beach_slope;
            case num2str(6)
                y=d.bias;
            case num2str(7)
                y=vertcat(d.mean_high_water);
        end
        
        a = get(findobj('Tag','beginTransect'),'value');
        b = get(findobj('Tag','endTransect'),'value');
        
%         figure(sp4)
        plot(x(a:b),y(a:b),'color','b','linewidth',2);
        grid on;box on;
        title([]);
        font=12-length(selecteditems);
        set(gca, 'fontsize',font);

        if lat==1
            xlabel('Lattitude (degrees)');
        end
        if refline==1
            xlabel('Distance along reference line (m)');
        end
        if lat==0 && refline==0
            xlabel('Profile number');
        end

        ylabel(USGSParametersshort{i});

        clear y
    end
    set(findobj('tag','par'), 'visible', 'on');    
    figure(findobj('tag','par'))
    set(findobj('tag','par'), 'Position', UCIT_getPlotPosition('UL'));

end

