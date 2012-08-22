function  [the_quantiles,the_indices] = donar_plot_boxwhiskers(donarMatFile,sensorname,thefontsize)
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
    
    minX = now;
    maxX = datenum('01-Jan-1800');
    for j = 1:length(thefields)

        thecompend.(thefields{j}).data(:,4) = thecompend.(thefields{j}).data(:,4) + thecompend.(thefields{j}).referenceDate;

        minX = min(minX,min(thecompend.(thefields{j}).data(:,4)));
        maxX = max(maxX,max(thecompend.(thefields{j}).data(:,4)));
    end

    for j = 1:length(thefields)

        thedates = [month(thecompend.(thefields{j}).data(:,4))];

        
        h = figure('visible','off');
        hold on;
        uniquemonth = unique(thedates);
        for imonth = uniquemonth'
            the_indices = find(thedates(:,1) == imonth);
            the_quantiles(imonth,:) = boxPlot(imonth, thecompend.(thefields{j}).data(the_indices,5),h);
        end
        title([strrep(sensorname,'_',' '),' observations between ',num2str(year(minX)),' and ',num2str(year(maxX))],'FontWeight','bold','FontSize',thefontsize);
        ylabel([upper(thecompend.(thefields{j}).deltares_name(1)),strrep(thecompend.(thefields{j}).deltares_name(2:end),'_',' '),' [',thecompend.(thefields{j}).hdr.EHD{2},']'],'fontsize',thefontsize)
        theticks = [1:2:12];
        xlim([0,13])
        tick(gca,'x',theticks,'%f')
        set(gca,'XTickLabel',monthstr(theticks,'mmm'))
        set(gca,'fontsize',thefontsize)
        fileName = [sensorname,'_boxplot','_',num2str(year(minX)),'-',num2str(year(maxX)),'_',thecompend.(thefields{j}).deltares_name];
        print('-depsc2',[thedir,fileName]);
        print('-dpng',[thedir,fileName]);
        close;
    end
end
        