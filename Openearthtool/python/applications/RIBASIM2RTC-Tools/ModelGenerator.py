import os
import argparse
import shp_to_mo
from collections import namedtuple, OrderedDict
import shapefile
from network import *
import cvktools2015 as cvk

R2M = {'RIB_QSW': ['QSW_','Deltares.ChannelFlow.SimpleRouting.Branches.Steady'], 
       'RIB_ADVIR': ['ADVIR_','Deltares.ChannelFlow.SimpleRouting.Nodes.Node'],
       'RIB_CONFL': ['CONFL_','Deltares.ChannelFlow.SimpleRouting.Nodes.Node'],
       'RIB_DUMMY': ['DUMMY_','Deltares.ChannelFlow.SimpleRouting.Nodes.Node'],
       'RIB_FIXIRR': ['FIXIRR_','Deltares.ChannelFlow.SimpleRouting.Nodes.Node'],
       'RIB_LOWFL': ['LOWFL_','Deltares.ChannelFlow.SimpleRouting.Nodes.Node'],
       'RIB_PWS': ['PWS_','Deltares.ChannelFlow.SimpleRouting.Nodes.Node'],
       'RIB_RSV': ['RSV_','Deltares.ChannelFlow.SimpleRouting.Reservoir.Reservoir'],
       'RIB_RSV': ['RSV_','Deltares.ChannelFlow.SimpleRouting.Storage.Storage'],
       'RIB_TERM': ['TERM_','Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal'],
       'RIB_DIV': ['DIV_', 'Deltares.ChannelFlow.SimpleRouting.Nodes.Node'],
       'RIB_VARINF': ['VARINF_','Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow'],
       'RIB_FIXINF': ['FIXINF_', 'Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow'],
       'RIB_RUNOFRIV': ['RUNOFRIV_', 'Deltares.ChannelFlow.SimpleRouting.Nodes.Node'],
       'RIB_QDV': ['QDV_', 'Deltares.ChannelFlow.SimpleRouting.Branches.Steady'],
       'Else': ['NO_','Deltares.ChannelFlow.SimpleRouting.Nodes.Node'],
       }

FromTo = {"Ribasim": {"from": "ID_FROM","to":"ID_TO"}, "RTC":{"from": "FRM_MEL_ID","to": "TO_MEL_ID"}}


class RibaNetwork(object):
    def __init__(self, shp_path_nodes, shp_path_branches, shp_path_template_nodes, shp_path_template_branches):
        # Make sure that we are working with ordered dicts, to keep things deterministic
        self._node_dict = OrderedDict()  # id to object
        self._branch_dict = OrderedDict()  # id to object

        self.__build(shapefile.Reader(shp_path_nodes), shapefile.Reader(shp_path_branches), shapefile.Reader(shp_path_template_nodes), shapefile.Reader(shp_path_template_branches))

    def stats(self):
        return {"n_branches": len(self._branch_dict), "n_nodes": len(self._node_dict)}

    @property
    def nodes(self):
        return self._node_dict.values()

    @property
    def branches(self):
        return self._branch_dict.values()

    def add_node(self, n):
        self._node_dict[n.id] = n

    def add_branch(self, b):
        self._branch_dict[b.id] = b

#        if b._start_node:
#            b._start_node._branches.add(b)
#        if b._end_node:
#            b._end_node._branches.add(b)
#        if b._conn_branch:
#            self._branch_dict[b]

    def __build(self, n_sf, b_sf, t_n, t_b):
        # First we add all the nodes
        keys = [x[0] for x in t_n.fields[1:]]  # template - Skip DeletionFlag
        dkeys = [x[0] for x in n_sf.fields[1:]] # data-keys
#        print keys
#        print dkeys
#        print "n_sf", n_sf
#        print n_sf

        #shapeRecs = n_sf.iterShapeRecords()  #records() and shapes() reads the whole file into memory. iterShapeRecords would allow to iter one at a time.
#        print n_sf.shapeType
#        print len(n_sf), n_sf.bbox
#        print n_sf.fields
#        shapes = n_sf.shapes()
#        for name in dir(shapes[3]):
#            if not name.startswith('__'):
#                print name
         
        # get a template row
        trec = t_n.records()[0]
        trow = dict(zip(keys, trec))
      
        for shapeRec in n_sf.iterShapeRecords():
            trow2 = trow
            # create dictionary from keys and records to make it retrievable
            # the keys all had length 10 (filled with spaces to the right. apply strip:)
            strippedkeys = []
            for k in dkeys:
                ##print len(k.strip())
                strippedkeys.append(k.strip())
            ##print strippedkeys
            n_data = dict(zip(strippedkeys, shapeRec.record))  
            ##print "n_data:", n_data
            ##print n_data.keys()
            ##print n_data["PARENTID"], R2M[n_data["PARENTID"]] 
            ##print "trow2", trow2
          
            #replace the information in our template row
            trow2['MO_TYPE'] = R2M[n_data["PARENTID"]][1]
            trow2['MEL_NAME'] = R2M[n_data["PARENTID"]][0]+n_data['ID']
            trow2['MEL_ID'] = n_data['ID']
            #print trow2
            # store the template row in node_data
            node_data = trow2
            # add the node with XY data and table information
            self.add_node(Node(shapeRec.shape.points[0], **node_data))
