"""
    This module contains raster functions and methods.

    It comprises (amongst others) reading, writing, rescaling, sampling,
    reprojecting, operators, statistics, conditionals, window operations
    on raster data.

    Raster data is stored in rasterArr objects, basicly a numpy MaskedArray
    and a dict with geographical information.

    All GDAL supported raster formats are handled. Additionally iMOD raster
    files (IDF) are handled.

    Rescaling/resampling is done automatically if needed.
"""

__author__  = "Wiebe Borren <Wiebe.Borren@deltares.nl>"
__version__ = "2.0"
__date__    = "Sep 2015"


####################################
## EXTERNAL MODULES AND FUNCTIONS ##
####################################

import struct, os.path, string, sys, mmap, traceback, shutil, subprocess, tempfile
from copy import deepcopy
import numpy as np
import numpy.ma as ma
from numpy import bool,bool8,uint8,uint16,uint32,uint64,int8,int16,int32,int64,float16,float32,float64
try: from netCDF4 import Dataset
except: pass
try: from plot_func import *
except: pass
## Check if DLLs in GDAL_DRIVER_PATH could be loaded; otherwise try to remove GDAL_DRIVER_PATH
try:
    from os import environ, listdir
    d=environ["GDAL_DRIVER_PATH"]
    if os.path.isdir(d):
        for dll_file in listdir(d):
            if dll_file[-3:] in ["dll","DLL"]:
                import ctypes
                try:
                    ctypes.WinDLL("%s\\%s" %(d,dll_file))
                except:
                    environ["GDAL_DRIVER_PATH"]=""
                break
except: pass
try:
    import osgeo.gdal
    osgeo.gdal.UseExceptions()
    import osgeo.osr
except:
    pass



#########################################################################################
## GLOBAL VARIABLES: GEO_INFO KEYWORDS AND TYPES, PREFERED NODATA VALUES, RASTER TYPES ##
#########################################################################################

global l_gi_key,l_gi_type
l_gi_key=["xll","yll","dx","dy","nrow","ncol","proj","ang","crs"]
l_gi_type=["float()","float()","float()","float()","int()","int()","int(bool())","float()","str()"]

global l_prefered_nodata
l_prefered_nodata=[\
    [bool,False,True],\
    [bool8,False,True],\
    [uint8,2**8-1,0],\
    [uint16,9999,2**16-1,0],\
    [uint32,999999,2**32-1,0],\
    [uint64,999999,2**64-1,0],\
    [int8,-128,127,0],\
    [int16,-9999,-2**16/2,9999,(2**16-1)/2,0],\
    [int32,-999999,-2**32/2,999999,(2**32-1)/2,0],\
    [int64,-999999,-2**64/2,999999,(2**64-1)/2,0],\
    [float16,-999,999],\
    [float32,-999999,999999,-999.99,999.99],\
    [float64,-999999,999999,-999.99,999.99],\
    ]

global l_raster_format_str,l_raster_format_num
l_raster_format_str=["INVALID","AAIGrid","IDF","PCRaster","AIG","BIL","GTiff","netCDF","HDF4Image"]
l_raster_format_ext=["invalid","asc","idf","map","","bil","tif","nc","hdf"]
l_raster_format_num=[0,1,2,3,4,5,6,7,8]
#l_raster_format_str+=["ACE2","ADRG","AIRSAR","ARG","BLX","BAG","BMP","BSB","BT","CEOS","COASP","COSAR","CPG","CTG","DDS","DIMAP","DIPEx","DODS","DOQ1","DOQ2","DTED","E00GRID","ECRGTOC","ECW","EHdr","EIR","ELAS","ENVI","EPSILON","ERS","ESAT","FAST","FIT","FITS","FujiBAS","GENBIN","GEORASTER","GFF","GIF","GRIB","GMT","GRASS","GRASSASCIIGrid","GSAG","GSBG","GS7BG","GSC","GTA","GTX","GXF","HDF4","HDF5","HF2","HFA","IDA","ILWIS","INGR","IRIS","ISIS2","ISIS3","JAXAPALSAR","JDEM","JPEG","JPEGLS","JPEG2000","JP2ECW","JP2KAK","JP2MrSID","JP2OpenJPEG","JPIPKAK","KMLSUPEROVERLAY","L1B","LAN","LCP","Leveller","LOSLAS","MBTiles","MAP","MEM","MFF","MFF2 (HKV)","MG4Lidar","MrSID","MSG","MSGN","NDF","NGSGEOID","NITF","NTv2","NWT_GRC","NWT_GRD","OGDI","OZI","PAux","PCIDSK","PDF","PDS","PNG","PostGISRaster","PNM","R","RASDAMAN","Rasterlite","RIK","RMF","RPFTOC","RS2","RST","SAGA","SAR_CEOS","SDE","SDTS","SGI","SNODAS","SRP","SRTMHGT","TERRAGEN","TIL","TSX","USGSDEM","VRT","WCS","WEBP","WMS","XPM","XYZ","ZMap"]
l_raster_format_str+=["ACE2","ADRG","ARG","AirSAR","BAG","BIGGIF","BLX","BMP","BSB","BT","CEOS","COASP","COSAR","CPG","CTG","CTable2","DIMAP","DIPEx","DOQ1","DOQ2","DTED","E00GRID","ECRGTOC","EHdr","EIR","ELAS","ENVI","ERS","ESAT","FAST","FIT","FujiBAS","GFF","GIF","GMT","GRASSASCIIGrid","GRIB","GS7BG","GSAG","GSBG","GSC","GTX","GXF","GenBin","HDF4","HDF5","HDF5Image","HF2","HFA","HTTP","IDA","ILWIS","INGR","IRIS","ISIS2","ISIS3","JAXAPALSAR","JDEM","JP2OpenJPEG","JPEG","KMLSUPEROVERLAY","KRO","L1B","LAN","LCP","LOSLAS","Leveller","MAP","MBTiles","MEM","MFF","MFF2","MSGN","NDF","NGSGEOID","NITF","NTv2","NWT_GRC","NWT_GRD","OGDI","OZI","PAux","PCIDSK","PDF","PDS","PNG","PNM","PostGISRaster","R","RIK","RMF","RPFTOC","RS2","RST","Rasterlite","SAGA","SAR_CEOS","SDTS","SGI","SNODAS","SRP","SRTMHGT","TIL","TSX","Terragen","USGSDEM","VRT","WCS","WMS","XPM","XYZ","ZMap"]
l_raster_format_ext+=[s.lower() for s in l_raster_format_str[len(l_raster_format_num):]]
l_raster_format_num+=range(len(l_raster_format_num),len(l_raster_format_str))

global l_pcr_Struct,l_pcr_valueScale
l_pcr_Struct=np.array([\
    ("uint8",   1, "B",   0,  2**8-1 ),\
    ("uint16",  2, "H",  17,  2**16-1),\
    ("uint32",  4, "L",  34,  2**32-1),\
    ("int8",    1, "b",   4, -2**8/2 ),\
    ("int16",   2, "h",  21, -2**16/2),\
    ("int32",   4, "l",  38, -2**32/2),\
    ("float32", 4, "f",  90, "np.nan"),\
    ("float64", 8, "d", 219, "np.nan"),\
    ],dtype="a10,uint8,a1,uint8,a15")
l_pcr_Struct.dtype.names=["data_type","data_bytesize","structFormat","cellRepr","nodata"]

l_pcr_valueScale=np.array([\
    ("boolean",     224, ("uint8",   "uint8")  ),\
    ("nominal",     226, ("uint8",   "int32")  ),\
    ("scalar",      235, ("float32", "float64")),\
    ("ldd",         240, ("uint8",   "uint8")  ),\
    ("ordinal",     242, ("uint8",   "int32")  ),\
    ("directional", 251, ("float32", "float64")),\
    ],dtype="a15,uint8,2a10")
l_pcr_valueScale.dtype.names=["frm_map","valueScale","l_data_type"]


#################################################
## GLOBAL NODATA VALUES FOR IDF AND ASCII Grid ##
#################################################

def set_nodataIDF(nodata=None):
    """Function to set the global IDF nodata value.

    The global IDF nodata value is used in writing an IDF file if no specific nodata value is specified.

    Parameters
    ----------
    nodata : int, float or None (optional)
        The global IDF nodata value.
    """
    global nodataIDF
    nodataIDF=nodata

def get_nodataIDF():
    """Function to get the global IDF nodata value.

    The global IDF nodata value is used in writing an IDF file if no specific nodata value is specified.

    Returns
    -------
    nodata : int, float or None
        The global IDF nodata value.
    """
    return nodataIDF

def set_nodataASC(nodata=None):
    """Function to set the global ASC nodata value.

    The global ASC nodata value is used in writing an ASC file if no specific nodata value is specified.

    Parameters
    ----------
    nodata : int, float or None (optional)
        The global ASC nodata value.
    """
    global nodataASC
    nodataASC=nodata

def get_nodataASC():
    """Function to get the global ASC nodata value.

    The global ASC nodata value is used in writing an ASC file if no specific nodata value is specified.

    Returns
    -------
    nodata : int, float or None
        The global ASC nodata value.
    """
    return nodataASC

## Set the global IDF nodata value initially to -9999
set_nodataIDF(-9999)

## Set the global ASC nodata value initially to -9999
set_nodataASC(-9999)


############################################
## GLOBAL METHOD FOR RESCALING/RESAMPLING ##
############################################

def set_global_method(method=None):
    """Function to set the global method for rescaling/resampling.

    The global method is used if rescaling/resampling is needed, but no method
    is specified by the programmer.

    Parameters
    ----------
    method : str or None (optional)
        The global method for rescaling/resampling. Possible methods are:
        'sum', 'min', 'max', 'harm', 'log10', 'log', 'mean', 'sample', None.

    See Also
    --------
    :ref:`rescaling_resampling`
    """
    global global_method
    if method != None:
        global_method=method
    else:
        global_method="sample"

def reset_global_method():
    """Function to reset the global method for rescaling/resampling to None.

    Same as ``set_global_method(None)``

    See Also
    --------
    :ref:`rescaling_resampling`

    :func:`raster_func.set_global_method`
    """
    set_global_method(None)

def get_global_method():
    """Function to get the global method for rescaling/resampling.

    The global method is used if rescaling/resampling is needed, but no method
    is specified by the programmer.

    Returns
    -------
    method : str or None
        The global method for rescaling/resampling. Possible methods are:
        'sum', 'min', 'max', 'harm', 'log10', 'log', 'mean', 'sample', None.

    See Also
    --------
    :ref:`rescaling_resampling`
    """
    return global_method

## Set the global method initially to None
set_global_method(None)


#####################
## CLASS rasterArr ##
#####################

