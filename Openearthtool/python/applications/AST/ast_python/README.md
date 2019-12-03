
Python 3, pandas and numpy are used.

See `test_ast.py` for some basic unit tests.

Move this `pluvflood` logic to the client:
```
    if geometry_type == "line":
        measure_area = measure_length * measure_width
    elif geometry_type == "point":
        measure_area = (measure_width / 2.0) ** 2 * math.pi
```
