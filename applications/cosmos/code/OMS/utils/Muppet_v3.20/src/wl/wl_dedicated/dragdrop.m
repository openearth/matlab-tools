function dragdrop(cmd)
%DRAGDROP Drag 'n drop example
%         Just type DRAGDROP to start

% Dec. 7, 2001, H.R.A. Jagers
%               WL | Delft Hydraulics, The Netherlands

if isempty(gcbf)
    F=figure('windowbuttondownfcn','dragdrop down');
    A=subplot(1,3,2:3);
    set(A,'tag','plotaxes','units','pixels');
    L=line('xdata',[],'ydata',[],'tag','plotline','marker','.','linestyle','none');
    uicontrol('tag','listbox', ...
        'style','listbox', ...
        'units','normalized', ...
        'position',[0.05 0.1 0.25 0.825], ...
        'backgroundcolor','w', ...
        'string',{'x','x squared','sin x','cos x','tan x','asin x','acos x','atan x','log x','exp x','sinh x','cosh x','tanh x','asinh x','acosh x','atanh x',}, ...
        'units','pixels', ...
        'max',2, ...
        'fontunits','pixels', ...
        'enable','inactive')
    uicontrol('tag','dragbox', ...
        'style','text', ...
        'units','pixels', ...
        'backgroundcolor',[0 0 0.5], ...
        'foregroundcolor','w', ...
        'enable','inactive', ...
        'horizontalalignment','left', ...
        'visible','off')
else
    F=gcbf;
    DB=findobj(F,'tag','dragbox');
    if strcmp(cmd,'down') & strcmp(get(DB,'visible'),'on') % Oops, something went wrong ...
        cmd='up';
    end
    switch cmd
    case 'down'
        O=get(F,'currentobject');
        P=get(F,'currentpoint');
        % Was the click on top of the listbox?
        if strcmp(get(O,'tag'),'listbox')
            % Was it on top of an item?
            fs=get(O,'fontsize'); % fontsize in pixels
            lp=get(O,'position'); % listbox position in pixels
%            fs=get(F,'position'); % figure size in pixels
            fi=get(O,'listboxtop'); % first item =
            it=ceil((lp(2)+lp(4)-P(2)-4)/(1.215*fs))-1+fi;
            itll=lp(2)+lp(4)-4-(it-fi+1)*1.215*fs;
            itlu=lp(2)+lp(4)-4-(it-fi)*1.215*fs;
            str=get(O,'string');
            if it>length(str) | it<1
                set(O,'value',[])
            else
                set(O,'value',it)
                set(F,'windowbuttonmotionfcn','dragdrop drag')
                set(F,'windowbuttonupfcn','dragdrop up')
                dbp=[lp(1)+2 itll lp(3)-20 itlu-itll];
                set(DB,'position',dbp, ...
                    'visible','on', ...
                    'string',[' ' str{it}], ...
                    'userdata',[it P-dbp(1:2)])
            end
        end
    case 'drag'
        P=get(F,'currentpoint');
        dbp=get(DB,'position');
        UD=get(DB,'userdata');
        dbp(1:2)=P-UD(2:3);
        set(DB,'position',dbp);
    case 'up'
        set(F,'windowbuttonmotionfcn','')
        set(F,'windowbuttonupfcn','')
        P=get(F,'currentpoint');
        UD=get(DB,'userdata');
        set(DB,'visible','off');
        A=findobj(F,'tag','plotaxes');
        L=findobj(A,'tag','plotline');
        LUD=get(L,'userdata');
        ap=get(A,'position');
        LB=findobj(F,'tag','listbox');
        str=get(LB,'string');
        if (abs(P(1)-ap(1))<20) & (P(2)>ap(2)) & (P(2)<ap(2)+ap(4)) % y
            axes(A);
            ylabel(str{UD(1)})
            LUD.Y=getdata(str{UD(1)},-pi:.1:pi);
        elseif (abs(P(2)-ap(2))<20) & (P(1)>ap(1)) & (P(1)<ap(1)+ap(3)) % x
            axes(A);
            xlabel(str{UD(1)})
            LUD.X=getdata(str{UD(1)},-pi:.1:pi);
        else
            return
        end
        set(L,'userdata',LUD)
        if isfield(LUD,'X') & isfield(LUD,'Y')
            set(L,'xdata',LUD.X,'ydata',LUD.Y)
        end
    otherwise
        error(sprintf('Command %s not yet defined.',cmd))
    end
end

function y=getdata(keyword,x);
switch keyword
case 'x',
    y=x;
case 'x squared'
    y=x.^2;
otherwise
    y=feval(strtok(keyword),x);
    y(imag(y)~=0)=NaN;
end