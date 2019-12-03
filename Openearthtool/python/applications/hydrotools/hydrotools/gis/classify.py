# -*- coding: utf-8 -*-
"""
Created on Tue Jul 16 11:41:58 2013

@author: Hessel Winsemius
"""
import numpy as np
from matplotlib import patches
import matplotlib.pyplot as plt

def classify(value, classes, cmap, extend=None):
    """
    Return a color tuple (R, G, B, trans) for the chosen value
    according to a list of classes
    Inputs:
        value       -   numeric value
        classes     -   list with classes
        cmap        -   colormap object (e.g. cm.jet)
        extend      -   either 'min', 'max' or 'both'. Indicates whether the 
                        list of classes is extended on left or right side
                        if values smaller/larger than the most extreme values
                        in the list of classes are also feasible
    """
    # first estimate a number between 0 and one
    idx = 0
    if np.logical_or(extend == 'min', extend == 'max'):
        nrClasses = len(classes)
    elif extend == 'both':
        nrClasses = len(classes) + 1
    else:
        nrClasses = len(classes) - 1
    # define the color locations in cmap per class
    lookup = np.linspace(0, 1, nrClasses)
    
    if np.logical_or(extend == 'min', extend == 'both'):
        idx_start = 0
    else:
        idx_start = 1
    if np.logical_or(extend == 'max', extend == 'both'):
        idx_end   = len(classes)
    else:
        idx_end   = len(classes)-1
    
        
    for n, Class in enumerate(classes[idx_start:idx_end]):
        if value > Class:
            idx += 1
    return cmap(lookup[idx])

def class_legend(ax, classes, cmap, extend=None, ncol=1, bbox_to_anchor=None, \
        prop=None, class_title=None):
    """
    class_legend(ax, classes, cmap, extend=None, ncol=1, bbox_to_anchor=None, \
        prop=None, classTitle=None):

    create a legend with small boxes per class. Inputs are anagolous to matplotlib.pyplot.legend
    Inputs:
        ax:             matplotlib axis on which to plot the legend
        classes:        list of number. Classes are made in between each list entry
        cmap:           colormap of user choice in form of matplotlib.cm
        extend          either 'min', 'max' or 'both'. Indicates whether the 
                        list of classes is extended on left or right side
                        if values smaller/larger than the most extreme values
                        in the list of classes are also feasible
        ncol:           number of columns for the legend
        bbox_to_anchor: re-position legend, analagous to matplotlib.pyplot.legend
        prop:           additional properties for legend ticks
        class_title:     title on top of legend
                    
    """
    allFaceColors = []
    p = []
    classLabels = []
    if np.logical_or(extend == 'min', extend == 'max'):
        nrClasses = len(classes)
    elif extend == 'both':
        nrClasses = len(classes) + 1
    else:
        nrClasses = len(classes) - 1
    # define the color locations in cmap per class
    
    if np.logical_or(extend == 'min', extend == 'both'):
        idx_start = 0
        classLabels.append('< ' + '{:,}'.format(classes[0]))
        classColor = classify(classes[0]-1, classes, cmap, extend=extend)
        allFaceColors.append(classColor)
        ClassPatch = patches.Rectangle((0,0), 1, 1, fc=classColor, ec='#999999')
        p.append(ClassPatch)
    for n, Class in enumerate(classes[1:]):
        classLabels.append('{:,}'.format(classes[n]) + ' -- ' + '{:,}'.format(Class))
        classColor = classify(Class, classes, cmap, extend=extend)
        allFaceColors.append(classColor)
        ClassPatch = patches.Rectangle((0,0), 1, 1, fc=classColor, ec='#999999')
        p.append(ClassPatch)
    if np.logical_or(extend == 'max', extend == 'both'):
        classLabels.append('> ' + '{:,}'.format(Class))
        classColor = classify(Class + 1, classes, cmap, extend=extend)
        allFaceColors.append(classColor)
        ClassPatch = patches.Rectangle((0,0), 1, 1, fc=classColor, ec='#999999')
        p.append(ClassPatch)
    leg = ax.legend(p, classLabels, loc='right', ncol=ncol,
                    bbox_to_anchor=bbox_to_anchor, handlelength=.7,
                    prop=prop, title=class_title) # ,columnspacing=.75,handletextpad=.25, , 
    leg.draw_frame(False)
    plt.setp(leg.get_title(),fontsize='small')