class rasterArr(object):
    """Raster data object class.

    Parameters
    ----------
    arr : array, array_like, rasterArr object, float or int
        Raster values.

        *arr* could be an existing rasterArr object, a numpy array (ndarray or MaskedArray) or an array_like object (list or tuple).
        It could be 2-D or 3-D (map stack).

    gi : dict or list (optional)
        Geographical information.

        If *gi* is specified as a list the order of the elements should be: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.
        If *arr* is specified as rasterArr object then *gi* is overruled with the geographical information of *arr*.

    nodata : bool, int or float (optional)
        Nodata value to be applied.

    kwargs : keyword arguments (optional)
        The keyword arguments could be used to set basic geographical information. Recognized keywords are:
        xll, yll, dx, dy, nrow, ncol, proj, ang, crs.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`rasterArr_object`
    :ref:`geo_info`

    Notes
    -----
    Some internal methods for consistency are applied upon initialisation.
    This comprises the number of dimensions of the object (see below), nodata value and mask, nrow and ncol of *arr* and *gi* etc.

    If the number of dimensions of the object is lower than 2 the number of dimensions is increased to 2 by adding new dimensions.
    E.g. the 1-D array [1,2] becomes the 2-D array [[1,2]].

    If the number of dimensions of the object is higher than 3 the number of dimensions is decreased to 3 by removing dimensions.
    From each dimension higher than 3 the first element is taken. The other elements are removed.
    E.g. the 4-D array [ [[(1,2),(3,4)],[(11,12),(13,14)]], [[(101,102),(103,104)],[(111,112),(113,114)]] ] becomes
    the 3-D array [[(1,2),(3,4)],[(11,12),(13,14)]].
    """


    ## INITIALISATION / INSTANTIATION ##

    def __init__(self, arr, gi=None, nodata=None, **kwargs):
        """Method to create/initiate a rasterArr object.

        See Also
        --------
        :ref:`rasterArr_object`
        :class:`raster_func.rasterArr`
        """

        ## set array, geo_info and nodata
        try:                                     # arr is rasterArr object: make deep copy of arr, gi and nodata
            arr,gi,nodata=deepcopy(arr.arr),deepcopy(arr.gi()),deepcopy(arr.nodata())
        except:
            if type(arr) == ma.core.MaskedArray: # arr is masked array: nodata is set to fill_value
                nodata=_value_dtype2type(arr.fill_value)
        self.arr=ma.array(arr)                   # array: numpy MaskedArray object
        self.__gi=gi2dict(gi,**kwargs)           # geographical information (geo_info, gi): dictionary with keys xll,yll,dx,dy,nrow,ncol,proj,ang
        self.__nodata=nodata                     # nodata value

          # make object consistent
        self.__set_ndim_arr()                    # set number of dimensions of array to minimum of 2 (lower 2 dimensions are rows and columns)
        self.set_nodata(nodata)                  # mask nodata cells of array and re-set nodata of object
        if self.__nodata == None:                # if nodata is still None
            self.set_nodata_mask()               #  then set nodata to prefered default nodata value
        self.__set_nrowcol_gi()                  # set nrow and ncol of geo_info to nrow and ncol of array
        self.__set_types_gi()                    # set types of geo_info elements
        if self.arr.mask.ndim == 0:              # set shape of mask to same shape as array
            self.arr.mask=np.ones(self.arr.shape,bool)*self.arr.mask


    ## METHOD TO CREATE STRING REPRESENTATION (E.G. FOR PRINTING) ##

    def __str__(self):
        """Method to create a string representation of the rasterArr object.

        Returns
        -------
        result : str
            String of the raster data array.
        """
        return "%s" %(self.arr)


    ## METHOD TO COPY RASTERARR OBJECT TO A NEW OBJECT ##

    def copy(self):
        """Method to create a deep copy of the rasterArr object.

        Returns
        -------
        result : rasterArr object
            A deep copy of the rasterArr object.

        See Also
        --------
        :ref:`rasterArr_assignment`
        """
        return rasterArr(deepcopy(self.arr),deepcopy(self.gi()),deepcopy(self.nodata()))


    ## METHODS TO SET GEOGRAPHICAL INFORMATION, NODATA, MASK AND DATA ARRAY ##

    def set_gi(self,**kwargs):
        """Method to set geographical information using keyword arguments (in-place).

        Parameters
        ----------
        kwargs : keyword arguments
            Recognized keyword arguments are: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.
            Other keyword arguments are ignored.

        See Also
        --------
        :ref:`geo_info`
        """
        for key in kwargs:
            try: self.__gi[key]=kwargs[key]
            except: pass
        self.__set_nrowcol_gi()
        self.__set_types_gi()

    def set_extent(self,l_extent,snap=True):
        """Method to create a new rasterArr object with a changed extent.

        Parameters
        ----------
        extent : list
            A list containing xll, yll, xur and yur of the new extent (in this order).

        snap : bool (optional)
            Flag to snap (shift) the new extent to match with the original cell boundaries.

            True = snap is performed to the nearest cell boundaries.

            False = snap is not performed

        Returns
        -------
        result : rasterArr object
            RasterArr object with new extent.
        """
        to_gi = gi_set_extent(self.gi(),l_extent,snap)
        return self.rescale(to_gi, method="sample")

    def set_dxdy(self,dx=None,dy=None,method="sample"):
        """Method to create a new rasterArr object with changed cellsize.

        Parameters
        ----------
        dx : float, int, numpy array or array_like (optional)
            Cell size in x direction (column width).

            If *dx* is a numpy array (or array_like) the number of columns (ncol) is adjusted too.

        dy : float, int or numpy array (optional)
            Cell size in y direction (row height).

            If *dy* is a numpy array (or array_like) the number of rows (nrow) is adjusted too.

        method : str or None (optional)
            The rescaling/resampling method. Possible methods are:
            'sum', 'min', 'max', 'harm', 'log10', 'log', 'mean', 'sample', None.

        Returns
        -------
        result : rasterArr object
            RasterArr object with new cellsize.
        """
        to_gi = gi_set_dxdy(self.gi(),dx,dy)
        return self.rescale(to_gi, method=method)

    def set_nodata(self,nodata=None):
        """Method to set the nodata value (in-place).

        Original nodata cells are kept; new nodata cells are added if applicable.

        Parameters
        ----------
        nodata : bool, int, float or str
            If *nodata* is of type str then nodata is used in a where condition. E.g. '>10' means that all values greater than 10 are set to nodata.

        See Also
        --------
        :ref:`nodata`
        """
        nodata=_value_dtype2type(nodata)
        if type(nodata) in [str,bool,int,float]:
            if type(self.arr) != ma.core.MaskedArray:
                self.arr=ma.array(self.arr)
            if type(nodata) == str:
                nodata=string.replace(nodata,"rasterValue","self.arr")
                try:
                    exec("self.arr.mask=ma.where(self.arr %s,True,self.arr.mask)" %(nodata))
                except:
                    exec("self.arr.mask=np.where(%s,True,self.arr.mask)" %(nodata))
                try:
                    if self.arr.mask.min():
                        self.__nodata=_value_dtype2type(_get_prefered_nodata(self))
                    else: raise
                except:
                    self.__nodata=_value_dtype2type(_get_prefered_nodata(self))
            else:
                self.__nodata=nodata
            #self.arr=ma.masked_values(ma.filled(ma.array(self.arr,_get_min_dtype(self.arr,self.__nodata)),self.__nodata),self.__nodata)
            if self.arr.mask.ndim == 0: self.arr.mask=np.ones(self.arr.shape,bool)*self.arr.mask
            self.arr.mask[self.arr.data == self.__nodata]=True
            self.arr.data[self.arr.mask]=self.__nodata
            self.arr.fill_value=self.__nodata

    def set_mask(self,mask=None,add=False):
        """Method to set the mask (in-place).

        Parameters
        ----------
        mask : numpy array (ndarray or MaskedArray), rasterArr object, bool, int, float or str
            The mask to be applied.

            If *mask* is of type bool, int, float or str this value is used to set the nodata value. See :func:`raster_func.rasterArr.set_nodata`.

        add : bool (optional)
            True = add new masked cells to existing mask

            False = change existing mask to new mask

        See Also
        --------
        :ref:`nodata`
        """
        if type(mask) in [str,bool,int,float]:
            self.set_nodata(mask)
        elif type(mask) != type(None):
            if type(self.arr) != ma.core.MaskedArray:
                self.arr=ma.array(self.arr)
                self.arr.mask=np.zeros(self.arr.shape,bool)
            if add:
                try:
                    mask.gi(); self.arr.mask=np.maximum(self.arr.mask,mask.arr)
                except: self.arr.mask=np.maximum(self.arr.mask,mask)
            else:
                try: mask.gi(); self.arr.mask=mask.arr
                except: self.arr.mask=mask
            if self.arr.mask.ndim == 0: self.arr.mask=np.ones(self.arr.shape,bool)*self.arr.mask
            self.arr.data[self.arr.mask == True]=self.__nodata

    def set_nodata_mask(self):
        """Method to set all cells with nodata value to masked cells (in-place).

        See Also
        --------
        :ref:`nodata`
        """
        nodata=_get_prefered_nodata(self)
        if self.arr.mask.ndim == 0: self.arr.mask=np.ones(self.arr.shape,bool)*self.arr.mask
        self.arr.data[self.arr.mask]=nodata
        self.__nodata=nodata
        self.arr.fill_value=nodata

    def cover(self,other):
        """Method to fill (cover) nodata cells.

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        method=get_global_method()
        a=self.copy()
        mask1=a.arr.mask
        if mask1.ndim == 0: mask1=np.ones(a.arr.shape,bool)*mask1
        try:
            other.gi()
            b=other.rescale(self.gi(),method=method).arr
            mask2=b.mask
        except:
            try:
                if other.shape == a.arr.shape:
                    b=deepcopy(other)
                    try: mask2=other.mask
                    except: mask2=False
                elif other.shape == ():
                    b=np.resize(other,a.arr.shape)
                    try: mask2=other.mask
                    except: mask2=False
                else:
                    return a
            except:
                if type(other) in [int,float]:
                    b=other
                    mask2=False
                else:
                    return a
        mask=np.minimum(mask1,mask2)
        a.arr=ma.filled(a.arr,0)
        cp=np.ravel((mask == False)*(mask1 == True))
        rowcol=np.indices(a.arr.shape)
        cpr=np.compress(cp,np.ravel(rowcol[0]))
        cpc=np.compress(cp,np.ravel(rowcol[1]))
        if type(b) in [int,float]:
            a.arr[cpr,cpc]=b
        else:
            a.arr[cpr,cpc]=b[cpr,cpc]
        a.set_mask(mask,False)
        return a

    def set_arr(self,arr,method="sample"):
        """Method to set the data array (in-place).

        Does not work for non-equidistant rasters if rescaling/resampling is needed.

        Parameters
        ----------
        arr : numpy array (ndarray or MaskedArray), rasterArr object, bool, int or float
            The new data array.

            If *arr* is of type bool, int or float the data array is set to this value on all cells.

            If *arr* is a rasterArr object a rescaling/resampling of *arr* is applied if needed.

        method : str or None (optional)
            Method for rescaling/resampling, if needed.

        See Also
        --------
        :ref:`indexing_slicing`
        """
        if type(arr) in [bool,int,float]:
            self.arr.data[:]=arr
            if arr == self.nodata(): self.set_nodata(self.nodata())
        elif type(arr) != type(None):
            try:
                arr.gi()
                self.arr=arr.rescale(self.gi(),method)
                self.set_nodata(arr.nodata())
            except:
                if type(arr) != ma.core.MaskedArray:
                    self.arr.data[:]=deepcopy(arr)
                    self.set_nodata(self.nodata())
                else:
                    self.arr=deepcopy(arr)
                    self.set_nodata(arr.fill_value)

    def shape(self):
        """Method to get the shape of the data array.

        Returns
        -------
        shape : tuple
        """
        return self.arr.shape

    def dtype(self):
        """Method to get the dtype of the data array.

        Returns
        -------
        dtype : numpy dtype object
        """
        return self.arr.dtype


    ## METHODS FOR CONSISTENCY OF OBJECT ##

    def __set_ndim_arr(self):
        """Method to set the dimensions (ndim) of the data array to 2-D or 3-D (in-place).

        If the number of dimensions is lower than 2 the number of dimensions is increased to 2 by adding new dimensions.
        E.g. the 1-D array [1,2] becomes the 2-D array [[1,2]].

        If the number of dimensions is higher than 3 the number of dimensions is decreased to 3 by removing dimensions.
        From each dimension higher than 3 the first element is taken. The other elements are removed.
        E.g. the 4-D array [ [[(1,2),(3,4)],[(11,12),(13,14)]], [[(101,102),(103,104)],[(111,112),(113,114)]] ] becomes
        the 3-D array [[(1,2),(3,4)],[(11,12),(13,14)]].

        See Also
        --------
        :ref:`rasterArr_object`
        """
        if self.arr.ndim == 0:
            try:
                self.arr=ma.resize(self.arr,(self.__gi["nrow"],self.__gi["ncol"]))
            except:
                pass
        for i in range(self.arr.ndim,2): self.arr=ma.reshape(self.arr,(1,)+self.arr.shape)
        for i in range(3,self.arr.ndim): self.arr=self.arr[0]
        if self.arr.mask.ndim == 0: self.arr.mask=np.ones(self.arr.shape,bool)*self.arr.mask

    def __set_types_gi(self):
        """Method to set the data types of the geographical information elements (in-place).

        If not possible then set geo_info element to None or (in case of proj and ang) to default value.
        """
          # xll: float or None
        try: self.__gi["xll"]=float(self.__gi["xll"])
        except: self.__gi["xll"]=None
          # yll: float or None
        try: self.__gi["yll"]=float(self.__gi["yll"])
        except: self.__gi["yll"]=None
          # dx: float, array or None
        try:
            if np.array(self.__gi["dx"]).ndim > 0:
                try:
                    self.__gi["dx"]=np.ravel(np.array(self.__gi["dx"]))
                    self.__gi["dx"]=np.array(self.__gi["dx"],_get_min_dtype(np.array(1,float32),self.__gi["dx"].min(),self.__gi["dx"].max()))
                except: self.__gi["dx"]=None
            else: self.__gi["dx"]=float(self.__gi["dx"])
        except: self.__gi["dx"]=None
          # dy: float, array or None
        try:
            if np.array(self.__gi["dy"]).ndim > 0:
                try:
                    self.__gi["dy"]=np.ravel(np.array(self.__gi["dy"]))
                    self.__gi["dy"]=np.array(self.__gi["dy"],_get_min_dtype(np.array(1,float32),self.__gi["dy"].min(),self.__gi["dy"].max()))
                except: self.__gi["dy"]=None
            else: self.__gi["dy"]=float(self.__gi["dy"])
        except: self.__gi["dy"]=None
          # dx and dy: convert to float or array, depending on ieq
        try: self.__gi["dx"]=self.__dx_ieq()
        except: pass
        try: self.__gi["dy"]=self.__dy_ieq()
        except: pass
          # ncol: int or None
        try: self.__gi["ncol"]=int(self.__gi["ncol"])
        except: self.__gi["ncol"]=None
          # nrow: int or None
        try: self.__gi["nrow"]=int(self.__gi["nrow"])
        except: self.__gi["nrow"]=None
          # proj: int (0 or 1)
        try:
            if self.__gi["proj"] != None:
                self.__gi["proj"]=int(bool(self.__gi["proj"]))
            else: raise
        except: self.__gi["proj"]=1
          # ang: float
        try: self.__gi["ang"]=float(self.__gi["ang"])
        except: self.__gi["ang"]=0.0
          # crs: string
        try:
            if self.__gi["crs"] == None: raise
            self.__gi["crs"]=crs2epsg(self.__gi["crs"],"%s" %(self.__gi["crs"]))
        except: self.__gi["crs"]=""

    def __set_nrowcol_gi(self):
        """Method to set the nrow and ncol elements of the geographical information to the shape of the array (in-place).
        """
        self.__gi["nrow"]=self.arr.shape[-2]
        self.__gi["ncol"]=self.arr.shape[-1]
        if np.array(self.__gi["dx"]).ndim > 0:
            dx=np.ravel(np.array(self.__gi["dx"]))
            if len(dx) != self.__gi["ncol"]: self.__gi["dx"]=dx.mean()
        if np.array(self.__gi["dy"]).ndim > 0:
            dy=np.ravel(np.array(self.__gi["dy"]))
            if len(dy) != self.__gi["nrow"]: self.__gi["dy"]=dy.mean()


    ## METHODS TO GET GEOGRAPHICAL INFORMATION

    def get_gi(self,*args):
        """Method to get a list of specified geographical information elements.

        Parameters
        ----------
        args : arguments (str)
            Recognized arguments are: 'gi', 'gi_list', 'nodata', 'xll', 'xur', 'yll', 'yur', 'dx', 'Dx',
            'dy', 'Dy', 'ieq', 'nrow', 'ncol', 'proj', 'ang', 'crs'.
            Other arguments are ignored.

            If 'gi' is specified the dict of the basic geographical information is returned.
            If 'gi_list' is specified the basic geographical information is returned as list with fixed order:
            xll, yll, dx, dy, nrow, ncol, proj, ang, crs.

        Returns
        -------
        result : list
            The list with the specified elements.

        See Also
        --------
        :ref:`geo_info`
        """
        l_result=[]
        for key in args:
            if key in ['gi', 'gi_list', 'nodata', 'xll', 'xur', 'yll', 'yur', 'dx', 'Dx', 'dy', 'Dy', 'ieq', 'nrow', 'ncol', 'proj', 'ang', 'crs']:
                try: exec("l_result.append(self.%s())" %(key))
                except: pass
        return l_result

    def gi(self):
        """Method to get the basic geographical information dict.

        The basic geographical information comprises: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.

        Returns
        -------
        gi : dict
            The basic geographical information.

        See Also
        --------
        :ref:`geo_info`
        """
        return deepcopy(self.__gi)

    def gi_list(self):
        """Method to get the basic geographical information as list.

        The basic geographical information comprises: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.

        Returns
        -------
        gi : list
            The basic geographical information.

            The order of the elements is fixed: see above.

        See Also
        --------
        :ref:`geo_info`
        """
        return gi2list(self.__gi)

    def gi_extended(self,as_list=False):
        """Method to get the extended geographical information.

        The extended geographical information comprises: xur, yur, Dx, Dy.

        Parameters
        ----------
        as_list : bool (optional)
            True = return result as list; order of elements is fixed: see above.

            False = return result as dict.

        Returns
        -------
        gi : dict or list
            The extended geographical information.

        See Also
        --------
        :ref:`geo_info`
        """
        return gi_extended(self)

    def nodata(self):
        """Method to get the nodata value.

        Returns
        -------
        nodata : bool, int or float

        See Also
        --------
        :ref:`nodata`
        """
        return self.__nodata

    def mask(self):
        """Method to get the mask.

        Returns
        -------
        mask : numpy array

        See Also
        --------
        :ref:`nodata`
        """
        return self.arr.mask

    def xll(self):
        """Method to get xll (x coordinate of lower left corner).

        Returns
        -------
        xll : float

        See Also
        --------
        :ref:`geo_info`
        """
        return self.__gi["xll"]

    def yll(self):
        """Method to get yll (y coordinate of lower left corner).

        Returns
        -------
        yll : float

        See Also
        --------
        :ref:`geo_info`
        """
        return self.__gi["yll"]

    def dx(self):
        """Method to get dx (cell size in x direction).

        Returns
        -------
        dx : float or numpy array (1-D)
            If the raster is non-equidistant the dx is a numpy array containing the cell sizes of each column.

        See Also
        --------
        :ref:`geo_info`
        """
        return self.__gi["dx"]

    def dy(self):
        """Method to get dy (cell size in y direction).

        Returns
        -------
        dy : float or numpy array (1-D)
            If the raster is non-equidistant the dy is a numpy array containing the cell sizes of each row.

        See Also
        --------
        :ref:`geo_info`
        """
        return self.__gi["dy"]

    def nrow(self):
        """Method to get nrow (number of rows).

        Returns
        -------
        nrow : int

        See Also
        --------
        :ref:`geo_info`
        """
        return self.__gi["nrow"]

    def ncol(self):
        """Method to get ncol (number of columns).

        Returns
        -------
        ncol : int

        See Also
        --------
        :ref:`geo_info`
        """
        return self.__gi["ncol"]

    def proj(self):
        """Method to get proj (projection flag in PCRaster terms).

        Returns
        -------
        proj : int
            0 = y coordinates increase from top to bottom

            1 = y coordinates increase from bottom to top

        See Also
        --------
        :ref:`geo_info`
        """
        return self.__gi["proj"]

    def ang(self):
        """Method to get ang (angle/rotation of coordinate system in PCRaster terms).

        Returns
        -------
        ang : float

        See Also
        --------
        :ref:`geo_info`
        """
        return self.__gi["ang"]

    def crs(self):
        """Method to get crs (coordinate reference system).

        Returns
        -------
        ang : float

        See Also
        --------
        :ref:`geo_info`
        """
        return self.__gi["crs"]

    def xur(self):
        """Method to get xur (x coordinate of upper right corner).

        Returns
        -------
        xur : float

        See Also
        --------
        :ref:`geo_info`
        """
        try: return self.xll()+self.Dx()
        except: return None

    def yur(self):
        """Method to get yur (y coordinate of upper right corner).

        Returns
        -------
        yur : float

        See Also
        --------
        :ref:`geo_info`
        """
        if self.proj() == 0:
            try: return self.yll()-self.Dy()
            except: return None
        else:
            try: return self.yll()+self.Dy()
            except: return None

    def extent(self):
        """Method to get the extent: xll, yll, xur, yur.

        Returns
        -------
        extent : list
        """
        try: return [self.xll(),self.yll(),self.xur(),self.yur()]
        except: return None

    def Dx(self):
        """Method to get Dx (total extent/width in x direction).

        Returns
        -------
        Dx : float

        See Also
        --------
        :ref:`geo_info`
        """
        if type(self.dx()) not in [int,float]:
            try: return float(sum(self.dx()))
            except: return None
        else:
            try: return float(self.dx())*self.ncol()
            except: return None

    def Dy(self):
        """Method to get Dy (total extent/height in y direction).

        Returns
        -------
        Dy : float

        See Also
        --------
        :ref:`geo_info`
        """
        if type(self.dy()) not in [int,float]:
            try: return float(sum(self.dy()))
            except: return None
        else:
            try: return float(self.dy())*self.nrow()
            except: return None

    def x(self):
        """Method to get the x coordinates of the column centers of a rasterArr object.

        Returns
        -------
        x : numpy ndarray
        """
        if type(self.dx()) == float:
            dx=np.ones((self.ncol(),),float64)*self.dx()
        else:
            dx=self.dx().copy()
        x=np.add.accumulate(dx)
        x=(x+(x-dx))/2.
        return x+self.xll()

    def y(self):
        """Method to get the y coordinates of the row centers of a rasterArr object.

        Returns
        -------
        y : numpy ndarray
        """
        if type(self.dy()) == float:
            dy=np.ones((self.nrow(),),float64)*self.dy()
        else:
            dy=self.dy().copy()
        y=np.add.accumulate(dy)
        y=(y+(y-dy))/2.
        if self.proj() == 1:
            return -y+self.yur()
        else:
            return y+self.yur()

    def xarr(self):
        """Method to get the x coordinates of the cell centers of a rasterArr object and return them as a rasterArr object.

        Returns
        -------
        x : rasterArr object
        """
        return rasterArr(np.ones((self.nrow(),self.ncol()),float64)*self.x(),self.gi())

    def yarr(self):
        """Method to get the y coordinates of the cell centers of a rasterArr object and return them as a rasterArr object.

        Returns
        -------
        y : rasterArr object
        """
        return rasterArr(np.ones((self.nrow(),self.ncol()),float64)*np.reshape(self.y(),(self.nrow(),1)),self.gi())

    def dxarr(self):
        """Method to get dx (cell size in x direction) for all cells of a rasterArr object and return them as a rasterArr object.

        Returns
        -------
        dx : rasterArr object
        """
        return rasterArr(np.ones((self.nrow(),self.ncol()),float64)*self.dx(),self.gi())

    def dyarr(self):
        """Method to get dy (cell size in y direction) for all cells of a rasterArr object and return them as a rasterArr object.

        Returns
        -------
        dy : rasterArr object
        """
        if self.ieq() == 1:
            return rasterArr(np.ones((self.nrow(),self.ncol()),float64)*np.reshape(self.dy(),(self.nrow(),1)),self.gi())
        else:
            return rasterArr(np.ones((self.nrow(),self.ncol()),float64)*self.dy(),self.gi())

    def ieq(self):
        """Method to get ieq (equidistant flag).

        Returns
        -------
        ieq : int
            0 = equidistant raster

            1 = non-equidistant raster

        See Also
        --------
        :ref:`geo_info`
        """
        if type(self.dx()) not in [int,float]:
            try:
                if min(self.dx()) != max(self.dx()): return 1
                elif type(self.dy()) not in [int,float]:
                    try:
                        if min(self.dy()) != max(self.dy()): return 1
                        else: return 0
                    except: return None
                else: return 0
            except: return None
        elif type(self.dy()) not in [int,float]:
            try:
                if min(self.dy()) != max(self.dy()): return 1
                else: return 0
            except: return None
        else: return 0

    def __dx_ieq(self):
        """Method to get dx as float for equidistant raster or array for non-equidistant raster.

        This method is usefull to be sure to get dx in the right data type. In almost all cases this is the same as the method ``dx()``.

        Returns
        -------
        dx_ieq : float or numpy array (1-D)
        """
        if self.ieq() == 1:
            if type(self.dx()) not in [int,float]:
                try: return np.array(self.dx(),float32)
                except: return None
            else:
                try: return np.ones((self.ncol(),),float32)*self.dx()
                except: return None
        else:
            if type(self.dx()) not in [int,float]:
                try: return float(self.dx()[0])
                except: return None
            else:
                return float(self.dx())

    def __dy_ieq(self):
        """Method to get dy as float for equidistant raster or array for non-equidistant raster.

        This method is usefull to be sure to get dy in the right data type. In almost all cases this is the same as the method ``dy()``.

        Returns
        -------
        dy_ieq : float or numpy array (1-D)
        """
        if self.ieq() == 1:
            if type(self.dy()) not in [int,float]:
                try: return np.array(self.dy())
                except: return None
            else:
                try: return np.ones((self.nrow(),),float32)*self.dy()
                except: return None
        else:
            if type(self.dy()) not in [int,float]:
                try: return float(self.dy()[0])
                except: return None
            else:
                return float(self.dy())


    ## METHODS TO WRITE RASTERARR OBJECT TO RASTER FILES

    def write(self,f_raster,raster_format=0,frm_asc="%s",xy_center_asc=False,nodata_asc=None,itb_idf=None,nodata_idf=None,frm_map=None,f_hdr=None):
        """Method to write a 2-D or 3-D rasterArr object to raster file(s).

        Parameters
        ----------
        f_raster : str or list
            Raster file name(s).

            For a 2-D rasterArr object only one file name is required.
            For a 3-D rasterArr object (map stack) a list of file names is required if the raster format only supports 2-D rasters.

        raster_format : int or str (optional)
            Number or string referring to the format of the raster file.

            See :ref:`raster_formats`.

            If *raster_format* is 0 the raster format is determined from the extension of the file.

        frm_asc : str (optional)
            % format for writing ASCII grid file.

            Include a divider if needed, e.g. ' %.1f' for a single space divider; divider is set automatically to ' ' for the formats '%s', '%d' and '%f'.

        xy_center_asc : bool (optional)
            True = xll,yll coordinates for the center of the cell (XLLCENTER and YLLCENTER)

            False = xll,yll coordinates for the corner of the cell (XLLCORNER and YLLCORNER)

        nodata_asc : int, float or None (optional)
            Nodata value to be used for writing an ASCII grid file. Otherwise the global ASCII grid nodata value is used.

        itb_idf : list or None (optional)
            Top and bot values of IDF file: ITB option.

        nodata_idf : int, float or None (optional)
            Nodata value to be used for writing an IDF file. Otherwise the global IDF nodata value is used.

        frm_map : str or None (optional)
            PCRaster map type.

            Recognized types are: 'boolean', 'nominal', 'scalar', 'directional', 'ordinal', 'ldd'.

            If *frm_map* is None then the type is set to 'boolean', 'nominal' or 'scalar' depending on the dtype of the data array.

        f_hdr : str, list or None (optional)
            Header file name(s) for BIL file.

            If *f_hdr* is None the header file name is taken from the BIL file name (*f_raster*).

            In the case of a map stack to be written to multiple BIL files, *f_hdr* could be a list of file names (not required).

        Returns
        -------
        Raster file name(s), e.g. to be used for printing : str or list

        See Also
        --------
        :ref:`writing_rasters`
        :ref:`raster_formats`
        """
        if type(f_raster) not in [list,tuple]: f_raster=[f_raster]
        if raster_format not in l_raster_format_num[1:] and raster_format not in l_raster_format_str[1:]:
            raster_format=_fname2raster_format(f_raster[-1])
        if type(raster_format) == str:
            try: raster_format=l_raster_format_num[1:][l_raster_format_str[1:].index(raster_format)]
            except: raster_format=0
        if raster_format not in l_raster_format_num[1:]:
            raise Exception, "Cannot determine raster format (%s)" %(f_raster[-1])
        rnk=3
        if self.arr.ndim == 2: self.arr,rnk=ma.reshape(self.arr,(1,)+self.arr.shape),2
        self.__set_types_gi()
        self.set_nodata_mask()
        nam,ext=os.path.splitext(f_raster[-1])
        if raster_format not in [5,6,7] or (raster_format in [5,6,7] and len(f_raster) != 1):
            for i in range(len(f_raster),self.arr.shape[0]): f_raster+=["%s_#%d%s" %(nam,i+1,ext)]
        for f in f_raster:
            d=os.path.dirname(os.path.abspath(f))
            if not os.path.isdir(d):
               os.makedirs(d)
        if raster_format == 1:
            for l in range(0,self.arr.shape[0]): self.__arr2asc(l,f_raster[l],frm_asc,xy_center_asc,nodata_asc)
        elif raster_format == 2:
            for l in range(0,self.arr.shape[0]): self.__arr2idf(l,f_raster[l],itb_idf,nodata_idf)
        elif raster_format == 3:
            for l in range(0,self.arr.shape[0]): self.__arr2map(l,f_raster[l],frm_map)
        elif raster_format == 5:
            if len(f_raster) == 1: self.__arr2bil(-1,f_raster[0],f_hdr)
            else:
                for l in range(0,self.arr.shape[0]): self.__arr2bil(l,f_raster[l],f_hdr)
        elif raster_format == 7:
            if len(f_raster) == 1: self.__arr2netcdf(-1,f_raster[0])
            else:
                for l in range(0,self.arr.shape[0]): self.__arr2netcdf(l,f_raster[l])
        else:
            if len(f_raster) == 1: self.__arr2gdal(-1,f_raster[0],raster_format)
            else:
                for l in range(0,self.arr.shape[0]): self.__arr2gdal(l,f_raster[l],raster_format)
        if rnk == 2:
            self.arr=ma.reshape(self.arr,self.arr.shape[-2:])
            return f_raster[-1]
        else: return f_raster

    def arr2raster(self,f_raster,raster_format=0,frm_asc="%s",xy_center_asc=False,nodata_asc=None,itb_idf=None,nodata_idf=None,frm_map=None,f_hdr=None):
        """Method to write a 2-D or 3-D rasterArr object to raster file(s).

        Same as method ``write(..)``.

        See Also
        --------
        :func:`raster_func.rasterArr.write`
        """
        return self.write(f_raster,raster_format,frm_asc,xy_center_asc,nodata_asc,itb_idf,nodata_idf,frm_map,f_hdr)

    def __arr2asc(self,l,f_raster,frm_asc=None,xy_center_asc=False,nodata_asc=None):
        """Method to write a ASCII grid file.

        The raster data is 3-D ({nlay,}nrow,ncol), but only one 2-D array is written.

        Parameters
        ----------
        l : int
            Index of the layer/block to be written.

        f_raster : str
            ASCII grid file name.

        frm_asc : str (optional)
            % format for writing ASCII grid file.

            Include a divider if needed, e.g. ' %.1f' for a single space divider; divider is set automatically to ' ' for the formats '%s', '%d' and '%f'.

        xy_center_asc : bool (optional)
            True = xll,yll coordinates for the center of the cell (XLLCENTER and YLLCENTER)

            False = xll,yll coordinates for the corner of the cell (XLLCORNER and YLLCORNER)

        nodata_asc : int, float or None (optional)
            Nodata value to be used for writing an ASCII grid file. Otherwise the global ASCII grid nodata value is used.
        """
        try:
            nrow,ncol=self.arr[l].shape
            dx,dy=self.dx(),self.dy()
            if dx == None: raise Exception('no cellsize information present, dx == None')
            if dy == None: raise Exception('no cellsize information present, dy == None')
            if type(dx) != float: dx=float(dx.mean())
            if type(dy) != float: dy=float(dy.mean())
            dxy=dx*0.5+dy*0.5
            div=""
            if frm_asc == None: frm_asc="%s"
            if frm_asc in ["%d","%f","%s"]: div=" "
            arr=np.array(self.arr[l])
            if nodata_asc != None:
                nodata=nodata_asc
            elif nodataASC != None:
                nodata=nodataASC
            else:
                nodata=self.nodata()
            arr[arr == self.nodata()]=nodata
            outf=open(f_raster,"w")
            if xy_center_asc:
                outf.write("NCOLS        %s\nNROWS        %s\nXLLCENTER    %s\nYLLCENTER    %s\nCELLSIZE     %s\n" \
                   %(ncol,nrow,self.xll()+dxy/2,self.yll()+dxy/2,dxy))
            else:
                outf.write("NCOLS        %s\nNROWS        %s\nXLLCORNER    %s\nYLLCORNER    %s\nCELLSIZE     %s\n" \
                   %(ncol,nrow,self.xll(),self.yll(),dxy))
            if nodata != None: outf.write("NODATA_VALUE %s\n" %(nodata))
            for r in range(0,nrow):
                outf.write("%s" %(frm_asc %(arr[r,0])))
                for c in range(1,ncol):
                    outf.write("%s%s" %(div,frm_asc %(arr[r,c])))
                outf.write("\n")
            outf.close()
            if self.crs() != "":
                crs2prj("%s.prj" %(os.path.splitext(f_raster)[0]),self.crs())
        except Exception, err:
            try: outf.close()
            except: pass
            raise err

    def __arr2idf(self,l,f_raster,itb_idf=None,nodata_idf=None):
        """Method to write an iMOD IDF file.

        The raster data is 3-D ({nlay,}nrow,ncol), but only one 2-D array is written.

        Parameters
        ----------
        l : int
            Index of the layer/block to be written.

        f_raster : str
            iMOD IDF file name.

        itb_idf : list or None (optional)
            Top and bot values of IDF file: ITB option.

        nodata_idf : int, float or None (optional)
            Nodata value to be used for writing an IDF file. Otherwise the global IDF nodata value is used.
        """
        try:
            nrow,ncol=self.arr[l].shape
            xll=_fort_double2single(self.xll())
            yll=_fort_double2single(self.yll())
            if self.ieq() == 0:
                dx=_fort_double2single(self.dx())
                xur=xll+dx*ncol
                dy=_fort_double2single(self.dy())
                if self.proj() == 1:
                    yur=yll+dy*nrow
                else:
                    yur=yll-dy*nrow
            else:
                dx=[_fort_double2single(v) for v in self.__dx_ieq()]
                dy=[_fort_double2single(v) for v in self.__dy_ieq()]
                xur=xll+sum(dx)
                if self.proj() == 1:
                    yur=yll+sum(dy)
                else:
                    yur=yll-sum(dy)
            if itb_idf != None:
                try:
                    itb_idf=[float(v) for v in itb_idf[:2]]
                    if itb_idf[0] < itb_idf[1]:
                        itb_idf=None
                except:
                    itb_idf=None
            if itb_idf == None: itb_flag=False
            else: itb_flag=True
            if nodata_idf != None:
                nodata=float(nodata_idf)
            elif nodataIDF != None:
                nodata=float(nodataIDF)
            else:
                nodata=self.nodata()
            outf=open(f_raster,"wb")
            if self.mask().all():
                outf.write(struct.pack("=3L 7f 4B",1271,ncol,nrow,xll,xur,yll,yur,nodata,nodata,nodata,self.ieq(),int(itb_flag),0,0))
            else:
                outf.write(struct.pack("=3L 7f 4B",1271,ncol,nrow,xll,xur,yll,yur,self.arr.min(),self.arr.max(),nodata,self.ieq(),int(itb_flag),0,0))
            if self.ieq() == 0:
                outf.write(struct.pack("=2f",dx,dy))
            else:
                for v in dx:
                    outf.write(struct.pack("=f",v))
                for v in dy:
                    outf.write(struct.pack("=f",v))
            if itb_flag:
                outf.write(struct.pack("=ff",itb_idf[0],itb_idf[1]))
            arr=np.ravel(np.array(self.arr[l],float32))
            arr[arr == self.nodata()]=nodata
            limit=16600000
            for i in range(0,nrow*ncol,limit):
                outf.write(arr[i:min(nrow*ncol,i+limit)].tostring())
            if self.crs() != "":
                crs=crs2epsg(self.crs(),crs2wkt(self.crs(),""))
                if crs != "":
                    crs="CRS={%s}" %(crs)
                    crs=crs+" "*(((len(crs)+3)/4)*4-len(crs))
                    outf.write(struct.pack("=2L%ds" %(len(crs)),1,len(crs)/4,crs))
            outf.close()
        except Exception, err:
            try: outf.close()
            except: pass
            raise err

    def __arr2map(self,l,f_raster,frm_map=None):
        """Method to write a PCRaster file.

        The raster data is 3-D ({nlay,}nrow,ncol), but only one 2-D array is written.

        Parameters
        ----------
        l : int
            Index of the layer/block to be written.

        f_raster : str
            PCRaster file name.

        frm_map : str or None (optional)
            PCRaster map type.

            Recognized types are: 'boolean', 'nominal', 'scalar', 'directional', 'ordinal', 'ldd'.

            If *frm_map* is None then the type is set to 'boolean', 'nominal' or 'scalar' depending on the dtype of the data array.
        """
        try:
            nrow,ncol=self.arr[l].shape
            dx,dy=self.dx(),self.dy()
            if type(dx) != float: dx=float(dx.mean())
            if type(dy) != float: dy=float(dy.mean())

            if self.mask().all():
                minval,maxval=self.nodata(),self.nodata()
            else:
                minval,maxval=self.arr[l].min(),self.arr[l].max()

            if frm_map not in l_pcr_valueScale["frm_map"].tolist():
                if self.arr.dtype in [bool,bool8]: frm_map="boolean"
                elif self.arr.dtype in [float16,float32,float64]: frm_map="scalar"
                else: frm_map="nominal"

            xxx,valueScale,l_data_type=l_pcr_valueScale[l_pcr_valueScale["frm_map"] == frm_map][0]
            nodata=l_pcr_Struct["nodata"][l_pcr_Struct["data_type"] == l_data_type[0]][0]
            exec("nodata=%s" %(nodata))

            if frm_map == "boolean":
                minval,maxval=0,1
                arr=ma.array(ma.array(self.arr[l],bool),l_data_type[0])
            elif frm_map in ["nominal","ldd","ordinal"]:
                if np.can_cast(self.arr[l].dtype,l_data_type[0]) and ((nodata < 0 and minval > nodata) or (nodata > 0 and maxval < nodata)):
                    arr=ma.array(self.arr[l],l_data_type[0])
                else:
                    arr=ma.array(self.arr[l],l_data_type[1])
                if frm_map == "ldd":
                    arr[(arr.data > 9)*(arr.mask == False)]=9
                    arr[(arr.data < 1)*(arr.mask == False)]=1
            else:
                if np.can_cast(self.arr[l].dtype,l_data_type[0]):
                    arr=ma.array(self.arr[l],l_data_type[0])
                else:
                    arr=ma.array(self.arr[l],l_data_type[1])

            xxx,data_bytesize,structFormat,cellRepr,nodata=l_pcr_Struct[l_pcr_Struct["data_type"] == arr.dtype.name][0]

            if nodata == "np.nan":
                nodata=struct.unpack("=%s" %(structFormat),struct.pack("=%ds" %(data_bytesize),"\xff"*data_bytesize))

            arr=np.ravel(ma.filled(arr,np.array(nodata,arr.dtype)))

            outf=open(f_raster,"wb")
            outf.write(struct.pack("=27s","RUU CROSS SYSTEM MAP FORMAT"))
            outf.write(struct.pack("=5s HLHLHL 14s 2H","\x00"*5,2,0,self.proj(),0,1,1,"\x00"*14,valueScale,cellRepr))
            outf.write(struct.pack("=%s" %("%s%ds" %(structFormat,8-data_bytesize)*2),minval,"\xff"*(8-data_bytesize),maxval,"\xff"*(8-data_bytesize)))
            outf.write(struct.pack("=ddLLddd",self.xll(),self.yur(),nrow,ncol,dx,dy,self.ang()))
            outf.write(struct.pack("=124s","\x00"*124))
            limit=8300000*(8/data_bytesize)
            for i in range(0,nrow*ncol,limit):
                outf.write(arr[i:min(nrow*ncol,i+limit)].tostring())
            outf.close()
            if self.crs() != "":
                crs2prj("%s.prj" %(os.path.splitext(f_raster)[0]),self.crs())
        except Exception, err:
            try: outf.close()
            except: pass
            raise err

    def __arr2bil(self,l,f_raster,f_hdr=None):
        """Method to write a FEWS BIL file.

        The raster data is 3-D ({nlay,}nrow,ncol).

        Parameters
        ----------
        l : int
            Index of the layer/block to be written.

            If *l* equals -1 all blocks are written to the same BIL file.

        f_raster : str
            BIL file name.

        f_hdr : str, int or None
            Header file name.

            If *f_hdr* equals None *f_hdr* is determined from *f_raster*.
            If *f_hdr* equals -1 *f_hdr* is not written.
        """
        try:
            nrow,ncol=self.arr.shape[-2:]
            dx,dy=self.dx(),self.dy()
            if type(dx) != float: dx=float(dx.mean())
            if type(dy) != float: dy=float(dy.mean())
            if f_hdr == None: f_hdr="%s.hdr" %(os.path.splitext(f_raster)[0])

            if l == -1: arr,nlay=np.array(self.arr),self.arr.shape[0]
            else: arr,nlay=np.array(self.arr[l]),1

            if arr.dtype in [float16,float32,float64]: arr,nbit=np.array(arr,float32),0
            else: nbit=arr.itemsize
            arr=np.ravel(arr)

            outf=open(f_raster,"wb")
            limit=16600000
            for i in range(0,nlay*nrow*ncol,limit):
                outf.write(arr[i:min(nlay*nrow*ncol,i+limit)].tostring())
            outf.close()

            if f_hdr != -1:
                l_hdr=[\
                    "BYTEORDER I",\
                    "LAYOUT    BIL",\
                    "NROWS     %d" %(nrow),\
                    "NCOLS     %d" %(ncol),\
                    "NBANDS    1",\
                    "NBLOCKS   %d" %(nlay),\
                    "NBITS     %d" %(nbit),\
                    "NODATA    %s" %(self.nodata()),\
                    "ULXMAP    %s" %(self.xll()+0.5*dx),\
                    "ULYMAP    %s" %(self.yur()-0.5*dy),\
                    "XDIM      %s" %(dx),\
                    "YDIM      %s" %(dy),\
                    ]
                outf=open(f_hdr,"w"); outf.write("%s\n" %(string.join(l_hdr,"\n"))); outf.close()
            if self.crs() != "":
                crs2prj("%s.prj" %(os.path.splitext(f_raster)[0]),self.crs())
        except Exception, err:
            try: outf.close()
            except: pass
            raise err

    def __arr2netcdf(self,l,f_raster):
        """Method to write a netCDF raster file.

        The raster data is 3-D ({nlay,}nrow,ncol).

        Parameters
        ----------
        l : int
            Index of the layer/block to be written.

            If *l* equals -1 all blocks are written to the same file if possible.

        f_raster : str
            Raster file name.
        """
        try:
            go=True
            try:
                outf=Dataset(f_raster,"w",format="NETCDF4")
            except:
                self.__arr2gdal(l,f_raster,7)
                go=False

            if go:

                outf.Conventions="CF-1.5"

                outf.createDimension("x_center",self.ncol())
                outf.createVariable("x_center",self.x().dtype,("x_center",))
                outf.variables["x_center"].standard_name="projection_x_coordinate"
                outf.variables["x_center"][:]=self.x()

                outf.createDimension("y_center",self.nrow())
                outf.createVariable("y_center",self.y().dtype,("y_center",))
                outf.variables["y_center"].standard_name="projection_y_coordinate"
                outf.variables["y_center"][:]=self.y()

                if type(self.dx()) == float:
                    outf.createDimension("dx",1)
                else:
                    outf.createDimension("dx",len(self.dx()))
                outf.createVariable("dx","f8",("dx",))
                outf.variables["dx"][:]=self.dx()

                if type(self.dy()) == float:
                    outf.createDimension("dy",1)
                else:
                    outf.createDimension("dy",len(self.dy()))
                outf.createVariable("dy","f8",("dy",))
                outf.variables["dy"][:]=self.dy()

                if l == -1: llay=range(0,self.arr.shape[0])
                else: llay=[l]
                for lay in llay:
                    outf.createVariable("Band%d" %(lay+1),self.arr.dtype,("y_center","x_center"),fill_value=self.nodata())
                    outf.variables["Band%d" %(lay+1)][:]=self[lay]

                if self.crs() != "":
                    outf.spatial_ref=self.crs()

                outf.close()

        except Exception, err:
            try: outf=None
            except: pass
            raise err

    def __arr2gdal(self,l,f_raster,raster_format):
        """Method to write a raster file supported by GDAL (at present only GeoTIFF and netCDF are tested).

        The raster data is 3-D ({nlay,}nrow,ncol), but not all raster formats support 3-D.

        Parameters
        ----------
        l : int
            Index of the layer/block to be written.

            If *l* equals -1 all blocks are written to the same file if possible.

        f_raster : str
            Raster file name.

        raster_format : int
            Number referring to the format of the raster file.

            See :ref:`raster_formats`.

            At present only GeoTIFF and netCDF (raster format 6 and 7) are tested.
        """
        try:
            #if raster_format not in [6,7]:
            #    try: raster_format=l_raster_format_str[raster_format]
            #    except: raster_format=l_raster_format_str[0]
            #    raise Exception, "Cannot write to raster_format %s (not supported or invalid)" %(raster_format)

            try:
                try: raster_format=l_raster_format_str[raster_format]
                except: raster_format=l_raster_format_str[0]
                driver=osgeo.gdal.GetDriverByName(raster_format)
                if driver.GetMetadata()[osgeo.gdal.DCAP_CREATE] != "YES":
                    raise
            except:
                raise Exception, "Cannot write to raster_format %s (not supported or invalid)" %(raster_format)

            nrow,ncol=self.arr.shape[-2:]
            xll,yul,dx,dy,proj=self.xll(),self.yur(),self.dx(),self.dy(),self.proj()
            if type(dx) != float: dx=float(dx.mean())
            if type(dy) != float: dy=float(dy.mean())
            rot1,rot2=0,0

            l_data_type=[["Byte","UInt16","Int16","UInt32","Int32","Float32","Float64","CInt16","CInt32","CFloat32","CFloat64"],\
                         [osgeo.gdal.GDT_Byte,osgeo.gdal.GDT_UInt16,osgeo.gdal.GDT_Int16,osgeo.gdal.GDT_UInt32,osgeo.gdal.GDT_Int32,osgeo.gdal.GDT_Float32,osgeo.gdal.GDT_Float64,osgeo.gdal.GDT_CInt16,osgeo.gdal.GDT_CInt32,osgeo.gdal.GDT_CFloat32,osgeo.gdal.GDT_CFloat64],\
                         [uint8,uint16,int16,uint32,int32,float32,float64,int16,int32,float32,float64],\
                         ["B","H","h","L","l","f","d","h","l","f","d"]]
            if l == -1: arr,nlay=np.array(self.arr),self.arr.shape[0]
            else: arr,nlay=np.array(self.arr[l:l+1]),1

            if arr.dtype == float16:
                arr=np.array(arr,float32)
            elif arr.dtype == int8:
                arr=np.array(arr,int16)

            outf=driver.Create(f_raster,ncol,nrow,nlay,l_data_type[1][l_data_type[2].index(arr.dtype)])
            if proj == 0: outf.SetGeoTransform([xll,dx,rot1,yul,rot2,dy])
            else: outf.SetGeoTransform([xll,dx,rot1,yul,rot2,-dy])
            try: outf.SetProjection(crs2wkt(self.crs(),self.crs()))
            except:
                if self.crs() != "":
                    crs2prj("%s.prj" %(os.path.splitext(f_raster)[0]),self.crs())
            for l in range(0,nlay):
                outf.GetRasterBand(l+1).WriteArray(arr[l])
                outf.GetRasterBand(l+1).SetNoDataValue(self.nodata())
        except Exception, err:
            try: outf=None
            except: pass
            raise err

    def arr2figure(self,colorscale="jet",n_class=8,scale_type="linear",perc_bnd=[0,100],use_underover=True,list_of_shapes=[]):
        """Method to create a matplotlib figure object with a map and a colorbar.

        Parameters
        ----------
        colorscale : str or legendScale object (optional)
            Color scale / legend to be used.

            If *colorscale* is a string and refers to an existing iMOD legend file, then this legend file is used and the arguments *n_class* and *scale_type* are ignored.

            If *colorscale* is a string and does not refer to an iMOD legend file, it is interpreted as a colorscale name of matplotlib or plot_func (including the _r option).

            If *colorscale* is a legendScale object (see :class:`class legendScale in plot_func library <plot_func.legendScale>`), then this legend is used and the arguments *n_class* and *scale_type* are ignored.

        n_class : int or None (optional)
            Number of intervals. This is an initial number; the final number of intervals may differ depending on the determined interval width.

            If *n_class* is None then the initial number of intervals will be 8.

            A minimum number of 2 is required.

        scale_type : str (optional)
            Two types are supported: 'linear' and 'histogram'.

            If *scale_type* is 'linear' then the intervals will have equal widths.

            If *scale_type* is 'histogram' then the interval widths will be based on the distribution of values (percentiles).

        perc_bnd : numpy array or array_like (optional)
            Lower and upper percentiles to be used as initial minimum and maximum boundary values.

        use_underover : bool (optional)
            True = color_under and color_over are used if needed.

            False = color_under and color_over are not used.

        list_of_shapes : list (optional)
            List containing the information of point/polyline/polygon overlays. The list contains records; each record contains the following information (in fixed order):

            - shape type (str) = type of the overlay; recognized are 'POINT', 'POLYLINE' and 'POLYGON'

            - shape xy (list or numpy ndarray) = x,y coordinates of the shapes; see :func:`gis_func.write_gen` or :func:`gis_func.write_shp`

            - fill color (rgb or rgba tuple; value range 0-1); optional; default = (0,0,0,0)

            - line color (rgb or rgba tuple; value range 0-1); optional; default = (0.5,0.5,0.5,1)

            - line width (int) = widht of the lines; optional; default = 1

            - marker (str) = type of marker, matplotlib style; optional; default = 'o'

            - marker size (int) = size of the markers; optional; default = 4

        Returns
        -------
        fig : matplotlib figure object
        """
        if str(type(colorscale)) == "<class 'plot_func.legendScale'>":
            leg=colorscale.copy()
        elif os.path.isfile(colorscale):
            leg=read_imod_leg(colorscale)
        else:
            leg=legendScale(self,n=n_class,scale_type=scale_type,perc_bnd=perc_bnd,colorscale=colorscale)
        boundaries=leg.getBoundaries()
        if use_underover:
            if perc_bnd[0] > 0:
                leg.setUnder()
            if perc_bnd[-1] < 100:
                leg.setOver()

        ax_w=8.0
        cb_w=1.5
        cb_h=6*min(1,0.08*leg.getCmap().N)
        pad=0.05

        ratio=self.Dy()/self.Dx()
        ax_h=ax_w*ratio
        fig_w=ax_w+cb_w+4*pad
        fig_h=max(ax_h+2*pad,cb_h+6*pad)

        bounds=leg.getBoundaries()
        if bounds[0] < -1e30 or bounds[0] > 1e30 and len(bounds) >= 2:
            bounds=bounds[1:]
        if bounds[-1] < -1e30 or bounds[-1] > 1e30 and len(bounds) >= 2:
            bounds=bounds[:-1]

        norm=matplotlib.colors.BoundaryNorm(bounds,leg.getCmap().N)

        fig=figure(figsize=(fig_w,fig_h))
        ax=axes([pad/fig_w,pad/fig_h,ax_w/fig_w,ax_h/fig_h],frameon=True,xticks=[],yticks=[])
        for child in ax.get_children():
            if isinstance(child, matplotlib.spines.Spine): child.set_edgecolor((0.5,0.5,0.5,1))

        ax_cb=axes([3*pad/fig_w+ax_w/fig_w,3*pad/fig_h,0.25*cb_w/fig_w,cb_h/fig_h],frameon=False,xticks=[],yticks=[])
        ax.set_xlim([self.xll(),self.xur()])
        ax.set_ylim([self.yll(),self.yur()])
        ax.imshow(self.arr,extent=[self.xll(),self.xur(),self.yll(),self.yur()],cmap=leg.getCmap(),norm=norm,interpolation="nearest")

        if len(list_of_shapes) > 0:

            for i in range(0,len(list_of_shapes)):
                rec=list(list_of_shapes[i])
                for i in range(len(rec),7): rec+=[None]
                shp_type,shp_xy,fill_color,line_color,line_width,marker,marker_size=rec
                if fill_color == None: fill_color=(0,0,0,0)
                if line_color == None: line_color=(0.5,0.5,0.5,1)
                if line_width == None: line_width=1
                if marker == None: marker="o"
                if marker_size == None: marker_size=4
                if shp_type == "POINT":
                    ax.scatter(shp_xy[:,0],shp_xy[:,1],s=marker_size,c=fill_color,marker=marker,linewidths=line_width,edgecolors=line_color)
                elif shp_type == "POLYLINE":
                    ax.add_collection(matplotlib.collections.LineCollection(shp_xy,colors=line_color,linestyle="solid",linewidth=line_width))
                elif shp_type == "POLYGON":
                    ax.add_collection(matplotlib.collections.PatchCollection([matplotlib.patches.Polygon(shp_xy[i],closed=True) for i in range(0,len(shp_xy))],facecolor=fill_color,linestyle="solid",linewidth=line_width,edgecolor=line_color))

        cmap=leg.getCmap()
        ticks=leg.getTicks()
        if self.count() == 0 and cmap.N == 1 and ticks[0] in [">","<"] and ticks[-1] in [">","<"]:
            cmap=matplotlib.colors.ListedColormap([[0,0,0,0]])
            ticks=["nodata","nodata"]
        cb=matplotlib.colorbar.ColorbarBase(ax_cb,cmap=cmap,norm=norm,boundaries=leg.getBoundaries(),extend="neither",ticks=leg.getBoundaries())
        cb.set_ticklabels(ticks)
        setp(cb.ax.get_ymajorticklabels(),fontname="Arial",fontsize=10,fontweight="normal",color=(0,0,0,1))

        return fig


    ## MATHEMATICAL OPERATIONS ##

    def __neg__(self):
        """Method to calculate the arithmetic negation.

        result = -self

        Returns
        -------
        result : rasterArr object
        """
        return 0-self

    def __pos__(self):
        """Method to calculate the positive.

        result = +self

        Returns
        -------
        result : rasterArr object
        """
        return self

    def __abs__(self):
        """Method to calculate the absolute value.

        result = abs(self)

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        a.arr=ma.abs(a.arr)
        return a

    ## Add (+)
    def __add__(self,other):
        """Method to calculate addition.

        result = self + other

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        method=get_global_method()
        a=self.copy()
        try:
            other.gi()
            a.arr=a.arr+other.rescale(a.gi(),method=method).arr
        except:
            a.arr=a.arr+deepcopy(other)
        return a
    def __radd__(self,other):
        """Method to calculate addition (right-side).

        result = other + self

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        return self+other
    def __iadd__(self,other):
        """Method to calculate addition (in-place).

        self += other

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        self : rasterArr object
        """
        method=get_global_method()
        try:
            other.gi()
            self.arr=self.arr+other.rescale(self.gi(),method=method).arr
        except:
            self.arr=self.arr+deepcopy(other)
        return self

    ## Subtract (-)
    def __sub__(self,other):
        """Method to calculate subtraction.

        result = self - other

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        method=get_global_method()
        a=self.copy()
        try:
            other.gi()
            a.arr=a.arr-other.rescale(a.gi(),method=method).arr
        except:
            a.arr=a.arr-deepcopy(other)
        return a
    def __rsub__(self,other):
        """Method to calculate subtraction (right-side).

        result = other - self

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        a.arr=deepcopy(other)-a.arr
        return a
    def __isub__(self,other):
        """Method to calculate subtraction (in-place).

        self -= other

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        self : rasterArr object
        """
        method=get_global_method()
        try:
            other.gi()
            self.arr=self.arr-other.rescale(self.gi(),method=method).arr
        except:
            self.arr=self.arr-deepcopy(other)
        return self

    ## Multiply (*)
    def __mul__(self,other):
        """Method to calculate multiplication.

        result = self * other

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        method=get_global_method()
        a=self.copy()
        try:
            other.gi()
            a.arr=a.arr*other.rescale(a.gi(),method=method).arr
        except:
            a.arr=a.arr*deepcopy(other)
        return a
    def __rmul__(self,other):
        """Method to calculate multiplication (right-side).

        result = other * self

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        return self*other
    def __imul__(self,other):
        """Method to calculate multiplication (in-place).

        self *= other

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        self : rasterArr object
        """
        method=get_global_method()
        try:
            other.gi()
            self.arr=self.arr*other.rescale(self.gi(),method=method).arr
        except:
            self.arr=self.arr*deepcopy(other)
        return self

    ## Divide (/)
    def __div__(self,other):
        """Method to calculate division.

        result = self / other

        A nodata value (in self and/or other) results in a nodata value.

        A zero in other results in a nodata value.

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        method=get_global_method()
        a=self.copy()
        try:
            other.gi()
            b=other.rescale(a.gi(),method=method)
            b.set_mask(b.arr == 0,True)
            b.arr.data[b.arr.data == 0]=-1
            a.arr=a.arr/b.arr
            a.set_mask(np.maximum(a.arr.mask,b.arr.mask),True)
        except:
            b=deepcopy(other)
            try:
                a.set_mask(np.maximum(a.arr.mask,b == 0),True)
                b[b == 0]=-1
                a.arr=a.arr/b
            except:
                a.arr=a.arr/b
        return a
    def __rdiv__(self,other):
        """Method to calculate division (right-side).

        result = other / self

        A nodata value (in self and/or other) results in a nodata value.

        A zero in self results in a nodata value.

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        a,b=self.copy(),deepcopy(other)
        a.set_mask(a.arr == 0,True)
        a.arr.data[a.arr.data == 0]=-1
        a.arr=b/a.arr
        a.arr.data[a.arr.mask == True]=a.nodata()
        return a
    def __idiv__(self,other):
        """Method to calculate division (in-place).

        self /= other

        A nodata value (in self and/or other) results in a nodata value.

        A zero in other results in a nodata value.

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        self : rasterArr object
        """
        method=get_global_method()
        try:
            other.gi()
            b=other.rescale(self.gi(),method=method)
            b.set_mask(b.arr == 0,True)
            b.arr.data[b.arr.data == 0]=-1
            self.arr=self.arr/b.arr
            self.set_mask(np.maximum(self.arr.mask,b.arr.mask),True)
        except:
            b=deepcopy(other)
            try:
                self.set_mask(np.maximum(self.arr.mask,b == 0),True)
                b[b == 0]=-1
                self.arr=self.arr/b
            except:
                self.arr=self.arr/b
        return self

    ## Power (**)
    def __pow__(self,other):
        """Method to calculate exponentiation (power).

        result = self ** other

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        method=get_global_method()
        a=self.copy()
        try:
            other.gi()
            a.arr=a.arr**other.rescale(a.gi(),method=method).arr
        except:
            a.arr=a.arr**deepcopy(other)
        return a
    def __rpow__(self,other):
        """Method to calculate exponentiation (power) (right-side).

        result = other ** self

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        a.arr=deepcopy(other)**a.arr
        return a
    def __ipow__(self,other):
        """Method to calculate exponentiation (power) (in-place).

        self **= other

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        self : rasterArr object
        """
        method=get_global_method()
        try:
            other.gi()
            self.arr=self.arr**other.rescale(self.gi(),method=method).arr
        except:
            self.arr=self.arr**deepcopy(other)
        return self

    ## Mod (%)
    def __mod__(self,other):
        """Method to calculate modulo.

        result = self % other

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        method=get_global_method()
        a=self.copy()
        try:
            other.gi()
            a.arr=a.arr%other.rescale(a.gi(),method=method).arr
        except:
            a.arr=a.arr%deepcopy(other)
        return a
    def __rmod__(self,other):
        """Method to calculate modulo (right-side).

        result = other % self

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        a.arr=deepcopy(other)%a.arr
        return a
    def __imod__(self,other):
        """Method to calculate modulo (in-place).

        self %= other

        Parameters
        ----------
        other : rasterArr object, numpy array (ndarry or MaskedArray) or single numeric value

            If *other* is a rasterArr object it is rescaled/resampled to meet self if needed, using the global method.

        Returns
        -------
        self : rasterArr object
        """
        method=get_global_method()
        try:
            other.gi()
            self.arr=self.arr%other.rescale(self.gi(),method=method).arr
        except:
            self.arr=self.arr%deepcopy(other)
        return self

    ## Abs
    def abs(self):
        """Method to calculate the absolute value.

        result = abs(self)

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        a.arr=ma.absolute(a.arr)
        return a

    ## Log, log10 and exp
    def log(self):
        """Method to calculate natural logarithm (base *e*).

        result = log(self)

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        a.set_mask=(a.arr.data <= 0,True)
        a.arr.data[a.arr.mask]=1
        a.arr.data=np.log(a.arr.data)
        a.arr.data[a.arr.mask]=a.arr.fill_value
        return a
    def log10(self):
        """Method to calculate logarithm (base 10).

        result = log10(self)

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        a.set_mask=(a.arr.data <= 0,True)
        a.arr.data[a.arr.mask]=1
        a.arr.data=np.log10(a.arr.data)
        a.arr.data[a.arr.mask]=a.arr.fill_value
        return a
    def exp(self):
        """Method to calculate exponential (base *e*).

        result = exp(self) = *e* ** self

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        a.arr=ma.exp(a.arr)
        return a
    def exp10(self):
        """Method to calculate exponential (base 10).

        result = exp10(self) = 10 ** self

        Returns
        -------
        result : rasterArr object
        """
        return 10**self


    ## COMPARISON OPERATIONS ##
       ## 1 = True, 0 = False, -1 = masked

    def __lt__(self,other):
        """Method to perform less than comparison.

        result = self < other

        Returns
        -------
        result : rasterArr object
        """
        if type(other) == type(None):
            return False
        method=get_global_method()
        try:
            other.gi()
            a=self.arr < other.rescale(self.gi(),method=method).arr
        except:
            a=self.arr < other
        mask=a.mask
        a=rasterArr(np.array(a.data,int8),self.gi(),-1)
        a.set_mask(mask)
        return a
    def __le__(self,other):
        """Method to perform less than or equal comparison.

        result = self <= other

        Returns
        -------
        result : rasterArr object
        """
        if type(other) == type(None):
            return False
        method=get_global_method()
        try:
            other.gi()
            a=self.arr <= other.rescale(self.gi(),method=method).arr
        except:
            a=self.arr <= other
        mask=a.mask
        a=rasterArr(np.array(a.data,int8),self.gi(),-1)
        a.set_mask(mask)
        return a
    def __gt__(self,other):
        """Method to perform greater than comparison.

        result = self > other

        Returns
        -------
        result : rasterArr object
        """
        if type(other) == type(None):
            return False
        method=get_global_method()
        try:
            other.gi()
            a=self.arr > other.rescale(self.gi(),method=method).arr
        except:
            a=self.arr > other
        mask=a.mask
        a=rasterArr(np.array(a.data,int8),self.gi(),-1)
        a.set_mask(mask)
        return a
    def __ge__(self,other):
        """Method to perform greater than or equal comparison.

        result = self >= other

        Returns
        -------
        result : rasterArr object
        """
        if type(other) == type(None):
            return False
        method=get_global_method()
        try:
            other.gi()
            a=self.arr >= other.rescale(self.gi(),method=method).arr
        except:
            a=self.arr >= other
        mask=a.mask
        a=rasterArr(np.array(a.data,int8),self.gi(),-1)
        a.set_mask(mask)
        return a
    def __eq__(self,other):
        """Method to perform equal comparison.

        result = self == other

        Returns
        -------
        result : rasterArr object
        """
        if type(other) == type(None):
            return False
        method=get_global_method()
        try:
            other.gi()
            a=self.arr == other.rescale(self.gi(),method=method).arr
        except:
            a=self.arr == other
        mask=a.mask
        a=rasterArr(np.array(a.data,int8),self.gi(),-1)
        a.set_mask(mask)
        return a
    def __ne__(self,other):
        """Method to perform not equal comparison.

        result = self != other

        Returns
        -------
        result : rasterArr object
        """
        if type(other) == type(None):
            return True
        method=get_global_method()
        try:
            other.gi()
            a=self.arr != other.rescale(self.gi(),method=method).arr
        except:
            a=self.arr != other
        mask=a.mask
        a=rasterArr(np.array(a.data,int8),self.gi(),-1)
        a.set_mask(mask)
        return a


    ## METHODS TO CONVERT DTYPE

    def bool(self):
        """Method to convert data type to bool.

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        mask,nodata=a.arr.mask.copy(),a.nodata()
        a.arr=ma.array(a.arr,dtype=bool)
        a.set_nodata(bool(nodata))
        a.set_mask(mask,False)
        return a

    def int(self):
        """Method to convert data type to int (int8, int16, int32 or int64).

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        mask,nodata=a.arr.mask,a.nodata()
        dt=_get_min_dtype([int(a.arr.min()),int(a.arr.max()),int(a.nodata()),int(a.arr.fill_value)])
        a.arr=ma.array(a.arr,dtype=dt)
        a.set_nodata(int(nodata))
        a.set_mask(mask,False)
        return a

    def float(self):
        """Method to convert data type to float (float32 or float64).

        Returns
        -------
        result : rasterArr object
        """
        a=self.copy()
        mask,nodata=a.arr.mask,a.nodata()
        dt=_get_min_dtype([float(a.arr.min()),float(a.arr.max()),float(a.nodata()),float(a.arr.fill_value)])
        if dt == float16: dt=float32
        a.arr=ma.array(a.arr,dtype=dt)
        a.set_nodata(float(nodata))
        a.set_mask(mask,False)
        return a


    ## METHODS TO GET STATISTICS ##

    def sum(self,axis=None):
        """Method to calculate the sum of the array elements over the given axis.

        Parameters
        ----------
        axis : int or None (optional)
            Axis over which the calculation is done.

            If *axis* is None the calculation is done over all dimensions, resulting in a single value.

        Returns
        -------
        sum : numpy array

        See Also
        --------
        :ref:`statistics`
        """
        return self.arr.sum(axis)

    def count(self,axis=None):
        """Method to calculate the number of non-nodata elements over the given axis.

        Parameters
        ----------
        axis : int or None (optional)
            Axis over which the calculation is done.

            If *axis* is None the calculation is done over all dimensions, resulting in a single value.

        Returns
        -------
        count : numpy array

        See Also
        --------
        :ref:`statistics`
        """
        return (self.arr.mask == False).sum(axis)

    def mean(self,axis=None):
        """Method to calculate the mean of the array elements over the given axis.

        Parameters
        ----------
        axis : int or None (optional)
            Axis over which the calculation is done.

            If *axis* is None the calculation is done over all dimensions, resulting in a single value.

        Returns
        -------
        mean : numpy array

        See Also
        --------
        :ref:`statistics`
        """
        return self.arr.mean(axis)

    def std(self,axis=None):
        """Method to calculate the standard deviation of the array elements over the given axis.

        Parameters
        ----------
        axis : int or None (optional)
            Axis over which the calculation is done.

            If *axis* is None the calculation is done over all dimensions, resulting in a single value.

        Returns
        -------
        std : numpy array

        See Also
        --------
        :ref:`statistics`
        """
        return self.arr.std(axis)

    def var(self,axis=None):
        """Method to calculate the variance of the array elements over the given axis.

        Parameters
        ----------
        axis : int or None (optional)
            Axis over which the calculation is done.

            If *axis* is None the calculation is done over all dimensions, resulting in a single value.

        Returns
        -------
        var : numpy array

        See Also
        --------
        :ref:`statistics`
        """
        return self.arr.var(axis)

    def min(self,axis=None):
        """Method to get the minimum value of the array elements over the given axis.

        Parameters
        ----------
        axis : int or None (optional)
            Axis over which the calculation is done.

            If *axis* is None the calculation is done over all dimensions, resulting in a single value.

        Returns
        -------
        min : numpy array

        See Also
        --------
        :ref:`statistics`
        """
        return self.arr.min(axis)

    def max(self,axis=None):
        """Method to get the maximum value of the array elements over the given axis.

        Parameters
        ----------
        axis : int or None (optional)
            Axis over which the calculation is done.

            If *axis* is None the calculation is done over all dimensions, resulting in a single value.

        Returns
        -------
        max : numpy array

        See Also
        --------
        :ref:`statistics`
        """
        return self.arr.max(axis)

    def median(self,axis=None):
        """Method to calculate the median of the array elements over the given axis.

        Parameters
        ----------
        axis : int or None (optional)
            Axis over which the calculation is done.

            If *axis* is None the calculation is done over all dimensions, resulting in a single value.

        Returns
        -------
        median : numpy array

        See Also
        --------
        :ref:`statistics`
        """
        return ma.median(self.arr,axis)

    def percentile(self,p=50,axis=None):
        """Method to calculate a percentile of the array elements over the given axis.

        Parameters
        ----------
        p : int or float in range 0-100
        axis : int or None (optional)
            Axis over which the calculation is done.

            If *axis* is None the calculation is done over all dimensions, resulting in a single value.

        Returns
        -------
        percentile : numpy array

        See Also
        --------
        :ref:`statistics`
        """
        return np.percentile(np.compress(np.ravel(self.arr.mask == False),np.ravel(self.arr.data),0),p,axis)


    ## INDEXING, SLICING: GETTING AND SETTING

    def __getitem__(self,k):
        """Method to get single value or slice of the data array.

        Parameters
        ----------
        k : index or slice

        Returns
        -------
        slice : numpy MaskedArray
        """
        return self.arr[k]

    def __setitem__(self,k,value):
        """Method to set single value or slice of the data array (in-place).

        Parameters
        ----------
        k : index or slice
        value : single value, numpy array or array_like
            *value* should be broadcastable to the selected index/slice.
        """
        self.arr[k]=value


    ## METHODS TO RESCALE/RESAMPLE

    def rescale(self,to_gi,method="sample"):
        """Method to rescale/resample.

        Does not work for non-equidistant rasters.

        Parameters
        ----------
        to_gi : dict or list
            The target geographical information dict/list to which the rescaling/resampling is done.

            If *to_gi* is specified as a list the order of the elements should be: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.
            See also :ref:`geo_info`.

        method : str or None (optional)
            The rescaling/resampling method. Possible methods are:
            'sum', 'min', 'max', 'harm', 'log10', 'log', 'mean', 'sample', None.

        Returns
        -------
        result : rasterArr object

        See Also
        --------
        :ref:`rescaling_resampling`
        """
        return rescale_rA(self,to_gi,method)

    def resample(self,step_xy=[1,1]):
        """Method to resample using a step size.

        Parameters
        ----------
        step_xy : int, list or dict
            The step size in x and y direction, with 1 as lowest value meaning no resampling.

            The step size is not necessarily the same in x in y direction.

            If *step_xy* is an int or a list with only one value the step size in x and y direction are both set to this value.

            If *step_xy* is a dict it is assumed that it is a basic geographical information dict.
            The step sizes are then determined using this dict. See also the ``rescale(..)`` method.

        Returns
        -------
        result : rasterArr object

        See Also
        --------
        :ref:`rescaling_resampling`
        """
        return resample_rA(self,step_xy)

    def nonequi2equi(self,dx=None,dy=None):
        """Method to resample a non-equidistant raster to an equidistant raster.

        Parameters
        ----------
        dx : float, int or None (optional)
            Cell size in x direction (column width).

            If *dx* is None then the minimum column width of the non-equidistant raster is used.

        dy : float, int or None (optional)
            Cell size in y direction (row height).

            If *dy* is None then the minimum row height of the non-equidistant raster is used.

        Returns
        -------
        result : rasterArr object
        """
        return rA_nonequi2equi(self,dx,dy)

    def slice(self,l_rowcol):
        """Method to crop the raster to a given slice.

        Parameters
        ----------
        l_rowcol : list
            Minimum and maximum row and column numbers: [iRow_min,iRow_max,iCol_min,iCol_max]

            iRow_max and iCol_max are not included in the slice.

        Returns
        -------
        result : rasterArr object
        """
        iRow_min,iRow_max,iCol_min,iCol_max=l_rowcol
        if iRow_max < 0: iRow_max+=self.nrow()
        if iCol_max < 0: iCol_max+=self.ncol()
        arr=self.arr.copy()[iRow_min:iRow_max,iCol_min:iCol_max]
        if type(self.dx()) == float:
            dx=self.dx()
            xll=self.xll()+dx*iCol_min
        else:
            dx=self.dx()[iCol_min:iCol_max]
            xll=self.xll()+(self.dx()[:iCol_min]).sum()
        if type(self.dy()) == float:
            dy=self.dy()
            if self.proj() == 1:
                yll=self.yll()+dy*(self.nrow()-iRow_max)
            else:
                yll=self.yll()-dy*(self.nrow()-iRow_max)
        else:
            dy=self.dy()[iRow_min:iRow_max]
            if self.proj() == 1:
                yll=self.yll()+(self.dy()[iRow_max:]).sum()
            else:
                yll=self.yll()-(self.dy()[iRow_max:]).sum()
        gi=[xll,yll,dx,dy,arr.shape[0],arr.shape[1],self.proj(),self.ang()]
        return rasterArr(arr,gi,self.nodata())

    def crop(self):
        """Method to crop the raster to non-nodata values.

        Returns
        -------
        result : rasterArr object
        """
        rowcol=np.indices(self.arr.shape)
        cp=np.ravel(self.arr.mask) == False
        irow=np.compress(cp,np.ravel(rowcol[0]))
        icol=np.compress(cp,np.ravel(rowcol[1]))
        return self.slice([irow.min(),irow.max()+1,icol.min(),icol.max()+1])


    ## (RE)PROJECT METHODS ##

    def reproject(self,to_crs,from_crs=None,method="sample",xyur=None):
        """Method to reproject.

        Does not work for non-equidistant rasters.

        Parameters
        ----------
        to_crs : str, int, list or dict
            Target crs.

            If this is a list or a dict it is interpreted as geographical information from which the crs, extent and cell size are taken.

        from_crs : str, int, list, dict or None (optional)
            Source crs. Will be used if the crs of the raster is not specified.

            If this is a list or a dict it is interpreted as geographical information from which the crs is taken.

        method : str or None (optional)
            The reprojecting method. Possible methods are:
            'mean' or 'average', 'sample' or 'near', 'bilinear', 'cubic', 'cubicspline', 'lanczos', 'mode', None.

        xyur : list or None (optional)
            X and Y coordinates of upper right corner. May be used by gdalwarp if to_crs is geographical information, but xur and yur could not be calculated (e.g. because dx and dy are None).

        Returns
        -------
        result : rasterArr object
        """
        return reproject_rA(self,to_crs=to_crs,from_crs=from_crs,method=method,xyur=xyur)

    def warp(self,to_crs,from_crs=None,exe_warp=None,screen_output=False,xyur=None):
        """Method to reproject by using gdalwarp.

        Does not work for non-equidistant rasters.

        Parameters
        ----------
        to_crs : str, int, list or dict
            Target crs.

            If this is a list or a dict it is interpreted as geographical information from which the crs, extent and cell size are taken.

        from_crs : str, int, list, dict or None (optional)
            Source crs. Will be used if the crs of the raster is not specified.

            If this is a list or a dict it is interpreted as geographical information from which the crs is taken.

        exe_warp : str or None (optional)
            File name of the gdalwarp executable. If *exe_warp* is None then 'gdalwarp' is used; this only works if 'gdalwarp' is known to the system (e.g. in the PATH environment).

        screen_output : bool (optional)
            True = output of gdal's process to the screen.
            False = no output of gdal's process to the screen.

        xyur : list or None (optional)
            X and Y coordinates of upper right corner. May be used by gdalwarp if to_crs is geographical information, but xur and yur could not be calculated (e.g. because dx and dy are None).

        Returns
        -------
        result : rasterArr object
        """
        return warp_rA(self,to_crs=to_crs,from_crs=from_crs,exe_warp=exe_warp,screen_output=screen_output,xyur=xyur)


    ## OTHER METHODS ##

    def unique(self):
        """Method to get the unique values of the data array.

        Returns
        -------
        result : numpy array (1-D)
        """
        un=ma.unique(self.arr)
        return np.compress(un.mask == False,un.data,0)

    def toGDALobj(self):
        """Method to create a GDAL in-memory object from the rasterArr object.

        Does not work for 3-D rasterArr objects and for non-equidistant rasters.

        Returns
        -------
        result : GDAL object
        """
        l_data_type=[["Byte","UInt16","Int16","UInt32","Int32","Float32","Float64","CInt16","CInt32","CFloat32","CFloat64"],\
                     [osgeo.gdal.GDT_Byte,osgeo.gdal.GDT_UInt16,osgeo.gdal.GDT_Int16,osgeo.gdal.GDT_UInt32,osgeo.gdal.GDT_Int32,osgeo.gdal.GDT_Float32,osgeo.gdal.GDT_Float64,osgeo.gdal.GDT_CInt16,osgeo.gdal.GDT_CInt32,osgeo.gdal.GDT_CFloat32,osgeo.gdal.GDT_CFloat64],\
                     [uint8,uint16,int16,uint32,int32,float32,float64,int16,int32,float32,float64],\
                     ["B","H","h","L","l","f","d","h","l","f","d"]]

        rot1,rot2=0,0
        gd=osgeo.gdal.GetDriverByName("MEM").Create("",self.ncol(),self.nrow(),1,l_data_type[1][l_data_type[2].index(self.arr.dtype)])
        if self.proj() == 0: gd.SetGeoTransform([self.xll(),self.dx(),rot1,self.yur(),rot2,self.dy()])
        else: gd.SetGeoTransform([self.xll(),self.dx(),rot1,self.yur(),rot2,-self.dy()])
        if self.crs() not in ["",None]:
            gd.SetProjection(self.crs())
        gd.GetRasterBand(1).WriteArray(np.array(self.arr.data.copy()))
        gd.GetRasterBand(1).SetNoDataValue(self.nodata())
        return gd


