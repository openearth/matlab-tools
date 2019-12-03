from bokeh.plotting import figure, output_file, save
from bokeh.palettes import Category20

# Author: Joan Sala Calero
# CLASS to generate bokeh plots for Fiber optics data
class line_Plot:
    def generate_plot(self, xarr, yarr, xlabel, ylabel, outfile, xsize=1800, ysize=800):
        output_file(outfile)
        p = figure(plot_width=xsize, plot_height=ysize)
        p.line(xarr, yarr, line_width=2)
        p.xaxis.axis_label = xlabel
        p.yaxis.axis_label = ylabel
        save(p)
        print 'Saving {}'.format(outfile)

    def generate_plot_multi(self, datapairs, xlabel, ylabel, leg, outfile, xsize=1800, ysize=800, tit=None):
        output_file(outfile)
        if tit is None:
            p = figure(plot_width=xsize, plot_height=ysize)
        else:
            p = figure(plot_width=xsize, plot_height=ysize, title=tit)
        i = 0
        for x,y in datapairs:
            p.line(x, y, line_width=2, color=Category20[10][i], legend=leg[i])
            i += 1
        p.xaxis.axis_label = xlabel
        p.yaxis.axis_label = ylabel
        p.legend.location = "bottom_right"
        save(p)
        print 'Saving {}'.format(outfile)