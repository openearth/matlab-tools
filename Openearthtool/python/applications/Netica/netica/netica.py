# -*- coding: utf-8 -*-
"""
Created on Wed Nov 07 15:24:37 2012

@author: cornelisdenheijer

$Id: netica.py 13429 2017-06-30 12:20:53Z heijer $
$Date: 2017-06-30 05:20:53 -0700 (Fri, 30 Jun 2017) $
$Author: heijer $
$Revision: 13429 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/Netica/netica/netica.py $

http://www.norsys.com/onLineAPIManual/index.html
"""

import os

import exceptions
import logging

logger = logging.getLogger(__name__)

from ctypes import cdll, c_char, c_char_p, c_void_p, c_int, c_double, create_string_buffer, c_bool, POINTER, byref

c_double_p = POINTER(c_double)
from numpy.ctypeslib import ndpointer
import numpy as np
from numpy import array
import platform

# constants
MESGLEN = 600
NO_VISUAL_INFO = 0
NO_WINDOW = 0x10
MINIMIZED_WINDOW = 0x30
REGULAR_WINDOW = 0x70
if 'window' in platform.system().lower():
    from ctypes import windll

    NETICA_LIB = os.path.join(os.path.split(__file__)[0], '..', 'lib', 'Netica.dll')
else:
    from ctypes import cdll

    NETICA_LIB = os.path.join(os.path.split(__file__)[0], '..', 'lib', 'libnetica.so')


