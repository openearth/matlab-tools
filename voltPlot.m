function voltPlot(varargin)
%voltPlot plot one or more signals
%   Basic plotting of siginals. voltPlot accepts multiple signal tags as
%   input. An example of input:
%   voltPlot( ...
%       'BOT288 uwp rpm                         [rpm    ]', ...
%       'AIN61 main engine sb speed            [rpm    ]')

global volt

for ii = 1: nargin
    ySignals(ii) = voltGetTagNumber(varargin{ii});    
end % for ii = 1: nargin

hf = figure('position', [20 105 980 560]);
hl = plot( ...
        volt.data(volt.selection, 2), ...
        volt.data(volt.selection, ySignals) );
legend(volt.signalTags{ySignals}, 'Location', 'NorthEastOutside')
datetick('x')
xlabel('time')
grid on
title(volt.header{7})