function  donar_plot_monthlyHist(donarMatFile,sensorname,thefontsize)
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


    load(donarMatFile);

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

        cont = 1;
        h = figure('visible','off');

        uniquemonth = unique(thedates);
        for imonth = uniquemonth'
            the_indices = (thedates(:,1) == imonth);
            thefig = subplot(3,4,imonth,'parent',h);
            [n,x] = hist(thecompend.(thefields{j}).data(the_indices,5),15);
            bar(x,n/sum(the_indices)*100)
            shading flat;          
            title([monthstr(imonth,'mmmm'),char(10),' (',num2str(sum(the_indices)),' Obs)'],'fontsize',thefontsize+2)
            xlabel([upper(thecompend.(thefields{j}).deltares_name(1)),strrep(thecompend.(thefields{j}).deltares_name(2:end),'_',' '),' [',thecompend.(thefields{j}).hdr.EHD{2},']'],'fontsize',thefontsize)
            ylabel('Number of Observations [%]','fontsize',thefontsize)
            set(gca,'fontsize',thefontsize)
        end
        cont = cont+1;

        [ax4,h3] = suplabel([sensorname,': ',num2str(year(minX)),' - ',num2str(year(maxX))],'t');
        set(h3,'FontSize',thefontsize+2,'fontweight','bold')
        fileName = [sensorname,'_monthly_hist','_',num2str(year(minX)),'-',num2str(year(maxX)),'_',thecompend.(thefields{j}).deltares_name];
        disp(['Saving ',thedir,fileName])
        print('-depsc2',[thedir,fileName]);
        print('-dpng',[thedir,fileName]);
        close;
    end
end
    