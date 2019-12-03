#!/usr/bin/env python

"""
This module provides an implementation of a ctypes wrapper around the BMI model interface.

The BMI interface is described at the csdms website:
http://csdms.colorado.edu/wiki/BMI_Description

The default way to talk to a BMI model is through the babel package:
https://computation.llnl.gov/casc/components/#page=doc

Here we assume that the functions are exposed through the iso_c_bindings module.
"""
import inspect
import collections
import functools

import os
import sys
import platform
import logging
import os.path
import ntpath

from ctypes import POINTER, create_string_buffer, addressof, pointer, byref, c_int, c_char_p, c_double, c_void_p, c_float

# try:
#     from ctypes import windll as LL
# except ImportError:
from ctypes import cdll as LL

# Use numpy ndpointer for arrays
from numpy.ctypeslib import ndpointer, as_array
import numpy as np

from .ibmi import IBmi
# interface

__file__ = inspect.getfile(inspect.currentframe())
DIRNAME = os.path.dirname(os.path.abspath(__file__))

# Library suffix
SUFFIXES = collections.defaultdict(lambda:'.so')
SUFFIXES['Darwin'] = '.dylib'
SUFFIXES['Windows'] = '.dll'
SUFFIX = SUFFIXES[platform.system()]

TYPEMAP = {
    "int": "int32",
    "double": "double",
    "float": "float32"

}

# Utility functions for library unloading
def isloaded(lib):
    """return true if library is loaded"""
    libp = os.path.abspath(lib)
    # posix check to see if library is loaded
    ret = os.system("lsof -p %d | grep %s > /dev/null" % (os.getpid(), libp))
    return (ret == 0)

def dlclose(lib):
    """force unload of the library"""
    handle = lib._handle
    # this only works on posix I think....
    # windows should use something like:
    # http://msdn.microsoft.com/en-us/library/windows/desktop/ms683152(v=vs.85).aspx
    name = 'libdl' + SUFFIX
    libdl = LL.LoadLibrary(name)
    libdl.dlerror.restype = c_char_p
    libdl.dlclose.argtypes = [c_void_p]
    logging.debug('Closing dll (%x)',handle)
    rc = libdl.dlclose(handle)
    if rc!=0:
        logging.debug('Closing failed, looking up error message')
        error = libdl.dlerror()
        logging.debug('Closing dll returned %s (%s)', rc, error)
        if error == 'invalid handle passed to dlclose()':
            raise ValueError(error)
    else:
        logging.debug('Closed')


