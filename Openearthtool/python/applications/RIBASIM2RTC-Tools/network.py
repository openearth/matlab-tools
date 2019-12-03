from collections import namedtuple, OrderedDict
import shapefile
import logging
logger = logging.getLogger("rtctools")


Point = namedtuple('Point', ['x', 'y'])


# These objects do not care about where the data is stored (i.e. a shape
# file). They only care that certain fields with certain names exist, i.e. the
# MEL_ID and MEL_NAME fields. You can also try to get any attribute, but an
# error will be raised if it's not in the shape file.
class NetworkObject(object):
    @property
    def id(self):
        try:
            # FIXME: used workaround "upper" until input shapefiles use case sensitive names
            return self.attributes.get('MEL_ID')
        except KeyError as e:
            raise AttributeError(e)

    @property
    def name(self):
        try:
            return self.attributes.get('MEL_NAME')
        except KeyError as e:
            raise AttributeError(e)

    @property
    def mo_type(self):
        try:
            return self.attributes.get('MO_TYPE')
        except KeyError as e:
            raise AttributeError(e)

    def __getattr__(self, key):
        try:
            return self.attributes.get(key)
        except KeyError as e:
            raise AttributeError(e)


class Node(NetworkObject):
    def __init__(self, loc, **kwargs):
        self.loc = Point(*loc)
        self.attributes = kwargs
        self._branches = set()

    def get_branches(self):
        return self._branches

    @property
    def n_in(self):
        return [b.TO_MEL_ID for b in self.get_branches()].count(self.id)

    @property
    def n_out(self):
        return [b.FRM_MEL_ID for b in self.get_branches()].count(self.id)

    @property
    def n_QForcing(self):
        # no forcings on nodes
        return 0 

class Branch(NetworkObject):
    def __init__(self, points, **kwargs):
        self.points = [Point(*x) for x in points]
        self.attributes = kwargs
        self._laterals = []


    @property
    def frm_mel_id(self):
        try:
            return str(self.attributes.get('FRM_MEL_ID')).strip()
        except KeyError as e:
            raise AttributeError(e)

    @property
    def to_mel_id(self):
        try:
            return str(self.attributes.get('TO_MEL_ID')).strip()
        except KeyError as e:
            raise AttributeError(e)

    @property
    def start_node(self):
        return self._start_node

    @property
    def end_node(self):
        return self._end_node

    @property
    def start_loc(self):
        return self.points[0]

    @property
    def end_loc(self):
        return self.points[-1]

    @property
    def conn_branch(self):
        return self._conn_branch

    @property
    def laterals(self):
        return self._laterals

    def add_lateral(self, lateral):
        self._laterals.append(lateral)

    @property
    def n_QLateral(self):
        return len(self.laterals)

    @property
    def n_QForcing(self):
        return int(self.attributes.N_QFORC)


# The Network class can translate from a shape file into a network object
# consisting of branches and nodes.
class Network(object):
    def __init__(self, shp_path_nodes, shp_path_branches):
        # Make sure that we are working with ordered dicts, to keep things deterministic
        self._node_dict = OrderedDict()  # id to object
        self._branch_dict = OrderedDict()  # id to object

        self.__build(shapefile.Reader(shp_path_nodes), shapefile.Reader(shp_path_branches))

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

    def __build(self, n_sf, b_sf):
        # First we add all the nodes
        keys = [x[0] for x in n_sf.fields[1:]]  # Skip DeletionFlag
        #cvk print keys
        #cvk print "n_sf", n_sf
        shapeRecs = n_sf.iterShapeRecords()
        
        for shapeRec in shapeRecs:
            node_data = dict(zip(keys, shapeRec.record))
            
            self.add_node(Node(shapeRec.shape.points[0], **node_data))
            
        # Next, we add the branches (which refer to nodes).
        keys = [x[0] for x in b_sf.fields[1:]]  # Skip DeletionFlag
        shapeRecs = b_sf.iterShapeRecords()
        
        for shapeRec in shapeRecs:
            branch_data = dict(zip(keys, shapeRec.record))
            b = Branch(shapeRec.shape.points, **branch_data)

            self.add_branch(b)



        # add the connections, upstream nodes if not QSO, downstream nodes or branches, add laterals to downstream branches.
        # This can only be done after all branches have been added to the dictionary
        for b in self.branches:
            if not b.mo_type == 'Deltares.ChannelFlow.SimpleRouting.Storage.QSO':
                try:
                    b._start_node = self._node_dict[b.FRM_MEL_ID]
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
        # check for proper spelling rules in the ids
        msg = self.checkspelling_ids()
        if msg:
            for line in msg: print('ERROR Network:' + line)
        print('INFO Network: completed reading network')

    def checkspelling_ids(self):

        errormsg = []
        unique_ids = []
        non_unique_ids = []
        ids_with_spaces = []
        ids_with_dot = []
        ids_with_colon = []
        ids_with_semicolon = []
        ids_with_dash = []
        ids_with_slash = []
        ids_with_backslash = []
        ids_with_leftstraighthook = []
        ids_with_rightstraighthook = []

        for n in self.nodes:
            if n.id in unique_ids:
                #if n.id not in non_unique_ids:
                non_unique_ids.append(n.id)
            else:
                unique_ids.append(n.id)
            if " " in n.id: ids_with_spaces.append(n.id)
