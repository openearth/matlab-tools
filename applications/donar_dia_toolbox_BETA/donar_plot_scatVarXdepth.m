function donar_plot_scatVarXdepth(donarMatFile,sensorname,thefontsize,themarkersize)
%DONAR_MULTIYEAR_BOXPLOTS Makes Box-Whiskers plots from "donarmat files"
%   with the use of DONAR_DIA2DONARMAT. 
%
%   [Qs,Ind] = DONAR_MULTIYEAR_BOXPLOTS(path2donarMatFile,sensorname)
%   where Qs is a structure containing the quantiles of the information per
%   sensor name and per month. 
%  
%   Arguments:
%   <X> x coordenates of the grid to be checked 
%   <Y> y coordenates of the grid to be checked 
%   <coord> the type of coordenates
%   See also: INPOLYGON, REDUCE2MASK

%   Copyright: Deltares, the Netherlands
%        http://www.delftsoftware.com
%        Date: 14.08.2012
%      Author: I. Garcia Triana
% -------------------------------------------------------------------------


    disp(['Loading: ',donarMatFile]);
    load(donarMatFile)
    
    thefields = fields(thecompend);

    the_path2file = donarMatFile(1:max(findstr(donarMatFile,'\')));
    thedir = [the_path2file,'donar_dia_TeX\figures\'];
    if ~exist(thedir), mkdir(thedir); end

    
    
    % Get the minimum and maximum date in the data series... it will be
    % usefull for names and titles. 
    minX = now;
    maxX = datenum('01-Jan-1800');
    for j = 1:length(thefields)
        thecompend.(thefields{j}).data(:,4) = thecompend.(thefields{j}).data(:,4) + thecompend.(thefields{j}).referenceDate;
        minX = min(minX,min(thecompend.(thefields{j}).data(:,4)));
        maxX = max(maxX,max(thecompend.(thefields{j}).data(:,4)));
    end
    
% -> LATEX
                fileID = fopen([the_path2file,'donar_dia_TeX\theTeX_General.tex'],'W');
                thestr = ['\section{Relationship between depth and ',strrep(thecompend.(thefields{j}).deltares_name,'_',' '),' \(',num2str(year(minX)),' and ',num2str(year(maxX)),'\)}'];
                fprintf(fileID,'%s\n',thestr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % All Observations Maps %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    for j = 6%1:length(thefields)
        
        disp(thefields{j});
        f = figure('visible','off');
        thelineS = colormap;        

        plot_scatterhist(thecompend.(thefields{j}).data(:,5),-thecompend.(thefields{j}).data(:,3),60,'cBins',15);
        
        xlabel([upper(thecompend.(thefields{j}).deltares_name(1)),strrep(thecompend.(thefields{j}).deltares_name(2:end),'_',' '),' [',thecompend.(thefields{j}).hdr.EHD{2},']'],'fontsize',thefontsize)
        
        %  The ylabel
        if strcmpi(thecompend.Troebelheid.dimensions{3,2},'centimeters'),             ylabel('Depth [cm]','fontsize',thefontsize)
        elseif strcmpi(thecompend.Troebelheid.dimensions{3,2},'meters'),              ylabel('Depth [m]', 'fontsize',thefontsize)
        end
        
        title([sensorname,': ',upper(thecompend.(thefields{j}).deltares_name(1)),strrep(thecompend.(thefields{j}).deltares_name(2:end),'_',' '),' vs Depth (',num2str(year(minX)),' - ',num2str(year(maxX)),')'],'FontWeight','bold','FontSize',thefontsize);
        
        
        
        set(gca,'FontSize',thefontsize);
        fileName = [sensorname,'_scatVarXdepth_',num2str(year(minX)),'-',num2str(year(maxX)),'_',thecompend.(thefields{j}).deltares_name];
        
        print('-depsc2',[thedir,fileName]);
        print('-dpng',[thedir,fileName]);
        close(f);

% -> LATEX
                thestr = ['\begin{figure}[htbp] \centering \includegraphics[width=1.1\textwidth]{figures/',fileName,'} \end{figure}'];
                fprintf(fileID,'%s\n',thestr);
    end
    
    fclose(fileID);
end