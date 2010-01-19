function code = fig2pngNew_getCodeOfSmallestTileThatContainsAllData(D)

dataBounds.N = max(D.lat(:));
dataBounds.S = min(D.lat(:));
dataBounds.W = min(D.lon(:));
dataBounds.E = max(D.lon(:));

code   = '0';
search = true;
while search;
    dataIntile = 0;
    for addCode = ['0','1','2','3']
        tileBounds = fig2pngNew_code2boundary([code addCode]);
        if ((dataBounds.E>tileBounds.W&&dataBounds.W<tileBounds.E)&&...
                (dataBounds.N>tileBounds.S&&dataBounds.S<tileBounds.N))
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