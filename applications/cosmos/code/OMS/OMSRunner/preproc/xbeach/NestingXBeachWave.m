function NestingXBeachWave(hm,m)

tmpdir=hm.TempDir;

mm=hm.Models(m).WaveNestModelNr;

dr=hm.Models(m).Dir;

outputdir=[hm.Models(mm).Dir 'lastrun' filesep 'output' filesep];

switch lower(hm.Models(mm).Type)

    case{'delft3dwave','delft3dflowwave'}

        try

            % Nesting Delft3D in SWAN

            disp('Nesting in SWAN ...');
            
            [success,message,messageid]=copyfile([outputdir hm.Models(m).Runid '*.sp2'],tmpdir,'f');

            tstart=hm.Models(mm).TWaveStart;
            dt=hm.Models(mm).WavmTimeStep;
            runid=hm.Models(m).Runid;
            outfile='waves.txt';
            trefxbeach=hm.Models(m).TFlowStart;
            runtime=hm.Models(m).RunTime;
            morfac=hm.Models(m).MorFac;
            
            MakeSpecList(tmpdir,tstart,dt,runid,tmpdir,outfile,trefxbeach,runtime,morfac);
            
            parfile=[tmpdir 'params.txt'];
            findreplace(parfile,'INSTATNR','5');
            findreplace(parfile,'WAVEFILE',outfile);

        catch
            WriteErrorLogFile(hm,'An error occured during nesting of XBeach in SWAN');
        end
     
end
