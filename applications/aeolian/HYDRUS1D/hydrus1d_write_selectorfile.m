function hydrus1d_write_selectorfile(varargin)

OPT = struct( ...
    'MaxIt', 20, ...
    'TolTh', 0.001, ...
    'TolH', 1, ...
    'tInit', 0, ...
    'tMax', 1, ...
    'dt', 0.001, ...
    'dtMin', 1e-005, ...
    'dtMax', 5, ...
    'DMul', 1.3, ...
    'DMul2', 0.7, ...
    'ItMin', 3, ...
    'ItMax', 7, ...
    'MPL', 240, ...
    'PrintTimes', 10000, ...
    'PrintInterval', 1, ...
    'path', pwd);

OPT = setproperty(OPT, varargin);

fid = fopen(fullfile(OPT.path, 'SELECTOR.IN'), 'w');
fprintf(fid, '%s\n', 'Pcp_File_Version=4');
fprintf(fid, '%s\n', '*** BLOCK A: BASIC INFORMATION *****************************************');
fprintf(fid, '%s\n', 'Heading');
fprintf(fid, '%s\n', 'Welcome to HYDRUS-1D');
fprintf(fid, '%s\n', 'LUnit  TUnit  MUnit  (indicated units are obligatory for all input data)');
fprintf(fid, '%s\n', 'cm');
fprintf(fid, '%s\n', 'days');
fprintf(fid, '%s\n', 'mmol');
fprintf(fid, '%s\n', 'lWat   lChem lTemp  lSink lRoot lShort lWDep lScreen lVariabBC lEquil lInverse');
fprintf(fid, '%s\n', ' t     f     f      f     f     f      f     t       t         t         f');
fprintf(fid, '%s\n', 'lSnow  lHP1   lMeteo  lVapor lActiveU lFluxes lIrrig  lDummy  lDummy  lDummy');
fprintf(fid, '%s\n', ' f       f       f       f       f       t       f       f       f       f');
fprintf(fid, '%s\n', 'NMat    NLay  CosAlpha');
fprintf(fid, '%s\n', '  1       1       1');
fprintf(fid, '%s\n', '*** BLOCK B: WATER FLOW INFORMATION ************************************');
fprintf(fid, '%s\n', 'MaxIt   TolTh   TolH       (maximum number of iterations and tolerances)');
fprintf(fid, '%5d %15f %5d\n', OPT.MaxIt, OPT.TolTh, OPT.TolH);
fprintf(fid, '%s\n', 'TopInf WLayer KodTop InitCond');
fprintf(fid, '%s\n', ' t     f       0       f');
fprintf(fid, '%s\n', 'BotInf qGWLF FreeD SeepF KodBot DrainF  hSeep');
fprintf(fid, '%s\n', ' f     f     f     f      1      f      0');
fprintf(fid, '%s\n', '    hTab1   hTabN');
fprintf(fid, '%s\n', '    1e-006   10000');
fprintf(fid, '%s\n', '    Model   Hysteresis');
fprintf(fid, '%s\n', '      3          0');
fprintf(fid, '%s\n', '   thr     ths    Alfa      n         Ks       l');
fprintf(fid, '%s\n', '  0.045    0.43   0.145    2.68      712.8     0.5 ');
fprintf(fid, '%s\n', '*** BLOCK C: TIME INFORMATION ******************************************');
fprintf(fid, '%s\n', '        dt       dtMin       dtMax     DMul    DMul2  ItMin ItMax  MPL');
fprintf(fid, '%10e %10e %10e %10.1f %10.1f %10d %10d %10d\n', OPT.dt, OPT.dtMin, OPT.dtMax, OPT.DMul, OPT.DMul2, OPT.ItMin, OPT.ItMax, OPT.MPL);
fprintf(fid, '%s\n', '      tInit        tMax');
fprintf(fid, '%5d %5d\n', OPT.tInit, OPT.tMax);
fprintf(fid, '%s\n', '  lPrintD  nPrintSteps tPrintInterval lEnter');
fprintf(fid, '%10s %10d %10d %10s\n', 't', OPT.PrintTimes, OPT.PrintInterval, 't');
fprintf(fid, '%s\n', 'TPrint(1),TPrint(2),...,TPrint(MPL)');

t = linspace(OPT.tInit, OPT.tMax, OPT.MPL+1);
for i = 2:length(t)
    fprintf(fid, '%15f ', t(i));
    if mod(i-1,6) == 0
        fprintf(fid, '\n');
    end
end

fprintf(fid, '%s\n', '*** END OF INPUT FILE ''SELECTOR.IN'' ************************************');