###############################################################
## FUNCTIONS TO GET / SET / CONVERT GEOGRAPHICAL INFORMATION ##
###############################################################

def get_gi(rA,*args):
    """Function to get a list of specified geographical information elements of a rasterArr object or a geographical information dict/list.

    Parameters
    ----------
    rA : rasterArr object, dict, list or tuple
        The input raster or the geographical information dict/list.

        If *rA* is a list or tuple it is assumed that this contains the basic geographical information, in fixed order: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.

    args : arguments (str)
        Recognized arguments are: 'gi', 'gi_list', 'nodata', 'xll', 'xur', 'yll', 'yur', 'dx', 'Dx',
        'dy', 'Dy', 'ieq', 'nrow', 'ncol', 'proj', 'ang'.
        Other arguments are ignored.

        If *rA* is a dict the recognized arguments are limited to what is included in the dict.

        If *rA* is a list or tuple the recognized arguments are limited to 'xll', 'yll', 'dx', 'dy', 'nrow', 'ncol', 'proj', 'ang'.

        If 'gi' is specified the dict of the basic geographical information is returned.
        If 'gi_list' is specified the basic geographical information is returned as list with fixed order: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.

    Returns
    -------
    result : list
        The list with the specified elements.

    See Also
    --------
    :ref:`geo_info`
    """
    if type(rA) in [tuple,list,dict]:
        l_result=[]
        if type(rA) in [tuple,list]:
            for key in args:
                try: l_result.append(rA[l_gi_key.index(key)])
                except: pass
        else:
            for key in args:
                try: l_result.append(rA[key])
                except: pass
        return l_result
    else: return rA.get_gi(*args)

def gi_extended(rA,as_list=False):
    """Function to get the extended geographical information of a rasterArr object or a basic geographical information dict/list.

    The extended geographical information comprises: xur, yur, Dx, Dy.

    Parameters
    ----------
    rA : rasterArr object, dict, list or tuple
        The input raster or the basic geographical information dict/list.

    as_list : bool (optional)
        True = return result as list; order of elements is fixed: see above.

        False = return result as dict.

    Returns
    -------
    gi : dict or list
        The extended geographical information.

    See Also
    --------
    :ref:`geo_info`
    """
    if type(rA) in [tuple,list,dict]:
        if type(rA) in [tuple,list]:
            for key in ["xll","yll","dx","dy","nrow","ncol","proj"]:
                exec('%s=rA[l_gi_key.index("%s")]' %(key,key))
        else:
            for key in ["xll","yll","dx","dy","nrow","ncol","proj"]:
                exec('%s=rA["%s"]' %(key,key))
        if type(dx) not in [int,float]:
            try: Dx=float(sum(dx))
            except: Dx=None
        else:
            try: Dx=float(dx*ncol)
            except: Dx=None
        if type(dy) not in [int,float]:
            try: Dy=float(sum(dx))
            except: Dy=None
        else:
            try: Dy=float(dy*nrow)
            except: Dy=None
        try: xur=xll+Dx
        except: xur=None
        try:
            if proj == 0: yur=yll-Dy
            else: yur=yll+Dy
        except:
            try: yur=yll+Dy
            except: yur=None
        result=[xur,yur,Dx,Dy]
    else: result=rA.get_gi("xur","yur","Dx","Dy")
    if as_list: return result
    else: return {"xur":result[0],"yur":result[1],"Dx":result[2],"Dy":result[3]}

def gi2dict(gi=None,**kwargs):
    """Function to convert and set geographical information into a dict with at least the basic geographical information.

    Parameters
    ----------
    gi : list, dict, None
        Existing geographical information.

        If *gi* is specified as a list the order of the elements should be: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.

        If *gi* is None it is ignored.

    kwargs : keyword arguments

        Existing keywords in *gi* will be overruled.

    Returns
    -------
    result : dict

    See Also
    --------
    :ref:`geo_info`
    """
    gi_new=dict([(key,None) for key in l_gi_key])
    if type(gi) in [tuple,list,dict]:
        if type(gi) in [tuple,list]:
            for i in range(0,min(len(l_gi_key),len(gi))): gi_new[l_gi_key[i]]=gi[i]
        else:
            for key in l_gi_key:
                try: gi_new[key]=gi[key]
                except: pass
    for key in kwargs:
        try: gi_new[key]=kwargs[key]
        except: pass
    for i in range(0,len(l_gi_key)):
        if gi_new[l_gi_key[i]] != None:
            try: exec("gi_new[l_gi_key[i]]=%s" %(string.replace(l_gi_type[i],"()","(gi_new[l_gi_key[i]])")))
            except: pass
    return gi_new

