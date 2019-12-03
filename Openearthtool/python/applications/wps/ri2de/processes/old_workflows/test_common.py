import common
import shapely
from shapely import ops
import numpy
import rasterio

def test_cut_1():
	# test to verify if function cut will cut a line segment exactly in half
	A = shapely.geometry.Point(0, 0)
	B = shapely.geometry.Point(2, 0)
	AB = shapely.geometry.LineString([A, B])
	r = common.cut(AB, 1)
	l1 = r[0].length
	l2 = r[1].length
	assert l1==1
	assert l2==1
def test_cut_2():
	#Checks whether, when split_length is greater than line length, the result is the original linestring
	A = shapely.geometry.Point(0, 0)
	B = shapely.geometry.Point(2, 0)
	AB = shapely.geometry.LineString([A, B])
	r = common.cut(AB, 2.1)
	length = r[0].length

	assert len(r) == 1
	assert length == 2

def test_cut_3():
	#test to verify if function cut will split a multipoint linestring into segments with correct length
	A = shapely.geometry.Point(0, 0)
	B = shapely.geometry.Point(3,4)
	C = shapely.geometry.Point(5,4)
	ABC = shapely.geometry.LineString([A, B, C])
	r = common.cut(ABC,6)

	assert r[0].length==6
	assert r[1].length==1


def test_split_linestring_1():
	#dividing up linestring into 10 even segments. checking length of result list and values
	A = shapely.geometry.Point(0.0, 0.0)
	B = shapely.geometry.Point(1.0, 0.0)
	AB = shapely.geometry.LineString([A, B])
	r = common.split_linestring(AB, 0.1)
	assert len(r)==10
	total_length = 0
	for item in r:
		total_length = item.length+total_length
	assert total_length==AB.length

def test_split_linestring_2():
	#dividing up linestring into 3 uneven segments. checking length of result list and values
	A = shapely.geometry.Point(0.0, 0.0)
	B = shapely.geometry.Point(1.0, 0.0)
	AB = shapely.geometry.LineString([A, B])
	r = common.split_linestring(AB, 0.3)
	assert len(r)==4
	total_length = 0
	for item in r:
		total_length = item.length+total_length
	assert total_length==AB.length
def test_split_linestring_3():
	#to ensure that if split length is greater than linestring length, that the full original linestring is returned
	A = shapely.geometry.Point(0.0, 0.0)
	B = shapely.geometry.Point(1.0, 0.0)
	AB = shapely.geometry.LineString([A, B])
	r = common.split_linestring(AB, 2)
	assert len(r)==1
	total_length = 0
	for item in r:
		total_length = item.length+total_length
	assert total_length==AB.length
def test_check_divisibility_1():
	#checks whether check_divisibility can successfully detect if a linestring length is divisible by a certain length
	A = shapely.geometry.Point(0.0, 0.0)
	B = shapely.geometry.Point(1.0, 0.0)
	AB = shapely.geometry.LineString([A, B])
	l = AB.length
	assert common.check_divisibility(l, 0.1)==True
	assert common.check_divisibility(l, 0.2)==True
	assert common.check_divisibility(l, 0.3) == False
	assert common.check_divisibility(l, 0.4) == False

def test_ops_line_merge_1():
	#testing out native shapely.ops linemerge method with arbitrary orderings of the linestrings and point definitions

	A = shapely.geometry.Point(0, 5)
	B = shapely.geometry.Point(1, 4)
	C = shapely.geometry.Point(6, 2)
	D = shapely.geometry.Point(10, 8)
	E = shapely.geometry.Point(20, 10)
	F = shapely.geometry.Point(10, 1)
	G = shapely.geometry.Point(20, 5)

	#regular ordering of points
	AB = shapely.geometry.LineString([A, B])
	BC = shapely.geometry.LineString([B, C])
	CD = shapely.geometry.LineString([C, D])
	CF = shapely.geometry.LineString([C, F])
	FG = shapely.geometry.LineString([F, G])
	DE = shapely.geometry.LineString([D, E])

	#regular ordering of linestrings
	multi_line_string = shapely.geometry.MultiLineString([AB, BC, CD, CF, FG, DE])
	out = ops.linemerge(multi_line_string)
	assert len(out)==3
	assert out[0].xy[0][0] == 0
	assert out[0].xy[0][1] == 1
	assert out[0].xy[1][0] == 5
	assert out[0].xy[1][1] == 4
	assert len(out[0].xy[0]) ==3

	#irregular ordering of linestrings
	multi_line_string = shapely.geometry.MultiLineString([DE, FG, CD, AB, BC, CF])
	out_irregular_linestrings = ops.linemerge(multi_line_string)
	assert len(out) == 3
	assert out[0].xy[0][0] == 0
	assert out[0].xy[0][1] == 1
	assert out[0].xy[1][0] == 5
	assert out[0].xy[1][1] == 4
	assert len(out[0].xy[0]) == 3
	assert out == out_irregular_linestrings

