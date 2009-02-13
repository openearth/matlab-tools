function hhh=vline(x,in1,in2,varargin)
%VLINE  draw horizontal line
%
% function h=vline(x, linetype, label)
% function h=vline(x, linetype, label,'on')
% function h=vline(x, linetype, label,'off')
% 
% Draws a vertical line on the current axes at the location 
% specified by 'x'.  Optional arguments are 'linetype' 
% (default is 'r:') and 'label', which applies a text label to 
% the graph near the line. The label appears in the same color 
% as the line.
%
% The line is held on the current axes, and after plotting the 
% line, the function returns the axes to its prior hold state.
%
% The HandleVisibility property of the line object is set to "off",
% so not only does it not appear on legends, but it is not findable 
% by using findobj.  Specifying an output argument causes the function
% to return a handle to the line, so it can be manipulated or deleted.
% Also, the HandleVisibility can be overridden by setting the root's 
% ShowHiddenHandles property to on.
%
% function h=vline(y, linetype, label,'on'/'off')
% An optional 4th argument can be specified that is passed to 
% the 'handlevisibility' property of the line (default 'off').
%
% h = vline(42,'g','The Answer')
%
% returns a handle to a green vertical line on the current axes at x=42,
% and creates a text object on the current axes, close to the line, 
% which reads "The Answer".
%
% vline also supports vector inputs to draw multiple lines at once.  For example,
%
% vline([4 8 12],{'g','r','b'},{'l1','lab2','LABELC'})
%
% draws three lines with the appropriate labels and colors.
% 
% Note that when axis limits are set to '-Inf' or 'Inf', function will not work.
% Note that sometimes the vline does show up in the legend when 'off' is passed, 
% but stops doing so after rebooting matlab ...
%
% See also: HLINE

% By Brandon Kuczenski for Kensington Labs (brandon_kuczenski@kensingtonlabs.com) 8 November 2001
% changed G.J. de Boer(g.j.deboer@tudelft.nl) 11th March 2006

if length(x)>1  % vector input
    for I=1:length(x)
        if nargin ==1
            linetype='r:';
            label='';
        elseif nargin ==2
            if ~iscell(in1)
                in1={in1};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            label='';
        elseif nargin > 2
            if ~iscell(in1)
                in1={in1};
            end
            if ~iscell(in2)
                in2={in2};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            if I>length(in2)
                label=in2{end};
            else
                label=in2{I};
            end
        end
        h(I)=vline(x(I),linetype,label);
    end
else
    if nargin ==1
        linetype = 'r:';
        label    = '';
    elseif nargin == 2 
        linetype = in1;
        label    = '';
    elseif nargin > 2
        linetype = in1;
        label    = in2;
    end
    
    g=ishold(gca);
    hold on

    y=get(gca,'ylim');
    h=plot([x x],y,linetype);
    if length(label)
        xx     = get(gca,'xlim');
        xrange = xx(2)-xx(1);
        xunit  = (x-xx(1))/xrange;
        %if xunit<0.8
            text(x+0.01*xrange,y(1)+0.1*(y(2)-y(1)),label,'color',get(h,'color'),'rotation',90)
        %else
        %    text(x-.05*xrange, y(1)+0.1*(y(2)-y(1)),label,'color',get(h,'color'),'rotation',90)
        %end
    end     

    if g==0
    hold off
    end
    if nargin==4
       handlevisibility = varargin{1};
    else
       handlevisibility ='off';
    end
    set(h,'tag','vline','handlevisibility',handlevisibility);
    % this last part is so that it doesn't show up on legends
    % NOT ALWAYS A GOOD IDEA AS THEN THE LINE DOES NOT DISAPPEAR WHEN CALLING CLA
end % else

if nargout
    hhh=h;
end
