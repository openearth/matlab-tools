function [position]=ddb_dnami_getPlotPosition(location)

switch location
    %                 x          y      width     height
    case 'UL' % Upper left
        position = [0.00    0.60    0.56    0.47];
    case 'UR' % Upper right
        position = [0.45    0.60    0.56    0.47];
    case 'LL' % Lower left
        position = [0.00    0.04    0.56    0.47];
    case 'LR' % Lower right
        position = [0.45    0.04    0.56    0.47];
end