def gi2list(gi=None,**kwargs):
    """Function to convert and set geographical information into a list with the basic geographical information.

    Parameters
    ----------
    gi : list, dict, None
        Existing geographical information.

        If *gi* is specified as a list the order of the elements should be: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.

        If *gi* is None it is ignored.

    kwargs : keyword arguments

        Existing keywords in *gi* will be overruled.

    Returns
    -------
    result : list

    See Also
    --------
    :ref:`geo_info`
    """
    gi_new=[None]*len(l_gi_key)
    if type(gi) in [tuple,list,dict]:
        if type(gi) in [tuple,list]:
            for i in range(0,min(len(l_gi_key),len(gi))): gi_new[i]=gi[i]
        else:
            for i in range(0,len(l_gi_key)):
                try: gi_new[i]=gi[l_gi_key[i]]
                except: pass
    for key in kwargs:
        try: gi_new[l_gi_key.index(key)]=kwargs[key]
        except: pass
    for i in range(0,len(l_gi_key)):
        try: exec("gi_new[i]=%s" %(string.replace(l_gi_type[i],"()","(gi_new[i])")))
        except: pass
    return gi_new

def gi_get_Dx(gi):
    """Function to get Dx (total extent/width in x direction) from a geographical information dict/list.

    Parameters
    ----------
    gi : dict or list
        Geographical information dict/list.

    Returns
    -------
    Dx : float

    See Also
    --------
    :ref:`geo_info`
    """
    gi1=gi2dict(gi)
    if type(gi1["dx"]) not in [int,float]:
        try: return float(sum(gi1["dx"]))
        except: return None
    else:
        try: return float(gi1["dx"])*gi1["ncol"]
        except: return None

def gi_get_Dy(gi):
    """Function to get Dy (total extent/height in y direction) from a geographical information dict/list.

    Parameters
    ----------
    gi : dict or list
        Geographical information dict/list.

    Returns
    -------
    Dy : float

    See Also
    --------
    :ref:`geo_info`
    """
    gi1=gi2dict(gi)
    if type(gi1["dy"]) not in [int,float]:
        try: return float(sum(gi1["dy"]))
        except: return None
    else:
        try: return float(gi1["dy"])*gi1["nrow"]
        except: return None

def gi_get_xur(gi):
    """Function to get xur (x coordinate of upper right corner) from a geographical information dict/list.

    Parameters
    ----------
    gi : dict or list
        Geographical information dict/list.

    Returns
    -------
    xur : float

    See Also
    --------
    :ref:`geo_info`
    """
    gi1=gi2dict(gi)
    try: return gi1["xll"]+gi_get_Dx(gi1)
    except: return None

def gi_get_yur(gi):
    """Function to get yur (y coordinate of upper right corner) from a geographical information dict/list.

    Parameters
    ----------
    gi : dict or list
        Geographical information dict/list.

    Returns
    -------
    yur : float

    See Also
    --------
    :ref:`geo_info`
    """
    gi1=gi2dict(gi)
    try: proj=gi1["proj"]
    except: proj=1
    if proj == 0:
        try: return gi1["yll"]-gi_get_Dy(gi1)
        except: return None
    else:
        try: return gi1["yll"]+gi_get_Dy(gi1)
        except: return None

def set_gi(rA,**kwargs):
    """Function to set geographical information using keyword arguments.

    Parameters
    ----------
    rA : rasterArr object, list or dict

        If *rA* is a rasterArr object the object is modified in-place.

        If *rA* is a dict or list it is assumed to be a geographical information list/dict.
        If *rA* is a list the order of the elements should be: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.

    kwargs : keyword arguments

        Recognized keyword arguments are: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.

    Returns
    -------
    rA : rasterArr object, list or dict

        Result is depending on input type.

    See Also
    --------
    :ref:`geo_info`
    """
    if type(rA) in [tuple,list,dict]:
        if type(rA) in [tuple,list]: return gi2list(rA,**kwargs)
        else: return gi2dict(rA,**kwargs)
    else:
        rA.set_gi(**kwargs)
        return rA.gi()

def gi_set_extent(gi,l_extent,snap=False):
    """Function to set (change) the extent of a geographical information dict/list.

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    gi : dict or list
        Geographical information dict/list.

    l_extent : list
        A list containing xll, yll, xur and yur of the new extent (in this order).

    snap : bool (optional)
        Flag to snap (shift) the new extent to match with the original cell boundaries.

        True = snap is performed to the nearest cell boundaries.

        False = snap is not performed

    Returns
    -------
    result : dict
        New geographical information dict

    See Also
    --------
    :ref:`geo_info`
    """
    gi_new=gi2dict(gi)
    try: proj=gi_new["proj"]
    except: proj=1
    xll,xur=float(min(l_extent[0],l_extent[2])),float(max(l_extent[0],l_extent[2]))
    if proj == 0:
        yll,yur=float(max(l_extent[1],l_extent[3])),float(min(l_extent[1],l_extent[3]))
    else:
        yll,yur=float(min(l_extent[1],l_extent[3])),float(max(l_extent[1],l_extent[3]))
    if snap:
        xll=gi_new["xll"]+_roundoff((xll-gi_new["xll"])/gi_new["dx"])*gi_new["dx"]
        xur=gi_get_xur(gi_new)+_roundoff((xur-gi_get_xur(gi_new))/gi_new["dx"])*gi_new["dx"]
        if proj == 0:
            yll=gi_new["yll"]-_roundoff((yll-gi_new["yll"])/gi_new["dx"])*gi_new["dx"]
            yur=gi_get_yur(gi_new)-_roundoff((yur-gi_get_yur(gi_new))/gi_new["dx"])*gi_new["dx"]
        else:
            yll=gi_new["yll"]+_roundoff((yll-gi_new["yll"])/gi_new["dx"])*gi_new["dx"]
            yur=gi_get_yur(gi_new)+_roundoff((yur-gi_get_yur(gi_new))/gi_new["dx"])*gi_new["dx"]
    gi_new["xll"]=xll
    gi_new["yll"]=yll
    gi_new["nrow"]=int(_roundoff(abs(yur-yll)/gi_new["dy"]))
    gi_new["ncol"]=int(_roundoff(abs(xur-xll)/gi_new["dx"]))
    return gi_new

def gi_set_dxdy(gi,dx=None,dy=None):
    """Function to set (change) the cell size of a geographical information dict/list.

    Parameters
    ----------
    gi : dict or list
        Geographical information dict/list.

    dx : float, int, numpy array or array_like (optional)
        Cell size in x direction (column width)

        If *dx* is a numpy array (or array_like) the number of columns (ncol) is adjusted too.

    dy : float, int or numpy array (optional)
        Cell size in y direction (row height)

        If *dy* is a numpy array (or array_like) the number of rows (nrow) is adjusted too.

    Returns
    -------
    result : dict
        New geographical information dict

    See Also
    --------
    :ref:`geo_info`
    """
    gi_new=gi2dict(gi)
    if type(dx) != type(None):
        if type(dx) not in [int,float]:
            try: gi_new["ncol"]=len(dx)
            except: dx=float(dx)
        if type(dx) in [int,float]:
            gi_new["ncol"]=int(_roundoff(gi_get_Dx(gi_new)/dx))
        gi_new["dx"]=deepcopy(dx)
    if type(dy) != type(None):
        if type(dy) not in [int,float]:
            try: gi_new["nrow"]=len(dy)
            except: dy=float(dy)
        if type(dy) in [int,float]:
            gi_new["nrow"]=int(_roundoff(gi_get_Dy(gi_new)/dy))
        gi_new["dy"]=deepcopy(dy)
    return gi_new

def equal_gi(gi1,gi2,tol=1e-7):
    """Function to check if 2 geographical information dicts/lists are equal.

    Parameters
    ----------
    gi1 : dict or list
        Geographical information dict/list.

    gi2 : dict or list
        Geographical information dict/list.

    tol : float (optional)
        Tolerance factor. If values differ less than *tol* they are considered to be equal.

    Returns
    -------
    equal : bool
    """
    gi1=gi2dict(deepcopy(gi1))
    gi2=gi2dict(deepcopy(gi2))
    eq=True
    for key in l_gi_key:
        if l_gi_type[l_gi_key.index(key)] != "str()":
            if key not in gi1 or key not in gi2:
                eq=False
                break
            d=np.abs(np.array(gi1[key])-np.array(gi2[key])).max()
            if d > tol:
                eq=False
                break
    return eq


################################################
## FUNCTIONS TO GET/READ RASTER INFO AND DATA ##
################################################

def _raster2info(f_raster,f_hdr=None):
    """Function to get general file information and geographical information of the raster.

    Parameters
    ----------
    f_raster : str
        Raster file name.

    f_hdr : str or None (optional)
        Header file name for BIL file.

    Returns
    -------
    result : 1 list and 1 dict
        List: [raster_format, header_size, data_bytesize, data_type, nodata, nlay, [frm_map,minval,maxval]]
            raster_format:           0=invalid, 1=asc, 2=idf, 3=pcraster, 4=esri, 5=bil, 6=geotif, 99=other
            header_size:             size of header in bytes (idf, pcraster, bil) or number of header lines (asc)
            data_bytesize:           number of bytes for each array value (idf, pcraster, bil)
            data_type:               dtype of array (idf, pcraster, bil)
            nodata:                  nodata value
            nlay:                    number of layers/bands
            frm_map, minval, maxval: only for PCRaster and IDF maps: map type, minimum value and maximum value
        Dict: basic geographical information dict; see also :ref:`geo_info`.
    """
    ## 0=INVALID
    raster_info,gi=[l_raster_format_str[0],None,None,None,None,None,None],None
    ## 2=IDF
    if raster_info[0] == l_raster_format_str[0]:
        try:
            inf=open(f_raster,"rb")
            magic=struct.unpack("=L",inf.read(4))[0]
            #if magic != 1271: raise
            ncol,nrow,xll,xur,yll,yur,minval,maxval,nodata,ieq,itb,x1,x2=struct.unpack("=2L 7f 4B",inf.read(40))
            if (os.path.getsize(f_raster)-44+bool(ieq-1)*8+bool(itb)*8+bool(ieq)*(nrow+ncol)*4-ncol*nrow*4) < 0: raise
            if ieq == 0:
                dx,dy=struct.unpack("=2f",inf.read(8))
                Dx,Dy=dx*ncol,dy*nrow
            else:
                if itb == 1: inf.read(8)
                dx,dy=np.reshape(np.fromstring(inf.read(ncol*4),float32),(ncol,)),np.reshape(np.fromstring(inf.read(nrow*4),float32),(nrow,))
                Dx,Dy=dx.sum(),dy.sum()
                if dx.min() == dx.max(): dx=float(dx[0])
                if dy.min() == dy.max(): dy=float(dy[0])
            inf.close()
            if not ((abs(abs(xll-xur)-Dx) < 1e-4*ncol) and (abs(abs(yll-yur)-Dy) < 1e-4*nrow)): raise
            raster_info=[l_raster_format_str[2],44+bool(ieq-1)*8+bool(itb)*8+bool(ieq)*(nrow+ncol)*4,4,float32,nodata,1,["scalar",minval,maxval]]

            crs=""
            endofdata=raster_info[1]+(nrow*ncol*raster_info[2])
            if os.path.getsize(f_raster) > endofdata:
                inf=open(f_raster,"rb")
                mm=mmap.mmap(inf.fileno(),0,access=mmap.ACCESS_READ)
                try:
                    mm.seek(endofdata)
                    nrec=struct.unpack("=2L",mm.read(8))[1]
                    mm.seek(endofdata+8)
                    s=struct.unpack("=%ds" %(nrec*4),mm.read(nrec*4))[0].strip()
                    s=s.replace("\r\n","\n")
                    if string.find(s,"CRS={") != -1:
                        crs=s.split("CRS={",1)[1].split("}")[0]
                        crs=crs2epsg(crs,crs)
                except:
                    crs=""
                mm.close()
                inf.close()
            if crs == "":
                crs=prj2crs("%s.prj" %(os.path.splitext(f_raster)[0]))
            gi=gi2dict([xll,yll,dx,dy,nrow,ncol,1,0.0,crs])
            return raster_info,gi
        except:
            try: inf.close()
            except: pass
            raster_info,gi=[l_raster_format_str[0],None,None,None,None,None,None],None
    ## 3=PCRaster
    if raster_info[0] == l_raster_format_str[0]:
        try:
            inf=open(f_raster,"rb")
            magic=struct.unpack("=27s",inf.read(27))[0]
            if magic != "RUU CROSS SYSTEM MAP FORMAT": raise
            xxx,version,gisFileId,projection,attrTable,dataType,byteOrder,xxx,valueScale,cellRepr=struct.unpack("=5s HLHLHL 14s 2H",inf.read(41))
            data_type,data_bytesize,structFormat,xxx,nodata=l_pcr_Struct[l_pcr_Struct["cellRepr"] == cellRepr][0]
            data_type=np.dtype(data_type)
            exec("nodata=%s" %(nodata))
            minVal,xxx,maxVal,xxx=struct.unpack("=%s" %("%s%ds" %(structFormat,8-data_bytesize)*2),inf.read(16))
            xUL,yUL,nrRows,nrCols,cellSizeX,cellSizeY,angle=struct.unpack("=ddLLddd",inf.read(48))
            inf.close()
            frm_map=l_pcr_valueScale["frm_map"][l_pcr_valueScale["valueScale"] == valueScale][0]
            xll,dx,dy,nrow,ncol,proj,ang=xUL,cellSizeX,cellSizeY,nrRows,nrCols,projection,angle
            if proj == 0: yll=yUL+nrow*dy
            else: yll=yUL-nrow*dy
            raster_info=[l_raster_format_str[3],256,data_bytesize,data_type,nodata,1,[frm_map,minVal,maxVal]]
            crs=prj2crs("%s.prj" %(os.path.splitext(f_raster)[0]))
            gi=gi2dict([xll,yll,dx,dy,nrow,ncol,proj,ang,crs])
            return raster_info,gi
        except:
            try: inf.close()
            except: pass
            raster_info,gi=[l_raster_format_str[0],None,None,None,None,None,None],None
    ## 1=AAIGrid (ascii grid)
    if raster_info[0] == l_raster_format_str[0]:
        try:
            inf=open(f_raster,"r")
            if string.find(inf.read(100).lower(),"col") == -1:
                raise
            inf.close()
            inf=open(f_raster,"r")
            ncol=int(float(string.split(inf.readline())[-1])+1e-5)
            nrow=int(float(string.split(inf.readline())[-1])+1e-5)
            x_rec=string.split(string.lower(inf.readline()))
            y_rec=string.split(string.lower(inf.readline()))
            dxy=float(string.split(inf.readline())[-1])
            xll=float(x_rec[-1])
            if string.find(x_rec[0],"cent") != -1: xll-=dxy/2
            yll=float(y_rec[-1])
            if string.find(y_rec[0],"cent") != -1: yll-=dxy/2
            header_linesize=5
            nodata=None
            rec=string.split(string.lower(inf.readline()))
            if len(rec) >= 2:
                if string.find(rec[0],"nodata") != -1:
                    nodata=float(rec[-1])
                    if abs(nodata-int(nodata)) < 1e-7: nodata=int(nodata)
                    header_linesize+=1
            inf.close()
            raster_info=[l_raster_format_str[1],header_linesize,None,None,nodata,1,None]
            crs=prj2crs("%s.prj" %(os.path.splitext(f_raster)[0]))
            gi=gi2dict([xll,yll,dxy,dxy,nrow,ncol,1,0.0,crs])
            return raster_info,gi
        except:
            try: inf.close()
            except: pass
            raster_info,gi=[l_raster_format_str[0],None,None,None,None,None,None],None
    ## 5=BIL (fews bil)
    if raster_info[0] == l_raster_format_str[0]:
        try:
            if f_hdr == None: f_hdr="%s.hdr" %(os.path.splitext(f_raster)[0])
            inf=open(f_hdr,"r"); recs=[string.split(string.strip(string.lower(line))) for line in inf.readlines()]; inf.close()
            nlay,nrow,ncol,nbit,data_type=0,0,0,-1,None
            for rec in recs:
                if rec[0] == "nblocks": nlay=int(rec[1])
                elif rec[0] == "nrows": nrow=int(rec[1])
                elif rec[0] == "ncols": ncol=int(rec[1])
                elif rec[0] == "nbits":
                    nbit=int(rec[1])/8
                    if nbit == 0: nbit,data_type=4,float32
                    else: exec("data_type=int%d" %(nbit*8))
            if os.path.getsize(f_raster) != nlay*nrow*ncol*nbit: raise
            xll,yur,dx,dy,nodata=None,None,None,None,None
            for rec in recs:
                if rec[0] == "ulxmap": xll=float(rec[1])
                elif rec[0] == "ulymap": yur=float(rec[1])
                elif rec[0] == "xdim": dx=float(rec[1])
                elif rec[0] == "ydim": dy=float(rec[1])
                elif rec[0] == "nodata": nodata=float(rec[1])
            if xll == None or yur == None or dx == None or dy == None: raise
            xll=xll-0.5*dx
            yll=yur-nrow*dy+0.5*dy
            raster_info=[l_raster_format_str[5],0,nbit,data_type,nodata,nlay,None]
            crs=prj2crs("%s.prj" %(os.path.splitext(f_raster)[0]))
            gi=gi2dict([xll,yll,dx,dy,nrow,ncol,1,0.0,crs])
            return raster_info,gi
        except:
            try: inf.close()
            except: pass
            raster_info,gi=[l_raster_format_str[0],None,None,None,None,None,None],None
    ## 4=AIG (Esri grid), 6=GTiff (geotiff), 7=netCDF, 8=HDF4Image, >9=GDAL (other gdal supported grid)
    if raster_info[0] == l_raster_format_str[0]:
        try:
            gd=osgeo.gdal.Open(f_raster)
            raster_format=gd.GetDriver().ShortName
            nlay,nrow,ncol=gd.RasterCount,gd.RasterYSize,gd.RasterXSize
            xll,dx,rot1,yul,rot2,dy=gd.GetGeoTransform()
            dx,dy=abs(dx),abs(dy)
            yll=yul-nrow*dy
            crs=gd.GetProjection()
            if crs == "" and raster_format == "netCDF":
                try: crs=Dataset(f_raster).spatial_ref
                except: pass
            crs=crs2epsg(crs,crs)
            if crs == "":
                crs=prj2crs("%s.prj" %(os.path.splitext(f_raster)[0]))
            l_data_type=[["Byte","UInt16","Int16","UInt32","Int32","Float32","Float64","CInt16","CInt32","CFloat32","CFloat64"],\
                         [osgeo.gdal.GDT_Byte,osgeo.gdal.GDT_UInt16,osgeo.gdal.GDT_Int16,osgeo.gdal.GDT_UInt32,osgeo.gdal.GDT_Int32,osgeo.gdal.GDT_Float32,osgeo.gdal.GDT_Float64,osgeo.gdal.GDT_CInt16,osgeo.gdal.GDT_CInt32,osgeo.gdal.GDT_CFloat32,osgeo.gdal.GDT_CFloat64],\
                         [uint8,uint16,int16,uint32,int32,float32,float64,int16,int32,float32,float64],\
                         ["B","H","h","L","l","f","d","h","l","f","d"]]
            data_type,nodata=[],[]
            for l in range(0,nlay):
                layer=gd.GetRasterBand(l+1)
                i_data_type=l_data_type[0].index(osgeo.gdal.GetDataTypeName(layer.DataType))
                data_type+=[l_data_type[2][i_data_type]]
                nodata+=[layer.GetNoDataValue()]
            del gd,layer
            if nlay == 1: data_type,nodata=data_type[0],nodata[0]
            else:
                dt=data_type[0]
                for l in range(1,nlay): dt=np.promote_types(dt,data_type[l])
                data_type=dt
                if min(nodata) == max(nodata): nodata=nodata[0]
            data_bytesize=np.ones((1,),data_type).itemsize
            raster_info=[raster_format,None,data_bytesize,data_type,nodata,nlay,None]
            gi=gi2dict([xll,yll,dx,dy,nrow,ncol,1,0.0,crs])
            return raster_info,gi
        except:
            try: del gd
            except: pass
            try: del layer
            except: pass
            raster_info,gi=[l_raster_format_str[0],None,None,None,None,None,None],None

    return raster_info,gi # >> return: [raster_format, header_size, data_bytesize, data_type, nodata, nlay, [frm_map,minval,maxval]], geo_info

def raster2gi(f_raster,f_hdr=None):
    """Function to get the basic geographical information of the raster.

    Parameters
    ----------
    f_raster : str
        Raster file name.

    f_hdr : str or None (optional)
        Header file name for BIL file.

    Returns
    -------
    gi : dict
        Basic geographical information.

    See Also
    --------
    :ref:`geo_info`
    """
    return _raster2info(f_raster,f_hdr)[1]

def get_raster_format(f_raster):
    """Function to get the raster format of a file.

    Parameters
    ----------
    f_raster : str
        File name.

    Returns
    -------
    raster_format : str
        String referring to the format of the raster file.

    See Also
    --------
    :ref:`raster_formats`
    """
    return _raster2info(f_raster)[0][0]

def get_raster_crs(f_raster,f_hdr=None):
    """Function to get the crs of a file.

    Parameters
    ----------
    f_raster : str
        File name.

    f_hdr : str or None (optional)
        Header file name for BIL file.

    Returns
    -------
    crs : str
        String referring to the crs of the raster file.

    See Also
    --------
    :ref:`projection`
    """
    return raster2gi(f_raster,f_hdr=f_hdr)["crs"]

def get_raster_nodata(f_raster,f_hdr=None):
    """Function to get the nodata value of a raster file.

    Parameters
    ----------
    f_raster : str
        Raster file name.

    f_hdr : str or None (optional)
        Header file name for BIL file.

    Returns
    -------
    nodata : float
    """
    return _raster2info(f_raster,f_hdr)[0][4]

def get_raster_minmax(f_raster):
    """Function to get the minimum and maximum value of a PCRaster or IDF file.

    Parameters
    ----------
    f_raster : str
        File name of PCRaster or IDF file

    Returns
    -------
    result : tuple
        Minimum and maximum value.
    """
    raster_info=_raster2info(f_raster)[0]
    if raster_info[6] == None:
        return (None,None)
    else:
        return (raster_info[6][1],raster_info[6][2])

def get_raster_pcrMapType(f_raster):
    """Function to get the map type (valueScale) of a PCRaster file.

    Recognized types are: 'boolean', 'nominal', 'scalar', 'directional', 'ordinal', 'ldd'.

    Parameters
    ----------
    f_raster : str
        File name of PCRaster file

    Returns
    -------
    pcrMapType : string
        PCRaster map type; returns None if *f_raster* is not a PCRaster file.
    """
    raster_info=_raster2info(f_raster)[0]
    if raster_info[6] == None:
        return None
    else:
        return raster_info[6][0]

def _raster_format2ext(raster_format):
    """Function to get default file extension for a raster format.

    Parameters
    ----------
    raster_format : int or str
        Number or string referring to the format of the raster file.

    Returns
    -------
    ext : str
        File extension.

    See Also
    --------
    :ref:`raster_formats`
    """
    if type(raster_format) == str:
        try: raster_format=l_raster_format_num[l_raster_format_str.index(raster_format)]
        except: raster_format=0
    if raster_format not in l_raster_format_num: raster_format=0
    return l_raster_format_ext[l_raster_format_num.index(raster_format)]

def _ext2raster_format(ext):
    """Function to get the raster format corresponding to the file extension.

    Parameters
    ----------
    ext : str
        File extension.

    Returns
    -------
    raster_format : str
        String referring to the format of the raster file.

    See Also
    --------
    :ref:`raster_formats`
    """
    ext=ext.lower().strip()
    try:
        if ext[0] == ".": ext=ext[1:]
    except: pass
    if ext not in l_raster_format_ext:
        if ext in [s.lower() for s in l_raster_format_str]:
            return [s.lower() for s in l_raster_format_str].index(ext)
        else:
            return l_raster_format_str[0]
    else: return l_raster_format_str[l_raster_format_ext.index(ext)]

def _fname2raster_format(fname):
    """Function to get the raster format corresponding to the extension of the given file name.

    Parameters
    ----------
    fname : str
        File name.

    Returns
    -------
    raster_format : str
        String referring to the format of the raster file.

    See Also
    --------
    :ref:`raster_formats`
    """
    return _ext2raster_format(string.replace(os.path.splitext(fname)[-1],".",""))

def raster2arr(f_raster,nodata=None,gi=None,method="sample",step_xy=1,dtype_asc=None,f_hdr=None):
    """Function to read a raster file and create a rasterArr object.

    Parameters
    ----------
    f_raster : str
        Raster file name.

    nodata : float, int or None (optional)
        Nodata value to be applied.

    gi : dict, list or None (optional)
        Basic geographical information dict/list.

        If *gi* is specified a rescaling/resampling is performed to meet *gi*.
        The rescaling/resampling method is specified with the parameter *method*.
        If *method* is None no rescaling/resampling is performed, but only the extent of the raster is set to meet *gi* ("crop").

    method : str or None (optional)
        The rescaling/resampling method. Possible methods are:
        'sum', 'min', 'max', 'harm', 'log10', 'log', 'mean', 'sample', None.

        Rescaling/resampling is only applied if *gi* is specified. See above.

    step_xy : int or list (optional)
        The resampling step size in x and y direction, with 1 as lowest value meaning no resampling.

        Note: if *step_xy* is specified resampling is performed irrespective of rescaling/resampling invoked by *gi* and *method*.
        Resampling with *step_xy* is done before rescaling/resampling to meet *gi*.

        The step size is not necessarily the same in x in y direction.

        If *step_xy* is an int or a list with only one value the step size in x and y direction are both set to this value.

    dtype_asc : numpy dtype or None (optional)
        Data type for the resulting data array if the raster file is an ArcInfo ASCII Grid.

        If *dtype_asc* is not specified the resulting data type will be float64.

    f_hdr: str or None (optional)
        Header file name for BIL file.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`reading_rasters`
    :ref:`rescaling_resampling`
    """
    if not os.path.isfile(f_raster) and not os.path.isdir(f_raster): raise Exception, "Raster does not exist (%s)" %(f_raster)
    raster_info,gi0=_raster2info(f_raster,f_hdr)
    if raster_info[0] in [0,l_raster_format_str[0]]:
        raise Exception, "Invalid raster (%s)" %(f_raster)
    elif raster_info[0] in [1,l_raster_format_str[1]]: rA=_asc2arr(f_raster,nodata,raster_info,gi0,dtype_asc,gi,step_xy)
    elif raster_info[0] in [2,l_raster_format_str[2]]: rA=_idf2arr(f_raster,nodata,raster_info,gi0,gi,step_xy)
    elif raster_info[0] in [3,l_raster_format_str[3]]: rA=_map2arr(f_raster,nodata,raster_info,gi0,gi,step_xy)
    elif raster_info[0] in [4,6,l_raster_format_str[4],l_raster_format_str[6]]+l_raster_format_num[7:]+l_raster_format_str[7:]: rA=_gdal2arr(f_raster,nodata,raster_info,gi0,gi,step_xy)
    elif raster_info[0] in [5,l_raster_format_str[5]]: rA=_bil2arr(f_raster,nodata,raster_info,gi0,f_hdr,gi,step_xy)
    if gi != None and method != None:
        try: rA=rescale_rA(rA,gi2dict(gi),method)
        except: pass
    if rA.arr.dtype == float16:
        rA.arr=ma.array(rA.arr,float32)
    return rA

def rasters2arr(fl_raster,nodata=None,gi=None,method="sample",step_xy=1,dtype_asc=None,fl_hdr=None):
    """Function to read a list of raster files and create a rasterArr object (map stack).

    The raster files are not necessarily of the same raster format and may have different extents and/or cell sizes.

    If needed rescaling/resampling is performed to the first raster file in the list.

    Parameters
    ----------
    fl_raster : list or tuple
        List of raster file names.

    nodata : float, int or None (optional)
        Nodata value to be applied.

    gi : dict, list or None (optional)
        Basic geographical information dict/list.

        If *gi* is specified a rescaling/resampling is performed to meet *gi*.
        The rescaling/resampling method is specified with the parameter *method*.
        If *method* is None no rescaling/resampling is performed, but only the extent of the raster is set to meet *gi* ("crop").

    method : str or None (optional)
        The rescaling/resampling method. Possible methods are:
        'sum', 'min', 'max', 'harm', 'log10', 'log', 'mean', 'sample', None.

        Rescaling/resampling is only applied if *gi* is specified. See above.

    step_xy : int or list (optional)
        The resampling step size in x and y direction, with 1 as lowest value meaning no resampling.

        Note: if *step_xy* is specified resampling is performed irrespective of rescaling/resampling invoked by *gi* and *method*.
        Resampling with *step_xy* is done before rescaling/resampling to meet *gi*.

        The step size is not necessarily the same in x in y direction.

        If *step_xy* is an int or a list with only one value the step size in x and y direction are both set to this value.

    dtype_asc : numpy dtype or None (optional)
        Data type for the resulting data array if the raster file is an ArcInfo ASCII Grid.

        If *dtype_asc* is not specified the resulting data type will be float64.

    fl_hdr: str, list, tuple or None (optional)
        List of header file names for the BIL files.

        If *fl_header* is a single file name this header file is used for all BIL files.

    Returns
    -------
    result : rasterArr object (3-D map stack)

    See Also
    --------
    :ref:`reading_rasters`
    :ref:`rescaling_resampling`
    """
    if type(fl_raster) not in [list,tuple]:
        return raster2arr(fl_raster,nodata,gi,method,step_xy,dtype_asc,fl_hdr)
    else:
        if type(fl_hdr) not in [list,tuple]: fl_hdr=[fl_hdr]*len(fl_raster)
        return rasterStack([raster2arr(fl_raster[i],nodata,gi,method,step_xy,dtype_asc,fl_hdr[i]) for i in range(0,len(fl_raster))])

