function cosmos_nestingXBeachWave(hm,m)

tmpdir=hm.tempDir;

mm=hm.models(m).waveNestModelNr;

outputdir=[hm.models(mm).dir 'archive' hm.cycStr filesep 'output' filesep];

switch lower(hm.models(mm).type)

    case{'delft3dwave','delft3dflowwave'}

        try

            % Nesting Delft3D in SWAN

            disp('Nesting in SWAN ...');
            
            [success,message,messageid]=copyfile([outputdir hm.models(m).runid '*.sp2'],tmpdir,'f');
            
            % Get rid of spaces in sp2 file names
            flist=dir([tmpdir '*.sp2']);
            for i=1:length(flist)
                newname=strrep(flist(i).name,' ','');
                movefile([tmpdir flist(i).name],[tmpdir newname]);
            end

            tstart=hm.models(mm).tWaveStart;
            dt=hm.models(mm).wavmTimeStep;
            runid=hm.models(m).runid;
            outfile='waves.txt';
            trefxbeach=hm.models(m).tFlowStart;
            runtime=hm.models(m).runTime;
            morfac=hm.models(m).morFac;
            
            MakeSpecList(tmpdir,tstart,dt,runid,tmpdir,outfile,trefxbeach,runtime,morfac);
            
            parfile=[tmpdir 'params.txt'];
            findreplace(parfile,'INSTATNR','5');
            findreplace(parfile,'WAVEFILE',outfile);

        catch
            WriteErrorLogFile(hm,'An error occured during nesting of XBeach in SWAN');
        end
     
end
