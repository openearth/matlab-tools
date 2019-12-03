import numpy as np

def fill_poly_with_pixels(xg, yg, xpoly, ypoly, tgt, val): 
    '''
       pixel - vult alle pixels met val die behoren tot de polygoon.
       xg - array van x-coordinaten van het grid (ruitjespapier)
       yg - array van y-coordinaten van het grid
       xpoly - x-coordinaten van polygon hoekpunten (niet gesloten)
       ypoly - y-coordinaten van polygon hoekpunten
       tgt - target array [len(yg), len(xg)]
       val - in te vullen waarde
  
    '''
    # bounding box for polygon
    d = 0
    polyxmin = min(xpoly)
    polyymin = min(ypoly)
    polyxmax = max(xpoly)
    polyymax = max(ypoly)
    j0 = np.argmax(np.ma.masked_array(xg,mask=(xg>polyxmin))) - d
    i0 = np.argmax(np.ma.masked_array(yg,mask=(yg>polyymin))) - d
    j1 = np.argmin(np.ma.masked_array(xg,mask=(xg<polyxmax))) + d
    i1 = np.argmin(np.ma.masked_array(yg,mask=(yg<polyymax))) + d
    for i in range(i0, i1+1):            # lopend over horizontale lijnen binnen de bbox
        yl = yg[i]
        x_int = []                       # maak een lijst van snijpunten aan
        for k in range(len(xpoly)):     # lopend over de polygon zijden
            edge = [xpoly[k-1],ypoly[k-1],xpoly[k],ypoly[k]]
            if (ypoly[k] != ypoly[k-1]):
                lamb = (yg[i] - ypoly[k-1]) /(ypoly[k] - ypoly[k-1])
                if (lamb>=0 and lamb<=1):
                    x_int.append(xpoly[k-1] + lamb*(xpoly[k]-xpoly[k-1]))
                    if (len(x_int)==2):
                        break
        if len(x_int) == 2:
            mask = ((xg-x_int[0])*(xg-x_int[1])<0)  # maskeer alle interne punten
            tgt[i, mask] = val