#            if len(n.id) <> len(n.id.strip(" ")): ids_with_spaces.append(n.id)
            if "." in n.id: ids_with_dot.append(n.id)
            if ":" in n.id: ids_with_colon.append(n.id)
            if ";" in n.id: ids_with_semicolon.append(n.id)
            if "/" in n.id: ids_with_slash.append(n.id)
            if "\'" in n.id: ids_with_backslash.append(n.id)
            if "-" in n.id: ids_with_dash.append(n.id)
            if "[" in n.id: ids_with_leftstraighthook.append(n.id)
            if "]" in n.id: ids_with_rightstraighthook.append(n.id)

        bids = set(b.id.lower() for b in self.branches)
        for b in self.branches:
            if set(b.id.lower().split()) & bids:
                #if b.id not in non_unique_ids:
                unique_ids.append(b.id)

            else:
                non_unique_ids.append(b.id)#unique_ids.append(b.id)

            if " " in b.id: ids_with_spaces.append(b.id)
            if "." in b.id: ids_with_dot.append(b.id)
            if ":" in b.id: ids_with_colon.append(b.id)
            if ";" in b.id: ids_with_semicolon.append(b.id)
            if "/" in b.id: ids_with_slash.append(b.id)
            if "\'" in b.id: ids_with_backslash.append(b.id)
            if "-" in b.id: ids_with_dash.append(b.id)
            if "[" in b.id: ids_with_leftstraighthook.append(b.id)
            if "]" in b.id: ids_with_rightstraighthook.append(b.id)

        if non_unique_ids:
            errormsg.append('{} DUPLICATE identifiers detected {}.'.format(len(non_unique_ids),non_unique_ids))
        if ids_with_dot:
            errormsg.append('{} identifiers detected with (.) {}.'.format(len(ids_with_dot),ids_with_dot))
        if ids_with_colon:
            errormsg.append('{} identifiers detected with COLON(:) {}.'.format(len(ids_with_colon),ids_with_colon))
        if ids_with_semicolon:
            errormsg.append('{} identifiers detected with SEMICOLON(;) {}.'.format(len(ids_with_semicolon),ids_with_semicolon))
        if ids_with_dash:
            errormsg.append('{} identifiers detected with (-) {}.'.format(len(ids_with_dash),ids_with_dash))
        if ids_with_spaces:
            errormsg.append('{} identifiers detected with SPACES {}.'.format(len(ids_with_spaces),ids_with_spaces))
        if ids_with_slash:
            errormsg.append('{} identifiers detected with (/) {}.'.format(len(ids_with_slash),ids_with_slash))
        if ids_with_backslash:
            errormsg.append('{} identifiers detected with (\) {}.'.format(len(ids_with_backslash),ids_with_backslash))
        if ids_with_leftstraighthook:
            errormsg.append('{} identifiers detected with [ {}.'.format(len(ids_with_leftstraighthook),ids_with_leftstraighthook))
        if ids_with_rightstraighthook:
            errormsg.append('{} identifiers detected with ] {}.'.format(len(ids_with_rightstraighthook),ids_with_rightstraighthook))

        return errormsg


if __name__ == "__main__":
    s = Network('../../shp/NHI-verificationmodel8/shp\\NHI-verificationmodel8.shp', '../../shp/NHI-verificationmodel8/shp\\NHI-verificationmodel8_network.shp')
    print( s.stats())
    for n in s.nodes:
        print( 'NODE', n.id)
        for b in n._branches:
            print( 'branch', b.id, b.QOUT_MIN)
