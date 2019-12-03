# A collection of functions that work with PCRaster
# These functions work only with PCRaster 3.0 (earlier versions not guaranteed)

import pcraster as pcr


def derive_HAND(dem, ldd, accuThreshold):
    """
    Function derives Height-Above-Nearest-Drain.
    See http://www.sciencedirect.com/science/article/pii/S003442570800120X
    Input:
        dem -- pcraster object float32, elevation data
        ldd -- pcraster object direction, local drain directions
        accuThreshold -- upstream amount of cells as threshold for river
            delineation
    Output:
        hand -- pcraster bject float32, height, normalised to nearest stream
        dist -- distance to nearest stream measured in cell lengths
            according to D8 directions
    """
    stream = pcr.ifthenelse(pcr.accuflux(ldd, 1) >= accuThreshold,
                            pcr.boolean(1), pcr.boolean(0))
    height_river = pcr.ifthenelse(stream, pcr.ordinal(dem), 0)
    up_elevation = pcr.scalar(pcr.subcatchment(ldd, height_river))
    hand = pcr.max(dem-up_elevation, 0)
    dist = pcr.ldddist(ldd, stream, 1)
    return hand, dist
