function EHY_stampTime(times,values,stamp,timeNow,varargin)
%  Adds a small "stamp" with the computed water levels at a certain station in combination with a vertical bar at the current time
%  After execution, contral is given back to the original (current) axes.
%
%  First beta version
%% Initialise
pos_stamp = stamp.Position;
TLim         = stamp.TLim;
YLim         = stamp.YLim;
YTick        = stamp.YTick;
YTickLabel   = stamp.YTickLabel;
Title        = stamp.Title;
nrSeries     = size(values,2);

OPT.YLabel   = 'waterlevel';
OPT.language = 'en'; 
OPT        = setproperty(OPT,varargin);

%% Begin Time plot: Start with setting original axes to normalized
originalAxes = gca;
set(gca,'Units','normalized');

%% Define new axis in the existing axes (for some reason retrieving 'Position' directly from gca doe not always work??????)
tmp      = get(gca);
position = tmp.Position;
newAxes  = axes('Units','normalized','Position',[position(1) + pos_stamp(1)*position(3)   position(2) + pos_stamp(2)*position(4)  pos_stamp(3)*position(3)  pos_stamp(4)*position(4)]);

%% First, water levels
for i_series = 1: nrSeries
    plot(times,values(:,i_series));
    hold on;
end
       
%% Then TimeNow
for i_time = 1: length(timeNow)
    plot ([timeNow(i_time) timeNow(i_time)],YLim,'r','Linewidth',1.5);
end

%% Set axis etc (make Figure nicer)
set (gca,'Xlim'       ,TLim);
set (gca,'Ylim'       ,YLim);
if ~isempty(YTick     ) set(gca,'YTick'     ,YTick     ); end
if ~isempty(YTickLabel) set(gca,'YTickLabel',YTickLabel); end
set (gca,'FontSize',3   );
set (gca,'XGrid'   ,'on');
set (gca,'YGrid'   ,'on');

Text = get (gca,'YLabel');
set(Text,'string',waterDictionary(OPT.YLabel,NaN,OPT.language));
if ~isempty(Title)
    Text = get(gca,'Title'); 
    posSpace = strfind(Title,' ');
    if ~isempty(posSpace)
       param    = Title(1:posSpace(1) - 1);
       param_n  = waterDictionary(param,NaN,OPT.language,'addUnit',false);
    else
        posSpace = 1;
        param_n  = '';
    end
    Title    = [param_n Title(posSpace:end)]; 
    set(Text,'string',Title,'FontSize',5.0); 
end
timeticks('x',TLim(1),TLim(2),'custom'); 

%% Restore to original axes
set(gcf,'CurrentAxes',originalAxes);

end
