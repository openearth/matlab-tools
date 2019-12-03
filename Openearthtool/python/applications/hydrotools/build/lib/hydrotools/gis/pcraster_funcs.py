# A collection of functions that work with PCRaster
# These functions work only with PCRaster 3.0 (earlier versions not guaranteed)

import pcraster as pcr

def derive_HAND(dem, ldd, accuThreshold, rivers=None, basin=None, up_area=None):
    """
    Function derives Height-Above-Nearest-Drain.
    See http://www.sciencedirect.com/science/article/pii/S003442570800120X
    Input:
        dem -- pcraster object float32, elevation data
        ldd -- pcraster object direction, local drain directions
        accuThreshold -- upstream amount of cells as threshold for river
            delineation
        rivers=None -- you can provide a rivers layer here. Pixels that are 
                        identified as river should have a value > 0, other
                        pixels a value of zero.
        basin=None -- set a boolean pcraster map where areas with True are estimated using the nearest drain in ldd distance
                        and areas with False by means of the nearest friction distance. Friction distance estimated using the 
                        upstream area as weight (i.e. drains with a bigger upstream area have a lower friction)
                        the spreadzone operator is used in this case.
    Output:
        hand -- pcraster bject float32, height, normalised to nearest stream
        dist -- distance to nearest stream measured in cell lengths
            according to D8 directions
    """
    if rivers is None:
        stream = pcr.ifthenelse(pcr.accuflux(ldd, 1) >= accuThreshold,
                                pcr.boolean(1), pcr.boolean(0))
    else:
        stream = pcr.boolean(pcr.cover(rivers, 0))
    
    height_river = pcr.ifthenelse(stream, pcr.ordinal(dem*100), 0)
    if basin is None:
        up_elevation = pcr.scalar(pcr.subcatchment(ldd, height_river))
    else:
        if up_area is None:
            up_area = pcr.ifthen(stream, pcr.accuflux(ldd, 1))
        friction = 1./pcr.scalar(pcr.spreadzone(pcr.cover(pcr.ordinal(up_area), 0), 0, 0))
        up_elevation = pcr.ifthenelse(basin, pcr.scalar(pcr.subcatchment(ldd, height_river)), pcr.scalar(pcr.spreadzone(height_river, 0, friction)))
        # replace areas outside of basin by a spread zone calculation.
    hand = pcr.max(pcr.scalar(pcr.ordinal(dem*100))-up_elevation, 0)/100
    dist = pcr.ldddist(ldd, stream, 1)
        
    return hand, dist

def subcatch_stream(ldd, threshold, min_strahler=-999, max_strahler=999, assign_edge=False, assign_existing=False, up_area=None):
    """
    Derive catchments based upon strahler threshold
    Input:
        ldd -- pcraster object direction, local drain directions
        threshold -- integer, strahler threshold, subcatchments ge threshold 
            are derived
        min_strahler -- integer, minimum strahler threshold of river catchments 
            to return
        max_strahler -- integer, maximum strahler threshold of river catchments 
            to return
        assign_unique=False -- if set to True, unassigned connected areas at 
            the edges of the domain are assigned a unique id as well. If set 
            to False, edges are not assigned
        assign_existing=False == if set to True, unassigned edges are assigned 
            to existing basins with an upstream weighting. If set to False, 
            edges are assigned to unique IDs, or not assigned
    output:
        stream_ge -- pcraster object, streams of strahler order ge threshold
        subcatch -- pcraster object, subcatchments of strahler order ge threshold
        
    """
    # derive stream order
    
    stream = pcr.streamorder(ldd)
    stream_ge = pcr.ifthen(stream >= threshold, stream)
    stream_up_sum = pcr.ordinal(pcr.upstream(ldd, pcr.cover(pcr.scalar(stream_ge), 0)))
    # detect any transfer of strahler order, to a higher strahler order.
    transition_strahler = pcr.ifthenelse(pcr.downstream(ldd, stream_ge) != stream_ge, pcr.boolean(1),
                                         pcr.ifthenelse(pcr.nominal(ldd) == 5, pcr.boolean(1), pcr.ifthenelse(pcr.downstream(ldd, pcr.scalar(stream_up_sum)) > pcr.scalar(stream_ge), pcr.boolean(1),
                                                                                           pcr.boolean(0))))
    # make unique ids (write to file)
    transition_unique = pcr.ordinal(pcr.uniqueid(transition_strahler))

    # derive upstream catchment areas (write to file)
    subcatch = pcr.nominal(pcr.subcatchment(ldd, transition_unique))
    
    if assign_edge:
        # fill unclassified areas (in pcraster equal to zero) with a unique id, above the maximum id assigned so far
        unique_edge = pcr.clump(pcr.ifthen(subcatch==0, pcr.ordinal(0)))
        subcatch = pcr.ifthenelse(subcatch==0, pcr.nominal(pcr.mapmaximum(pcr.scalar(subcatch)) + pcr.scalar(unique_edge)), pcr.nominal(subcatch))
    elif assign_existing:
        # unaccounted areas are added to largest nearest draining basin
        if up_area is None:
            up_area = pcr.ifthen(pcr.boolean(pcr.cover(stream_ge, 0)), pcr.accuflux(ldd, 1))
        riverid = pcr.ifthen(pcr.boolean(pcr.cover(stream_ge, 0)), subcatch)
        
        friction = 1./pcr.scalar(pcr.spreadzone(pcr.cover(pcr.ordinal(up_area), 0), 0, 0)) # *(pcr.scalar(ldd)*0+1)
        delta = pcr.ifthen(pcr.scalar(ldd)>=0, pcr.ifthen(pcr.cover(subcatch, 0)==0, pcr.spreadzone(pcr.cover(riverid, 0), 0, friction)))
        subcatch = pcr.ifthenelse(pcr.boolean(pcr.cover(subcatch, 0)),
                                      subcatch,
                                      delta)

    # finally, only keep basins with minimum and maximum river order flowing through them
    strahler_subcatch = pcr.areamaximum(stream, subcatch)
    subcatch = pcr.ifthen(pcr.ordinal(strahler_subcatch) >= min_strahler, pcr.ifthen(pcr.ordinal(strahler_subcatch) <= max_strahler, subcatch))
            
    return stream_ge, pcr.ordinal(subcatch)  # delta # pcr.ifthen(pcr.cover(subcatch, 0)==0, friction) # 

