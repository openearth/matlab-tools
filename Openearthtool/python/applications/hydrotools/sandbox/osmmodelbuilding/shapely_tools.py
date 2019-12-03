"""
library with functions to edit and perform spatial analysis on vector data.
build around shapely and fiona libraries

Created on 2016-July-16
@author: Dirk Eilander (dirk.eilander@deltares.nl)

"""


from shapely.geometry import (box, LineString, MultiLineString, MultiPoint,
                              Point, Polygon, MultiPolygon, shape, GeometryCollection)
import shapely.ops
import numpy as np
import rtree
from fiona import collection


# I/O
def read_geometries(fn, bbox=None):
    """
    reads to shapely geometries to features using fiona collection
    feature = dict('geometry': <shapely geometry>, 'properties': <dict with properties>
    """
    with collection(fn, "r") as c:
        ft_list = []
        c = c.items(bbox=bbox)
        for ft in c:
            if ft[1]['geometry'] is not None:
                ft_list.append(shape(ft[1]['geometry']))
    return ft_list


def snap_lines(lines, max_dist, tolerance=1e-3, return_index=False):
    """Snap lines together if the endpoint of one line1 is at most max_dist apart from the line2.
    Both lines are snapped by extending line1 towards line2
    the max distance is measured in the direction of the line1

    Args:
        lines: a list of LineStrings or a MultiLineString
        max_dist: maximum distance two endpoints may be joined together

    """
    # extend all lines with max_dist to snap lines at a sharp angle
    lines_ext = [extend_line(line, max_dist) for line in lines]

    # build spatial index of line bounding boxes
    tree_idx = rtree.index.Index()
    lines_bbox = [l.bounds for l in lines_ext]
    for i, bbox in enumerate(lines_bbox):
        tree_idx.insert(i, bbox)


    lines_snap = []
    idx_snapped = []
    for i1, line in enumerate(lines):
        if isinstance(line, LineString):
            for side in ['start', 'end']:
                coords = line.coords[:]
                # make line extensions
                if side == 'start':
                    ext = LineString([shift_point(coords[0], coords[1], -1. * max_dist), coords[0]])
                    pnt_from = Point(coords[0])
                elif side == 'end':
                    ext = LineString([coords[-1], shift_point(coords[-1], coords[-2], -1. * max_dist)])
                    pnt_from = Point(coords[-1])

                # point instead of line if max_dist is zero (only clipping)
                if max_dist == 0:
                    ext = pnt_from

                # find close-by lines based on bounds with spatial index
                if tolerance > 0:
                    hits = list(tree_idx.intersection(ext.buffer(tolerance).bounds))
                else:
                    hits = list(tree_idx.intersection(ext.bounds))
                lines_hit = MultiLineString([lines_ext[i] for i in hits if i != i1])
                # find intersection points. function yields list of points
                int_points = intersection_points([ext], lines_hit, tolerance=tolerance)
                if len(int_points) == 0:
                    continue

                # if intersection yields something else then a Point, break down to nearest point
                if len(int_points) > 1:
                    # if more intersections, find closest
                    pnt_to = closest_object(int_points, pnt_from)[0]
                else:
                    pnt_to = int_points[0]

                # at this point pnt_to is the closest intersecting point
                if pnt_from != pnt_to:  # check if lines are not already touching
                    # snap line towards pnt_to
                    if side == 'start':
                        coords[0] = pnt_to.coords[0]
                    elif side == 'end':
                        coords[-1] = pnt_to.coords[0]
                    line = LineString(coords)
                    if i1 not in idx_snapped:
                        # bookkeeping: list with changes features
                        idx_snapped.append(i1)

            lines_snap.append(line)

    if return_index:
        return lines_snap, idx_snapped
    else:
        return lines_snap


