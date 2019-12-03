from pyramid.view import view_config
import numpy as np

# from .models import fm

@view_config(route_name='home', renderer='mytemplate.mak')
def home(request):
    return {'project':'bmidemo'}


@view_config(route_name='streamlines', renderer='streamlines.mak')
def streamlines(request):
    return {'project':'bmidemo'}



@view_config(route_name='ge', renderer='ge.mak')
def ge(request):
    return {'project':'bmidemo'}


# @view_config(route_name='get', renderer='binary')
# def getdata(request):
#     variable = request.context.variable
#     assert variable in ('s1', 'ucx', 'ucy'), variable
#     data = fm.get_1d_double(variable).copy()
#     data.ravel()[:data.shape[0]] = data
#     return data.astype('float32')

# @view_config(route_name='grid', renderer="json")
# def getgrid(request):
#     xk = fm.get_1d_double('xk').copy()
#     yk = fm.get_1d_double('yk').copy()
#     netelemnode = fm.get_2d_int('netelemnode').copy() - 1
#     # rescale to 0-1
#     scale = [xk.max() - xk.min(), yk.max() - yk.min()]
#     xk = (xk - xk.min())  / (xk.max() - xk.min())
#     yk = (yk - yk.min())  / (yk.max() - yk.min())
#     cells = []
#     for elem in netelemnode:
#         cells.append(
#             {
#                 'x':[xk[i] for i in elem],
#                 'y': [yk[i] for i in elem],
#                 'nodes': elem.tolist(),
#                 'points': [{'x':xk[i], 'y':yk[i], 'node':int(i)} for i in elem]
#              }
#             )
#     return {'xk':xk.tolist(), 'yk':yk.tolist(), 'cells':cells, 'scale':scale}


# # @view_config(route_name='command', renderer="json")
# # def runcommand(request):
# #     command = request.context.command
# #     assert command in ('reset', 'update')
# #     # Run the command, very unsafe
# #     kwargs = {}
# #     if command == 'update':
# #         dt = float(request.params['dt'])
# #         kwargs['dt'] = dt
# #         # Don't do updates
# #         return []
# #     getattr(fm, command)(**kwargs)
# #     return []

# @view_config(route_name='set', renderer="json")
# def setdata(request):
#     name = request.context.variable
#     cell = int(request.context.cell)
#     fm.set_1d_double_at_index(name, cell, 20.0)
#     return []