class BMI(IBmi):
    def __init__(self, libname, rundir, *args, **kwargs):
        self.libname = libname # TODO: PEP8, rename to lib_name, run_dir
        self.rundir = rundir
        self.olddir = None
        self.load()
    def load(self):
        olddir=os.getcwd()
        os.chdir(os.path.dirname(self.libname))
        filename=ntpath.basename(self.libname)

        self.lib = LL.LoadLibrary(filename)

        os.chdir(olddir)

        # Change directory
        self.olddir = os.getcwd()
        # Change to the directory where the test is
        os.chdir(self.rundir)
        logging.info('Loaded library %s in directory %s' % (self.libname, self.rundir))


    def unload(self):
        handle = self.lib._handle
        logging.debug('Checking if %s is loaded %s', self.libname, isloaded(self.libname))
        while isloaded(self.libname):
            dlclose(self.lib)
        os.chdir(self.olddir)

    # Model Control Functions
    def initialize(self, config_file):
        """
        This function should perform all tasks that are to take place before entering the model's time loop.
        """
        self.lib.argtypes = [c_char_p]
        self.lib.restype = None
        config_file_buffer = create_string_buffer(config_file)
        self.lib.initialize(config_file_buffer)
    def run_model(self):
        """
        run the model in "stand-alone mode"
        """
        self.lib.run_model()
    def update(self, dt):
        """
        perform all tasks that take place during one pass through the model's time loop
        """
        c_dt = c_double(dt)
        self.lib.update.argtypes = [POINTER(c_double)]
        self.lib.update.restype = None
        self.lib.update(byref(c_dt))
    def finalize(self):
        """
        perform all tasks that take place after exiting the model's time loop
        """
        self.lib.finalize.argtypes = []
        self.lib.finalize.restype = None
        self.lib.finalize()


    # Model Information Functions
    def get_attribute(self, name):
        """
        function returns a static attribute of the model (as a string)
        """
        name = create_string_buffer(name)
        value = create_string_buffer(self.MAXSTRLEN)
        self.lib.get_attribute.argtypes = [c_char_p, c_char_p]
        self.lib.get_attribute.restype = None
        self.lib.get_attribute(name, value)


    # Variable Information Functions
    def get_var_type (self, name):
        """
        returns type string, compatible with numpy
        """
        name = create_string_buffer(name)
        type_ = c_char_p() # we don't know what size string we get back...
        self.lib.get_var_type.argtypes = [c_char_p, c_char_p]
        self.lib.get_var_type(name, type_)
        return type_.value

    def get_var_units (self, name):
        """
        returns unit names (in lower case)
        """
        name = create_string_buffer(name)
        units = c_char_p() # we don't know what size string we get back...
        self.lib.get_var_units.argtypes = [c_char_p, c_char_p]
        self.lib.get_var_units.restype = None
        self.lib.get_var_units(name, unit)
        return units.value
    def get_var_rank(self, name):
        """
        returns array rank or 0 for scalar
        """
        name = create_string_buffer(name)
        rank = c_int() # we don't know what size string we get back...
        self.lib.get_var_rank.argtypes = [c_char_p, POINTER(c_int)]
        self.lib.get_var_rank.restype = None
        self.lib.get_var_rank(name, byref(rank))
        return rank.value
    def get_var_shape(self, name):
        """
        returns shape of the array
        """
        rank = self.get_var_rank(name)
        name = create_string_buffer(name)
        arraytype = ndpointer(dtype='int32',
                              ndim=1,
                              shape=(self.MAXDIMS,),
                              flags='F')
        shape = np.empty((self.MAXDIMS,) ,dtype='int32', order='fortran')
        self.lib.get_var_shape.argtypes = [c_char_p, arraytype]
        self.lib.get_var_shape(name, shape)
        return tuple(shape[:rank])

    def get_start_time(self):
        """
        returns start time
        """
        start_time = c_double()
        self.lib.get_start_time.argtypes = [POINTER(c_double)]
        self.lib.get_start_time.restype = None
        self.lib.get_start_time(byref(start_time))
        return start_time.value

    def get_end_time (self):
        """
        returns end time of simulation
        """
        end_time = c_double()
        self.lib.get_end_time.argtypes = [POINTER(c_double)]
        self.lib.get_end_time.restype = None
        self.lib.get_end_time(byref(end_time))
        return end_time.value

    def get_current_time (self):
        """
        returns current time of simulation
        """
        current_time = c_double()
        self.lib.get_current_time.argtypes = [POINTER(c_double)]
        self.lib.get_current_time.restype = None
        self.lib.get_current_time(byref(current_time))
        return current_time.value

    # Variable Getter and Setter Functions
    def get_0d_double(name):
        name = create_string_buffer(name)
        self.lib.get_0d_double.argtypes = [POINTER(c_double)]
        self.lib.get_0d_double.restype = None
        self.lib.get_0d_double(name, byref(value))
        return value.value

    def get_nd(self, name):
        rank = self.get_var_rank(name)
        shape = self.get_var_shape(name)
        type_ = self.get_var_type(name)
        arraytype = ndpointer(dtype=TYPEMAP[type_],
                              ndim=rank,
                              shape=shape[::-1],
                              flags='F')
        # Create a pointer to the array type
        data = arraytype()
        get_nd_type_ = getattr(self.lib, 'get_{rank:d}d_{type:s}'.format(rank=rank, type= type_))
        get_nd_type_.argtypes = [c_char_p, POINTER(arraytype)]
        get_nd_type_.restype = None
        # Get the array
        get_nd_type_(name, byref(data))
        array = np.asarray(data)
        # Not sure why we need this....
        array = np.reshape(array.ravel(), shape, order='F')
        return array


    def set_0d_double(name, value):
        name = create_string_buffer(name)
        self.lib.set_0d_double.argtypes = [POINTER(c_double)]
        self.lib.set_0d_double.restype = None
        self.lib.set_0d_double(name, byref(value))
        return

    def set_nd(self, name, value):
        rank = self.get_var_rank(name)
        shape = self.get_var_shape(name)
        type_ = self.get_var_type(name)

        arraytype = ndpointer(dtype=TYPEMAP[type_],
                              ndim=rank,
                              shape=shape[::-1],
                              flags='F')
        # Create a pointer to the array type
        data = arraytype()
        funcname = 'set_{rank:d}d_{type:s}'.format(rank=rank, type= type_)
        set_nd_type_ = getattr(self.lib, funcname)
        # Ok, now for a bit of a hack... The array we get is an nd array, but
        # we're passing an nd array pointer
        # I don't know how to pass a pointer to a ndpointer that points to python data
        # so we'll first convert the value to a void pointer and pass on the pointer to that
        # pointer....
        set_nd_type_.argtypes = [c_char_p, POINTER(c_void_p)]
        set_nd_type_.restype = None
        # Set the array
        set_nd_type_(name, byref(c_void_p(value.ctypes.data)))

    # Official interface...
    def get_value (self, long_var_name):
        return self.get_nd_double(long_var_name)
    def get_value_at_indices (self, long_var_name, inds):
        # no optimization
        return self.get_value_at_indices(long_var_name)[inds]
    def set_value (self, long_var_name, src):
        self.set_nd_double(long_var_name, src)
    def set_value_at_indices (self, long_var_name, inds, src):
        # no optimization
        val = self.get_nd_double(long_var_name)
        val[inds] = src
        self.set_nd_double(long_var_name, val)



    #  Model information functions
    def get_component_name (self):
        pass
    def get_input_var_names (self):
        pass
    def get_output_var_names (self):
        pass