#        # Next, we add the branches (which refer to nodes).   ### here # do the same for branches
        keys = [x[0] for x in t_b.fields[1:]]
        dkeys = [x[0] for x in b_sf.fields[1:]]  # Skip DeletionFlag
        shapeRecs = b_sf.iterShapeRecords()
        
        ##print keys
        ##print dkeys
        ##print "b_sf", b_sf
            
        # get a template row
        trec = t_b.records()[0]
        trow = dict(zip(keys, trec))

        for shapeRec in b_sf.iterShapeRecords():
            trow2 = trow
            # create dictionary from keys and records to make it retrievable
            # the keys all had length 10 (filled with spaces to the right. apply strip:)
            strippedkeys = []
            for k in dkeys:
                ##print len(k.strip())
                strippedkeys.append(k.strip())
            ##print strippedkeys
            n_data = dict(zip(strippedkeys, shapeRec.record))  
           
    
            #replace the information in our template row
            trow2['MO_TYPE'] = R2M[n_data["PARENTID"]][1]
            trow2['MEL_NAME'] = R2M[n_data["PARENTID"]][0]+n_data['ID']
            trow2['MEL_ID'] = n_data['ID']
            trow2['MEL_INTID'] = n_data['ID']
            trow2['SW_TYPE'] = R2M[n_data["PARENTID"]][0]
            trow2['FRM_MEL_ID'] = n_data["ID_FROM"]
            trow2['TO_MEL_ID'] = n_data["ID_TO"]
        
            
            #print trow2
    
            # store the template row in node_data
            branch_data = trow2
        
    
            b = Branch(shapeRec.shape.points, **branch_data)
    
            self.add_branch(b)



        # add the connections, upstream nodes if not QSO, downstream nodes or branches, add laterals to downstream branches.
        # This can only be done after all branches have been added to the dictionary
        for b in self.branches:
            ##print b.mo_type
            b.QOUT_MAX = 100000
            b.QOUT_MIN = 0
            b.QIN_MAX = b.QOUT_MAX
            b.QIN_MIN = b.QOUT_MIN
            if not b.mo_type == 'Deltares.ChannelFlow.SimpleRouting.Storage.QSO':
                ##print "not a reservoir" 
                ##print b.FRM_MEL_ID
                ##print self._node_dict
                try:
                    b._start_node = self._node_dict[b.FRM_MEL_ID]
                    #print self._node_dict[b.FRM_MEL_ID]
                    b._start_node._branches.add(b)
                except:
                    print('ERROR Network: missing start node {} listed in branch {}. Check availability in Nodes.dbf'.format(
                        b.frm_mel_id,b.id))
            try:
                b._end_node = self._node_dict[b.TO_MEL_ID]
                b._end_node._branches.add(b)
            except:
                try:
                    b._conn_branch = self._branch_dict[b.TO_MEL_ID]
                    self._branch_dict[b._conn_branch.id].add_lateral(b)
                except:
                    print('ERROR Network: missing end object {} listed in branch {}. Check availability in Nodes.dbf of Network.dbf'.format(
                        b.to_mel_id, b.id))

        print('INFO Network: completed parsing network connections')
#        # check for proper spelling rules in the ids
#        #msg = self.checkspelling_ids()
#        #if msg:
#        #    for line in msg: print('ERROR Network:' + line)
#        print('INFO Network: completed reading network')

#we are going to simultaneously create a mo-model and a ribasim model
#let's read!

ws=cvk.folder()
print (ws.fp)

#Input
#locations of the input shapefiles:
# The folder with Modelica shape file for definition
modelicashp = cvk.folder(ws.fp+r"Input\Modelica\shp")

# The folder with RIBASIM model shape file
ribasimshp = cvk.folder(ws.fp+r"Input\RIBASIM\shp")
ribasimshp = cvk.folder(ws.fp+r"020RIBASIM\shp")

# The output path
outputpath = cvk.folder(ws.fp+"Output\model")
outputpath = cvk.folder(ws.fp+"020RTC-Tools\model")

# the shape files itself
moshp = Network(modelicashp.fp+'nodes.shp',modelicashp.fp+'network.shp')
rishp = RibaNetwork(ribasimshp.fp+'NODES.shp', ribasimshp.fp+'LINKS.shp', modelicashp.fp+'nodes.shp', modelicashp.fp+'network.shp')

#s = Network(os.path.join(args.path,'model','shp','nodes.shp'), os.path.join(args.path,'model','shp', 'network.shp'))
m = shp_to_mo.MoBuilder(network=rishp, model_name='RIBASIM', dst=outputpath.fp, model_schematisation_type='RIBASIM')
print (m)
m.build_mo_blocks()
m.write_mo()