def _asc2arr(f_raster,nodata=None,raster_info=None,gi0=None,dtype=None,crop_gi=None,step_xy=1):
    """Function to read a ArcInfo ASCII Grid (AAIGrid) and create a rasterArr object.
    """
    try:
        if raster_info == None or gi0 == None: raster_info,gi0=_raster2info(f_raster)
        if raster_info[0] not in [1,l_raster_format_str[1]]: raise Exception, "Raster is not a valid asc file (%s)" %(f_raster)
        gi0=gi2dict(gi0)
        nrow,ncol,nodata0=gi0["nrow"],gi0["ncol"],raster_info[4]
        if dtype == None: dtype=float64
        inf=open(f_raster,"r")
        for i in range(0,raster_info[1]): inf.readline()
        # check cropping
        dr1,dr2,dc1,dc2=0,0,0,0
        if crop_gi != None:
            [dr1,dr2],[dc1,dc2]=_calc_drc(gi0,crop_gi)
            dr1,dr2,dc1,dc2=max(0,dr1),min(0,dr2),max(0,dc1),min(0,dc2)
            gi0["nrow"],gi0["ncol"]=nrow-dr1+dr2,ncol-dc1+dc2
            gi0["xll"]=gi0["xll"]+gi0["dx"]*dc1
            if gi0["proj"] == 0: gi0["yll"]=gi0["yll"]-gi0["dy"]*-dr2
            else: gi0["yll"]=gi0["yll"]+gi0["dy"]*-dr2
        nrow2,ncol2=gi0["nrow"],gi0["ncol"]
        crop=True
        if dr1 == 0 and dr2 == 0 and dc1 == 0 and dc2 == 0: crop=False
        # check resampling
        try:
            if type(step_xy) not in [list,tuple]: step_xy=[step_xy,step_xy]
            fct_x,fct_y=int(step_xy[0]),int(step_xy[1])
            if fct_x <= 1 and fct_y <= 1: raise
            ix,iy=np.arange(0,gi0["ncol"],fct_x)+((gi0["ncol"]-1)%fct_x)/2,gi0["nrow"]-1-np.arange(0,gi0["nrow"],fct_y)[::-1]-((gi0["nrow"]-1)%fct_y)/2
            gi0["nrow"],gi0["ncol"]=len(iy),len(ix)
            gi0["dx"],gi0["dy"]=gi0["dx"]*fct_x,gi0["dy"]*fct_y
            resam,crop=True,True
        except:
            resam=False
        if gi0["nrow"] <= 0 or gi0["ncol"] <= 0:
            gi0["nrow"]=1
            gi0["ncol"]=1
            return rasterArr(np.array([[raster_info[4]]],dtype),gi0,raster_info[4])
        if crop:
            vr,vc=np.zeros((nrow,),bool),np.zeros((ncol,),bool)
            if resam:
                vr[dr1+iy],vc[dc1+ix]=True,True
            else:
                vr[dr1:dr1+nrow2],vc[dc1:dc1+ncol2]=True,True
            arr=np.zeros((gi0["nrow"]*gi0["ncol"]),dtype)
            if dtype in [float16,float32,float64]:
                i,ii=0,0
                while True:
                    if ii >= gi0["nrow"]*gi0["ncol"]: break
                    rec=[float(s) for s in string.split(inf.readline())]
                    for j in range(0,len(rec)):
                        r,c=(i+j)/ncol,(i+j)%ncol
                        if vr[r] and vc[c]:
                            arr[ii]=rec[j]; ii+=1
                    i+=len(rec)
            else:
                i,ii=0,0
                while True:
                    if ii >= gi0["nrow"]*gi0["ncol"]: break
                    rec=[int(s) for s in string.split(inf.readline())]
                    for j in range(0,len(rec)):
                        r,c=(i+j)/ncol,(i+j)%ncol
                        if vr[r] and vc[c]:
                            arr[ii]=rec[j]; ii+=1
                    i+=len(rec)
        else:
            arr=np.zeros((nrow*ncol),dtype)
            if dtype in [float16,float32,float64]:
                i=0
                while True:
                    if i >= nrow*ncol: break
                    rec=[float(s) for s in string.split(inf.readline())]
                    n=min(len(rec),nrow*ncol-i)
                    arr[i:i+n]=rec[:n]
                    i+=n
            else:
                i=0
                while True:
                    if i >= nrow*ncol: break
                    rec=[int(s) for s in string.split(inf.readline())]
                    n=min(len(rec),nrow*ncol-i)
                    arr[i:i+n]=rec[:n]
                    i+=n
        inf.close()
        if nodata0 == None:
            nodata0=_get_prefered_nodata(arr[:i])
            arr=np.array(arr,_get_min_dtype(arr,nodata0))
            raster_info[4]=nodata0
        arr[i:]=nodata0
        if nodata != None:
            arr=np.array(arr,_get_min_dtype(arr,nodata))
            arr[arr == nodata0]=nodata #arr=np.where(arr == nodata0,nodata,arr)
            raster_info[4]=nodata
        arr=np.array(np.reshape(arr,(gi0["nrow"],gi0["ncol"])),dtype)
        return rasterArr(arr,gi0,raster_info[4])
    except Exception, err:
        try: inf.close()
        except: pass
        raise err

def _idf2arr(f_raster,nodata=None,raster_info=None,gi0=None,crop_gi=None,step_xy=1):
    """Function to read a iMOD IDF file and create a rasterArr object.
    """
    try:
        if raster_info == None or gi0 == None: raster_info,gi0=_raster2info(f_raster)
        if raster_info[0] not in [2,l_raster_format_str[2]]: raise Exception, "Raster is not a valid idf file (%s)" %(f_raster)
        gi0=gi2dict(gi0)
        nrow,ncol,nodata0=gi0["nrow"],gi0["ncol"],raster_info[4]
        # check cropping
        dr1,dr2,dc1,dc2=0,0,0,0
        if crop_gi != None:
            [dr1,dr2],[dc1,dc2]=_calc_drc(gi0,crop_gi)
            dr1,dr2,dc1,dc2=max(0,dr1),min(0,dr2),max(0,dc1),min(0,dc2)
            gi0["nrow"],gi0["ncol"]=nrow-dr1+dr2,ncol-dc1+dc2
            gi0["xll"]=gi0["xll"]+gi0["dx"]*dc1
            if gi0["proj"] == 0: gi0["yll"]=gi0["yll"]-gi0["dy"]*-dr2
            else: gi0["yll"]=gi0["yll"]+gi0["dy"]*-dr2
        ncol2=gi0["ncol"]
        # check resampling
        try:
            if type(step_xy) not in [list,tuple]: step_xy=[step_xy,step_xy]
            fct_x,fct_y=int(step_xy[0]),int(step_xy[1])
            if fct_x <= 1 and fct_y <= 1: raise
            ix,iy=np.arange(0,gi0["ncol"],fct_x)+((gi0["ncol"]-1)%fct_x)/2,gi0["nrow"]-1-np.arange(0,gi0["nrow"],fct_y)[::-1]-((gi0["nrow"]-1)%fct_y)/2
            gi0["nrow"],gi0["ncol"]=len(iy),len(ix)
            gi0["dx"],gi0["dy"]=gi0["dx"]*fct_x,gi0["dy"]*fct_y
            resam=True
        except:
            resam=False
        if gi0["nrow"] <= 0 or gi0["ncol"] <= 0:
            gi0["nrow"]=1
            gi0["ncol"]=1
            return rasterArr(np.array([[raster_info[4]]],raster_info[3]),gi0,raster_info[4])
        arr=np.zeros((gi0["nrow"],gi0["ncol"]),raster_info[3])
        inf=open(f_raster,"rb")
        inf.read(raster_info[1])
        inf.read(dr1*ncol*raster_info[2])
          # resampling
        if resam:
            r=0
            for R in range(0,nrow-dr1+dr2):
                if R in iy:
                    inf.read(dc1*raster_info[2]); arr[r]=np.fromstring(inf.read(ncol2*raster_info[2]),raster_info[3])[ix]; inf.read(-dc2*raster_info[2])
                    r+=1
                else: inf.read(ncol*raster_info[2])
          # no resampling
        else:
            for r in range(0,gi0["nrow"]):
                inf.read(dc1*raster_info[2]); arr[r]=np.fromstring(inf.read(gi0["ncol"]*raster_info[2]),raster_info[3]); inf.read(-dc2*raster_info[2])
        inf.close()
        if nodata != None:
            arr[arr == nodata0]=nodata #arr=np.where(arr == nodata0,nodata,arr)
            raster_info[4]=nodata
        return rasterArr(arr,gi0,raster_info[4])
    except Exception, err:
        try: inf.close()
        except: pass
        raise err

def _map2arr(f_raster,nodata=None,raster_info=None,gi0=None,crop_gi=None,step_xy=1):
    """Function to read a PCRaster file and create a rasterArr object.
    """
    try:
        if raster_info == None or gi0 == None: raster_info,gi0=_raster2info(f_raster)
        if raster_info[0] not in [3,l_raster_format_str[3]]: raise Exception, "Raster is not a valid pcraster map file (%s)" %(f_raster)
        gi0=gi2dict(gi0)
        nrow,ncol,nodata0=gi0["nrow"],gi0["ncol"],raster_info[4]
        # check cropping
        dr1,dr2,dc1,dc2=0,0,0,0
        if crop_gi != None:
            [dr1,dr2],[dc1,dc2]=_calc_drc(gi0,crop_gi)
            dr1,dr2,dc1,dc2=max(0,dr1),min(0,dr2),max(0,dc1),min(0,dc2)
            gi0["nrow"],gi0["ncol"]=nrow-dr1+dr2,ncol-dc1+dc2
            gi0["xll"]=gi0["xll"]+gi0["dx"]*dc1
            if gi0["proj"] == 0: gi0["yll"]=gi0["yll"]-gi0["dy"]*-dr2
            else: gi0["yll"]=gi0["yll"]+gi0["dy"]*-dr2
        ncol2=gi0["ncol"]
        # check resampling
        try:
            if type(step_xy) not in [list,tuple]: step_xy=[step_xy,step_xy]
            fct_x,fct_y=int(step_xy[0]),int(step_xy[1])
            if fct_x <= 1 and fct_y <= 1: raise
            ix,iy=np.arange(0,gi0["ncol"],fct_x)+((gi0["ncol"]-1)%fct_x)/2,gi0["nrow"]-1-np.arange(0,gi0["nrow"],fct_y)[::-1]-((gi0["nrow"]-1)%fct_y)/2
            gi0["nrow"],gi0["ncol"]=len(iy),len(ix)
            gi0["dx"],gi0["dy"]=gi0["dx"]*fct_x,gi0["dy"]*fct_y
            resam=True
        except:
            resam=False
        if gi0["nrow"] <= 0 or gi0["ncol"] <= 0:
            gi0["nrow"]=1
            gi0["ncol"]=1
            return rasterArr(np.array([[raster_info[4]]],raster_info[3]),gi0,raster_info[4])
        arr=np.zeros((gi0["nrow"],gi0["ncol"]),raster_info[3])
        inf=open(f_raster,"rb")
        inf.read(raster_info[1])
        inf.read(dr1*ncol*raster_info[2])
          # resampling
        if resam:
            r=0
            for R in range(0,nrow-dr1+dr2):
                if R in iy:
                    inf.read(dc1*raster_info[2]); arr[r]=np.fromstring(inf.read(ncol2*raster_info[2]),raster_info[3])[ix]; inf.read(-dc2*raster_info[2])
                    r+=1
                else: inf.read(ncol*raster_info[2])
          # no resampling
        else:
            for r in range(0,gi0["nrow"]):
                inf.read(dc1*raster_info[2]); arr[r]=np.fromstring(inf.read(gi0["ncol"]*raster_info[2]),raster_info[3]); inf.read(-dc2*raster_info[2])
        inf.close()
        if raster_info[3] in [float32,float64]:
            if nodata == None:
                nodata=raster_info[6][1]-1
            arr[np.isnan(arr)]=nodata
            raster_info[4]=nodata
        elif nodata != None:
            arr=np.array(arr,_get_min_dtype(arr,nodata))
            arr[arr == nodata0]=nodata #arr=np.where(arr == nodata0,nodata,arr)
            raster_info[4]=nodata
        return rasterArr(arr,gi0,raster_info[4])
    except Exception, err:
        try: inf.close()
        except: pass
        raise err

def _gdal2arr(f_raster,nodata=None,raster_info=None,gi0=None,crop_gi=None,step_xy=1):
    """Function to read a GDAL supported raster file and create a rasterArr object.
    """
    try:
        if raster_info == None or gi0 == None: raster_info,gi0=_raster2info(f_raster)
        if raster_info[0] not in [1,3,4,6]+l_raster_format_num[7:]+[l_raster_format_str[1],l_raster_format_str[3],l_raster_format_str[4],l_raster_format_str[6]]+l_raster_format_str[7:]:
            raise Exception, "Raster is not a valid grid (%s)" %(f_raster)
        gi0=gi2dict(gi0)
        nlay,nrow,ncol,nodata0,dt=raster_info[5],gi0["nrow"],gi0["ncol"],raster_info[4],raster_info[3]
        # check cropping
        dr1,dr2,dc1,dc2=0,0,0,0
        if crop_gi != None:
            [[dr1,dr2],[dc1,dc2]]=_calc_drc(gi0,crop_gi)
            dr1,dr2,dc1,dc2=max(0,dr1),min(0,dr2),max(0,dc1),min(0,dc2)
            gi0["nrow"],gi0["ncol"]=nrow-dr1+dr2,ncol-dc1+dc2
            gi0["xll"]=gi0["xll"]+gi0["dx"]*dc1
            if gi0["proj"] == 0: gi0["yll"]=gi0["yll"]-gi0["dy"]*-dr2
            else: gi0["yll"]=gi0["yll"]+gi0["dy"]*-dr2
        crop=True
        if dr1 == 0 and dr2 == 0 and dc1 == 0 and dc2 == 0: crop=False
        # check resampling
        try:
            if type(step_xy) not in [list,tuple]: step_xy=[step_xy,step_xy]
            fct_x,fct_y=int(step_xy[0]),int(step_xy[1])
            if fct_x <= 1 and fct_y <= 1: raise
            ix,iy=np.arange(0,gi0["ncol"],fct_x)+((gi0["ncol"]-1)%fct_x)/2,gi0["nrow"]-1-np.arange(0,gi0["nrow"],fct_y)[::-1]-((gi0["nrow"]-1)%fct_y)/2
            gi0["nrow"],gi0["ncol"]=len(iy),len(ix)
            gi0["dx"],gi0["dy"]=gi0["dx"]*fct_x,gi0["dy"]*fct_y
            resam=True
        except:
            resam=False

        l_data_type=[["Byte","UInt16","Int16","UInt32","Int32","Float32","Float64","CInt16","CInt32","CFloat32","CFloat64"],\
                     [osgeo.gdal.GDT_Byte,osgeo.gdal.GDT_UInt16,osgeo.gdal.GDT_Int16,osgeo.gdal.GDT_UInt32,osgeo.gdal.GDT_Int32,osgeo.gdal.GDT_Float32,osgeo.gdal.GDT_Float64,osgeo.gdal.GDT_CInt16,osgeo.gdal.GDT_CInt32,osgeo.gdal.GDT_CFloat32,osgeo.gdal.GDT_CFloat64],\
                     [uint8,uint16,int16,uint32,int32,float32,float64,int16,int32,float32,float64],\
                     ["B","H","h","L","l","f","d","h","l","f","d"]]

        gd=osgeo.gdal.Open(f_raster)
        arr=[]
        if type(nodata0) not in [list,tuple]:
            nodata1=[nodata0 for l in range(0,nlay)]
        else:
            nodata1=deepcopy(nodata0)
            if None in nodata1: nodata0=None
        nodata2=deepcopy(nodata1)
        for l in range(0,nlay):
            if nodata1[l] == None: nodata1[l]=0
        for l in range(0,nlay):
            layer=gd.GetRasterBand(l+1)
            i_data_type=l_data_type[0].index(osgeo.gdal.GetDataTypeName(layer.DataType))
            if crop:
                arr0=np.ones((nrow-dr1+dr2,ncol-dc1+dc2),dt)*nodata1[l]
                for r in range(dr1,nrow+dr2):
                    data=layer.ReadRaster(dc1,r,ncol-dc1+dc2,1,ncol-dc1+dc2,1,l_data_type[1][i_data_type]) # x-offset,y-offset,x-size,y-size,x-buf(=x-size),y-buf(=y-size)
                    arr0[r-dr1]=np.array(struct.unpack("%d%s" %(ncol-dc1+dc2,l_data_type[3][i_data_type]),data),dtype=dt)
            else:
                data=layer.ReadRaster(dc1,dr1,ncol-dc1+dc2,nrow-dr1+dr2,ncol-dc1+dc2,nrow-dr1+dr2,l_data_type[1][i_data_type])
                arr0=np.reshape(np.array(struct.unpack("%d%s" %((ncol-dc1+dc2)*(nrow-dr1+dr2),l_data_type[3][i_data_type]),data),dtype=dt),(nrow-dr1+dr2,ncol-dc1+dc2))
            if resam:
                arr+=[np.take(np.take(arr0,iy,0),ix,1)]
            else:
                arr+=[arr0.copy()]
        del gd,layer

        arr=np.array(arr,dtype=dt)
        if nodata0 == None:
            nodata0=_get_prefered_nodata(arr)
            arr=np.array(arr,_get_min_dtype(arr,nodata0))
        for l in range(0,nlay):
            if nodata2[l] != None:
                arr[l][arr[l] == nodata1[l]]=nodata0 #arr[l]=np.where(arr[l] == nodata1[l],nodata0,arr[l])
        if nodata != None:
            arr=np.array(arr,_get_min_dtype(arr,nodata))
            arr[arr == nodata0]=nodata #arr=np.where(arr == nodata0,nodata,arr)
            raster_info[4]=nodata
        if nlay == 1: arr=arr[0]
        return rasterArr(arr,gi0,raster_info[4])
    except Exception, err:
        try: del gd
        except: pass
        raise err

def _bil2arr(f_raster,nodata=None,raster_info=None,gi0=None,f_hdr=None,crop_gi=None,step_xy=1):
    """Function to read a USGS/FEWS BIL file (BIL) and create a rasterArr object.
    """
    try:
        if raster_info == None or gi0 == None: raster_info,gi0=_raster2info(f_raster,f_hdr)
        if raster_info[0] not in [5,l_raster_format_str[5]]: raise Exception, "Raster is not a valid bil file (%s)" %(f_raster)
        gi0=gi2dict(gi0)
        nlay,nrow,ncol,nodata0=raster_info[5],gi0["nrow"],gi0["ncol"],raster_info[4]

        dr1,dr2,dc1,dc2=0,0,0,0
        if crop_gi != None:
            [dr1,dr2],[dc1,dc2]=_calc_drc(gi0,crop_gi)
            dr1,dr2,dc1,dc2=max(0,dr1),min(0,dr2),max(0,dc1),min(0,dc2)
            gi0["nrow"],gi0["ncol"]=nrow-dr1+dr2,ncol-dc1+dc2
            gi0["xll"]=gi0["xll"]+gi0["dx"]*dc1
            if gi0["proj"] == 0: gi0["yll"]=gi0["yll"]-gi0["dy"]*-dr2
            else: gi0["yll"]=gi0["yll"]+gi0["dy"]*-dr2
        ncol2=gi0["ncol"]
        # check resampling
        try:
            if type(step_xy) not in [list,tuple]: step_xy=[step_xy,step_xy]
            fct_x,fct_y=int(step_xy[0]),int(step_xy[1])
            if fct_x <= 1 and fct_y <= 1: raise
            ix,iy=np.arange(0,gi0["ncol"],fct_x)+((gi0["ncol"]-1)%fct_x)/2,gi0["nrow"]-1-np.arange(0,gi0["nrow"],fct_y)[::-1]-((gi0["nrow"]-1)%fct_y)/2
            gi0["nrow"],gi0["ncol"]=len(iy),len(ix)
            gi0["dx"],gi0["dy"]=gi0["dx"]*fct_x,gi0["dy"]*fct_y
            resam=True
        except:
            resam=False
        arr=np.zeros((nlay,gi0["nrow"],gi0["ncol"]),raster_info[3])
        inf=open(f_raster,"rb")
        for l in range(0,nlay):
            inf.read(dr1*ncol*raster_info[2])
              # resampling
            if resam:
                r=0
                for R in range(0,nrow-dr1+dr2):
                    if R in iy:
                        inf.read(dc1*raster_info[2]); arr[l,r]=np.fromstring(inf.read(ncol2*raster_info[2]),raster_info[3])[ix]; inf.read(-dc2*raster_info[2])
                        r+=1
                    else: inf.read(ncol*raster_info[2])
                inf.read(-dr2*ncol*raster_info[2])
              # no resampling
            else:
                for r in range(0,gi0["nrow"]):
                    inf.read(dc1*raster_info[2]); arr[l,r]=np.fromstring(inf.read(gi0["ncol"]*raster_info[2]),raster_info[3]); inf.read(-dc2*raster_info[2])
                inf.read(-dr2*ncol*raster_info[2])
        inf.close()
        if nlay == 1: arr=arr[0]
        if nodata != None:
            arr=np.array(arr,_get_min_dtype(arr,nodata))
            arr[arr == nodata0]=nodata #arr=np.where(arr == nodata0,nodata,arr)
            raster_info[4]=nodata
        return rasterArr(arr,gi0,raster_info[4])
    except Exception, err:
        try: inf.close()
        except: pass
        raise err


###################################################################
## FUNCTIONS TO RESCALE/RESAMPLE >> ONLY FOR EQUIDISTANT RASTERS ##
###################################################################

def resample_rA(rA,step_xy=[1,1]):
    """Function to resample a rasterArr object using a step size.

    Parameters
    ----------
    rA : rasterArr object

    step_xy : int, list or dict
        The step size in x and y direction, with 1 as lowest value meaning no resampling.

        The step size is not necessarily the same in x in y direction.

        If *step_xy* is an int or a list with only one value the step size in x and y direction are both set to this value.

        If *step_xy* is a dict it is assumed that it is a basic geographical information dict.
        The step sizes are then determined using this dict. See also :func:`raster_func.rescale_rA`

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`rescaling_resampling`
    """
    try:
        step_is_gi=False
        if type(step_xy) == dict: step_is_gi=True
        elif type(step_xy) in [list,tuple]:
            if len(step_xy) >= 6: step_xy,step_is_gi=gi2dict(deepcopy(step_xy)),True
        else: step_xy=[step_xy,step_xy]
        if step_is_gi:
            gi=deepcopy(step_xy)
            x=rc2xy(np.append(np.zeros((1,gi["ncol"])),np.reshape(np.arange(0,gi["ncol"]),(1,gi["ncol"])),0),gi)
            y=rc2xy(np.append(np.reshape(np.arange(0,gi["nrow"]),(1,gi["nrow"])),np.zeros((1,gi["nrow"])),0),gi)
            r=xy2rc(y,rA.gi())[0]
            c=xy2rc(x,rA.gi())[1]
        else:
            fct_x=float(step_xy[0])
            fct_y=float(step_xy[1])
            if fct_x <= 1 and fct_y <= 1: raise
            gi=deepcopy(rA.gi())
            gi["dx"],gi["dy"]=gi["dx"]*fct_x,gi["dy"]*fct_y
            c=np.arange(0,rA.ncol(),fct_x)
            c=np.array(np.around(c+max(0,rA.ncol()-1-c[-1])/2.,0),int32)
            r=np.arange(0,rA.nrow(),fct_y)
            r=np.array(np.around(r+max(0,rA.nrow()-1-r[-1])/2.,0),int32)
        no_r=np.logical_or(r < 0,r >= rA.nrow())
        no_c=np.logical_or(c < 0,c >= rA.ncol())
        r[no_r],c[no_c]=0,0
        arr=ma.take(ma.take(rA.arr,r,0),c,1)
        arr.fill_value=rA.nodata()
        if arr.mask.ndim == 0: arr.mask=np.ones(arr.shape,bool)*arr.mask
        arr[no_r,:],arr[:,no_c]=arr.fill_value,arr.fill_value
        arr.mask[no_r,:],arr.mask[:,no_c]=True,True
        return rasterArr(arr,gi)
    except Exception, err:
        return rA.copy()

def rescale_rA(rA,to_gi,method="sample"):
    """Function to rescale/resample a rasterArr object.

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    rA : rasterArr object

    to_gi : dict or list
        The target geographical information dict/list to which the rescaling/resampling is done.

        If *to_gi* is specified as a list the order of the elements should be: xll, yll, dx, dy, nrow, ncol, proj, ang, crs.
        See also :ref:`geo_info`.

    method : str or None (optional)
        The rescaling/resampling method. Possible methods are:
        'sum', 'min', 'max', 'harm', 'log10', 'log', 'mean', 'sample', None.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`rescaling_resampling`
    """
    if method != None:
        try:
            try: to_gi=to_gi.gi()
            except: to_gi=gi2dict(to_gi)
            if to_gi["crs"] == None: to_gi["crs"]=""
            try:
                if abs(np.array(rA.gi_list()[:6])-np.array(gi2list(to_gi)[:6])).max() < 1e-7:
                    return rA.copy()
                else: raise
            except:
                if rA.ieq() != 0: raise Exception, "Raster is non-equidistant: not supported"
                if type(to_gi["dx"]) not in [int,float] or type(to_gi["dy"]) not in [int,float]: raise Exception, "Target geo_info is non-equidistant: not supported"
                if None in rA.gi_list()[:6]: raise Exception, "Raster geo_info is not complete: %s" %(rA.gi())
                if None in gi2list(to_gi)[:6]: raise Exception, "Target geo_info is not complete: %s" %(to_gi)
                if rA.proj() != to_gi["proj"] or rA.crs() != to_gi["crs"]:
                    mess=""
                    if not same_crs(rA.crs(),to_gi["crs"]):
                        crs1,crs2=crs2epsg(rA.crs(),""),crs2epsg(to_gi["crs"],"")
                        if not (crs1 == "" or crs2 == ""):
                            mess+="Crs is different:\n  A: %s\n  B: %s\n" %(crs2epsg(rA.crs(),rA.crs()),crs2epsg(to_gi["crs"],to_gi["crs"]))
                    if rA.proj() != to_gi["proj"]:
                        mess+="Y projection is different: A: %s, B: %s" %(rA.proj(),to_gi["proj"])
                    if mess != "":
                        raise Exception, mess.strip()
                if method not in ["sum","min","max","harm","log10","log","mean"]:
                    return resample_rA(rA,to_gi)
                else:
                    drc1,dxy3,drc3,dxy2=_calc_drc_dxy(rA.gi(),to_gi)
                    arr=rA.arr.copy()
                    if arr.mask.ndim == 0: arr.mask=np.ones(arr.shape,bool)*arr.mask
                    dt0=arr.dtype
                    arr=_reform_arr(arr,drc1)
                    arr=_split_cells(arr,dxy3[2],dxy3[3])
                    if method == "sum":
                        if arr.dtype == float64: dt=float64
                        else: dt=float32
                        if dxy3[2] > 1: arr=ma.array(arr/float(dxy3[2]),dtype=dt)
                        if dxy3[3] > 1: arr=ma.array(arr/float(dxy3[3]),dtype=dt)
                    arr=_reform_arr(arr,drc3)
                    arr=_merge_cells(arr,dxy2[2],dxy2[3],method)
                    return rasterArr(arr,to_gi)
        except Exception, err:
            if sys.exc_info()[0] == MemoryError:
                print err; pass
            else: print err
            return rA.copy()
    else: return rA.copy()

def _calc_drc(gi1,gi2):
    """Function to calculate the number of rows and columns to add or remove.
      # calculate row and column offsets and cell sizes for rescaling
      #   gi1, gi2: source and target geo_info
      #    gi: geo_info dict/list or rasterArr object
      #   drc: [[dr_top,dr_bottom],[dc_left,dc_right]]
      #    dr,dc: offset
      #   dxy: [dx,dy,mult_x,mult_y]
      #    mult: n_split or n_merge
    """
    xll1,yll1,dx1,dy1,proj1=get_gi(gi1,"xll","yll","dx","dy","proj")
    xur1,yur1=gi_extended(gi1,True)[:2]
    xll2,yll2=get_gi(gi2,"xll","yll")
    xur2,yur2=gi_extended(gi2,True)[:2]
    if proj1 == 1: dr=[int(_rounddown((yur1-yur2)/dy1)),(yll1-yll2)/dy1]
    else: dr=[int(_rounddown((yur2-yur1)/dy1)),(yll2-yll1)/dy1]
    if dr[1]-int(dr[1]) < 1e-7: dr[1]=int(_roundoff(dr[1]))
    else: dr[1]=int(_roundup(dr[1]))
    dc=[int(_rounddown((xll2-xll1)/dx1)),(xur2-xur1)/dx1]
    if dc[1]-int(dc[1]) < 1e-7: dc[1]=int(_roundoff(dc[1]))
    else: dc[1]=int(_roundup(dc[1]))
    return dr,dc

def _calc_dxy(gi1,gi2):
    """Function to calculate the greatest common cell sizes for down scaling.
    """
    xll1,yll1,dx1,dy1=get_gi(gi1,"xll","yll","dx","dy")
    xll2,yll2,dx2,dy2=get_gi(gi2,"xll","yll","dx","dy")
    dx=_calc_gcd(dx1,dx2)
    if abs(xll1-xll2) > 1e-7: dx=_calc_gcd(dx,xll1-xll2)
    dy=_calc_gcd(dy1,dy2)
    if abs(yll1-yll2) > 1e-7: dy=_calc_gcd(dy,yll1-yll2)
    return dx,dy

def _calc_drc_dxy(gi1,gi2):
    """Function to calculate number of rows/columns to add/remove and greatest common cell sizes for subsequent down and up scaling.
    """
    try: gi1=deepcopy(gi1.gi())
    except: gi1=deepcopy(gi1)
    try: gi2=deepcopy(gi2.gi())
    except: gi2=deepcopy(gi2)
    gi1,gi2=gi2list(gi1),gi2list(gi2)

    xll1,yll1,dx1,dy1,nrow1,ncol1,proj1,ang1=gi1[:8]
    xur1,yur1=gi_extended(gi1,True)[:2]
    xll2,yll2,dx2,dy2,nrow2,ncol2=gi2[:6]
    xur2,yur2=gi_extended(gi2,True)[:2]

    if abs((xll1-xll2)/(max(dx1-dx2,min(dx1,dx2)))) < 1e-2: xll1,gi1[0]=xll2,xll2
    if abs((yll1-yll2)/(max(dy1-dy2,min(dy1,dy2)))) < 1e-2: yll1,gi1[1]=yll2,yll2

    fdx,fdy=int(_roundup(dx2/dx1)),int(_roundup(dy2/dy1))

    dr1,dc1=_calc_drc(gi1,gi2); dr1[0],dr1[1],dc1[0],dc1[1]=max(dr1[0],-fdy),min(dr1[1],fdy),max(dc1[0],-fdx),min(dc1[1],fdx)
    dx3,dy3=_calc_dxy(gi1,gi2)

    xll3,xur3=xll1+dc1[0]*dx1,xur1+dc1[1]*dx1
    if proj1 == 1: yll3,yur3=yll1-dr1[1]*dy1,yur1-dr1[0]*dy1
    else: yll3,yur3=yll1+dr1[1]*dy1,yur1+dr1[0]*dy1
    gi3=[xll3,yll3,dx3,dy3,int(_roundoff(abs(yur3-yll3)/dy3)),int(_roundoff((xur3-xll3)/dx3)),proj1,ang1]

    dr3,dc3=_calc_drc(gi3,gi2)

    return [dr1,dc1],[dx3,dy3,int(_roundoff(dx1/dx3)),int(_roundoff(dy1/dy3))],[dr3,dc3],[dx2,dy2,int(_roundoff(dx2/dx3)),int(_roundoff(dy2/dy3))]

