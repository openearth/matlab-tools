function NestingXBeachWave(hm,m)

tmpdir=hm.TempDir;

mm=hm.Models(m).WaveNestModelNr;

outputdir=[hm.Models(mm).Dir 'lastrun' filesep 'output' filesep];

switch lower(hm.Models(mm).Type)

    case{'delft3dwave','delft3dflowwave'}

        try

            % Nesting Delft3D in SWAN

            disp('Nesting in SWAN ...');
            
            [success,message,messageid]=copyfile([outputdir hm.Models(m).Runid '*.sp2'],tmpdir,'f');
            
            % Get rid of spaces in sp2 file names
            flist=dir([tmpdir '*.sp2']);
            for i=1:length(flist)
                newname=strrep(flist(i).name,' ','');
                movefile([tmpdir flist(i).name],[tmpdir newname]);
            end

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