# split methods
def split_lines(lines, points=None, tolerance=0., return_index=False):
    """split lines at intersection, or if given, at points"""
    if isinstance(points, Point):
        points = [points]

    # create output list
    lines_out = []
    index_out = []

    # build spatial index
    if points is None:
        # build spatial index of line bounding boxes
        tree_idx = rtree.index.Index()
        lines_bbox = [l.bounds for l in lines]
        for i, bbox in enumerate(lines_bbox):
            tree_idx.insert(i, bbox)
    else:
        # build spatial index of points
        tree_idx = rtree.index.Index()
        for i, p in enumerate(points):
            tree_idx.insert(i, p.buffer(tolerance).bounds)

    # loop through lines and split lines with split point
    for idx, line in enumerate(lines):
        if points is None:
            # find close-by lines based on bounds with spatial index
            hits = list(tree_idx.intersection(lines_bbox[idx]))
            lines_hit = MultiLineString([lines[i] for i in hits if i != idx])
            # find line intersections
            # lines_other = [l for i, l in enumerate(lines) if i != idx]
            split_points = intersection_points([line], lines_hit, tolerance=tolerance)
        else:
            # find close-by points based on bounds of line with spatial index
            hits = list(tree_idx.intersection(line.bounds))
            points_hit = [points[i] for i in hits]
            # find points which intersects with line
            split_points = [p for p in points_hit if line.distance(p) <= tolerance]
            # split_points = [p for p in points if line.distance(p) <= tolerance]

        # check if intersections for line
        if len(split_points) >= 1:
            for p in split_points:
                line = split_line(line, p, tolerance=tolerance)
            for l in line:
                lines_out.append(l)
                index_out.append(idx)
        else:
            lines_out.append(line)
            index_out.append(idx)

    if return_index:
        return remove_redundant_nodes(lines_out), index_out
    else:
        return remove_redundant_nodes(lines_out)


def split_line(line, point, tolerance=0.):
    """split line (Shapely LineString or MultiLineString) at  point (Shapely Point),
    return splitted line (Shapely MultiLineString)"""
    if not isinstance(line, (LineString, MultiLineString)):
        raise TypeError("line should be shapely LineString or MultiLineString object")
    if not isinstance(point, Point):
        raise TypeError("point should be shapely Point object")

    # function works with MultiLineStrings to be able to use the function in a split loop
    if not isinstance(line, MultiLineString):
        line = MultiLineString([line])
    lines_out = []

    # for intersecting line, find intersecting segment and split line
    for l0 in line:
        # check if point on line, but not one of its endpoints
        if (not point.touches(l0.boundary)) and (point.distance(l0) <= tolerance):
            coords = list(l0.coords)
            segments = [LineString(s) for s in pairs(coords)]
            for i, segment in enumerate(segments):
                # find intersecting segment
                if segment.distance(point) <= tolerance:
                    if Point(coords[i]).touches(point):
                        # split line at vertex if within tolerance
                        la = LineString(coords[:i+1])
                        lb = LineString(coords[i:])
                        if (la.length > tolerance) & (lb.length > tolerance):
                            lines_out.append(la)
                            lines_out.append(lb)
                        else:
                            lines_out.append(l0)
                        break
                    else:
                        # split line at point on segment
                        la = LineString(coords[:i+1] + [(point.x, point.y)])
                        lb = LineString([(point.x, point.y)] + coords[i+1:])
                        if (la.length > tolerance) & (lb.length > tolerance):
                            lines_out.append(la)
                            lines_out.append(lb)
                        else:
                            lines_out.append(l0)
                        break
        else:
            lines_out.append(l0)

    return MultiLineString(lines_out)


def explode_polygons(polygons, return_index=False):
    """returns main line features that make up the polygons"""
    lines_out = []
    index = []

    if isinstance(polygons, Polygon):
        polygons = [polygons]
    for i, l in enumerate(polygons):
        for s in [LineString(s) for s in pairs(l.exterior.coords)]:
            lines_out.append(s)
            index.append(i)
        for p in l.interiors:
            lines_out.append(LineString(p.coords))
            index.append(i)


    if not return_index:
        return lines_out
    else:
        return lines_out, index