def _reform_arr(arr,drc,nodata=None):
    """Function to add or remove rows and columns.
      # reform array: adding or removing rows and columns
      #   arr: numpy ndarray or array-like, masked array or rasterArr object
      #    arr should be minimal 2D
      #    return array is numpy ndarray, masked array or rasterArr object (according to input arr)
      #   drc: [[dr_top,dr_bottom],[dc_left,dc_right]]
      #    dr,dc: offset
      #   nodata: nodata to be used for added cells (only if arr is numpy ndarray or array-like)
      #    if arr is rasterArr object or masked array then nodata is taken from arr
    """
    is_rA,is_ma=False,False
    try: arr,gi,nodata,is_rA=deepcopy(arr.arr),deepcopy(arr.gi()),deepcopy(arr.nodata()),True
    except: arr=deepcopy(arr)
    try: arr,nodata,is_ma=ma.filled(arr.copy()),arr.fill_value,True
    except:
        if type(nodata) not in [bool,int,float]:
            nodata=_get_prefered_nodata(arr); arr=np.array(arr,_get_min_dtype(arr,nodata))
    nodata=_value_dtype2type(nodata)
    if drc[0][0] > 0:   arr=arr[drc[0][0]:]
    elif drc[0][0] < 0: arr=np.concatenate([np.ones((-drc[0][0],arr.shape[-1]),arr.dtype)*nodata,arr],-2)
    if drc[0][1] < 0:   arr=arr[:drc[0][1]]
    elif drc[0][1] > 0: arr=np.concatenate([arr,np.ones((drc[0][1],arr.shape[-1]),arr.dtype)*nodata],-2)
    if drc[1][0] > 0:   arr=arr[:,drc[1][0]:]
    elif drc[1][0] < 0: arr=np.concatenate([np.ones((arr.shape[-2],-drc[1][0]),arr.dtype)*nodata,arr],-1)
    if drc[1][1] < 0:   arr=arr[:,:drc[1][1]]
    elif drc[1][1] > 0: arr=np.concatenate([arr,np.ones((arr.shape[-2],drc[1][1]),arr.dtype)*nodata],-1)
    if is_rA:
        gi["xll"]=gi["xll"]+drc[1][0]*gi["dx"]
        if gi["proj"] == 0:
            gi["yll"]=gi["yll"]+drc[0][1]*gi["dy"]
        else:
            gi["yll"]=gi["yll"]-drc[0][1]*gi["dy"]
        return rasterArr(arr,gi,nodata)
    elif is_ma: return ma.masked_values(arr,nodata)
    else: return arr

def _split_cells(arr,n_xsplit=1,n_ysplit=1):
    """Function to split cells.
      # split cells
      #   arr: numpy ndarray or array-like, masked array or rasterArr object
      #    arr should be minimal 2D
      #    return array is numpy ndarray, masked array or rasterArr object (according to input arr)
      #   n_xsplit: split number in x direction
      #   n_ysplit: split number in y direction
    """
    is_rA,is_ma=False,False
    try: arr,gi,nodata,is_rA=deepcopy(arr.arr),deepcopy(arr.gi()),deepcopy(arr.nodata()),True
    except: arr=deepcopy(arr)
    n_xsplit,n_ysplit=int(n_xsplit),int(n_ysplit)
    if n_xsplit > 1 or n_ysplit > 1:
        try:
            arr.fill_value; is_ma=True
        except: pass
        if n_xsplit > 1:
            if is_ma: arr=ma.repeat(arr,n_xsplit,-1)
            else: arr=np.repeat(arr,n_xsplit,-1)
        if n_ysplit > 1:
            if is_ma: arr=ma.repeat(arr,n_ysplit,-2)
            else: arr=np.repeat(arr,n_ysplit,-2)
        if is_rA:
            gi["dx"]=gi["dx"]/n_xsplit
            gi["dy"]=gi["dy"]/n_ysplit
    if is_rA: return rasterArr(arr,gi,nodata)
    else: return arr

def _merge_cells(arr,n_xmerge=1,n_ymerge=1,method="mean",nodata=None):
    """Function to merge cells.
      # merge cells
      #   arr: numpy ndarray or array-like, masked array or rasterArr object
      #    arr should be minimal 2D
      #    return array is numpy ndarray, masked array or rasterArr object (according to input arr)
      #   n_xmerge: merge number in x direction
      #   n_ymerge: merge number in y direction
      #   method: sum, min, max, harm, log10, log, mean
      #   nodata: nodata to be used if necessary (only if arr is numpy ndarray or array-like)
      #    if arr is rasterArr object or masked array then nodata is taken from arr
    """
    is_rA,is_ma=False,False
    try: arr,gi,nodata,is_rA=deepcopy(arr.arr),deepcopy(arr.gi()),deepcopy(arr.nodata()),True
    except: arr=deepcopy(arr)
    n_xmerge,n_ymerge=int(n_xmerge),int(n_ymerge)
    try: method=string.lower(method)
    except: method="mean"
    if n_xmerge > 1 or n_ymerge > 1:
        if arr.dtype == float64: dt=float64
        else: dt=float32
        try: nodata,is_ma=arr.fill_value,True
        except:
            if type(nodata) not in [bool,int,float]:
                nodata=_get_prefered_nodata(arr); arr=np.array(arr,_get_min_dtype(arr,nodata))
            arr=ma.masked_values(arr,nodata)
        nodata=_value_dtype2type(nodata)
        arr=ma.reshape(ma.swapaxes(ma.reshape(arr,arr.shape[:-2]+(arr.shape[-2]/n_ymerge,n_ymerge,arr.shape[-1])),-2,-1),arr.shape[:-3]+(arr.shape[-2]/n_ymerge,arr.shape[-1]/n_xmerge,n_ymerge*n_xmerge))
        if method == "sum":
            dt=arr.dtype
            arr=ma.array(arr.sum(-1),fill_value=nodata)
            arr=ma.array(arr,dtype=_get_min_dtype(np.ones((1,),dt),arr.min(),arr.max(),arr.fill_value))
        elif method == "min": arr=ma.array(arr.min(-1),arr.dtype,fill_value=nodata)
        elif method == "max": arr=ma.array(arr.max(-1),arr.dtype,fill_value=nodata)
        elif method == "harm":
            mask=np.logical_or(arr.mask,arr.data == 0)
            arr.data[mask]=1
            arr=ma.array(1.0/arr.data,mask=mask,dtype=dt).mean(-1)
            mask=np.logical_or(arr.mask,arr.data == 0)
            arr.data[mask]=1
            arr=ma.array(1.0/arr.data,mask=mask,dtype=dt)
            arr.data[arr.mask],arr.fill_value=nodata,nodata
        elif method == "log10":
            mask=np.logical_or(arr.mask,arr.data <= 0)
            arr.data[mask]=1
            arr=10**ma.array(ma.array(np.log10(arr.data),mask=mask,dtype=dt).mean(-1),dtype=dt)
            arr.data[arr.mask],arr.fill_value=nodata,nodata
        elif method == "log":
            mask=np.logical_or(arr.mask,arr.data <= 0)
            arr.data[mask]=1
            arr=ma.exp(ma.array(ma.array(np.log(arr.data),mask=mask,dtype=dt).mean(-1),dtype=dt))
            arr.data[arr.mask],arr.fill_value=nodata,nodata
        else: arr=ma.array(arr.mean(-1),dt,fill_value=nodata)
        if not is_ma: arr=ma.filled(arr)
        if is_rA:
            gi["dx"]=gi["dx"]*n_xmerge
            gi["dy"]=gi["dy"]*n_ymerge
    if is_rA: return rasterArr(arr,gi,nodata)
    else: return arr


##############################
## NONEQUIDISTANT FUNCTIONS ##
##############################

def rA_nonequi2equi(rA,dx=None,dy=None):
    """Function to resample a non-equidistant raster to an equidistant raster.

    Parameters
    ----------
    rA : rasterArr object

    dx : float, int or None (optional)
        Cell size in x direction (column width).

        If *dx* is None then the minimum column width of the non-equidistant raster is used.

    dy : float, int or None (optional)
        Cell size in y direction (row height).

        If *dy* is None then the minimum row height of the non-equidistant raster is used.

    Returns
    -------
    result : rasterArr object
    """
    if rA.ieq() == 0:

        if dx == None and dy == None:

            arr=rA.copy()

        else:

            if dx == None:
                dx=rA.dx()
            if dy == None:
                dy=rA.dy()

            gi2=gi_set_dxdy(rA.gi(),dx,dy)
            arr=rA.rescale(gi2,"sample")

    else:

        if dx == None:
            dx=rA.dx().min()
        if dy == None:
            dy=rA.dy().min()

        gi2=[rA.xll(),rA.yll(),dx,dy,int(rA.Dy()/dy+0.01*dy),int(rA.Dx()/dx+0.01*dx),rA.proj(),rA.ang(),rA.crs()]
        gi2=gi2dict(gi2)

        ## x1
        if type(rA.gi()["dx"]) not in [int,float]:
            dx=np.array(rA.gi()["dx"].copy(),float64)
        else:
            dx=np.ones((rA.gi()["ncol"],),float64)*rA.gi()["dx"]
        dx=np.insert(add.accumulate(dx),0,[0.0],0)
        x1=rA.gi()["xll"]+dx

        ## x2
        if type(gi2["dx"]) not in [int,float]:
            dx=np.array(gi2["dx"].copy(),float64)
        else:
            dx=np.ones((gi2["ncol"],),float64)*gi2["dx"]
        dx=np.insert(add.accumulate(dx),0,[0.0],0)
        x2=gi2["xll"]+dx
        x2=0.5*(x2[1:]+x2[:-1])

        ## xi
        xi=np.array(np.interp(x2,x1,np.arange(0,len(x1)),-1,-1),int32)
        xi=np.repeat(xi.reshape((1,len(xi))),gi2["nrow"],0)

        ## y1
        yur=gi_get_yur(rA.gi())
        if type(rA.gi()["dy"]) not in [int,float]:
            dy=np.array(rA.gi()["dy"].copy(),float64)
        else:
            dy=np.ones((rA.gi()["nrow"],),float64)*rA.gi()["dy"]
        dy=np.insert(add.accumulate(dy),0,[0.0],0)
        if rA.gi()["proj"] == 1:
            y1=yur-dy
        else:
            y1=yur+dy

        ## y2
        yur=gi_get_yur(gi2)
        if type(gi2["dy"]) not in [int,float]:
            dy=np.array(gi2["dy"].copy(),float64)
        else:
            dy=np.ones((gi2["nrow"],),float64)*gi2["dy"]
        dy=np.insert(add.accumulate(dy),0,[0.0],0)
        if gi2["proj"] == 1:
            y2=yur-dy
        else:
            y2=yur+dy
        y2=0.5*(y2[:-1]+y2[1:])

        ## yi
        if rA.gi()["proj"] == 1:
            yi=np.array(np.interp(y2,y1[::-1],np.arange(0,len(y1))[::-1],-1,-1),int32)
        else:
            yi=np.array(np.interp(y2,y1,np.arange(0,len(y1)),-1,-1),int32)
        yi=np.repeat(yi.reshape((len(yi),1)),gi2["ncol"],1)

        arr=rasterArr(rA[yi,xi],gi2,rA.nodata())
        msk=arr.mask()
        msk[xi == -1]=True
        msk[yi == -1]=True
        arr.set_mask(msk,True)
        arr.set_nodata(rA.nodata())

    return arr


##############################
## (RE)PROJECTION FUNCTIONS ##
##############################

def prj2crs(f_prj,epsg=True):
    """Function to create EPSG or WKT string from prj file.

    Parameters
    ----------
    f_prj : str
        File name of prj file.

    Returns
    -------
    wkt : str
    """
    wkt=""
    if os.path.isfile(f_prj):
        inf=open(f_prj); crs=inf.read().strip(); inf.close()
        wkt=crs2wkt(crs,crs)
    if epsg:
        return crs2epsg(wkt,wkt)
    else:
        return wkt

def crs2prj(f_prj,crs):
    """Function to write crs as WKT to prj file.

    Parameters
    ----------
    f_prj : str
        File name of prj file.

        Extension of the file is replaced by '.prj'.

    crs : int or str
        Crs reference.

        One of the following forms:

        Integer: EPSG reference number.

        String: 'EPSG:i' where i denotes a EPSG reference number.

        String: 'UTMiC' where i denotes a UTM zone number and C denotes 'N' or 'S' for the hemisphere.

        String: GDAL's so called WellKnownGeogCS string, e.g. 'WGS84'.

        String: Ohter recognized strings are: 'amersfoort', 'rd', 'gda94', 'gda94_vicgrid'

        String: WKT string
    """
    outf=open("%s.prj" %(os.path.splitext(f_prj)[0]),"w")
    outf.write("%s\n" %(crs2wkt(crs,crs)))
    outf.close()

def crs2wkt(crs,alt=""):
    """Function to create WKT string from a crs reference.

    Parameters
    ----------
    crs : int or str
        Crs reference.

        One of the following forms:

        Integer: EPSG reference number.

        String: 'EPSG:i' where i denotes a EPSG reference number.

        String: 'UTMiC' where i denotes a UTM zone number and C denotes 'N' or 'S' for the hemisphere.

        String: GDAL's so called WellKnownGeogCS string, e.g. 'WGS84'.

        String: Ohter recognized strings are: 'amersfoort', 'rd', 'gda94', 'gda94_vicgrid'

        String: WKT string

    alt : str (optional)
        Alternative string to be returned if *crs* could not be converted to WKT.

    Returns
    -------
    wkt : str

    See Also
    --------
    :ref:`projection`
    """
    if type(crs) == type(None):
        crs=""
    if type(crs) == str:
        crs=crs.strip()
    if alt == None: alt=""
    utm=None

    try:
        l_crs=[["amersfoort","rd" ,"gda94","gda94_vicgrid"],\
               [28992       ,28992,4283   , 3111]]
        if crs.lower() in l_crs[0]:
            crs="EPSG:%d" %(l_crs[1][l_crs[0].index(crs.lower())])
        else:
            raise
    except:
        try:
            if crs[:3].lower() == "utm":
                utm=crs[3:].lower()
                utm=[int(utm[:-1]),["s","n"].index(utm[-1])]
                crs="WGS84"
            else:
                raise
        except:
            try:
                crs=int(crs)
                crs="EPSG:%d" %(crs)
            except:
                pass

    crs0=osgeo.osr.SpatialReference()
    crs0.SetFromUserInput(crs)
    wkt=crs0.ExportToWkt()
    if wkt == "":
        wkt=alt
    elif utm != None:
        crs0.SetUTM(utm[0],utm[1])
        wkt=crs0.ExportToWkt()

    return wkt

def crs2epsg(crs,alt=""):
    """Function to create EPSG string from a crs reference.

    Parameters
    ----------
    crs : int or str
        Crs reference.

        One of the following forms:

        Integer: EPSG reference number.

        String: 'EPSG:i' where i denotes a EPSG reference number.

        String: 'UTMiC' where i denotes a UTM zone number and C denotes 'N' or 'S' for the hemisphere.

        String: GDAL's so called WellKnownGeogCS string, e.g. 'WGS84'.

        String: Ohter recognized strings are: 'amersfoort', 'rd', 'gda94', 'gda94_vicgrid'

        String: WKT string

    alt : str (optional)
        Alternative string to be returned if *crs* could not be converted to WKT.

    Returns
    -------
    epsg : str
        'EPSG:i' string or 'UTMiC' string.

    See Also
    --------
    :ref:`projection`
    """
    try:
        wkt=crs2wkt(crs,alt=alt)
        crs=osgeo.osr.SpatialReference()
        crs.ImportFromWkt(wkt)
        try:
            utmzone=crs.GetUTMZone()
            if utmzone in [0,None]:
                raise
            if string.find(crs.GetAttrValue("PROJCS",0).lower(),"southern") != -1:
                return "UTM%dS" %(utmzone)
            else:
                return "UTM%dN" %(utmzone)
        except:
            pass
        epsg=crs.GetAttrValue("AUTHORITY",1)
        if epsg in ["",None]:
            raise
        return "EPSG:%s" %(epsg)
    except:
        return alt

def same_crs(crs1,crs2):
    """Function to check if two crs references are the same.

    Parameters
    ----------
    crs1 : int or str
        First crs reference.

        One of the following forms:

        Integer: EPSG reference number.

        String: 'EPSG:i' where i denotes a EPSG reference number.

        String: 'UTMiC' where i denotes a UTM zone number and C denotes 'N' or 'S' for the hemisphere.

        String: GDAL's so called WellKnownGeogCS string, e.g. 'WGS84'.

        String: Ohter recognized strings are: 'amersfoort', 'rd', 'gda94', 'gda94_vicgrid'

        String: WKT string

    crs2 : int or str
        Second crs reference.

        See *crs1* for the possible forms.

    Returns
    -------
    result : bool
        True = crs references are the same.

        False = crs references are not the same.

    See Also
    --------
    :ref:`projection`
    """
    c1=osgeo.osr.SpatialReference(); c1.ImportFromWkt(crs2wkt(crs1))
    c2=osgeo.osr.SpatialReference(); c2.ImportFromWkt(crs2wkt(crs2))
    if c1.IsSame(c2) == 1:
        return True
    else:
        return False

def reproject_rA(rA,to_crs,from_crs=None,method="sample",xyur=None):
    """Function to reproject a rasterArr object.

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    rA : rasterArr object

    to_crs : str, int, list or dict
        Target crs.

        If this is a list or a dict it is interpreted as geographical information from which the crs, extent and cell size are taken.

    from_crs : str, int, list, dict or None (optional)
        Source crs. Will be used if the crs of the raster is not specified.

        If this is a list or a dict it is interpreted as geographical information from which the crs is taken.

    method : str or None (optional)
        The reprojecting method. Possible methods are:
        'sample' or 'near', 'bilinear', 'cubic', 'cubicspline', 'lanczos', 'mean' or 'average', 'mode', None.

    xyur : list or None (optional)
        X and Y coordinates of upper right corner. May be used by gdalwarp if to_crs is geographical information, but xur and yur could not be calculated (e.g. because dx and dy are None).

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`projection`
    """
    if from_crs == None and rA.crs() not in ["",None]:
        from_crs=rA.crs()
    elif type(from_crs) == list:
        try: from_crs=from_crs[8]
        except: pass
    elif type(from_crs) == dict:
        try: from_crs=from_crs["crs"]
        except: pass

    to_gi=None
    if type(to_crs) == list:
        try:
            to_gi=gi2dict(to_crs)
            to_crs=to_crs[8]
        except:
            to_gi=None
    elif type(to_crs) == dict:
        try:
            to_gi=gi2dict(to_crs)
            to_crs=to_crs["crs"]
        except:
            to_gi=None

    if to_crs in [None,""]:
        to_crs=from_crs
    if from_crs in [None,""]:
        from_crs=to_crs
    from_crs=crs2wkt(from_crs,"")
    to_crs=crs2wkt(to_crs,"")

    lut_method=[['sample','near','bilinear','cubic','cubicspline','lanczos','mean',   'average','mode',None],\
                ['near',  'near','bilinear','cubic','cubicspline','lanczos','average','average','mode',None],\
                [0,       0,     1,         2,      3,             4,       5,        5,        6,     0]]
    if method in lut_method[0]:
        method=lut_method[1][lut_method[0].index(method)]
    else:
        raise Exception, "ERROR: method '%s' not possible with reproject_rA." %(method)
        method='near'
    if method == None:
        try:
            to_gi["dx"]=None
            to_gi["dy"]=None
        except:
            pass
        method='near'

    try:

        if to_gi != None:
            rA2=warp_rA(rA,to_gi,from_crs,method=method,xyur=xyur)
        else:
            rA2=warp_rA(rA,to_crs,from_crs,method=method,xyur=xyur)
        return rA2

    except:

        if to_gi != None:
            if max([to_gi[key] == None for key in ["xll","yll","dx","dy","nrow","ncol"]]):
                to_gi=None

        l_data_type=[["Byte","UInt16","Int16","UInt32","Int32","Float32","Float64","CInt16","CInt32","CFloat32","CFloat64"],\
                     [osgeo.gdal.GDT_Byte,osgeo.gdal.GDT_UInt16,osgeo.gdal.GDT_Int16,osgeo.gdal.GDT_UInt32,osgeo.gdal.GDT_Int32,osgeo.gdal.GDT_Float32,osgeo.gdal.GDT_Float64,osgeo.gdal.GDT_CInt16,osgeo.gdal.GDT_CInt32,osgeo.gdal.GDT_CFloat32,osgeo.gdal.GDT_CFloat64],\
                     [uint8,uint16,int16,uint32,int32,float32,float64,int16,int32,float32,float64],\
                     ["B","H","h","L","l","f","d","h","l","f","d"]]

        arr=np.array(rA.arr.data.copy())
        if arr.dtype == float16:
            arr=np.array(arr,float32)
        elif arr.dtype == int8:
            arr=np.array(arr,int16)

        gd1=osgeo.gdal.GetDriverByName("MEM").Create("",rA.ncol(),rA.nrow(),1,l_data_type[1][l_data_type[2].index(arr.dtype)])
        rot1,rot2=0,0
        if rA.proj() == 0: gd1.SetGeoTransform([rA.xll(),rA.dx(),rot1,rA.yur(),rot2,rA.dy()])
        else: gd1.SetGeoTransform([rA.xll(),rA.dx(),rot1,rA.yur(),rot2,-rA.dy()])
        gd1.SetProjection(from_crs)
        gd1.GetRasterBand(1).WriteArray(arr)
        gd1.GetRasterBand(1).SetNoDataValue(rA.nodata())

        if to_gi == None:
            gd2=osgeo.gdal.AutoCreateWarpedVRT(gd1,from_crs,to_crs)
        else:
            gd2=osgeo.gdal.GetDriverByName("MEM").Create("",to_gi["ncol"],to_gi["nrow"],1,l_data_type[1][l_data_type[2].index(arr.dtype)])
            if to_gi["proj"] == 0: gd2.SetGeoTransform([to_gi["xll"],to_gi["dx"],rot1,gi_get_yur(to_gi),rot2,to_gi["dy"]])
            else: gd2.SetGeoTransform([to_gi["xll"],to_gi["dx"],rot1,gi_get_yur(to_gi),rot2,-to_gi["dy"]])
            gd2.SetProjection(to_crs)

        method=lut_method[2][lut_method[1].index(method)]
        osgeo.gdal.ReprojectImage(gd1,gd2,from_crs,to_crs,method)

        nlay,nrow,ncol=gd2.RasterCount,gd2.RasterYSize,gd2.RasterXSize
        xll,dx,rot1,yul,rot2,dy=gd2.GetGeoTransform()
        dx,dy=abs(dx),abs(dy)
        yll=yul-nrow*dy
        layer=gd2.GetRasterBand(1)
        i_data_type=l_data_type[0].index(osgeo.gdal.GetDataTypeName(layer.DataType))
        data=layer.ReadRaster(0,0,ncol,nrow,ncol,nrow,l_data_type[1][i_data_type])
        arr=np.reshape(np.array(struct.unpack("%d%s" %(ncol*nrow,l_data_type[3][i_data_type]),data),dtype=l_data_type[2][i_data_type]),(nrow,ncol))
        nodata=layer.GetNoDataValue()

        del gd1,gd2,layer
        return rasterArr(arr,[xll,yll,dx,dy,nrow,ncol,1,0.0,to_crs],nodata)

def warp_rA(rA,to_crs,from_crs=None,exe_warp=None,method="sample",screen_output=False,xyur=None):
    """Function to reproject a rasterArr object by using gdalwarp.

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    rA : rasterArr object

    to_crs : str, int, list or dict
        Target crs.

        If this is a list or a dict it is interpreted as geographical information from which the crs, extent and cell size are taken.

    from_crs : str, int, list, dict or None (optional)
        Source crs. Will be used if the crs of the raster is not specified.

        If this is a list or a dict it is interpreted as geographical information from which the crs is taken.

    exe_warp : str or None (optional)
        File name of the gdalwarp executable. If *exe_warp* is None then 'gdalwarp' is used; this only works if 'gdalwarp' is known to the system (e.g. in the PATH environment).

    method : str or None (optional)
        The reprojecting method. Possible methods are:
        'sample' or 'near', 'bilinear', 'cubic', 'cubicspline', 'lanczos', None.

    screen_output : bool (optional)
        True = output of gdal's process to the screen.
        False = no output of gdal's process to the screen.

    xyur : list or None (optional)
        X and Y coordinates of upper right corner. May be used by gdalwarp if to_crs is geographical information, but xur and yur could not be calculated (e.g. because dx and dy are None).

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`projection`
    """
    try:
        if from_crs == None and rA.crs() not in ["",None]:
            from_crs=rA.crs()
        elif type(from_crs) == list:
            try: from_crs=from_crs[8]
            except: pass
        elif type(from_crs) == dict:
            try: from_crs=from_crs["crs"]
            except: pass

        to_gi=None
        if type(to_crs) == list:
            try:
                to_gi=gi2dict(to_crs)
                to_crs=to_crs[8]
            except:
                to_gi=None
        elif type(to_crs) == dict:
            try:
                to_gi=gi2dict(to_crs)
                to_crs=to_crs["crs"]
            except:
                to_gi=None

        if to_crs in [None,""]:
            to_crs=from_crs
        if from_crs in [None,""]:
            from_crs=to_crs
        from_crs=crs2wkt(from_crs,"")
        to_crs=crs2wkt(to_crs,"")

        if to_gi != None:
            xur,yur=gi_get_xur(to_gi),gi_get_yur(to_gi)
            if xur == None:
                try: xur=xyur[0]
                except: xur=None
            if yur == None:
                try: yur=xyur[1]
                except: yur=None

        ##if crs2epsg(to_crs) in ["EPSG:102030"]:
        ##    raise Exception, "CRS %s not possible in function 'warp_rA'" %(crs2epsg(to_crs))

        lut_method=[['sample','near','bilinear','cubic','cubicspline','lanczos',None],\
                    ['near',  'near','bilinear','cubic','cubicspline','lanczos',None]]
        if method in lut_method[0]:
            method=lut_method[1][lut_method[0].index(method)]
        else:
            raise Exception, "ERROR: method '%s' not possible with gdalwarp." %(method)
        if method == None:
            try:
                to_gi["dx"]=None
                to_gi["dy"]=None
            except:
                pass
            method='near'

        if exe_warp == None:
            exe_warp="gdalwarp"

        tmp=tempfile.mkdtemp(prefix='warp_rA_')
        cwd=os.getcwd()
        os.chdir(tmp)

        args=[exe_warp]

        if from_crs != "" and to_crs != "":
            epsg=crs2epsg(from_crs,"")
            if epsg != "" and str(epsg)[:3].upper() != "UTM":
                args+=["-s_srs","%s" %(epsg)]
            else:
                outf=open(r"%s\in.prj" %(tmp),"w"); outf.write(from_crs); outf.close()
                args+=["-s_srs","in.prj"]
            epsg=crs2epsg(to_crs,"")
            if epsg != "" and str(epsg)[:3].upper() != "UTM":
                args+=["-t_srs","%s" %(epsg)]
            else:
                outf=open(r"%s\out.prj" %(tmp),"w"); outf.write(to_crs); outf.close()
                args+=["-t_srs","out.prj"]

        args+=["-srcnodata",'"%s"' %(rA.nodata()),"-dstnodata",'"%s"' %(rA.nodata()),"-r",method]

        try:
            if to_gi["xll"] != None and to_gi["yll"] != None and xur != None and yur != None:
                args+=["-te",to_gi["xll"],min(to_gi["yll"],yur),xur,max(to_gi["yll"],yur)]
        except:
            pass
        try:
            if to_gi["dx"] != None and to_gi["dy"] != None:
                args+=["-tr",to_gi["dx"],to_gi["dy"]]
        except:
            pass

        rA.write(r"%s\in.tif" %(tmp))
        args+=["-of","VRT","in.tif","out.vrt"]

        args=[str(a) for a in args]

        if screen_output:
            subprocess.call(args)
        else:
            subprocess.check_output(args)
        rA2=raster2arr("out.vrt")

        if not same_crs(rA2.crs(),to_crs) and crs2epsg(to_crs,"") != "":
            rA2.set_gi(crs=crs2epsg(to_crs,""))

        os.chdir(cwd)

        return rA2

    except:
        raise Exception, traceback.format_exc()

    finally:
        try: os.chdir(cwd)
        except: pass
        try: shutil.rmtree(tmp)
        except: pass


###########################
## CONDITIONAL FUNCTIONS ##
###########################

def if_then(if_statement,then_statement):
    """Function to perform a conditional operation (if-then).

    Same as ``if_then_else(..)`` function without an *else* statement.

    At least one of the *if* and *then* statements should be a rasterArr object.

    If needed rescaling/resampling is performed using the global method (see :ref:`rescaling_resampling`).
    If more than one statement is a rasterArr object the geographical information dict for rescaling/resampling is taken from one of them in the following prefered order: *then*, *if*.

    The datatype of the result is based on the datatype of the *then* statement.

    Parameters
    ----------
    if_statement : rasterArr object, single numerical value, numpy array or array_like (boolean or boolean_like)
        The *if* statement.

    then_statement : rasterArr object, single numerical value, numpy array or array_like
        The *then* statement.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`conditionals`
    :func:`raster_func.if_then_else`
    """
    return if_then_else(if_statement,then_statement,None)

def if_then_else(if_statement,then_statement,else_statement=None):
    """Function to perform a conditional operation (if-then-else).

    At least one of the *if*, *then* and *else* statements should be a rasterArr object.

    If needed rescaling/resampling is performed using the global method (see :ref:`rescaling_resampling`).
    If more than one statement is a rasterArr object the geographical information dict for rescaling/resampling is taken from one of them in the following prefered order: *then*, *else*, *if*.

    The datatype of the result is based on the datatype of the *then* statement.

    Parameters
    ----------
    if_statement : rasterArr object, single numerical value, numpy array or array_like (boolean or boolean_like)
        The *if* statement.

    then_statement : rasterArr object, single numerical value, numpy array or array_like
        The *then* statement.

    else_statement : rasterArr object, single numerical value, numpy array or array_like
        The *else* statement.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`conditionals`
    :func:`raster_func.if_then`
    """
    try:

        method=get_global_method()

        IF,THEN,ELSE=deepcopy(if_statement),deepcopy(then_statement),deepcopy(else_statement)
        try: to_gi,nodata=THEN.gi(),THEN.nodata()
        except:
            try: to_gi,nodata=ELSE.gi(),ELSE.nodata()
            except:
                try: to_gi,nodata=IF.gi(),IF.nodata()
                except: raise Exception, "ERROR: IF, THEN and ELSE are all not a rasterArr object"
        dt=_get_min_dtype(THEN,ELSE,nodata)
        dt=int32

        try:
            IF.gi(); IF=(rescale_rA(IF,to_gi,method=method).bool()).arr
        except:
            try:
                IF.dtype
                if IF.ndim == 0:
                    IF=ma.resize(IF,(to_gi["nrow"],to_gi["ncol"]))
                IF=ma.array(IF,bool)
            except:
                IF=ma.array(IF*ma.ones((to_gi["nrow"],to_gi["ncol"])),bool)
        if IF.mask.ndim == 0:
            IF.mask=np.ones(IF.shape,bool)*IF.mask

        try:
            THEN.gi(); THEN=rescale_rA(THEN,to_gi,method=method).arr
        except:
            try:
                THEN.dtype
                if THEN.ndim == 0:
                    THEN=ma.resize(THEN,(to_gi["nrow"],to_gi["ncol"]))
                THEN=ma.array(THEN,dtype=dt)
            except:
                THEN=ma.array(THEN*ma.ones((to_gi["nrow"],to_gi["ncol"]),dtype=dt))
        if THEN.mask.ndim == 0:
            THEN.mask=np.ones(THEN.shape,bool)*THEN.mask
        THEN.mask[IF == False]=True

        if type(ELSE) != type(None):
            try:
                ELSE.gi(); ELSE=rescale_rA(ELSE,to_gi,method=method).arr
            except:
                try:
                    ELSE.dtype
                    if ELSE.ndim == 0:
                        ELSE=ma.resize(ELSE,(to_gi["nrow"],to_gi["ncol"]))
                    ELSE=ma.array(ELSE,dtype=dt)
                except:
                    ELSE=ma.array(ELSE*ma.ones((to_gi["nrow"],to_gi["ncol"]),dtype=dt))
            if ELSE.mask.ndim == 0:
                ELSE.mask=np.ones(ELSE.shape,bool)*ELSE.mask
            ELSE.mask[IF == True]=True

            THEN.mask[IF == False]=ELSE.mask[IF == False]
            THEN.data[IF == False]=ELSE.data[IF == False]

        THEN.mask[IF.mask]=True

        return rasterArr(THEN,to_gi,nodata)

    except Exception, err:
        print err
        return None


