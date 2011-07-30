function NestingDelft3DWave(hm,m)

model=hm.models(m);

tmpdir=hm.tempDir;

curdir=pwd;

mm=model.waveNestModelNr;

% dr=model.dir;

outputdir=[hm.models(mm).dir 'lastrun' filesep 'output' filesep];

switch lower(hm.models(mm).type)

    case{'ww3'}

         try

            disp('Nesting in WWIII ...');

            % Nesting Delft3D in WWIII
            
%             nt=(model.tStop-model.tWaveStart)*24+1;
%            
%             [status,message,messageid]=copyfile([outputdir 'out_pnt.ww3'],tmpdir,'f');
%             [status,message,messageid]=copyfile([outputdir 'mod_def.ww3'],tmpdir,'f');
%             [status,message,messageid]=copyfile([hm.exeDir 'ww3_outp.exe'],tmpdir,'f');
% 
%             curdir=pwd;
%             
%             cd(tmpdir);
%             
%             % First check which stations are needed
%             
%             fid=fopen([tmpdir 'ww3_outp.inp'],'wt');
%             fprintf(fid,'%s\n','$');
%             fprintf(fid,'%s\n',[datestr(model.tWaveStart,'yyyymmdd HHMMSS') ' 3600 ' num2str(nt)]);
%             fprintf(fid,'%s\n','1');
%             fprintf(fid,'%s\n','-1');
%             fprintf(fid,'%s\n','0');
%             fclose(fid);
%             system('ww3_outp.exe>out.scr');
% 
%             fid=fopen('out.scr','r');
%             a = textscan(fid,'%s');
%             fclose(fid);
%             delete('out.scr');
% 
%             a=a{1};
%             i=strmatch('------------------------------------',a);
%             j=strmatch('Output',a);
%             i1=i(1)+1;
%             j1=j(1)-1;
%             b=a(i1:j1);
%             n=length(b)/3;
%             c=reshape(b,[3 n]);
%             c=c';
%             c=c(:,1);
%             for k=1:length(c)
%                 name{k}=c{k}(1:end-3);
%             end
%             ip=strmatch(model.runid,name,'exact');
% 
%             % Now extract the stations
%             
%             WriteWW3Outp([tmpdir 'ww3_outp.inp'],ip,model.tWaveStart,3600,nt,1);
%             
%             system('ww3_outp.exe');
%             
%             cd(curdir);
            
            fname=[outputdir 'ww3.' model.name '.spc'];

%            ConvertWW3spc(fname,[tmpdir 'ww3.spc'],model.coordinateSystem,model.coordinateSystemType,hm.coordinateSystems,hm.Operations);
            ConvertWW3spc(fname,[tmpdir model.name '.sp2'],model.coordinateSystem,model.coordinateSystemType);
            
%             delete([tmpdir 'ww3_outp.inp']);
%             delete([tmpdir 'out_pnt.ww3']);
%             delete([tmpdir 'mod_def.ww3']);
%             delete([tmpdir 'ww3_outp.exe']);
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of Delft3D in WWIII - ' model.name]);
        end

    case{'delft3dwave','delft3dflowwave'}

        try

            % Nesting Delft3D in SWAN

            disp('Nesting in SWAN ...');
            
            [success,message,messageid]=copyfile([outputdir model.runid '*.sp2'],tmpdir,'f');

            ConvertSWANNestSpec(tmpdir,[tmpdir model.name '.sp2'],hm,mm,m);
            
            delete([tmpdir model.runid '.*t*.sp2']);
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of Delft3D in SWAN - ' model.name]);
        end
     
end

cd(curdir);
