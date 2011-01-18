function code = KML_figure_tiler_SmallestTileThatContainsAllData(D)
%KML_FIG2PNGNEW_SMALLESTTILETHATCONTAINSALLDATA subsidiary of KMLfigure_tiler
%
%   code = KML_figure_tiler_SmallestTileThatContainsAllData(D)
%
% where D has fields lat and lon
%
%See also: KMLfigure_tiler, KML_figure_tiler_code2boundary

dataBounds.N = max(D.lat(:));
dataBounds.S = min(D.lat(:));
dataBounds.W = min(D.lon(:));
dataBounds.E = max(D.lon(:));

code   = '0';
search = true;
while search;
    dataIntile = 0;
    for addCode = ['0','1','2','3']
        tileBounds = KML_figure_tiler_code2boundary([code addCode]);
        if ((dataBounds.E > tileBounds.W &&...
             dataBounds.W < tileBounds.E   )&&...
            (dataBounds.N > tileBounds.S &&...
             dataBounds.S < tileBounds.N  ))
            dataIntile = dataIntile+1;
            nextCode = [code addCode];
        end
    end
    if dataIntile>1
        search = false;
    else
        code = nextCode;
    end
end