##########################
## STATISTICS FUNCTIONS ##
##########################

def rasters_mean(rA,*args):
    """Function to calculate the mean of two or more rasters (or numpy arrays, floats, ints).

    Parameters
    ----------
    rA : rasterArr object

    args : rasterArr object(s), numpy array(s), float(s), int(s)
        Arbitrary number of arguments.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`statistics`
    """
    if len(args) == 0:
        return rA
    gi=rA.gi()
    nodata=rA.nodata()
    msk=rA.arr.mask.copy()
    arr=rA.arr.data.copy()
    for arg in args:
        try:
            arg=arg.rescale(to_gi=gi)
            msk=np.maximum(msk,arg.arr.mask)
            arg=arg.arr.data
        except:
            try:
                msk=np.maximum(msk,arg.mask)
                arg=arg.data
            except:
                pass
        arr+=arg
    arr/=(len(args)+1)
    arr[msk]=nodata
    return rasterArr(ma.array(arr,mask=msk),gi,nodata)

def rasters_min(rA,*args):
    """Function to calculate the minimum of two or more rasters (or numpy arrays, floats, ints).

    Parameters
    ----------
    rA : rasterArr object

    args : rasterArr object(s), numpy array(s), float(s), int(s)
        Arbitrary number of arguments.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`statistics`
    """
    if len(args) == 0:
        return rA
    gi=rA.gi()
    nodata=rA.nodata()
    msk=rA.arr.mask.copy()
    arr=rA.arr.data.copy()
    for arg in args:
        try:
            arg=arg.rescale(to_gi=gi)
            msk=np.maximum(msk,arg.arr.mask)
            arg=arg.arr.data
        except:
            try:
                msk=np.maximum(msk,arg.mask)
                arg=arg.data
            except:
                pass
        arr=np.minimum(arr,arg)
    arr[msk]=nodata
    return rasterArr(ma.array(arr,mask=msk),gi,nodata)

def rasters_max(rA,*args):
    """Function to calculate the maximum of two or more rasters (or numpy arrays, floats, ints).

    Parameters
    ----------
    rA : rasterArr object

    args : rasterArr object(s), numpy array(s), float(s), int(s)
        Arbitrary number of arguments.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`statistics`
    """
    if len(args) == 0:
        return rA
    gi=rA.gi()
    nodata=rA.nodata()
    msk=rA.arr.mask.copy()
    arr=rA.arr.data.copy()
    for arg in args:
        try:
            arg=arg.rescale(to_gi=gi)
            msk=np.maximum(msk,arg.arr.mask)
            arg=arg.arr.data
        except:
            try:
                msk=np.maximum(msk,arg.mask)
                arg=arg.data
            except:
                pass
        arr=np.maximum(arr,arg)
    arr[msk]=nodata
    return rasterArr(ma.array(arr,mask=msk,fill_value=nodata),gi,nodata)


########################################################################
## EXTRACTING CELL VALUES BASED ON X,Y COORDINATES OR ROW,COL INDICES ##
########################################################################

def xy_arr2val(xy,rA,interpolate=False):
    """Function to extract cell values of a rasterArr object using x,y coordinates.

    It is possible to enable linear interpolation from cell centers to the exact x,y location(s).

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    xy : array or array_like (2-D)
        A 2xN array/matrix with the x,y coordinates.

    rA : rasterArr object

    interpolate : bool
        Flag for linear interpolation from cell centers to x,y location(s).

        True = enable linear interpolation

        False = disable linear interpolation

    Returns
    -------
    result : numpy array (MaskedArray)
    """
    rc=xy2rc(xy,rA.gi())
    arr=rc_arr2val(rc,rA)

    if interpolate:

        r=np.reshape(rc[0],rc.shape[1:]+(1,))
        r=np.ravel(np.repeat(np.concatenate([r-1,r,r+1],1),3,-1))
        c=np.reshape(rc[1],rc.shape[1:]+(1,))
        c=np.ravel(np.repeat(np.concatenate([c-1,c,c+1],1),3,-2))

        xy9=np.reshape(rc2xy([r,c],rA.gi()),(2,len(r)/9,9))

        arr9=ma.reshape(rc_arr2val([r,c],rA),(len(r)/9,9))

        for i in range(0,len(xy[0])):
            if not arr.mask[i]:
                fx=np.maximum(rA.dx()-np.abs(xy9[0][i]-xy[0][i]),0)
                fy=np.maximum(rA.dy()-np.abs(xy9[1][i]-xy[1][i]),0)
                fxy=fx*fy
                fxy[arr9[i].mask]=0
                arr[i]=(arr9[i]*fxy).sum()/fxy.sum()

    return arr

def rc_arr2val(rc,rA):
    """Function to extract cell values of a rasterArr object using row,col indices.

    Parameters
    ----------
    rc : array or array_like (2-D)
        A 2xN array with the row,col indices. Indices follow Python standard, i.e. starting at 0.

    rA : rasterArr object

    Returns
    -------
    result : numpy array (MaskedArray)
    """
    arr_nodata=np.maximum(np.maximum(rc[0] >= rA.nrow(),rc[0] < 0),np.maximum(rc[1] >= rA.ncol(),rc[1] < 0))
    rc[0][np.maximum(rc[0] >= rA.nrow(),rc[0] < 0)]=0
    rc[1][np.maximum(rc[1] >= rA.ncol(),rc[1] < 0)]=0
    arr=rA[rc[0],rc[1]]
    arr[arr_nodata]=rA.nodata()
    arr.mask[arr_nodata]=True
    return arr


#####################################################################
## SETTING CELL VALUES BASED ON X,Y COORDINATES OR ROW,COL INDICES ##
#####################################################################

def xy_val2arr(xy,val,rA):
    """Function to set cell values of a rasterArr object using x,y coordinates.

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    xy : array or array_like (2-D)
        A 2xN array/matrix with the x,y coordinates.

    val : int, float, array or array_like (1-D)
        Value(s) to set. Single value or array of values for each x,y coordinate.

    rA : rasterArr object

    Returns
    -------
    result : rasterArr object
    """
    rc=xy2rc(xy,rA.gi())
    return rc_val2arr(rc=rc,val=val,rA=rA)

def rc_val2arr(rc,val,rA):
    """Function to set cell values of a rasterArr object using row,col indices.

    Parameters
    ----------
    rc : array or array_like (2-D)
        A 2xN array with the row,col indices. Indices follow Python standard, i.e. starting at 0.

    val : int, float, array or array_like (1-D)
        Value(s) to set. Single value or array of values for each x,y coordinate.

    rA : rasterArr object

    Returns
    -------
    result : rasterArr object
    """
    arr=rA.arr.copy()
    cp=(rc[0] >= 0)*(rc[0] < rA.nrow())*(rc[1] >= 0)*(rc[1] < rA.ncol())
    if cp.sum() > 0:
        r,c=rc[0][cp],rc[1][cp]
        try: val=np.array(val)[cp]
        except: pass
        arr.data[rc[0],rc[1]]=val
        arr.data[arr.mask]=rA.nodata()
    return rasterArr(arr,rA.gi(),rA.nodata())


################################################################################
## DIRECT READING / MEMORY MAPPING >> ONLY FOR EQUIDISTANT IDF / PCRASTER MAP ##
################################################################################

def xy_idf2val(xy,f,nodata=None,interpolate=False):
    """Function to extract cell values of an iMOD IDF file using x,y coordinates.

    It is possible to enable linear interpolation from cell centers to the exact x,y location(s).

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    xy : array or array_like (2-D)
        A 2xN array/matrix with the x,y coordinates.

    f : str
        Input IDF file.

    nodata : float, int or None (optional)
        Nodata value to be applied.

    interpolate : bool (optional)
        Flag for linear interpolation from cell centers to x,y location.

        True = enable linear interpolation

        False = disable linear interpolation

    Returns
    -------
    result : numpy array

    See Also
    --------
    :ref:`memory_mapping`
    """
    l_mm=_idf2mm(f)
    arr=_xy_mm2val(xy,l_mm,nodata,interpolate)
    _close_infmm(l_mm[2])
    return arr

def rc_idf2val(rc,f,nodata=None,consecutive=False):
    """Function to extract cell values of an iMOD IDF file using row,col indices.

    Parameters
    ----------
    rc : array or array_like (2-D)
        A 2xN array/matrix with the row,col indices. Indices follow Python standard, i.e. starting at 0.

    f : str
        Input IDF file.

    nodata : float, int or None (optional)
        Nodata value to be applied.

    consecutive : bool (optional)
        True = specified cells form a consecutive series of cells

        False = specified cells do not form a consecutive series of cells

    Returns
    -------
    result : numpy array

    See Also
    --------
    :ref:`memory_mapping`
    """
    l_mm=_idf2mm(f)
    arr=_rc_mm2val(rc,l_mm,nodata,consecutive)
    _close_infmm(l_mm[2])
    return arr

def xy_map2val(xy,f,nodata=None,interpolate=False):
    """Function to extract cell values of a PCRaster file using x,y coordinates.

    Does not work on non-equidistant rasters.

    Parameters
    ----------
    xy : array or array_like (2-D)
        A 2xN array/matrix with the x,y coordinates.

    f : str
        Input PCRaster file.

    nodata : float, int or None (optional)
        Nodata value to be applied.

    interpolate : bool
        Flag for linear interpolation from cell centers to x,y location.

        True = enable linear interpolation

        False = disable linear interpolation

    Returns
    -------
    result : numpy array

    See Also
    --------
    :ref:`memory_mapping`
    """
    return xy_idf2val(xy,f,nodata,interpolate)

def rc_map2val(rc,f,nodata=None,consecutive=False):
    """Function to extract cell values of a PCRaster file using row,col indices.

    Parameters
    ----------
    rc : array or array_like (2-D)
        A 2xN array/matrix with the row,col indices. Indices follow Python standard, i.e. starting at 0.

    f : str
        Input PCRaster file.

    nodata : float, int or None (optional)
        Nodata value to be applied.

    consecutive : bool (optional)
        True = specified cells form a consecutive series of cells

        False = specified cells do not form a consecutive series of cells

    Returns
    -------
    result : numpy array

    See Also
    --------
    :ref:`memory_mapping`
    """
    return rc_idf2val(rc,f,nodata,consecutive)


def xy_val2idf(xy,val,f):
    """Function to write cell values to an existing iMOD IDF file using x,y coordinates.

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    xy : array or array_like (2-D)
        A 2xN array/matrix with the x,y coordinates.

    val : array or array_like (1-D)
        An array/matrix with the values. The values are converted to meet the data type of the IDF file.

    f : str
        Input IDF file.

    See Also
    --------
    :ref:`memory_mapping`
    """
    l_mm=_idf2mm(f,"r+b")
    rc=xy2rc(xy,l_mm[1])
    _rc_val2mm(rc,val,l_mm)
    _close_infmm(l_mm[2])

def rc_val2idf(rc,val,f,consecutive=False):
    """Function to write cell values to an existing iMOD IDF file using row,col indices.

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    rc : array or array_like (2-D)
        A 2xN array/matrix with the row,col indices. Indices follow Python standard, i.e. starting at 0.

    val : array or array_like (1-D)
        An array/matrix with the values. The values are converted to meet the data type of the IDF file.

    f : str
        Input IDF file.

    consecutive : bool (optional)
        True = specified cells form a consecutive series of cells

        False = specified cells do not form a consecutive series of cells

    See Also
    --------
    :ref:`memory_mapping`
    """
    l_mm=_idf2mm(f,"r+b")
    _rc_val2mm(rc,val,l_mm,consecutive)
    _close_infmm(l_mm[2])

def xy_val2map(xy,val,f):
    """Function to write cell values to an existing PCRaster file using x,y coordinates.

    Parameters
    ----------
    xy : array or array_like (2-D)
        A 2xN array/matrix with the x,y coordinates.

    val : array or array_like (1-D)
        An array/matrix with the values. The values are converted to meet the data type of the PCRaster file.

    f : str
        Input PCRaster file.

    See Also
    --------
    :ref:`memory_mapping`
    """
    xy_val2idf(xy,val,f)

def rc_val2map(rc,val,f,consecutive=False):
    """Function to write cell values to an existing PCRaster file using row,col indices.

    Parameters
    ----------
    rc : array or array_like (2-D)
        A 2xN array/matrix with the row,col indices. Indices follow Python standard, i.e. starting at 0.

    val : array or array_like (1-D)
        An array/matrix with the values. The values are converted to meet the data type of the PCRaster file.

    f : str
        Input PCRaster file.

    consecutive : bool (optional)
        True = specified cells form a consecutive series of cells

        False = specified cells do not form a consecutive series of cells

    See Also
    --------
    :ref:`memory_mapping`
    """
    rc_val2idf(rc,val,f,consecutive)

def _idf2mm(f,access="r"):
    """Function to get raster info and create mmap instance of an iMOD IDF file.
    """
    raster_info,gi=_raster2info(f)
    inf,mm=None,None
    if raster_info[0] in [2,3,l_raster_format_str[2],l_raster_format_str[3]]:
        if access.lower() in ["w","wb","r+","r+b"]:
            inf=open(f,"r+b")
            mm=mmap.mmap(inf.fileno(),0,access=mmap.ACCESS_WRITE)
        else:
            inf=open(f,"rb")
            mm=mmap.mmap(inf.fileno(),0,access=mmap.ACCESS_READ)
    if raster_info[4] == None:
        try: raster_info[4]=raster_info[6][1]-1
        except: raster_info[4]=-999999
    return raster_info,gi,[inf,mm]

def _map2mm(f):
    """Function to get raster info and create mmap instance of an PCRaster file.
    """
    return _idf2mm(f)

def _xy_mm2val(xy,l_mm,nodata=None,interpolate=False): # xy: 2xN matrix; l_mm: {raster_info,geo_info,[inf,mm]}
    """Function to get values from raster info and mmap instance using x,y coordinates.
    """

    rc=xy2rc(xy,l_mm[1])
    arr=_rc_mm2val(rc,l_mm,nodata)

    if interpolate:

        if nodata == None: nodata=l_mm[0][4]

        r=np.reshape(rc[0],rc.shape[1:]+(1,))
        r=np.ravel(np.repeat(np.concatenate([r-1,r,r+1],1),3,-1))
        c=np.reshape(rc[1],rc.shape[1:]+(1,))
        c=np.ravel(np.repeat(np.concatenate([c-1,c,c+1],1),3,-2))

        xy9=np.reshape(rc2xy([r,c],l_mm[1]),(2,len(r)/9,9))

        arr9=np.reshape(_rc_mm2val([r,c],l_mm,nodata),(len(r)/9,9))

        for i in range(0,len(xy[0])):
            if arr[i] != nodata:
                fx=np.maximum(l_mm[1]["dx"]-np.abs(xy9[0][i]-xy[0][i]),0)
                fy=np.maximum(l_mm[1]["dy"]-np.abs(xy9[1][i]-xy[1][i]),0)
                fxy=fx*fy
                fxy[arr9[i] == nodata]=0
                arr[i]=(arr9[i]*fxy).sum()/fxy.sum()

    return arr

def _rc_mm2val(rc,l_mm,nodata=None,consecutive=False): # rc: 2xN matrix; l_mm: {raster_info,geo_info,[inf,mm]}
    """Function to get values from raster info and mmap instance using row,col indices.
    """
    frm="=%s" %(l_pcr_Struct["structFormat"][[np.dtype(d) for d in l_pcr_Struct["data_type"]].index(l_mm[0][3])])
    #if l_mm[0][3] == uint8: frm="=B"
    #elif l_mm[0][3] == int32: frm="=l"
    #else: frm="=f"
    at=np.promote_types(l_mm[0][3],np.array(nodata).dtype)
    nodata0=l_mm[0][4]
    if nodata == None: nodata=nodata0
    rc=np.array(rc)
    if consecutive:
        l_mm[2][1].seek(l_mm[0][1]+l_mm[0][2]*(rc[0][0]*l_mm[1]["ncol"]+rc[1][0]))
        arr=np.fromstring(l_mm[2][1].read(len(rc[0])*l_mm[0][2]),dtype=l_mm[0][3])
        arr[arr == nodata0]=nodata
        try: arr[np.isnan(arr)]=nodata
        except: arr[arr == l_mm[0][4]]=nodata
    else:
        cp=(rc[0] >= 0)*(rc[0] < l_mm[1]["nrow"])*(rc[1] >= 0)*(rc[1] < l_mm[1]["ncol"]) #cp=np.where(rc[0] >= 0,np.where(rc[0] < l_mm[1]["nrow"],np.where(rc[1] >= 0,np.where(rc[1] < l_mm[1]["ncol"],True,False),False),False),False)
        ind=l_mm[0][1]+l_mm[0][2]*(cp*rc[0]*l_mm[1]["ncol"]+cp*rc[1]) #ind=l_mm[0][1]+l_mm[0][2]*(np.where(cp,rc[0].copy(),0)*l_mm[1]["ncol"]+np.where(cp,rc[1].copy(),0))
        arr=np.ones((len(ind),),at)*nodata
        for i in range(0,len(arr)):
            l_mm[2][1].seek(ind[i])
            v=struct.unpack(frm,l_mm[2][1].read(l_mm[0][2]))[0]
            if v != nodata0: arr[i]=v
        try: arr=np.where(cp,np.where(np.isnan(arr),nodata,arr),nodata)
        except: arr=np.where(cp,np.where(arr == l_mm[0][4],nodata,arr),nodata)
    return arr

def _rc_val2mm(rc,val,l_mm,consecutive=False):
    """Function to set values to mmap instance using row,col indices.
    """
    v=np.array(val,dtype=l_mm[0][3])
    if consecutive:
        l_mm[2][1].seek(l_mm[0][1]+(rc[0][0]*l_mm[1]["ncol"]+rc[1][0])*l_mm[0][2])
        l_mm[2][1].write(v.tostring())
    else:
        sk=l_mm[0][1]+(rc[0]*l_mm[1]["ncol"]+rc[1])*l_mm[0][2]
        for i in range(0,len(rc[0])):
            l_mm[2][1].seek(sk[i])
            l_mm[2][1].write(v[i].tostring())

def _close_infmm(infmm):
    """Function to close file and mmap instance.
    """
    infmm[1].close()
    infmm[0].close()

def idfs2stat(l_idf,stat="mean",ncel=100000,assume_same_mask=True,weights=None):
    """Function to calculate cell-by-cell statistics for a list of iMOD IDF files.

    Because reading entire rasters for a large number of files could cause memory errors, the function uses memory mapping to read a user-defined number of cells at the same time.

    All files should have the same extent and cell sizes.

    Parameters
    ----------
    l_idf : list
        List of iMOD IDF files.

    stat : str (optional)
        The statistic to be calculated. Recognized are: 'sum', 'count', 'mean', 'std', 'var', 'min', 'max', 'median'
        and percentiles in the form of 'pQ' where Q represents an integer between 0 and 100 (e.g. 'p10').

    ncel : int or None (optional)
        The number of cells to be read at the same time.

        If *ncel* is None all cells will be read at the same time.

    assume_same_mask : bool (optional)
        Flag to specify if the mask (nodata) of the cells could be assumed to be same or not.

        True = assume same masks

        False = do not assume same masks; this will be much slower

    weights : array, array_like or None (optional)
        The weights to be applied for the IDF files. Only relevant if *stat* is 'sum', 'count', 'mean', 'median' or a percentile.
        If *stat* is 'sum' or 'count' *weights* is used as multiplier.

        If *weights* is an array (or array_like) it should be 1 dimensional and containing one weight for each file.

        If *weights* is None all files will have the same weight.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`statistics`
    """
    if stat == "median": stat="p50"
    elif stat == "p100": stat="max"
    elif stat in ["p0","p00"]: stat="min"

    if not (stat in ["sum","count","mean","std","var","min","max","median"] or stat[0] == "p"):
        raise Exception, "Statistic %s not valid" %(stat)
    if stat[0] == "p":
        try:
            perc=int(stat[1:])
            if perc < 0 or perc > 100:
                raise Exception, "Statistic %s not valid" %(stat)
        except:
            raise Exception, "Statistic %s not valid" %(stat)

    if weights != None:
        weights=np.ravel(np.array(weights))
        if weights.min() == weights.max(): weights=None

    raster_info,gi=_raster2info(l_idf[0])
    l_nodata=[raster_info[4]]
    for i in range(1,len(l_idf)):
        l_nodata+=[_raster2info(l_idf[i])[0][4]]

    nrow,ncol=gi["nrow"],gi["ncol"]

    if ncel == None: ncel=nrow*ncol

    ii=np.arange(0,nrow*ncol,ncel)
    dd=np.append(ii[1:],[nrow*ncol])-ii.copy()

    arr_tot=ma.zeros((nrow*ncol,),raster_info[3])

    if arr_tot.mask.ndim == 0: arr_tot.mask=np.ones(arr_tot.shape,bool)*arr_tot.mask

    if stat[0] == "p":

        if weights != None:

            if assume_same_mask:

                for i in range(0,len(ii)):
                    arr=ma.zeros((len(l_idf),dd[i]),raster_info[3])

                    for j in range(0,len(l_idf)):
                        inf=open(l_idf[j],"rb")
                        mm=mmap.mmap(inf.fileno(),0,access=mmap.ACCESS_READ)
                        mm.seek(ii[i]*raster_info[2]+raster_info[1])
                        arr[j]=ma.masked_values(np.fromstring(mm.read(dd[i]*raster_info[2]),raster_info[3]),l_nodata[j])
                        mm.close()
                        inf.close()

                    if arr.mask.ndim == 0: arr.mask=np.ones(arr.shape,bool)*arr.mask
                    cp=arr.mask.max(0) == False
                    cpi1=np.compress(cp,np.arange(0,dd[i]))
                    cpi2=np.compress(cp == False,np.arange(0,dd[i]))

                    result=[]
                    for j in cpi1:
                        result+=[_weighted_percentile(arr[:,j],weights,[perc/100.])]
                    arr_tot.data[ii[i]:ii[i]+dd[i]][cpi1]=np.array(result,raster_info[3])
                    arr_tot.data[ii[i]:ii[i]+dd[i]][cpi2]=arr_tot.fill_value
                    arr_tot.mask[ii[i]:ii[i]+dd[i]][cpi2]=True

            else:

                for i in range(0,len(ii)):
                    arr=ma.zeros((len(l_idf),dd[i]),raster_info[3])

                    for j in range(0,len(l_idf)):
                        inf=open(l_idf[j],"rb")
                        mm=mmap.mmap(inf.fileno(),0,access=mmap.ACCESS_READ)
                        mm.seek(ii[i]*raster_info[2]+raster_info[1])
                        arr[j]=ma.masked_values(np.fromstring(mm.read(dd[i]*raster_info[2]),raster_info[3]),l_nodata[j])
                        mm.close()
                        inf.close()

                    if arr.mask.ndim == 0: arr.mask=np.ones(arr.shape,bool)*arr.mask

                    for c in range(0,dd[i]):
                        try:
                            cp=np.ravel(arr[:,c].mask == False)
                            arr_tot[ii[i]+c]=_weighted_percentile(np.compress(cp,np.ravel(arr[:,c].data),0),np.compress(cp,weights,0),[perc/100.])
                        except:
                            arr_tot.data[ii[i]+c]=arr_tot.fill_value
                            arr_tot.mask[ii[i]+c]=True

        else:

            if assume_same_mask:

                for i in range(0,len(ii)):
                    arr=ma.zeros((len(l_idf),dd[i]),raster_info[3])

                    for j in range(0,len(l_idf)):
                        inf=open(l_idf[j],"rb")
                        mm=mmap.mmap(inf.fileno(),0,access=mmap.ACCESS_READ)
                        mm.seek(ii[i]*raster_info[2]+raster_info[1])
                        arr[j]=ma.masked_values(np.fromstring(mm.read(dd[i]*raster_info[2]),raster_info[3]),l_nodata[j])
                        mm.close()
                        inf.close()

                    if arr.mask.ndim == 0: arr.mask=np.ones(arr.shape,bool)*arr.mask
                    cp=arr.mask.max(0) == False
                    cpi1=np.compress(cp,np.arange(0,dd[i]))
                    cpi2=np.compress(cp == False,np.arange(0,dd[i]))

                    arr_tot.data[ii[i]:ii[i]+dd[i]][cpi1]=np.array(np.percentile(np.compress(cp,arr,1),perc,0),raster_info[3])
                    arr_tot.data[ii[i]:ii[i]+dd[i]][cpi2]=arr_tot.fill_value
                    arr_tot.mask[ii[i]:ii[i]+dd[i]][cpi2]=True

            else:

                for i in range(0,len(ii)):
                    arr=ma.zeros((len(l_idf),dd[i]),raster_info[3])

                    for j in range(0,len(l_idf)):
                        inf=open(l_idf[j],"rb")
                        mm=mmap.mmap(inf.fileno(),0,access=mmap.ACCESS_READ)
                        mm.seek(ii[i]*raster_info[2]+raster_info[1])
                        arr[j]=ma.masked_values(np.fromstring(mm.read(dd[i]*raster_info[2]),raster_info[3]),l_nodata[j])
                        mm.close()
                        inf.close()

                    if arr.mask.ndim == 0: arr.mask=np.ones(arr.shape,bool)*arr.mask

                    for c in range(0,dd[i]):
                        try: arr_tot[ii[i]+c]=np.percentile(np.compress(np.ravel(arr[:,c].mask == False),np.ravel(arr[:,c].data),0),perc,0)
                        except:
                            arr_tot.data[ii[i]+c]=arr_tot.fill_value
                            arr_tot.mask[ii[i]+c]=True

    else:

        for i in range(0,len(ii)):
            arr=ma.zeros((len(l_idf),dd[i]),raster_info[3])

            for j in range(0,len(l_idf)):
                inf=open(l_idf[j],"rb")
                mm=mmap.mmap(inf.fileno(),0,access=mmap.ACCESS_READ)
                mm.seek(ii[i]*raster_info[2]+raster_info[1])
                arr[j]=ma.masked_values(np.fromstring(mm.read(dd[i]*raster_info[2]),raster_info[3]),l_nodata[j])
                mm.close()
                inf.close()

            if stat == "sum":
                if weights != None:
                                    arr_tot[ii[i]:ii[i]+dd[i]]=(arr*((arr.mask == False)*np.reshape(weights,(len(weights),1)))).sum(0)
                else:               arr_tot[ii[i]:ii[i]+dd[i]]=arr.sum(0)
            elif stat == "count":
                if weights != None: arr_tot[ii[i]:ii[i]+dd[i]]=((arr.mask == False)*np.reshape(weights,(len(weights),1))).sum(0)
                else:               arr_tot[ii[i]:ii[i]+dd[i]]=(arr.mask == False).sum(0)
            elif stat == "mean":    arr_tot[ii[i]:ii[i]+dd[i]]=ma.average(arr,axis=0,weights=weights)
            elif stat == "std":     arr_tot[ii[i]:ii[i]+dd[i]]=arr.std(0)
            elif stat == "var":     arr_tot[ii[i]:ii[i]+dd[i]]=arr.var(0)
            elif stat == "min":     arr_tot[ii[i]:ii[i]+dd[i]]=arr.min(0)
            elif stat == "max":     arr_tot[ii[i]:ii[i]+dd[i]]=arr.max(0)

    return rasterArr(np.reshape(arr_tot,(nrow,ncol)),gi,raster_info[4])

def maps2stat(l_map,stat="mean",ncel=10000,assume_same_mask=True,weights=None):
    """Function to calculate cell-by-cell statistics for a list of PCRaster files.

    Because reading entire rasters for a large number of files could cause memory errors, the function uses memory mapping to read a user-defined number of cells at the same time.

    All files should have the same extent and cell sizes.

    Parameters
    ----------
    l_map : list
        List of PCRaster files.

    stat : str (optional)
        The statistic to be calculated. Recognized are: 'sum', 'count', 'mean', 'std', 'var', 'min', 'max', 'median'
        and percentiles in the form of 'pQ' where Q represents an integer between 0 and 100 (e.g. 'p10').

    ncel : int or None (optional)
        The number of cells to be read at the same time.

        If *ncel* is None all cells will be read at the same time.

    assume_same_mask : bool (optional)
        Flag to specify if the mask (nodata) of the cells could be assumed to be same or not.

        True = assume same masks

        False = do not assume same masks; this will be much slower

    weights : array, array_like or None (optional)
        The weights to be applied for the IDF files. Only relevant if *stat* is 'sum', 'count', 'mean', 'median' or a percentile.
        If *stat* is 'sum' or 'count' *weights* is used as multiplier.

        If *weights* is an array (or array_like) it should be 1 dimensional and containing one weight for each file.

        If *weights* is None all files will have the same weight.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`statistics`
    """
    return idfs2stat(l_map,stat,ncel,assume_same_mask)


#########################################################
## ROW,COL TO/FROM X,Y >> ONLY FOR EQUIDISTANT RASTERS ##
#########################################################

def xy2rc(xy,gi,outsideVal=None): # xy: 2xN matrix; rc: 2xN matrix
    """Function to convert x,y coordinates to row,col indices.

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    xy : array or array_like (2-D)
        A 2xN array/matrix with the x,y coordinates.

    gi : dict or list
        The basic geographical information.

    outsideVal : int or None (optional)
        Row,col index value to be used for x,y coordinates which are outside the extent of gi.

    Returns
    -------
    rc : numpy array (2-D)
        A 2xN array with the row,col indices. Indices follow Python standard, i.e. starting at 0.

    See Also
    --------
    :ref:`geo_info`
    """
    xarr=np.array(xy[0],float64)
    yarr=np.array(xy[1],float64)
    xll,yll,dx,dy,nrow,ncol,proj,ang,crs=gi2list(gi)
    if proj == 1:
        rarr=np.array((yarr.copy()-yll)/dy)
        rarr[rarr < 0]=rarr[rarr < 0]-1
        rarr=-np.array(rarr,int32)-1+nrow
        rarr[yarr == yll+dy*nrow]=0
    else:
        rarr=np.array((-yarr.copy()+yll)/dy)
        rarr[rarr < 0]=rarr[rarr < 0]-1
        rarr=-np.array(rarr,int32)-1+nrow
        rarr[yarr == yll-dy*nrow]=0
    carr=np.array((xarr.copy()-xll)/dx)
    carr[carr < 0]=carr[carr < 0]-1
    carr=np.array(carr,int32)
    carr[xarr == xll+dx*ncol]=ncol-1
    if outsideVal != None:
        cp=((rarr >= 0)*(rarr < nrow)*(carr >= 0)*(carr < ncol)) == False
        rarr[cp]=outsideVal
        carr[cp]=outsideVal
    return np.array([rarr,carr],int32)

