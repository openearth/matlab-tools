# functions to sample from xyz files with spatial index
import rtree
import numpy as np


# build spatial index of xyz
def rtree_from_xyz(fn, delimiter=None, skiprows=0):
    """read point cloud file and build 2d spatial index based on x and y
    
    -input
    fn          (string)
                filepath to .xyz file with x and y coordinates in 1st and 2nd column resp., values in 3th-nth column
    delimiter   (string, optional)
                The string used to separate values. By default, this is any whitespace. 
    skiprows    (int, optional)
                Skip the first skiprows lines; default: 0. 
                
    -output
    tree_idx    rtree 2D spatial index object based on x&y coordinates
    xyz_array   numpy 2D array from fn file
          
    """
    # read pointcloud data from file
    xyz_array = np.loadtxt(fn, delimiter=delimiter, skiprows=skiprows)
    
    # make 2D spatial index for x&y
    tree_idx = rtree.index.Index()
    for i, xyz in enumerate(xyz_array):
        tree_idx.insert(i, (xyz[0], xyz[2]))
 
    return tree_idx, xyz_array


def sample_xyz_rtree(coords, tree_idx, xyz_array):
    """sample nearest values from point cloud based on x&y coordinates and spatial index
    
    -input
    coords      (list or numpy array)
                xy coordinates couples
    tree_idx    (rtree 2d spatial index)
                see rtree_from_xyz function
    xyz_array   (2d numpy array)
                x and y coordinates in 1st and 2nd column resp., values in 3th-nth column
                NOTE: this array should have same index as the one tree_idx!

    -output
    samples     (2d numpy array)
                x and y from coords in 1st and 2nd column resp., sampled values in 3th-nth column
    """
    # initialize numpy array
    samples = np.empty((np.shape(coords)[0], np.shape(xyz_array)[1]))
    for i, c in enumerate(coords):  # loop through coordinates
        # find nearest point in xyz
        idx = list(tree_idx.nearest((c[0], c[1]), 1))[0]
        samples[i, :] = np.concatenate([np.array(c), xyz_array[idx, :][2:]])
                
    return samples