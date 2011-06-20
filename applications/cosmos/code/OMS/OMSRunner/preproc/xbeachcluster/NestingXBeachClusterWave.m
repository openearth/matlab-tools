function ok=NestingXBeachClusterWave(hm,m)

tmpdir=hm.TempDir;

mm=hm.Models(m).WaveNestModelNr;

outputdir=[hm.Models(mm).Dir 'lastrun' filesep 'output' filesep];

np=hm.Models(m).NrProfiles;

switch lower(hm.Models(mm).Type)

    case{'delft3dwave','delft3dflowwave'}

        try

            % Nesting Delft3D in SWAN

            disp('Nesting in SWAN ...');

            tstart=hm.Models(mm).TWaveStart;
            dt=hm.Models(mm).WavmTimeStep;
            runid=hm.Models(m).Runid;
            outfile='sp2list.txt';
            trefxbeach=hm.Models(m).TFlowStart;
            morfac=hm.Models(m).MorFac;

            MakeSpecList(outputdir,tstart,dt,runid,tmpdir,outfile,trefxbeach,hm.Models(m).RunTime,morfac);

            ok=ExtractSWANNestSpec(outputdir,tmpdir,runid,trefxbeach,trefxbeach+hm.Models(m).RunTime/1440,hm,mm,m);
            
            disp('Compressing sp2 files ...');
            for j=1:np
                if ok(j)
                    [status,message,messageid]=copyfile([tmpdir outfile],[tmpdir hm.Models(m).Profile(j).Name],'f');
                end
                system([hm.MainDir 'exe' filesep 'zip.exe -q -j ' tmpdir hm.Models(m).Profile(j).Name filesep 'sp2.zip ' tmpdir hm.Models(m).Profile(j).Name filesep '*.sp2']);
%                zip([tmpdir hm.Models(m).Profile(j).Name filesep 'sp2.zip'],[tmpdir hm.Models(m).Profile(j).Name filesep '*.sp2']);
                delete([tmpdir hm.Models(m).Profile(j).Name filesep '*.sp2']);
            end
            
            delete([tmpdir outfile]);
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of XBeach in SWAN - ' hm.Models(m).Name]);
        end
     
end