def rc2xy(rc,gi,ll=False,outsideVal=None): # ll=lower left: coordinates for lower left corner of cell instead of center
    """Function to convert row,col indices to x,y coordinates.

    Default the x,y coordinates are for the cell centers.

    Does not work for non-equidistant rasters.

    Parameters
    ----------
    rc : array or array_like (2-D)
        A 2xN array with the row,col indices. Indices follow Python standard, i.e. starting at 0.

    gi : dict or list
        The basic geographical information.

    ll : bool
        True = coordinates for lower left (ll) corner of cell

        False = coordinates for cell center.

    outsideVal : int, float or None (optional)
        X,y coordinate value to be used for row,col indices which are outside the extent of gi.

    Returns
    -------
    xy : numpy array (2-D)
        A 2xN array/matrix with the x,y coordinates.

    See Also
    --------
    :ref:`geo_info`
    """
    rarr=np.array(rc[0])
    carr=np.array(rc[1])
    xll,yll,dx,dy,nrow,ncol,proj,ang,crs=gi2list(gi)
    if ll not in [0,None,False]: ll=1
    else: ll=0
    if proj == 1:
        yarr=(-rarr.copy()-0.5-0.5*ll+nrow)*dy+yll
    else:
        yarr=(rarr.copy()+0.5+0.5*ll-nrow)*dy+yll
    xarr=(carr.copy()+0.5-0.5*ll)*dx+xll
    if outsideVal != None:
        cp=((rarr >= 0)*(rarr < nrow)*(carr >= 0)*(carr < ncol)) == False
        xarr[cp]=outsideVal
        yarr[cp]=outsideVal
    return xarr,yarr

def rc2rc(gi1,gi2,raveled=False,rc_splitted=False):
    """Function to calculated row and column indices of a raster and the corresponding indices of a second raster.

    Parameters
    ----------

    gi1 : dict or list
        The basic geographical information of the first raster.

    gi2 : dict or list
        The basic geographical information of the second raster.

    raveled : bool (optional)
        True = ravel/flatten the indices in output (see below)

        False = do not ravel/flatten the indices

    rc_splitted : bool (optional)
        True = split row and column indices in output (see below)

        False = keep row and column indices in one array

    Returns
    -------

    result : tuple

        Result is depending on *rc_splitted*: (rc1,rc2,consecutive) or (r1,c1,r2,c2,consecutive).

        rc1 = row and column indices of the first raster; 2-D or 3-D array depending on *raveled*.

        rc2 = corresponding row and column indices of the second raster; 2-D or 3-D array depending on *raveled*.

        consecutive = boolean: True = cells of second raster are in consecutive order; False = cells or second raster are not in consecutive order.

        r1 = row indices of the first raster; 1-D or 2-D array depending on *raveled*.

        r2 = corresponding row indices of the second raster; 1-D or 2-D array depending on *raveled*.

        c1 = column indices of the first raster; 1-D or 2-D array depending on *raveled*.

        c2 = corresponding column indices of the second raster; 1-D or 2-D array depending on *raveled*.
    """
    gi1=gi2dict(gi1)
    gi2=gi2dict(gi2)

    rc1=np.indices((gi1["nrow"],gi1["ncol"]))
    xy1=rc2xy(rc1.reshape((2,gi1["nrow"]*gi1["ncol"])),gi1)
    rc2=xy2rc(xy1,gi2)

    cp=(rc2[0] >= 0)*(rc2[0] < gi2["nrow"])*(rc2[1] >= 0)*(rc2[1] < gi2["ncol"])
    rc2[0][cp == False]=-1
    rc2[1][cp == False]=-1

    ii=rc2[0]*gi2["ncol"]+rc2[1]
    di=ii[1:]-ii[:-1]
    if di.min() != 1 or di.max() != 1 or rc2.min() < 0:
        consecutive=False
    else:
        consecutive=True

    if not raveled:
        rc2=rc2.reshape((2,gi1["nrow"],gi1["ncol"]))
    else:
        rc1=rc1.reshape((2,gi1["nrow"]*gi1["ncol"]))
    if rc_splitted:
        return rc1[0],rc1[1],rc2[0],rc2[1],consecutive
    else:
        return rc1,rc2,consecutive

def masks2rc_overlap(rA1,rA2):
    """Function to calculated row and column indices of the overlapping area of 2 rasters.

    Parameters
    ----------

    rA1 : rasterArr object
        First raster.

    rA2 : rasterArr object
        Second raster.

    Returns
    -------

    rc : numpy ndarray
        Array with the overlapping and non-masked row and column indices of the two rasters.

        2x2xN array: [[irow1 array, icol1 array],[irow2 array,icol2 array]]

    rect : numpy ndarray
        Array with the 'from' and 'to' row and column indices for overlapping area (including masked cells) of the two rasters.

        2x2x2 array: [[(irow1 from,irow1 to),(icol1 from,icol1 to)],[(irow2 from,irow2 to),(icol2 from,icol2 to)]]
    """
    rA1_rc=xy2rc([[rA2.xll()+rA2.dx()*0.5,rA2.xur()-rA2.dx()*0.5],[rA2.yur()-rA2.dy()*0.5,rA2.yll()+rA2.dy()*0.5]],gi=rA1.gi())
    rA2_rc=xy2rc([[rA1.xll()+rA1.dx()*0.5,rA1.xur()-rA1.dx()*0.5],[rA1.yur()-rA1.dy()*0.5,rA1.yll()+rA1.dy()*0.5]],gi=rA2.gi())

    rA1_r1,rA1_r2=max(0,rA1_rc[0].min()), min(rA1.nrow(),rA1_rc[0].max()+1)
    rA1_c1,rA1_c2=max(0,rA1_rc[1].min()), min(rA1.ncol(),rA1_rc[1].max()+1)
    rA2_r1,rA2_r2=max(0,rA2_rc[0].min()), min(rA2.nrow(),rA2_rc[0].max()+1)
    rA2_c1,rA2_c2=max(0,rA2_rc[1].min()), min(rA2.ncol(),rA2_rc[1].max()+1)

    rA1_rc=np.indices((rA1_r2-rA1_r1,rA1_c2-rA1_c1))+np.array([[[rA1_r1]],[[rA1_c1]]])
    rA2_rc=np.indices((rA2_r2-rA2_r1,rA2_c2-rA2_c1))+np.array([[[rA2_r1]],[[rA2_c1]]])

    cp=np.ravel((rA1.mask()[rA1_r1:rA1_r2,rA1_c1:rA1_c2] == False)*(rA2.mask()[rA2_r1:rA2_r2,rA2_c1:rA2_c2] == False))
    rc=np.array([[np.ravel(rA1_rc[0])[cp],np.ravel(rA1_rc[1])[cp]],[np.ravel(rA2_rc[0])[cp],np.ravel(rA2_rc[1])[cp]]])

    return rc,np.array([[[rA1_r1,rA1_r2],[rA1_c1,rA1_c2]],[[rA2_r1,rA2_r2],[rA2_c1,rA2_c2]]])


#######################
## WINDOW OPERATIONS ##
#######################

def window_arr(arr,multArr=None,dWin=None,method="mean",round=False,unitCell=True):
    """Function to perform a window operation.

    A 'window' could be a rectangle, a circles or a free form.

    Does not work for non-equidistant rasters and for different dx and dy.

    Parameters
    ----------
    arr : rasterArr object or numpy array

    multArr : numpy ndarray, array_like (2-D) or None (optional)
        Multipliers/weights of the cells in the 'window'.

        If used this automatically determines the form/size of the window. It is possible to specify any form in the *multArr* array.
        Zeros in the array are ignored (not used as multipliers).

        *dWin* is not used if *multArr* is specified.

    dWin : float, int, str or None (optional)
        Window size/radius and form. Will be used if *multArr* is None. From *dWin* the multipliers/weights array is constructed.

        *dWin* is an int: 'radius' of a square window. The size of the square will be (*dWin* * 2) + 1.
        The multipliers/weights will be 1 in all cells within the square.

        *dWin* is a float: same as int, but not necessarily a whole number.
        The multipliers/weights in the outer cells of the window will be the remaining fraction between 0 and 1.

        *dWin* is a str:

           - 'circle_radius=<size>' ==> circle with radius <size>; multipliers are 1 within circle; remaining fraction between 0 and 1 in outer cells.

           - 'circle_dist_radius=<size>,<offset>' ==> circle with radius <size>; multipliers are the distance from the centre + <offset>.

           - 'rectangle_rc=<size R>,<size C>' ==> rectangle with <size R> and <size C> the 'radius' in resp. row (y) and column (x) direction;
             multipliers are 1 within rectangle; remaining fraction between 0 and 1 in outer cells.

        Size(s) in cell units unless *unitCell* is False.

    method : str
        The window operation method. Possible methods are:
        'mean', 'harm', 'log', 'log10', 'min', 'max', 'sum', 'std', 'var', 'count'.

    round : bool (optional)
        True = multipliers/weights constructed from *dWin* are rounded off.

        False = multipliers/weights constructed from *dWin* are not rounded off.

    unitCell : bool (optional)
        True = size(s) used in *dWin* are in cell units.

        False = size(s) used in *dWin* are in raster units (if *arr* is a rasterArr object).

    Returns
    -------
    result : rasterArr object or numpy MaskedArray (depending on input)

    See Also
    --------
    :ref:`window_operations`
    """
    unitMult=1
    if not unitCell:
        try:
            unitMult=1.0/arr.dx()
        except:
            pass

    if multArr == None:
        multArr=_getMultArr(dWin,round=round,unitMult=unitMult)
    else:
        multArr=np.array(multArr,float32)

    l_method=[\
        ["mean", "harm", "log", "log10", "min", "max", "sum", "std", "var", "count"],\
        [ 0,      0,      0,     0,       1e31,  -1e31, 0,     0,     0,     0     ],\
        ]
    fill_value=l_method[1][l_method[0].index(method)]

    gi=None
    nodata=fill_value
    msk=False

    try:
        gi=arr.gi()
        nodata=arr.nodata()
        msk=arr.mask()
        arr=ma.filled(arr.arr,nodata)
    except:
        try:
            nodata=arr.fill_value
            msk=arr.mask
            arr=ma.filled(arr,nodata)
        except:
            pass

    if np.ndim(msk) == 0:
        msk=np.ones(arr.shape,bool)*msk

    dt=arr.dtype
    arr=np.array(arr,float64)

    if method in ["mean", "harm", "log", "log10", "sum", "count"]:
        if method == "harm":
            msk[arr == 0]=True
            arr[arr == 0]=1
            arr=1.0/arr
        elif method == "log":
            msk[arr <= 0]=True
            arr[arr <= 0]=1
            arr=np.log(arr)
        elif method == "log10":
            msk[arr <= 0]=True
            arr[arr <= 0]=1
            arr=np.log10(arr)
        elif method == "count":
            arr=np.array(msk == False,float64)
        arr[msk]=fill_value

        arr=_window_sum(arr,multArr=multArr)

        if method in ["mean", "harm", "log", "log10"]:
            cnt=_window_sum(np.array(msk == False,float64),multArr)
            msk[cnt == 0]=True
            arr[msk]=1
            arr=arr/cnt

        if method == "harm":
            msk[arr == 0]=True
            arr[arr == 0]=1
            arr=1.0/arr
        elif method == "log":
            arr=np.exp(arr)
        elif method == "log10":
            arr=10**arr

    elif method in ["std","var"]:

        arr=ma.array(arr,mask=msk,fill_value=fill_value)
        mn=window_arr(arr,multArr=multArr,method="mean")
        n=window_arr(arr,multArr=multArr,method="count")
        arr=((window_arr(arr**2,multArr=multArr,method="sum") + n * mn**2 - 2 * mn * window_arr(arr,multArr=multArr,method="sum"))/n)**0.5
        if method == "var":
            arr=arr**2
        msk=arr.mask
        arr=arr.data

    elif method == "min":
        arr[msk]=fill_value
        arr=_window_min(arr,multArr=multArr,fill_value=fill_value)

    elif method == "max":
        arr[msk]=fill_value
        arr=_window_max(arr,multArr=multArr,fill_value=fill_value)

    arr[msk]=nodata

    arr=np.array(arr,dt)

    if gi != None:
        return rasterArr(arr,gi,nodata)
    else:
        return ma.array(arr,mask=msk,fill_value=nodata)

def _multArr2indices(arr,multArr):

    nrow,ncol=arr.shape

    i_rc=np.indices((multArr.shape[0],multArr.shape[1]))
    i_r=i_rc[0]-multArr.shape[0]/2
    i_c=i_rc[1]-multArr.shape[1]/2

    r1in=np.maximum(0,i_r)
    r2in=np.minimum(nrow,nrow+i_r)
    r1out=r1in[::-1]
    r2out=r2in[::-1]
    c1in=np.maximum(0,i_c)
    c2in=np.minimum(ncol,ncol+i_c)
    c1out=c1in[:,::-1]
    c2out=c2in[:,::-1]

    cp=np.ravel(multArr) > 0
    multArr=np.ravel(multArr)[cp]
    r1in=np.ravel(r1in)[cp]
    r2in=np.ravel(r2in)[cp]
    r1out=np.ravel(r1out)[cp]
    r2out=np.ravel(r2out)[cp]
    c1in=np.ravel(c1in)[cp]
    c2in=np.ravel(c2in)[cp]
    c1out=np.ravel(c1out)[cp]
    c2out=np.ravel(c2out)[cp]

    return multArr,r1in,r2in,r1out,r2out,c1in,c2in,c1out,c2out

def _window_sum(arr,multArr):
    ##multArr,r1in,r2in,r1out,r2out,c1in,c2in,c1out,c2out=_multArr2indices(arr,multArr)
    ##arrWin=np.zeros(arr.shape,arr.dtype)
    ##for i in range(0,len(r1in)):
    ##    arrWin[r1out[i]:r2out[i],c1out[i]:c2out[i]]+=arr[r1in[i]:r2in[i],c1in[i]:c2in[i]]*multArr[i]
    ##return arrWin
    import scipy.ndimage
    return scipy.ndimage.convolve(arr,weights=multArr,mode="constant",cval=0.0)

def _window_min(arr,multArr,fill_value=1e31):
    multArr,r1in,r2in,r1out,r2out,c1in,c2in,c1out,c2out=_multArr2indices(arr,multArr)
    arrWin=np.ones(arr.shape,arr.dtype)*fill_value
    for i in range(0,len(r1in)):
        arrWin[r1out[i]:r2out[i],c1out[i]:c2out[i]]=\
            np.minimum(arrWin[r1out[i]:r2out[i],c1out[i]:c2out[i]],arr[r1in[i]:r2in[i],c1in[i]:c2in[i]]*multArr[i])
    return arrWin

def _window_max(arr,multArr,fill_value=-1e31):
    multArr,r1in,r2in,r1out,r2out,c1in,c2in,c1out,c2out=_multArr2indices(arr,multArr)
    arrWin=np.ones(arr.shape,arr.dtype)*fill_value
    for i in range(0,len(r1in)):
        arrWin[r1out[i]:r2out[i],c1out[i]:c2out[i]]=\
            np.maximum(arrWin[r1out[i]:r2out[i],c1out[i]:c2out[i]],arr[r1in[i]:r2in[i],c1in[i]:c2in[i]]*multArr[i])
    return arrWin

def _getMultArr(dWin,round=False,unitMult=1):
    if type(dWin) == str:
        p,v=dWin.split("=")
        p=p.lower()
        if p == "circle_radius":
            r=float(v)*unitMult
            ri=int(r+1)
            ii=np.indices((ri*2+1,ri*2+1))
            multArr=np.array(((ii[0]-ri)**2+(ii[1]-ri)**2)**0.5,float32)
            multArr=(multArr-r)
            multArr[multArr <= 0]=1
            multArr[multArr > 1]=0
            multArr[(multArr > 0)*(multArr < 1)]=1-multArr[(multArr > 0)*(multArr < 1)]
        elif p == "circle_dist_radius":
            r,o=[float(s) for s in v.split(",")]
            r=r*unitMult
            ri=int(r+1)
            ii=np.indices((ri*2+1,ri*2+1))
            multArr=np.array(((ii[0]-ri)**2+(ii[1]-ri)**2)**0.5,float32)
            multArr[multArr > r]=-1
            multArr/=unitMult
            multArr[multArr >= 0]+=o
            multArr[multArr < 0]=0
        elif p == "rectangle_rc":
            r,c=[float(s)*unitMult for s in v.split(",")]
            if int(r) != r: R,r=int(r+1)*2+1,r%1
            else: R,r=int(r)*2+1,1
            if int(c) != c: C,c=int(c+1)*2+1,c%1
            else: C,c=int(c)*2+1,1
            multArr=np.ones((R,C),float32)
            multArr[0]*=r; multArr[-1]*=r
            multArr[:,0]*=c; multArr[:,-1]*=c
    elif type(dWin) in [float,int,bool]:
        dWin=float(dWin)*unitMult
        if int(dWin) != dWin:
            multArr=np.ones((int(dWin+1)*2+1,int(dWin+1)*2+1),float32)
            multArr[0]*=(dWin%1); multArr[-1]*=(dWin%1)
            multArr[:,0]*=(dWin%1); multArr[:,-1]*=(dWin%1)
        else:
            multArr=np.ones((int(dWin)*2+1,int(dWin)*2+1),float32)
    else:
        multArr=np.ones((3,3),float32)

    if round:
        multArr=np.around(multArr)

    multArr=multArr[multArr.sum(1) > 0][:,multArr.sum(0) > 0]

    return multArr


#####################
## OTHER FUNCTIONS ##
#####################

def idfs2mdf(l_idf,f_mdf,rgb=None):
    """Function to group a list of IDF files into a MDF file.

    Parameters
    ----------
    l_idf : list
        Lisf of IDF files to be grouped.

    f_mdf : string
        Output MDF file.

    rgb : list, tuple or None (optional)
        RGB color code(s) for the IDF files (layers).
    """
    l_rgb=[(64,0,0),(68,0,0),(73,0,0),(77,0,0),(82,0,0),(86,0,0),(91,0,0),(95,0,0),(100,0,0),(104,0,0),(109,0,0),(114,0,0),(118,0,0),(123,0,0),(127,0,0),(132,0,0),(136,0,0),(141,0,0),(145,0,0),(150,0,0),(154,0,0),(159,0,0),(164,0,0),(168,0,0),(173,0,0),(177,0,0),(182,0,0),(186,0,0),(191,0,0),(195,0,0),(200,0,0),(204,0,0),(209,0,0),(214,0,0),(218,0,0),(223,0,0),(227,0,0),(232,0,0),(236,0,0),(241,0,0),(245,0,0),(250,0,0),(255,0,0),(255,0,0),(255,0,6),(255,0,12),(255,0,18),(255,0,24),(255,0,30),(255,0,36),(255,0,42),(255,0,48),(255,0,54),(255,0,60),(255,0,66),(255,0,72),(255,0,78),(255,0,85),(255,0,91),(255,0,97),(255,0,103),(255,0,109),(255,0,115),(255,0,121),(255,0,127),(255,0,133),(255,0,139),(255,0,145),(255,0,151),(255,0,157),(255,0,163),(255,0,170),(255,0,176),(255,0,182),(255,0,188),(255,0,194),(255,0,200),(255,0,206),(255,0,212),(255,0,218),(255,0,224),(255,0,230),(255,0,236),(255,0,242),(255,0,248),(255,0,255),(255,0,255),(249,0,255),(243,0,255),(237,0,255),(231,0,255),(225,0,255),(219,0,255),(213,0,255),(207,0,255),(201,0,255),(195,0,255),(189,0,255),(183,0,255),(177,0,255),(170,0,255),(164,0,255),(158,0,255),(152,0,255),(146,0,255),(140,0,255),(134,0,255),(128,0,255),(122,0,255),(116,0,255),(110,0,255),(104,0,255),(98,0,255),(92,0,255),(85,0,255),(79,0,255),(73,0,255),(67,0,255),(61,0,255),(55,0,255),(49,0,255),(43,0,255),(37,0,255),(31,0,255),(25,0,255),(19,0,255),(13,0,255),(7,0,255),(0,0,255),(0,0,255),(0,6,249),(0,12,243),(0,18,237),(0,24,231),(0,31,224),(0,37,218),(0,43,212),(0,49,206),(0,55,200),(0,62,193),(0,68,187),(0,74,181),(0,80,175),(0,87,168),(0,93,162),(0,99,156),(0,105,150),(0,111,144),(0,118,137),(0,124,131),(0,130,125),(0,136,119),(0,143,112),(0,149,106),(0,155,100),(0,161,94),(0,167,88),(0,174,81),(0,180,75),(0,186,69),(0,192,63),(0,199,56),(0,205,50),(0,211,44),(0,217,38),(0,223,32),(0,230,25),(0,236,19),(0,242,13),(0,248,7),(0,254,1),(0,255,0),(6,255,0),(12,255,0),(18,255,0),(24,255,0),(31,255,0),(37,255,0),(43,255,0),(49,255,0),(55,255,0),(62,255,0),(68,255,0),(74,255,0),(80,255,0),(87,255,0),(93,255,0),(99,255,0),(105,255,0),(111,255,0),(118,255,0),(124,255,0),(130,255,0),(136,255,0),(143,255,0),(149,255,0),(155,255,0),(161,255,0),(167,255,0),(174,255,0),(180,255,0),(186,255,0),(192,255,0),(199,255,0),(205,255,0),(211,255,0),(217,255,0),(223,255,0),(230,255,0),(236,255,0),(242,255,0),(248,255,0),(254,255,0),(255,255,0),(252,255,6),(249,255,12),(246,255,18),(243,255,24),(240,255,31),(237,255,37),(234,255,43),(231,255,49),(228,255,55),(225,255,62),(221,255,68),(218,255,74),(215,255,80),(212,255,87),(209,255,93),(206,255,99),(203,255,105),(200,255,111),(197,255,118),(194,255,124),(190,255,130),(187,255,136),(184,255,143),(181,255,149),(178,255,155),(175,255,161),(172,255,167),(169,255,174),(166,255,180),(163,255,186),(159,255,192),(156,255,199),(153,255,205),(150,255,211),(147,255,217),(144,255,223),(141,255,230),(138,255,236),(135,255,242),(132,255,248),(128,255,254)]

    l_idf=[os.path.abspath(f) for f in l_idf]
    f_mdf=os.path.abspath(f_mdf)

    if rgb == None:
        rgb=[(255,255,128),(128,128,128)]*(len(l_idf)/2+1)
    if type(rgb[0]) not in [list,tuple]:
        rgb=[rgb]
    rgb=[v for v in rgb]
    for i in range(0,len(l_idf)-len(rgb)):
        rgb+=[rgb[i]]
    mx=max([max(v) for v in rgb])
    if mx > 0 and mx <= 1:
        rgb=[(v[0]*255,v[1]*255,v[2]*255) for v in rgb]

    outf=open(f_mdf,"w")

    outf.write("%d\n" %(len(l_idf)))

    for i in range(0,len(l_idf)):

        minval,maxval=get_raster_minmax(l_idf[i])
        if minval == maxval:
            minval-=1
            maxval+=1
        dval=float(maxval-minval)/len(l_rgb)
        bnd=np.arange(minval,maxval+1.1*dval,dval)[::-1]

        outf.write('"%s","%s",%d,9,0\n' %(l_idf[i],os.path.splitext(os.path.basename(l_idf[i]))[0],rgb[i][0]+rgb[i][1]*2**8+rgb[i][2]*2**16))

        outf.write("255,1,1,1,1,1,1,1\nUPPERBND,LOWERBND,IRED,IGREEN,IBLUE,DOMAIN\n")

        for j in range(0,len(l_rgb)):

            outf.write('%.7G,%.7G,%d,%d,%d,">=%.7G - < %.7G"\n' %(bnd[j],bnd[j+1],l_rgb[j][0],l_rgb[j][1],l_rgb[j][2],bnd[j+1],bnd[j]))

    outf.close()

def rasterStack(l_rA,nodata=None,to_gi=None,method="sample"):
    """Function to create a 3-D rasterArr object (map stack) from 2-D rasterArr objects.

    If needed rescaling/resampling is performed to the first rasterArr object.

    Parameters
    ----------
    l_rA : list
        List of 2-D rasterArr objects.

    nodata : float, int or None (optional)
        Nodata value to apply for the map stack.

        If *nodata* is None it is taken from the first rasterArr object.

    to_gi : dict, list or None (optional)
        Basis geographical information dict/list to rescale/resample to.

        If *to_gi* is None it is taken from the first rasterArr object. If rescaling/resampling of the other rasterArr objects is performed.

    method : str or None (optional)
        The rescaling/resampling method. Possible methods are:
        'sum', 'min', 'max', 'harm', 'log10', 'log', 'mean', 'sample', None.

    Returns
    -------
    result : rasterArr object (3-D)
    """
    nodata=_value_dtype2type(nodata)
    try: to_gi=to_gi.gi()
    except:
        if to_gi != None: to_gi=gi2dict(to_gi)
        else: to_gi=l_rA[0].gi()
    if type(nodata) not in [str,bool,int,float]: nodata=l_rA[0].nodata()
    l_rA=[rescale_rA(rA,to_gi,method) for rA in l_rA]
    for rA in l_rA: rA.set_nodata(nodata)
    l_rA=ma.array([rA.arr for rA in l_rA])
    return rasterArr(l_rA,to_gi)

def put_rA(rA,rA_in,method="sample"):
    """Function to replace a part of the data of a rasterArr object with another rasterArr object.

    If needed rescaling/resampling is performed.

    Parameters
    ----------
    rA : rasterArr object
        Base rasterArr object.

    rA_in : rasterArr object
        raterArr object containing the data to be put into the base rasterArr object.

    method : str or None (optional)
        The rescaling/resampling method. Possible methods are:
        'sum', 'min', 'max', 'harm', 'log10', 'log', 'mean', 'sample', None.

    Returns
    -------
    result : rasterArr object

    See Also
    --------
    :ref:`indexing_slicing`
    """
    rc=xy2rc([[rA_in.xll(),rA_in.xur()],[rA_in.yur(),rA_in.yll()]],rA.gi())
    rc=[[max(0,rc[0][0]),min(rA.nrow()-1,rc[0][1])],[max(0,rc[1][0]),min(rA.ncol()-1,rc[1][1])]]
    r,c=rc[0][0],rc[1][0]
    xy=rc2xy(rc,rA.gi(),True)
    xll,xur,yur,yll=xy[0][0],xy[0][1],xy[1][0],xy[1][1]
    if xll > rA_in.xll()+rA.dx()*1e-4: xll-=rA.dx()
    elif xll < rA_in.xll()-rA.dx()*(1-1e-4): xll+=rA.dx()
    if xur < rA_in.xur()-rA.dx()*1e-4: xur+=rA.dx()
    elif xur > rA_in.xur()+rA.dx()*(1-1e-4) >= rA_in.xur(): xur-=rA.dx()
    if yll > rA_in.yll()+rA.dy()*1e-4: yll-=rA.dy()
    elif yll < rA_in.yll()-rA.dy()*(1-1e-4): yll+=rA.dy()
    if yur < rA_in.yur()-rA.dy()*1e-4: yur+=rA.dy()
    elif yur > rA_in.yur()+rA.dy()*(1-1e-4): yur-=rA.dy()
    rc=xy2rc([[xll,xll+rA.dx()*1e-4],[yur,yur-rA.dy()*1e-4]],rA.gi())
    r,c=rc[0].max(),rc[1].max()
    nrow,ncol=int(_roundoff((yur-yll)/rA.dy())),int(_roundoff((xur-xll)/rA.dx()))
    gi=[xll,yll,rA.dx(),rA.dy(),nrow,ncol,rA.proj(),rA.ang()]
    arr_in=rA_in.rescale(gi,method)
    arr_out=rA.arr.copy()
    if arr_out.mask.ndim == 0: arr_out.mask=np.ones(arr_out.shape,bool)*arr_out.mask
    arr_out.data[r:r+nrow,c:c+ncol]=arr_in.arr.data
    arr_out.mask[r:r+nrow,c:c+ncol]=arr_in.arr.mask
    return rasterArr(arr_out,rA.gi())


## MISCELLANEOUS FUNCTIONS

def _fort_double2single(v):
    """Function to adjust double precision value in such a way that single precision interpretation by Fortran (iMOD) is correct.
    """
    v=float("%.7G" %(v))
    v=struct.unpack("=f",struct.pack("=f",v))[0]
    return v

def _calc_gcd(n1,n2):
    """Function to calculate the greatest common divisor of 2 numbers.
    """
    n1,n2=abs(n1),abs(n2)
    a,b=max(n1,n2),min(n1,n2)
    while 1:
        c=a%b
        if c <= 1e-10: break
        a=b; b=c
    return b

def _rounddown(v,rv=1,prec=1e-7):
    """Function rounddown.
    """
    v,rv=np.array(v),np.array(rv)
    v+=prec*rv
    return v-np.mod(v,rv)

def _roundup(v,rv=1,prec=1e-7):
    """Function to roundup.
    """
    v,rv=np.array(v),np.array(rv)
    v-=prec*rv
    return v+rv-np.mod(v,rv)

def _roundoff(v,rv=1,prec=1e-14):
    """Function to roundoff.
    """
    v1,v2=_rounddown(v,rv,prec)-v,_roundup(v,rv,prec)-v
    return np.where(np.abs(v1) < np.abs(v2),v+v1,v+v2)

def _get_min_dtype(l_val,*args):
    """Function to get the minimal common dtype of a list of values/arrays.
    """
    if type(l_val) != list:
        if type(l_val) == tuple: l_val=list(l_val)
        else: l_val=[l_val]
    for arg in args: l_val.append(arg)
    dt=np.array(1,bool).dtype
    for v in l_val:
        try:
            try: v=v.arr
            except: pass
            if type(v) != type(None):
                dt=np.promote_types(dt,np.min_scalar_type(_value_dtype2type(v)))
        except: pass
    return dt

def _value_dtype2type(v):
    """Function to convert a value from numpy dtype to bool/int/float.
    """
    try:
        if v.dtype in [bool,bool8]: return bool(v)
        elif v.dtype in [float16,float32,float64]: return float(v)
        else: return int(v)
    except: return v

def _get_prefered_nodata(arr):
    """Function to get a prefered nodata value for an array or rasterArr object.
    """
    try:
        arr.gi()
        arr1=np.compress(np.ravel(arr.arr.mask) == False,np.ravel(arr.arr.data),0)
        nodata=arr.nodata()
    except:
        try:
            arr1=np.compress(np.ravel(arr.mask) == False,np.ravel(arr.data),0)
            nodata=arr.fill_value
        except:
            arr1=np.array(arr)
            nodata=None
    if nodata == None or np.in1d(nodata,arr1)[0]:
        fnd=False
        for i in range(0,len(l_prefered_nodata)):
            if l_prefered_nodata[i][0] == arr1.dtype:
                for nodata in l_prefered_nodata[i][1:]:
                    if not np.in1d(nodata,arr1)[0]:
                        fnd=True
                        break
                break
        if not fnd:
            if arr1.dtype in [bool,bool8]: nodata=False
            elif arr1.dtype in [uint8,uint16,uint32,uint64]: nodata=arr1.max()+1
            else: nodata=arr1.min()-1
    return nodata

def _weighted_percentile(data_1D,weights_1D,l_perc=[0.5]):
    """Function to calculate weighted percentiles of a 1-D array of values.
    """
    data_1D=np.array(data_1D,float64)
    weights_1D=np.array(weights_1D,float64)
    l_perc=np.array(l_perc,float64)

    i=np.argsort(data_1D)
    data_1D=np.take(data_1D,i)
    weights_1D=np.take(weights_1D,i)

    S=np.arange(0,len(data_1D))*weights_1D+(len(data_1D)-1)*np.insert(np.cumsum(weights_1D)[:-1],0,[0])
    S=S/S[-1]

    return np.interp(np.interp(l_perc,S,np.arange(0,len(S))),np.arange(0,len(data_1D)),data_1D)
