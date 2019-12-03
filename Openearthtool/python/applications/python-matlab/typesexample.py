#!/usr/bin/env python
import numbers
import numpy
from mlabwrap import mlab, MlabObjectProxy


def dict2struct(data):
    """
    Convert a python dictionary to a mlab struct

    >>> value = {}
    >>> struct = dict2struct(value)
    >>> type(struct)
    <class 'mlabwrap.MlabObjectProxy'>
    >>> mlab.class_(struct)
    'struct'
    
    >>> value['a'] = [1,2,3]
    >>> struct = dict2struct(value)
    >>> struct.a
    array([[ 1.],
           [ 2.],
           [ 3.]])

    >>> value['b'] = {'a': 'text'}
    >>> struct = dict2struct(value)
    >>> struct.b.a
    'text'
    """
    struct = mlab.struct()
    if isinstance(data, dict):
        for key, value in data.items():
            setattr(struct, key, dict2struct(value))
    elif isinstance(data, (list, numbers.Number, numpy.ndarray, str)):
        return data
    else:
        raise ValueError("Got %s, expected %s" % (type(data), dict))

    return struct

def struct2dict(struct):
    """
    Convert a mlab struct to a python dictionary
    >>> s = mlab.struct()
    >>> type(s)
    <class 'mlabwrap.MlabObjectProxy'>
    >>> struct2dict(s)
    {}

    >>> s.text = 'some string'
    >>> struct2dict(s)
    {'text': 'some string'}

    >>> s2 = mlab.struct()
    >>> s2.number = 3.1
    >>> s2.list = [2.0,3.0]
    >>> s.somestruct = s2
    >>> struct2dict(s)
    {'text': 'some string', 'somestruct': {'list': array([[ 2.],
           [ 3.]]), 'number': array([[ 3.1]])}}
    
    Only mlab structs compatible types expected (string, list, numbers, dict)
    >>> struct2dict(object())
    Traceback (most recent call last):
        ...
    ValueError: Got <type 'object'>, expected <class 'mlabwrap.MlabObjectProxy'>
    """
    
    if isinstance(struct, MlabObjectProxy):
        mlabtype = mlab.class_(struct)
        assert mlabtype == 'struct', 'Was expecting a matlab structure but got %s' % (mlabtype, )
        fieldnames = mlab.fieldnames(struct)
        nkeys = mlab.length(fieldnames)
        keys = [fieldnames.__getitem__(i, parens='{}') for i in range(nkeys)]
        value = {key: struct2dict(getattr(struct, key))
                 for key in keys}
    elif isinstance(struct, (list, dict, str, numbers.Number, numpy.ndarray)):
        return struct
    else:
        raise ValueError("Got %s, expected %s" % (type(struct), MlabObjectProxy))
    return value


if __name__ == '__main__':
    import doctest
    doctest.testmod()
