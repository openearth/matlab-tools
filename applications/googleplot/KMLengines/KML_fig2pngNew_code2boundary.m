function bnd =  KML_fig2pngNew_code2boundary(code)
%KML_FIG2PNGNEW_CODE2BOUNDARY   subsidiary of KMLfig2pngNew
%
%  bnd =  KML_fig2pngNew_code2boundary(code)
%
%See also: KMLfig2pngNew, KML_fig2pngNew_SmallestTileThatContainsAllData

bnd.N     =  180;
bnd.S     = -180;
bnd.W     = -180;
bnd.E     =  180;
bnd.level = length(code)-1;

if ~code(1)=='0'
    error('code must begin with 0')
end

for ii = 2:bnd.level+1
    switch code(ii)
        case '0'
            bnd.S = bnd.S + (bnd.N-bnd.S)/2;
            bnd.E = bnd.E + (bnd.W-bnd.E)/2;
        case '1'
            bnd.S = bnd.S + (bnd.N-bnd.S)/2;
            bnd.W = bnd.W + (bnd.E-bnd.W)/2;
        case '2'
            bnd.N = bnd.N + (bnd.S-bnd.N)/2;
            bnd.E = bnd.E + (bnd.W-bnd.E)/2;
        case '3'
            bnd.N = bnd.N + (bnd.S-bnd.N)/2;
            bnd.W = bnd.W + (bnd.E-bnd.W)/2;
        otherwise
            disp(['warning: ignored wrong element in code, must consist of 0123, but contains:''',code(ii),''''])% probably colorbar
            bnd.N = [];
            bnd.W = [];
            break
    end
end

