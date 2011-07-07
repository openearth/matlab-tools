function NestingDelft3DWave(hm,m)

Model=hm.Models(m);

tmpdir=hm.TempDir;

curdir=pwd;

mm=Model.WaveNestModelNr;

% dr=Model.Dir;

outputdir=[hm.Models(mm).Dir 'lastrun' filesep 'output' filesep];

switch lower(hm.Models(mm).Type)

    case{'ww3'}

         try

            disp('Nesting in WWIII ...');

            % Nesting Delft3D in WWIII
            
%             nt=(Model.TStop-Model.TWaveStart)*24+1;
%            
%             [status,message,messageid]=copyfile([outputdir 'out_pnt.ww3'],tmpdir,'f');
%             [status,message,messageid]=copyfile([outputdir 'mod_def.ww3'],tmpdir,'f');
%             [status,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'ww3_outp.exe'],tmpdir,'f');
% 
%             curdir=pwd;
%             
%             cd(tmpdir);
%             
%             % First check which stations are needed
%             
%             fid=fopen([tmpdir 'ww3_outp.inp'],'wt');
%             fprintf(fid,'%s\n','$');
%             fprintf(fid,'%s\n',[datestr(Model.TWaveStart,'yyyymmdd HHMMSS') ' 3600 ' num2str(nt)]);
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
%             ip=strmatch(Model.Runid,name,'exact');
% 
%             % Now extract the stations
%             
%             WriteWW3Outp([tmpdir 'ww3_outp.inp'],ip,Model.TWaveStart,3600,nt,1);
%             
%             system('ww3_outp.exe');
%             
%             cd(curdir);
            
            fname=[outputdir 'ww3.' Model.Name '.spc'];

%            ConvertWW3spc(fname,[tmpdir 'ww3.spc'],Model.CoordinateSystem,Model.CoordinateSystemType,hm.CoordinateSystems,hm.Operations);
            ConvertWW3spc(fname,[tmpdir Model.Name '.sp2'],Model.CoordinateSystem,Model.CoordinateSystemType);
            
%             delete([tmpdir 'ww3_outp.inp']);
%             delete([tmpdir 'out_pnt.ww3']);
%             delete([tmpdir 'mod_def.ww3']);
%             delete([tmpdir 'ww3_outp.exe']);
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of Delft3D in WWIII - ' Model.Name]);
        end

    case{'delft3dwave','delft3dflowwave'}

        try

            % Nesting Delft3D in SWAN

            disp('Nesting in SWAN ...');
            
            [success,message,messageid]=copyfile([outputdir Model.Runid '*.sp2'],tmpdir,'f');

            ConvertSWANNestSpec(tmpdir,[tmpdir Model.Name '.sp2'],hm,mm,m);
            
            delete([tmpdir Model.Runid '.*t*.sp2']);
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of Delft3D in SWAN - ' Model.Name]);
        end
     
end

cd(curdir);
