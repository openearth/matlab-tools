# coding: utf-8
class Sobek3Model:
    """Sobek3 model"""

    runid             = " "   # Model id, normally the basename of the md1d/mdu file

    file_names        = {}    # Dictionary with file names
                                # network     Name of network                    file, read from md1d file: [Files]networkFile
                                # bound_loc   Name of boundary locations         file, read from md1d file: [Files]boundLocFile
                                # bound_def   Name of boundary conditions        file, read from md1d file: [Files]boundCondFile
                                # cross_loc   Name of cross sections locations   file, read from md1d file: [Files]crossLocFile
                                # cross_def   Name of cross sections definitions file, read from md1d file: [Files]crossDefFile
                                # roughness   Name of roughness                  file, read from md1d file: [Files]roughnessFile
                                # structure   Name of structure                  file, read from md1d file: [Files]structureFile

    md1d_sections     = {}    # Key: name of section in md1d ini file, value: number of appearances of this section
    md1d_config       = {}    # Full contents of        md1d ini file, read using configParser

    network_sections  = {}    # Key: name of section in network ini file, value: number of appearances of this section
    network_config    = {}    # Full contents of        network ini file, read using configParser

    bndloc_sections   = {}    # Key: name of section in network ini file, value: number of appearances of this section
    bndloc_config     = {}    # Full contents of        bndloc  ini file, read using configParser

    nnodes            = 0     # Number of nodes
    nodes             = {}    # nodes

    nbranches         = 0     # Number of branches
    branches          = {}    # branches

    nbounds           = 0     # Number of boundaries
    boundaries        = {}    # boundaries