def clip_lines_with_polygon(lines, polygon, tolerance=1e-3, within=True, return_index=False):
    """clip lines based on polygon outline"""
    # get boundaries of polygon
    boundaries = explode_polygons(polygon)
    # find intersection points of boundaries and lines and split lines based on it
    int_points = intersection_points(lines, boundaries)
    lines_split, index = split_lines(lines, int_points, tolerance=tolerance, return_index=True)

    # select lines that are contained by polygon
    polygon_buffer = polygon.buffer(tolerance)  # small buffer to allow for use 'within' function
    if within:
        lines_clip = [line for line in lines_split if line.within(polygon_buffer)]
        index = [i for i, line in zip(index, lines_split) if line.within(polygon_buffer)]
    else:
        lines_clip = [line for line in lines_split if not line.within(polygon_buffer)]
        index = [i for i, line in zip(index, lines_split) if not line.within(polygon_buffer)]
    if not return_index:
        return lines_clip
    else:
        return lines_clip, index


# neighborhood methods
def closest_object(geometries, point):
    """Find the nearest geometry among a list, measured from fixed point.

    Args:
        geometries: a list of shapely geometry objects
        point: a shapely Point

    Returns:
        Tuple (geom, min_dist, min_index) of the geometry with minimum distance
        to point, its distance min_dist and the list index of geom, so that
        geom = geometries[min_index].
    """
    min_dist, min_index = min((point.distance(geom), k)
                              for (k, geom) in enumerate(geometries))

    return geometries[min_index], min_dist, min_index


def intersection_points(lines1, lines2=None, tolerance=0., min_spacing=0):
    """ creates list with points of line intersections. if intersection is other type than a point,
    it is broken down to points of its coordinates

    :param lines1: MultiLineString or list of lines
    :param lines2: MultiLineString or list of lines, if None find intersections amongst lines1
    :return:        list with shapely points of intersection
    """
    points = []
    tree_idx_pnt = rtree.index.Index()
    ipnt = 0

    if lines2 is None:
        # build spatial index for lines1
        tree_idx = rtree.index.Index()
        lines_bbox = [l.bounds for l in lines1]
        for i, bbox in enumerate(lines_bbox):
            tree_idx.insert(i, bbox)

    # create multilinestring of close-by lines
    for i1, l1 in enumerate(lines1):
        if lines2 is None:
            # find close-by lines based on bounds with spatial index
            hits = list(tree_idx.intersection(lines_bbox[i1]))
            lines_hit = MultiLineString([lines1[i] for i in hits if i != i1])
        else:
            lines_hit = MultiLineString(lines2)

        if tolerance > 0:
            l1 = extend_line(l1, tolerance)

        x = l1.intersection(lines_hit)
        if not x.is_empty:
            if isinstance(x, Point):
                pnts = [x]

            else:
                if isinstance(x, MultiPoint):
                    pnts = [Point(geom) for geom in x]
                elif isinstance(x, (MultiLineString, MultiPolygon, GeometryCollection)):
                    pnts = [Point(coords) for geom in x for coords in geom.coords]
                elif isinstance(x, (LineString, Polygon)):
                    pnts = [Point(coords) for coords in x.coords]
                else:
                    raise NotImplementedError('intersection yields bad type')

            for pnt in pnts:
                if min_spacing > 0:
                    if ipnt > 0:
                        hits = list(tree_idx_pnt.intersection(pnt.bounds))
                    else:
                        hits = []

                    if len(hits) == 0:  # no pnts within spacing
                        ipnt += 1
                        tree_idx_pnt.insert(ipnt, pnt.buffer(min_spacing).bounds)
                        points.append(pnt)
                else:
                    points.append(pnt)

    return points


# utils
def cap_lines(line, offset=0., length=1.):
    """
    Prepare two cap lines at the beginning and end of a LineString object
    The function can be used to prepare boundary condition lines for a hydraulic model
    Args:
        line: LineString object
        offset=0.: float, determining an offset from the beginning/end point
        length=1.: length of the cap lines (in same units as LineString coordinates)
    Returns:
        a list with two LineString objects, containing the cap lines
    """
    coords = line.coords
    if offset > 0:
        # get start & end point line
        start, end = Point(coords[0]), Point(coords[-1])
    else:  # create short line around endpoints (necessary for perpendicular line function)
        offset = 0.1
        # get start & end point line
        start = shift_point(coords[0], coords[1], 2*abs(offset))
        end = shift_point(coords[-1], coords[-2], 2*abs(offset))

    # extend line at both sides
    start_extend = shift_point(coords[0], coords[1], -2*abs(offset))
    end_extend = shift_point(coords[-1], coords[-2], -2*abs(offset))

    # make new line segments
    start_line = shapely.geometry.LineString([start, start_extend])
    end_line = shapely.geometry.LineString([end, end_extend])

    # get perpendicular lines at half length of start &  end lines
    cap1 = perpendicular_line(start_line, length)
    cap2 = perpendicular_line(end_line, length)
    return [cap1, cap2]