from types import MethodType
# Avoid duplicating code, just implement all the methods using a partial function
# Copy the docstrings and stuff.
# BMI.get_nd_double = MethodType(
#     functools.update_wrapper(
#         functools.partial(BMI.get_nd_type, type_='double'), BMI.get_nd_type
#         ),
#     None,
#     BMI
#     )
# these are all the same....
BMI.get_1d_double = BMI.get_nd
BMI.get_2d_double = BMI.get_nd
BMI.get_3d_double = BMI.get_nd
BMI.get_4d_double = BMI.get_nd
BMI.get_1d_float = BMI.get_nd
BMI.get_2d_float = BMI.get_nd
BMI.get_3d_float = BMI.get_nd
BMI.get_4d_float = BMI.get_nd
BMI.get_1d_int = BMI.get_nd
BMI.get_2d_int = BMI.get_nd
BMI.get_3d_int = BMI.get_nd
BMI.get_4d_int = BMI.get_nd

# these are all the same....
BMI.set_1d_double = BMI.set_nd
BMI.set_2d_double = BMI.set_nd
BMI.set_3d_double = BMI.set_nd
BMI.set_4d_double = BMI.set_nd
BMI.set_1d_float = BMI.set_nd
BMI.set_2d_float = BMI.set_nd
BMI.set_3d_float = BMI.set_nd
BMI.set_4d_float = BMI.set_nd
BMI.set_1d_int = BMI.set_nd
BMI.set_2d_int = BMI.set_nd
BMI.set_3d_int = BMI.set_nd
BMI.set_4d_int = BMI.set_nd



class BMIFortran(BMI):
    """
    Some extensions to the BMI, specific for fortran.
    To make talking to fortran a bit easier we assume the following constants are available as data attributes.
    Let's discuss these with the BMI people, once we find them actually useful.
    """
    def __init__(self, *args, **kwargs):
        """
        Initialize a BMI model and read the parameter constants
        """
        super(BMIFortran, self).__init__(*args, **kwargs)
        for dimension in ('MAXSTRLEN', 'MAXDIMS'):
            setattr(self, dimension, self.get_dimension(dimension))
    def get_dimension(self, name):
        # assert dimension names are exposed as attributes
        val_p = POINTER(c_int).from_address(addressof(getattr(self.lib, name)))
        return val_p.contents.value
    def get_n_attributes(self):
        """
        Get number of attributes
        """
        c_n = c_int()
        self.lib.get_n_attributes.argtypes = [POINTER(c_int)]
        self.lib.get_n_attributes(byref(c_n))
        return c_n.value
    def get_attribute_name(self, index):
        """
        Get attribute given its index
        """
        c_index = c_int(index)
        name = create_string_buffer(self.MAXSTRLEN)
        self.lib.get_attribute_name.argtypes = [POINTER(c_int), c_char_p]
        self.lib.get_attribute_name(byref(c_index), name)
        return name.value
    def get_attribute_type(self, name):
        type_ = create_string_buffer(self.MAXSTRLEN)
        c_name = create_string_buffer(name)
        self.lib.get_attribute_type(c_name, type_)
        return type_.value
    def get_double_attribute(self, name):
        c_name = create_string_buffer(name)
        value = c_double()
        self.lib.get_double_attribute(c_name, byref(value))
        return value.value
    def get_int_attribute(self, name):
        name = create_string_buffer(name)
        value = c_int()
        self.lib.get_int_attribute(name, byref(value))
        return value.value
    def get_string_attribute(self, name):
        value = create_string_buffer(self.MAXSTRLEN)
        c_name = create_string_buffer(name)
        self.lib.get_string_attribute(c_name, value)
        return value.value
    def get_n_vars(self):
        n = c_int()
        self.lib.get_n_vars(byref(n))
        return n.value
    def get_time_step(self):
        c_dt = c_double()
        self.lib.get_time_step(byref(c_dt))
        return c_dt.value
    def get_var_name(self, i):
        i = c_int(i)
        name = create_string_buffer(self.MAXSTRLEN)
        self.lib.get_var_name(byref(i), name)
        return name.value
    def get_var_type(self, name):
        name = create_string_buffer(name)
        type_ = create_string_buffer(self.MAXSTRLEN)
        self.lib.get_var_type(name, type_)
        return type_.value
    def set_1d_double_at_index(self, name, index, value):
        name = create_string_buffer(name)
        index = c_int(index)
        value = c_double(value)
        self.lib.set_1d_double_at_index.argtypes = [c_char_p, POINTER(c_int), POINTER(c_double)]
        self.lib.set_1d_double_at_index(name, byref(index), byref(value))






if __name__=='__main__':
    pass