def test_split_linestring_list_1():
	#checks if a list of three linestrings will be split properly
	A =  shapely.geometry.Point(0.0, 0.0)
	B =  shapely.geometry.Point(1, 0.0)
	C =  shapely.geometry.Point(4,4)
	D =  shapely.geometry.Point(5, -6)
	E =  shapely.geometry.Point(8.2, -5)

	linestring_1 = shapely.geometry.LineString([A,B,C])
	linestring_2 = shapely.geometry.LineString([D,E])

	linestring_list = [linestring_1,linestring_2]
	r = common.split_linestring_list(linestring_list,0.5)

	assert len(r)==19
	assert r[11].xy[0][1] ==4
	assert r[11].xy[1][1] == 4
	assert r[12].xy[0][0] == 5
	assert r[12].xy[1][0] == -6

def test_number_of_segments_1():
	#checks if number of segments for line is calculated correctly
	A = shapely.geometry.Point(0.0, 0.0)
	B = shapely.geometry.Point(1.0, 0.0)
	AB = shapely.geometry.LineString([A, B])

	assert common.number_of_segments(AB, 0.1) == 10
	assert common.number_of_segments(AB, 0.2) == 5
	assert common.number_of_segments(AB, 0.3) == 4
	assert common.number_of_segments(AB, 0.33) == 4
	assert common.number_of_segments(AB, 0.4) == 3
	assert common.number_of_segments(AB,2) == 1

def test_buffer_linestring_1():
	#testing if buffered linestring with flat end caps has the right polygon vertex coordinates
	A = shapely.geometry.Point(0, 0)
	B = shapely.geometry.Point(2, 0)
	AB = shapely.geometry.LineString([A, B])
	buffer = common.buffer_linestring(AB, 1)

	assert buffer.bounds == (0.0,-1.0,2.0,1.0)

def test_extract_by_mask_1():
	#check if polygon extracts correct cells by checking if the sum of the cell values is correct (diagonal polygon)
	r = rasterio.open('raster.asc')
	p = shapely.geometry.Polygon([[0, 0], [0.3, 0.1], [1.58, 1.5], [2, 2], [1.56, 1.8], [0.1, 0.4]])
	m = common.extract_by_mask(r, p)
	m = m[0]
	m_unmasked = m[m.mask == False]
	m_unmasked = m_unmasked.data

	assert m_unmasked[0] == 4
	assert m_unmasked[1] == 7
	assert m_unmasked[2] == 10
	assert m_unmasked[3] == 13

def test_extract_by_mask_2():
	#check if polygon extracts correct cells by checking if the sum of the cell values is correct (diagonal polygon)
	r = rasterio.open('raster.asc')
	p = shapely.geometry.Polygon([[0, 0], [1, 0], [1, 1], [0, 1]])
	m = common.extract_by_mask(r, p)
	m = m[0]
	m_unmasked = m[m.mask == False]
	m_unmasked = m_unmasked.data

	assert m_unmasked[0] == 9
	assert m_unmasked[1] == 10
	assert m_unmasked[2] == 13
	assert m_unmasked[3] == 14
def test_compute_statistic_1():
	#testing mean method
	r = rasterio.open('raster.asc')
	p = shapely.geometry.Polygon([[0, 0], [1, 0], [1, 1], [0, 1]])
	m = common.extract_by_mask(r, p)
	m = m[0]
	result = common.compute_statistic(m, 'mean')
	assert result==11.5

def test_compute_statistic_2():
	#testing max method
	r = rasterio.open('raster.asc')
	p = shapely.geometry.Polygon([[0, 0], [1, 0], [1, 1], [0, 1]])
	m = common.extract_by_mask(r, p)
	m = m[0]
	result = common.compute_statistic(m, 'max')
	assert result==14

def test_compute_statistic_3():
	#testing max method
	r = rasterio.open('raster.asc')
	p = shapely.geometry.Polygon([[0, 0], [1, 0], [1, 1], [0, 1]])
	m = common.extract_by_mask(r, p)
	m = m[0]
	result = common.compute_statistic(m, 'min')
	assert result==9

def test_compute_statistic_list_1():
	r = rasterio.open('raster.asc')
	p1 = shapely.geometry.Polygon([[0, 0], [1, 0], [1, 1], [0, 1]])
	p2 = shapely.geometry.Polygon([[0, 0], [0.3, 0.1], [1.58, 1.5], [2, 2], [1.56, 1.8], [0.1, 0.4]])
	geometry_list = [p1, p2]
	stat_list = common.compute_statistic_list(geometry_list, r, 'mean')  # should be [11.5,8.5]
	assert stat_list == [11.5, 8.5]
	stat_list = common.compute_statistic_list(geometry_list, r, 'max')
	assert stat_list == [14,13]
	stat_list = common.compute_statistic_list(geometry_list, r, 'min')
	assert stat_list == [9, 4]