class Netica:
    """
    Wrapper for the netica dll
    """

    def __init__(self, *args, **kwargs):
        """
        initialize the Netica class
        """
        if not os.path.exists(NETICA_LIB):
            # library Netica.dll or libnetica.so not found
            err = exceptions.RuntimeError('"%s" NOT FOUND at\n %s' % (os.path.split(NETICA_LIB)[-1], NETICA_LIB))
            logger.error(err)
            raise err

        # self.ln = windll.LoadLibrary(NETICA_LIB)
        # TODO: use cdll
        if 'window' in platform.system().lower():
            self.ln = windll.LoadLibrary(NETICA_LIB)
        else:
            self.ln = cdll.LoadLibrary(NETICA_LIB)
            #        self.ln = cdll.LoadLibrary("/Users/heijer/Downloads/Netica_API_504/lib/libnetica.so")

    def newenv(self):
        """
        open environment
        """
        # (const char* license, environ_ns* env, const char* locn)
        self.ln.NewNeticaEnviron_ns.argtypes = [c_char_p, c_void_p, c_char_p]
        self.ln.NewNeticaEnviron_ns.restype = c_void_p
        return self.ln.NewNeticaEnviron_ns(None, None, None)  # env_p

    def initenv(self, env_p):
        mesg = create_string_buffer(MESGLEN)
        # (environ_ns* env, char* mesg)
        self.ln.InitNetica2_bn.argtypes = [c_void_p, c_char_p]
        self.ln.InitNetica2_bn.restype = c_int
        res = self.ln.InitNetica2_bn(env_p, mesg)
        logger.info(mesg.value)
        return res

    def closeenv(self, env_p):
        """
        close environment
        """
        # (environ_ns* env, char* mesg)
        self.ln.CloseNetica_bn.argtypes = [c_void_p, c_char_p]
        self.ln.CloseNetica_bn.restype = c_int
        mesg = create_string_buffer(MESGLEN)
        res = self.ln.CloseNetica_bn(env_p, mesg)
        logger.info(mesg.value)
        return res

    def newnet(self, name=None, env_p=None):
        """
        Creates and returns a new net, initially having no nodes
        """
        # (const char* name, environ_ns* env)
        self.ln.NewNet_bn.argtypes = [c_char_p, c_void_p]
        self.ln.NewNet_bn.restype = c_void_p
        return self.ln.NewNet_bn(name, env_p)  # net_p

    def opennet(self, env_p, name):
        """
        Creates new stream and reads net, returning a net pointer
        """
        file_p = self._newstream(env_p, name)
        return self._readnet(file_p)  # net_p

    def savenet(self, env_p, net_p, name):
        """
        Creates new stream and writes net
        """
        file_p = self._newstream(env_p, name)
        self._writenet(net_p, file_p)

    def _newstream(self, env_p, name):
        """
        create stream
        """
        # (const char* filename, environ_ns* env, const char* access)
        self.ln.NewFileStream_ns.argtypes = [c_char_p, c_void_p, c_char_p]
        self.ln.NewFileStream_ns.restype = c_void_p
        name = create_string_buffer(name)
        return self.ln.NewFileStream_ns(name, env_p, None)  # file_p

    def _readnet(self, file_p):
        """
        Reads a net from file
        """
        # (stream_ns* file, int options)
        self.ln.ReadNet_bn.argtypes = [c_void_p, c_int]
        self.ln.ReadNet_bn.restype = c_void_p
        return self.ln.ReadNet_bn(file_p, REGULAR_WINDOW)  # net_p

    def _writenet(self, net_p, file_p):
        """
        Writes net to a new file
        """
        # (const net_bn* net, stream_ns* file)
        self.ln.WriteNet_bn.argtypes = [c_void_p, c_void_p]
        self.ln.WriteNet_bn.restype = None
        self.ln.WriteNet_bn(net_p, file_p)

    def compilenet(self, net):
        """
        compile net
        """
        # (net_bn* net)
        self.ln.CompileNet_bn.argtypes = [c_void_p]
        self.ln.CompileNet_bn.restype = None
        self.ln.CompileNet_bn(net)

    def setautoupdate(self, net, auto_update=1):
        """
        """
        # (net_bn* net, int auto_update)
        self.ln.SetNetAutoUpdate_bn.argtypes = [c_void_p, c_int]
        self.ln.SetNetAutoUpdate_bn.restype = None
        self.ln.SetNetAutoUpdate_bn(net, auto_update)

    def enternodevalue(self, node_p, value):
        """
        Enter node finding as value
        """
        # (node_bn* node, double value)
        self.ln.EnterNodeValue_bn.argtypes = [c_void_p, c_double]
        self.ln.EnterNodeValue_bn.restype = None
        self.ln.EnterNodeValue_bn(node_p, value)

    def enterfinding(self, node_p, state):
        """
        Enters the discrete finding state for node. This means that in the case currently being analyzed, node is known with certainty to have value state.
        """
        # (	node_bn*  node,   state_bn  state )
        self.ln.EnterFinding_bn.argtypes = [c_void_p, c_int]
        self.ln.EnterFinding_bn.restype = None
        self.ln.EnterFinding_bn(node_p, state)

    def enternodelikelyhood(self, node_p, prob_bn):
        """
        Enters a likelihood finding for node;
        likelihood is a vector containing one probability for each state of node.
        """
        nstates = self.getnodenumberstates(node_p)
        prob_bn = array(prob_bn, dtype='float32')
        # (node_bn* node, const prob_bn* likelihood)
        self.ln.EnterNodeLikelihood_bn.argtypes = [c_void_p, ndpointer('float32', ndim=1, shape=(nstates,),
                                                                       flags='C')]  # (node_bn* node, const prob_bn* likelihood)
        self.ln.EnterNodeLikelihood_bn.restype = None
        self.ln.EnterNodeLikelihood_bn(node_p, prob_bn)

    def retractnodefindings(self, node_p):
        """
        Retract all findings from node
        """
        # (node_bn* node)
        self.ln.RetractNodeFindings_bn.argtypes = [c_void_p]
        self.ln.RetractNodeFindings_bn.restype = None
        self.ln.RetractNodeFindings_bn(node_p)

    def retractnetfindings(self, net_p):
        """
        Retracts all findings (i.e., the current case) from all the nodes in net, except "constant" nodes (use retractnodefindings for that)
        """
        # (net_bn* net)
        self.ln.RetractNetFindings_bn.argtypes = [c_void_p]
        self.ln.RetractNetFindings_bn.restype = None
        self.ln.RetractNetFindings_bn(net_p)

    def getnodenamed(self, nodename, net_p):
        """
        get node by name
        """
        # (const char* name, const net_bn* net)
        self.ln.GetNodeNamed_bn.argtypes = [c_char_p, c_void_p]
        self.ln.GetNodeNamed_bn.restype = c_void_p
        # nodename = create_string_buffer(nodename)
        node_p = self.ln.GetNodeNamed_bn(nodename, net_p)
        if node_p == None:
            logger.warning('Node with name "%s" does not exist' % nodename)
        return node_p

    def getnodenumberstates(self, node_p):
        """
        get number of states
        """
        # (const node_bn* node)
        self.ln.GetNodeNumberStates_bn.argtypes = [c_void_p]
        self.ln.GetNodeNumberStates_bn.restype = c_int
        return self.ln.GetNodeNumberStates_bn(node_p)  # nstates

    def getnodelevels(self, node_p):
        """
        Returns the list of numbers used to enable a continuous node to act discrete, or enables a discrete node to provide real-valued numbers. Levels are used to discretize continuous nodes, or to map from discrete nodes to real numbers.
        """
        node_type = self.getnodetype(node_p)
        nstates = self.getnodenumberstates(node_p)
        if node_type == 1:
            # CONTINUOUS_TYPE
            nlevels = nstates + 1
        else:
            # DISCRETE_TYPE
            nlevels = nstates
        print(nstates, nlevels)
        # (const node_bn* node)
        self.ln.GetNodeLevels_bn.argtypes = [c_void_p]
        T = ndpointer('double', ndim=1, shape=(nlevels,), flags='C')
        self.ln.GetNodeLevels_bn.restype = c_void_p
        res = self.ln.GetNodeLevels_bn(node_p)  # node_levels
        if res:
            return np.array(T(res))
        else:
            return None

    def getnodestatename(self, node_p, state=0):
        """
        Given an integer index representing a state of node, this returns the associated name of that state, or the empty string (rather than NULL) if it does not have a name.
        Either all of the states have names, or none of them do.
        """
        # GetNodeStateName_bn (	const node_bn*  node,   state_bn  state )
        self.ln.GetNodeStateName_bn.argtypes = [c_void_p, c_int]
        self.ln.GetNodeStateName_bn.restype = c_char_p
        return self.ln.GetNodeStateName_bn(node_p, state)  # node_levels

    def getnodebeliefs(self, node_p):
        """
        get node beliefs
        """
        nstates = self.getnodenumberstates(node_p)
        # (node_bn* node)
        self.ln.GetNodeBeliefs_bn.argtypes = [c_void_p]
        self.ln.GetNodeBeliefs_bn.restype = ndpointer('float32', ndim=1, shape=(nstates,), flags='C')
        return self.ln.GetNodeBeliefs_bn(node_p)  # prob_bn

    def getnetnodes(self, net_p):
        """
        get net nodes
        """
        zerochar_type = c_char * 0
        # (const net_bn* net, const char options[])
        self.ln.GetNetNodes2_bn.argtypes = [c_void_p, zerochar_type]
        self.ln.GetNetNodes2_bn.restype = c_void_p
        return self.ln.GetNetNodes2_bn(net_p, zerochar_type())  # nl_p

    def lengthnodelist(self, nl_p):
        """
        get number of nodes
        """
        # (const nodelist_bn* nodes)
        self.ln.LengthNodeList_bn.argtypes = [c_void_p]
        self.ln.LengthNodeList_bn.restype = c_int
        return self.ln.LengthNodeList_bn(nl_p)  # nnodes

    def getnodename(self, node_p):
        """
        Returns the node name as string
        """
        # (const node_bn* node)
        self.ln.GetNodeName_bn.argtypes = [c_void_p]
        self.ln.GetNodeName_bn.restype = c_char_p
        return self.ln.GetNodeName_bn(node_p)  # name

    def getnodetype(self, node_p):
        """
        Returns DISCRETE_TYPE if the variable corresponding to node is discrete (digital), and CONTINUOUS_TYPE if it is continuous (analog)
        """
        # (const node_bn* node)
        self.ln.GetNodeType_bn.argtypes = [c_void_p]
        self.ln.GetNodeType_bn.restype = c_int
        return self.ln.GetNodeType_bn(node_p)  # node_type

    def nthnode(self, nl_p, index):
        """
        Returns the node pointer at position "index" within list of nodes "nl_p"
        """
        # (const nodelist_bn* nodes, int index)
        self.ln.NthNode_bn.argtypes = [c_void_p, c_int]
        self.ln.NthNode_bn.restype = c_void_p
        return self.ln.NthNode_bn(nl_p, index)  # node_p

    def getnodeequation(self, node_p):
        """
        Returns a null terminated C character string which contains the equation associated with node, or the empty string (rather than NULL), if node does not have an equation.
        """
        # (const node_bn* node)
        self.ln.GetNodeEquation_bn.argtypes = [c_void_p]
        self.ln.GetNodeEquation_bn.restype = c_char_p
        return self.ln.GetNodeEquation_bn(node_p)  # equation

    def getnodeexpectedvalue(self, node_p):
        """
        Returns the expected real value of node, based on the current beliefs for node, and if std_dev is non-NULL, *std_dev will be set to the standard deviation. Returns UNDEF_DBL if the expected value couldn't be calculated.
        """
        # (node_bn* node, double* std_dev, double* x3, double* x4)
        self.ln.GetNodeExpectedValue_bn.argtypes = [c_void_p, c_double_p, c_double_p, c_double_p]
        self.ln.GetNodeExpectedValue_bn.restype = c_double
        stdev = c_double(9999)  # standard deviation
        x3 = c_double_p()
        x4 = c_double_p()
        expvalue = self.ln.GetNodeExpectedValue_bn(node_p, byref(stdev), x3, x4)  # expected value
        return expvalue, stdev.value

    def setnodeequation(self, node_p, eqn):
        """
        This associates the equation eqn (a null terminated C character string) as the equation of node.
        """
        # (node_bn* node, const char* eqn)
        self.ln.SetNodeEquation_bn.argtypes = [c_void_p, c_char_p]
        self.ln.SetNodeEquation_bn.restype = None
        self.ln.SetNodeEquation_bn(node_p, eqn)

    def setnodetitle(self, node_p, title):
        self.ln.SetNodeTitle_bn.argtypes = [c_void_p, c_char_p]
        self.ln.SetNodeTitle_bn.restype = None
        self.ln.SetNodeTitle_bn(node_p, title)

    def setnodestatenames(self, node_p, state_names):
        # (node_bn* node, const char* state_names)
        self.ln.SetNodeStateNames_bn.argtypes = [c_void_p, c_char_p]
        self.ln.SetNodeStateNames_bn.restype = None
        self.ln.SetNodeStateNames_bn(node_p, state_names)

    def setnodestatetitle(self, node_p, state, state_title):
        self.ln.SetNodeStateTitle_bn.argtypes = [c_void_p, c_int, c_char_p]
        self.ln.SetNodeStateTitle_bn.restype = None
        self.ln.SetNodeStateTitle_bn(node_p, state, state_title)

    def setnodelevels(self, node_p, num_states, levels):
        # (node_bn* node, int num_states, const level_bn* levels)
        self.ln.SetNodeLevels_bn.argtypes = [c_void_p, c_int,
                                             ndpointer('double', ndim=1, shape=(len(levels),), flags='C')]
        self.ln.SetNodeLevels_bn.restype = None
        self.ln.SetNodeLevels_bn(node_p, num_states, levels)

    def equationtotable(self, node_p, num_samples, samp_unc, add_exist):
        """
        Builds the CPT for node based on the equation that has been associated with it
        """
        # (node_bn* node, int num_samples, bool_ns samp_unc, bool_ns add_exist)
        self.ln.EquationToTable_bn.argtypes = [c_void_p, c_int, c_bool, c_bool]
        self.ln.EquationToTable_bn.restype = None
        self.ln.EquationToTable_bn(node_p, num_samples, samp_unc, add_exist)

    #    def revisecptsbyfindings(self, nl_p=None, updating=0, degree=0):
    #        """
    #        The current case (i.e., findings entered) is used to revise each node's conditional probabilities.
    #        """
    #        env_p = self.newenv()
    #        # (const nodelist_bn* nodes, int updating, double degree)
    #        self.ln.ReviseCPTsByFindings_bn.argtypes = [c_void_p, c_void_p, c_int, c_double]
    #        self.ln.ReviseCPTsByFindings_bn.restype = None
    #        self.ln.ReviseCPTsByFindings_bn(nl_p, updating, degree)
    def revisecptsbycasefile(self, filename='', nl_p=None, updating=0, degree=0):
        """
        Reads a file of cases from file and uses them to revise the experience and conditional probability tables (CPT) of each node in nodes.
        """
        env_p = self.newenv()
        file_p = self._newstream(env_p, filename)
        # (stream_ns* file, const nodelist_bn* nodes, int updating, double degree)
        self.ln.ReviseCPTsByCaseFile_bn.argtypes = [c_void_p, c_void_p, c_int, c_double]
        self.ln.ReviseCPTsByCaseFile_bn.restype = None
        self.ln.ReviseCPTsByCaseFile_bn(file_p, nl_p, updating, degree)

    def setnodeprobs(self, node_p, parent_states, probs):
        parenttype = ndpointer('int', ndim=1, shape=len(parent_states, ), flags='C')
        self.ln.SetNodeProbs_bn.argtypes = [
            c_void_p,
            parenttype,
            ndpointer('float32', ndim=1, shape=(len(probs),), flags='C')
        ]
        self.ln.SetNodeProbs_bn.restype = None
        import pdb
        pdb.set_trace()
        self.ln.SetNodeProbs_bn(node_p, parent_states, probs)

    def getnodeprobs(self, node_p, parent_states):
        parenttype = ndpointer('int', ndim=1, shape=len(20, ), flags='C')
        self.ln.GetNodeProbs_bn.argtypes = [
            c_void_p,
            parenttype
        ]

        self.ln.GetNodeProbs_bn.restype = c_void_p
        import pdb
        pdb.set_trace()
        probs = self.ln.GetNodeProbs_bn(node_p, parent_states)
        return probs

    def newnode(self, name=None, num_states=0, net_p=None):
        """
        Creates and returns a new node
        """
        # (const char* name, int num_states, net_bn* net)
        self.ln.NewNode_bn.argtypes = [c_char_p, c_int, c_void_p]
        self.ln.NewNode_bn.restype = c_void_p
        return self.ln.NewNode_bn(name, num_states, net_p)  # node_p

    def deletenode(self, node_p=None):
        """
        Removes node from its net, and frees all resources (e.g. memory) it was using
        """
        # (node_bn* node)
        self.ln.DeleteNode_bn.argtypes = [c_void_p]
        self.ln.DeleteNode_bn.restype = None
        self.ln.DeleteNode_bn(node_p)

    def addlink(self, parent=None, child=None):
        """
        Adds a link from node parent to node child, and returns the index of the added link
        """
        # (node_bn* parent, node_bn* child)
        self.ln.AddLink_bn.argtypes = [c_void_p, c_void_p]
        self.ln.AddLink_bn.restype = c_int
        return self.ln.AddLink_bn(parent, child)  # link_index

    def deletelink(self, link_index=1, child=None):
        """
        Removes the link going to child from the link_indexth parent node of child
        """
        # (int link_index, node_bn* child)
        self.ln.DeleteLink_bn.argtypes = [c_int, c_void_p]
        self.ln.DeleteLink_bn.restype = None
        self.ln.DeleteLink_bn(link_index, child)

    def reverselink(self, parent=None, child=None):
        """
        Reverses the link from parent to child, so that instead it goes from child to parent
        """
        # (node_bn* parent, node_bn* child)
        self.ln.ReverseLink_bn.argtypes = [c_void_p, c_void_p]
        self.ln.ReverseLink_bn.restype = None
        return self.ln.ReverseLink_bn(parent, child)  # link_index

    def switchnodeparent(self, link_index=1, node_p=None, new_parent=None):
        """
        Makes node new_parent a parent of node by replacing the existing parent at the link_indexth position, without modifying node's equation, or any of node's tables (such as CPT table or function table).
        """
        # (int link_index, node_bn* node, node_bn* new_parent)
        self.ln.ReverseLink_bn.argtypes = [c_int, c_void_p, c_void_p]
        self.ln.ReverseLink_bn.restype = None
        return self.ln.SwitchNodeParent_bn(link_index, node_p, new_parent)