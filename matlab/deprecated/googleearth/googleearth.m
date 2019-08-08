function googleearth(varargin)
 error('%s has been deprecated',mfilename)

switch varargin{1}
    case '-docinstall'
        try
            try

                fid=fopen(fullfile(googleearthroot,'info.xml.template'),'r');
                textInfoXML='';
                while true
                    tline = fgets(fid);
                    if ischar(tline)
                        textInfoXML = [textInfoXML,tline];
                    else
                        break
                    end
                end
                fclose(fid);

                fid=fopen(fullfile(googleearthroot,'info.xml'),'wt');
                fprintf(fid,textInfoXML,googleearthroot);
                fclose(fid);

            catch
                warning('SCEMUA:writing_of_info_file',...
                    ['An error occurred during writing ',...
                    'of googleearth ',char(39),...
                    'info.xml',char(39),' file'])
            end

            % % % % % % % % % % % % info.xml is written

            try

                fid=fopen(fullfile(prefdir,'matlab.prf'),'r');
                C = textscan(fid, '%s','delimiter','\r');
                fclose(fid);

                for k=1:numel(C{1})
                    try
                        MatlabVarName = strread(C{1}{k},'%[^=]',1);
                        switch MatlabVarName{1}
                            case 'Colors_M_Comments'
                                indColor = strread(C{1}{k},'%*[^=]%*[=]%s',1);
                                [r,g,b]=indexed2hexcolor(indColor{1});
                                Colors_M_CommentsStr =...
                                    [dec2hex(r,2),dec2hex(g,2),dec2hex(b,2)];
                            case 'Colors_M_Strings'
                                indColor = strread(C{1}{k},'%*[^=]%*[=]%s',1);
                                [r,g,b]=indexed2hexcolor(indColor{1});
                                Colors_M_StringsStr =...
                                    [dec2hex(r,2),dec2hex(g,2),dec2hex(b,2)];
                            case 'Colors_M_Keywords'
                                indColor = strread(C{1}{k},'%*[^=]%*[=]%s',1);
                                [r,g,b]=indexed2hexcolor(indColor{1});
                                Colors_M_KeywordsStr =...
                                    [dec2hex(r,2),dec2hex(g,2),dec2hex(b,2)];
                            case 'Colors_M_SystemCommands'
                                indColor = strread(C{1}{k},'%*[^=]%*[=]%s',1);
                                [r,g,b]=indexed2hexcolor(indColor{1});
                                Colors_M_SystemCommandsStr =...
                                    [dec2hex(r,2),dec2hex(g,2),dec2hex(b,2)];
                        end
                    catch
                        Colors_M_CommentsStr = '228B22';
                        Colors_M_StringsStr = 'A020F0';
                        Colors_M_KeywordsStr = '0000FF';
                        Colors_M_SystemCommandsStr = 'B28C00';
                    end
                end

                fid=fopen(fullfile(googleearthroot,'html','styles',...
                    'ge_styles.css.template'),'r');
                textStylesCSS='';
                while true
                    tline = fgets(fid);
                    if ischar(tline)
                        textStylesCSS = [textStylesCSS,tline];
                    else
                        break
                    end
                end
                fclose(fid);

                fid=fopen(fullfile(googleearthroot,'html','styles',...
                    'ge_styles.css'),'wt');
                fprintf(fid,textStylesCSS,...
                    Colors_M_CommentsStr,...
                    Colors_M_StringsStr,...
                    Colors_M_KeywordsStr,...
                    Colors_M_SystemCommandsStr);
                fclose(fid);

            catch
                warning('googleearth:writing_of_styles_file',...
                    ['An error occurred during writing ',...
                    'of googleearth ',char(39),...
                    'ge_styles.css',char(39),' file'])

            end

            disp(['Click on the MATLAB ',...
                'Start button->Desktop Tools->View Source Files...',...
                char(10),'...and click Refresh Start Button.'])
        catch
        end
        
    otherwise
        disp('Unrecognized option.')

end