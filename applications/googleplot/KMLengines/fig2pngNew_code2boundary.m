function bnd =  code2boundary(code)

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
            error('wrong element in code, must consist of 0123')
    end
end

