# coding: utf-8
class FMModel:
    """FMModel"""

    runid         = " "      # Model id, normally the basename of the md1d/mdu file

    file_names    = {}       # Dictionary with file names in the input directory

    networkdata   = {}       # 1d mesh

    boundarydata  = {}       # 1d boundaries

    griddata      = {}       # 2d mesh

    crosssections = []       # cross-sections

    keyvalue      = {}       # key-value pairs, (most probably) read from md1d file, (most probably) to be written to mdu file