def volume_spread(ldd, hand, subcatch, volume, volume_thres=0., area_multiplier=1., iterations=15):
    """
    Estimate 2D flooding from a 1D simulation per subcatchment reach
    Input:
        ldd -- pcraster object direction, local drain directions
        hand -- pcraster object float32, elevation data normalised to nearest drain
        subcatch -- pcraster object ordinal, subcatchments with IDs
        volume -- pcraster object float32, scalar flood volume (i.e. m3 volume outside the river bank within subcatchment)
        volume_thres=0. -- scalar threshold, at least this amount of m3 of volume should be present in a catchment
        area_multiplier=1. -- in case the maps are not in m2, set a multiplier other than 1. to convert
        iterations=15 -- number of iterations to use
    Output:
        inundation -- pcraster object float32, scalar inundation estimate
    """
    #initial values
    pcr.setglobaloption("unittrue")
    dem_min = pcr.areaminimum(hand, subcatch)  # minimum elevation in subcatchments
    # pcr.report(dem_min, 'dem_min.map')
    dem_norm = hand - dem_min
    # pcr.report(dem_norm, 'dem_norm.map')
    # surface of each subcatchment
    surface = pcr.areaarea(subcatch)*area_multiplier
    # pcr.report(surface, 'surface.map')

    error_abs = pcr.scalar(1e10)  # initial error (very high)
    volume_catch = pcr.areatotal(volume, subcatch)
    # pcr.report(volume_catch, 'volume_catch.map')
    
    depth_catch = volume_catch/surface
    # pcr.report(depth_catch, 'depth_catch.map')

    dem_max = pcr.ifthenelse(volume_catch > volume_thres, pcr.scalar(32.),
                             pcr.scalar(0))  # bizarre high inundation depth
    dem_min = pcr.scalar(0.)
    for n in range(iterations):
        print('Iteration: {:02d}'.format(n + 1))
        #####while np.logical_and(error_abs > error_thres, dem_min < dem_max):
        dem_av = (dem_min + dem_max)/2
        # pcr.report(dem_av, 'dem_av00.{:03d}'.format(n + 1))
        # compute value at dem_av
        average_depth_catch = pcr.areaaverage(pcr.max(dem_av - dem_norm, 0), subcatch)
        # pcr.report(average_depth_catch, 'depth_c0.{:03d}'.format(n + 1))
        error = pcr.cover((depth_catch-average_depth_catch)/depth_catch, depth_catch*0)
        # pcr.report(error, 'error000.{:03d}'.format(n + 1))
        dem_min = pcr.ifthenelse(error > 0, dem_av, dem_min)
        dem_max = pcr.ifthenelse(error <= 0, dem_av, dem_max)
    # error_abs = np.abs(error)  # TODO: not needed probably, remove
    inundation = pcr.max(dem_av - dem_norm, 0)
    return inundation
        
       