def shift_point(c1, c2, offset):
    """

    shift points with offset in orientation of line c1->c2
    """
    try:
        x1, y1 = c1
        x2, y2 = c2
    except:
        print(c1, c2)
    if ((x1-x2) == 0) and ((y1-y2) == 0):  # zero length line
        x_new, y_new = x1, y1
    else:
        rel_length = np.minimum(offset/np.sqrt((x1-x2)**2+(y1-y2)**2), 1)
        x_new = x1 + (x2-x1)*rel_length
        y_new = y1 + (y2-y1)*rel_length
    return Point(x_new, y_new)


def extend_line(line, offset, side='both'):
    """extend line in same orientation"""
    if side == 'both':
        sides = ['start', 'end']
    else:
        sides = [side]

    for side in sides:
        coords = line.coords
        if side == 'start':

            p_new = shift_point(coords[0], coords[1], -1. * offset)
            line = LineString([p_new] + coords[:])
        elif side == 'end':
            p_new = shift_point(coords[-1], coords[-2], -1. * offset)
            line = LineString(coords[:] + [p_new])
    return line


def perpendicular_line(l1, length):
    """Create a new Line perpendicular to this linear entity which passes
    through the point `p`.


    """
    dx = l1.coords[1][0] - l1.coords[0][0]
    dy = l1.coords[1][1] - l1.coords[0][1]

    p = Point(l1.coords[0][0] + 0.5*dx, l1.coords[0][1] + 0.5*dy)
    x, y = p.coords[0][0],  p.coords[0][1]

    if (dy == 0) or (dx == 0):
        a = length / l1.length
        l2 = LineString([(x - 0.5*a*dy, y - 0.5*a*dx),
                         (x + 0.5*a*dy, y + 0.5*a*dx)])

    else:
        s = -dx/dy
        a = ((length * 0.5)**2 / (1 + s**2))**0.5
        l2 = LineString([(x + a, y + s*a),
                         (x - a, y - s*a)])

    return l2


def pairs(lst):
    """Iterate over a list in overlapping pairs.

    Args:
        lst: an iterable/list

    Returns:
        Yields a pair of consecutive elements (lst[k], lst[k+1]) of lst. Last
        call yields (lst[-2], lst[-1]).

    Example:
        lst = [4, 7, 11, 2]
        pairs(lst) yields (4, 7), (7, 11), (11, 2)

    Source:
        http://stackoverflow.com/questions/1257413/1257446#1257446
    """
    i = iter(lst)
    prev = next(i)
    for item in i:
        yield prev, item
        prev = item


# coordinates of geoms
def add_coordinate(line, distance):
    # Cuts a line in two at a distance from its starting point
    if distance <= 0.0 or distance >= line.length:
        return line
    coords = list(line.coords)
    for i, p in enumerate(coords):
        pd = line.project(Point(p))
        if pd == distance:
            break
        if pd > distance:
            cp = line.interpolate(distance)
            line =  LineString(coords[:i] + [(cp.x, cp.y)] + coords[i:])
            break
    return line


def increase_points_line(line, spacing):
    line_length = line.length
    cp = Point(line.interpolate(line_length-spacing))
    line = LineString(line.coords[:-1] + [(cp.x, cp.y)] + [line.coords[-1]])
    for i, d in enumerate(np.arange(line_length, spacing, -spacing)):
        line = add_coordinate(line, d)
    return line


def remove_redundant_nodes(lines, tolerance=1e-7):
    """remove vertices with length smaller than tolerance"""
    lines_out = []
    for line in lines:
        coords = line.coords
        l_segments = np.array([Point(s[0]).distance(Point(s[1])) for s in pairs(coords)])
        idx = np.where(l_segments < tolerance)[0]
        lines_out.append(LineString([c for i, c in enumerate(coords) if i not in idx]))
    return lines_out