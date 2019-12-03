# Assuming that the Shape files are correct, this code automatically generates control variables, connections, inputs and outputs.
# Note if the Nodes.dbf is incorrect (e.g. MEL_ID or MO_TYPE), exceptions may occur on branches with a slight hint that nodes are problematic


#FIXME: 
# Checking if model is valid is also not done.
# Annotations are done in a small part. No coordinates yet
# No support for level boundaries/nodes yet

import os
import logging
logger = logging.getLogger("rtctools")

class MoBuilder:
    """
    Build a Modelica-file (.mo) based on a shape file with nodes and one with branches.
    """

    model_header            = None
    nodes_header            = ["Nodes"]
    bc_header               = ["Boundary conditions"]
    branches_header         = ["Branches"]
    qso_header              = ["SQO"]
    input_header            = ["Input. These come either as time series (fixed = true) or from the optimizer (fixed = false), which is the default."]
    output_header           = ["Output"]
    connectors_header       = ["Connectors"]
    alias_inputs_header     = ["Assign inputs"]
    control_q_header        = ["Aliasing control variables: discharge"]
    control_forc_header     = ["Aliasing control variables: forcings"]
    alias_outputs_q_header  = ["Alias outputs for discharge"]
    alias_v_header          = ["Alias outputs for volume"]
    equals_header           = ["Series fixed by equal min/max range"]

    node_submodel               = "Deltares.ChannelFlow.SimpleRouting.Nodes.Node"
    bc_inflow_submodel          = "Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow"
    terminal_submodel           = "Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal"
    steady_submodel             = "Deltares.ChannelFlow.SimpleRouting.Branches.Steady"
    integrator_submodel         = "Deltares.ChannelFlow.SimpleRouting.Branches.Integrator"
    qso_submodel                = "Deltares.ChannelFlow.SimpleRouting.Storage.QSO"
    reservoir_submodel = "Deltares.ChannelFlow.SimpleRouting.Storage.Storage"
#    reservoir_submodel = "Deltares.ChannelFlow.SimpleRouting.Reservoir.Reservoir"    

    input_label         = "input"
    output_label        = "output"
    connector_label     = "connect"

    node_attributes         = ['n_QForcing', 'nin', 'nout']
    branch_attributes       = ['n_QForcing', 'n_QLateral']
    qso_attributes          = ['n_QForcing']
    fixed_attributes        = ['fixed']
    range_attributes        = ['min', 'max']
    scaling_attributes      = ['min', 'max', 'nominal']
    reservoir_attributes = ['min', 'max', 'nominal']

    model_imports = ["import SI = Modelica.SIunits;"]

    unit_dict   = {'discharge':'SI.VolumeFlowRate',
                   'discharge in':'SI.VolumeFlowRate',
                   'discharge out':'SI.VolumeFlowRate',
                   'discharge forcing':'SI.VolumeFlowRate',
                   'volume':'SI.Volume'}
    sh_dict     = {'discharge':'Q',
                   'discharge in':'QIn',
                   'discharge out':'QOut',
                   'discharge control':'QOut_control',
                   'discharge forcing':'QForcing',
                   'discharge lateral':'QLateral',
                   'volume':'V'}
    sub_var_dict= {'discharge':'Q',
                   'discharge in':'QIn.Q',
                   'discharge out':'QOut.Q',
                   'discharge control':'QOut_control',
                   'discharge forcing':'QForcing[1]',
                   'discharge lateral':'QLateral',
                   'volume':'V'}
    ext_var_dict= {'discharge':'Q',
                   'discharge in':'QIn',
                   'discharge out':'QOut',
                   'discharge forcing':'QForcing',
                   'discharge lateral':'QLateral',
                   'volume':'V'}
                   
    def __init__(self, network, model_name, dst, model_schematisation_type):
        self.network    = network
        self.model_name = model_name
        self.dst        = dst
        self.model_schematisation_type = model_schematisation_type

    def build_mo_blocks(self):
        # Go through the complete network (nodes and branches) and construct
        # the Modelica declarations needed.

        def attributes_list(attributes, values):
            return ['%s=%s' % t for t in zip(attributes, values)]

        def link_declaration(el_id, p):
            return "{}.{} = {}_{};".format(el_id, self.sub_var_dict[p], el_id, self.ext_var_dict[p])

        def control_declaration(node, i, p):
            return "{}.{}[{}] = {};".format(node, self.sh_dict[p], i[0], i[1])

            # Build a standard Modelica declaration
        def declaration(label, el_id=None, attributes=None, values=None, nested_attributes=None, unit=None, annotation=None):
            string = label
            if unit is not None:
                string += " {}".format(unit)
            if el_id is not None:
                string += " {}".format(el_id)

            sub_string = ""
            if attributes is not None or nested_attributes is not None:
                sub_string = "("
                attr_strings = []
                if attributes is not None:
                    attr_strings += attributes_list(attributes, values)
                if nested_attributes is not None:
                    attr_strings += nested_attributes
                sub_string += "{})".format(', '.join('%s' % t for t in attr_strings))
            return string + sub_string + (" " + annotation if annotation is not None else "") + ";"

        # These blocks will be filled with lines of declarations
        nodes_block           = []
        bc_block              = []
        branches_block        = []
        qso_block             = []
        input_block           = []
        output_block          = []
        connectors_block      = []
        alias_inputs_block    = []
        alias_v_block         = []
        control_q_block       = []
        control_forc_block    = []
        alias_outputs_q_block = []
        all_qout_dict         = {}
        control_qin           = []
        equals_block          = []

        # For bookkeeping
        terminal_nodes         = []
        inflow_nodes           = []
        nodes_with_qin         = []
        nodes_with_qout        = []
        seen_node_from         = []
        seen_node_to           = []
        seen_branch_lateral_in = []
        branches_parsed     = []
        nodes_parsed        = []
        all_nodes = {}

        ## Nodes
        print('INFO start generating nodes, input en output blocks')
        for el in self.network.nodes:
            print (el.name)
            if el.id in nodes_parsed:
                print('ERROR: NodeId {} is duplicate listed in nodes shape'.format(el.id))
            else:
                nodes_parsed.append(el.id)
                all_nodes[el.id] = el.name
            if el.MO_TYPE == self.node_submodel:
                n_QForcing = el.n_QForcing
                if "FIXIRR" in el.name:
                    n_QForcing = 1
                if "PWS" in el.name:
                    n_QForcing = 1
                values = [n_QForcing, el.n_in, el.n_out]
                nodes_block.append(declaration(self.node_submodel, el.name,
                                               self.node_attributes, values))
            elif el.MO_TYPE == self.reservoir_submodel:
                values = [0, 999999999999.9,555555555555.5]
                p = "volume"
                nested_attributes = ["V(min= {}, max={}, nominal={})".format(values[0], values[1], values[2])]
                nodes_block.append(declaration(self.reservoir_submodel, el.name, None, None, nested_attributes))                                                                   
                output_block.append(declaration(self.output_label, el.name + '_{}'.format(self.sh_dict[p]), unit=self.unit_dict[p]))                
                alias_v_block.append(link_declaration(el.name,p))

            else:
                #FIXME: get parameter from somewhere?
                p = "discharge"
                if el.MO_TYPE == self.bc_inflow_submodel:
                    #FIXME: get values from somewhere?
                    values = ['true']
                    input_block.append(declaration(self.input_label, el.name + '_{}'.format(self.sh_dict[p]), unit=self.unit_dict[p],
                                               attributes=self.fixed_attributes, values=values))
# also need to add range attributes from el.QOUT_MIN, el.QOUT_MAX, as well as el.QIN_MIN, el.QIN_MAX 
# el.'{}_{}'.format(ucase(self.sh_dict[p]), MIN),el.'{}_{}'.format(ucase(self.sh_dict[p]), MAX)


                elif el.MO_TYPE == self.terminal_submodel:
                    #FIXME: needs additional filtering if it's input or output (or none?), now get too many
# also need to add range attributes from el.QOUT_MIN, el.QOUT_MAX, as well as el.QIN_MIN, el.QIN_MAX 
# el.'{}_{}'.format(ucase(self.sh_dict[p]), MIN),el.'{}_{}'.format(ucase(self.sh_dict[p]), MAX)
                    output_block.append(declaration(self.output_label, el.name + '_{}'.format(self.sh_dict[p]), unit=self.unit_dict[p]))
                    
                else:
                    print( 'ERROR: Unsupported MO_TYPE {} in nodes shape'.format(el.MO_TYPE))
                    continue # go to next element

                bc_block.append(declaration(el.MO_TYPE, el.name))
                #FIXME: needs additional filtering if it's input or output (or none?), now get too many
                #FIXMEDONE: only applies for bc_inflow_model
                alias_inputs_block.append(link_declaration(el.name, p))

        print('INFO finished generating nodes, input and output blocks')
        print('INFO start generating branch and connection blocks')

        ## Branches
        for el in self.network.branches:
            if el.id in branches_parsed:
                print('ERROR: BranchId {} is duplicate listed in branches/network shape'.format(el.id))
            else:
                branches_parsed.append(el.id)

            # Make connector blocks and link output blocks.
            p = "discharge in"
            #                alias_outputs_q_block.append(link_declaration(el.id, p))
            branch_in = el.name + '.{}'.format(self.sh_dict[p])
            branch_qin = el.name + '_{}'.format(self.sh_dict[p])
            branch_inq = branch_in+'.{}'.format(self.sh_dict['discharge'])
            p = "discharge out"
            branch_out = el.name + '.{}'.format(self.sh_dict[p])
            branch_outq= branch_out + '.{}'.format(self.sh_dict['discharge'])           
            print (el.name,  " ", el.start_node.name,  " ", el.end_node.name)

            if el.start_node:
                seen_node_from.append(el.start_node.id)
                node_from = el.start_node.name + '.{}[{}]'.format(self.sh_dict['discharge out'],seen_node_from.count(el.start_node.id))
                inflownode_from = el.start_node.name + '.{}'.format(self.sh_dict['discharge out'])
                reservoirnode_from = el.start_node.name + '.{}'.format(self.sh_dict['discharge out'])
                if el.start_node.mo_type == self.bc_inflow_submodel:
                    if el.start_node.id in inflow_nodes:
                        print('ERROR Shp_to_Mo: multiple branches start from inflow node {}, branch {}'.format(el.start_node.id, el.id))
                    else:
                        connectors_block.append(
                        declaration(self.connector_label, nested_attributes=[inflownode_from, branch_in],
                                    annotation="annotation(Line)"))
                        inflow_nodes.append(el.start_node.id)
                elif el.start_node.mo_type == self.reservoir_submodel:

                    connectors_block.append(declaration(self.connector_label, nested_attributes=[reservoirnode_from, branch_in], annotation="annotation(Line)"))
                else:
                    connectors_block.append(declaration(self.connector_label, nested_attributes=[node_from, branch_in],
                                                        annotation="annotation(Line)"))
                if el.start_node.mo_type == self.node_submodel and not el.start_node.id in nodes_with_qout:
                    nodes_with_qout.append(el.start_node.id)

                if el.start_node.id in all_qout_dict:
                    qout_list = all_qout_dict[el.start_node.id]
                else:
                    qout_list = []
                qout_list.append([seen_node_from.count(el.start_node.id), branch_qin])
                all_qout_dict[el.start_node.id] = qout_list
            elif not el.MO_TYPE == self.qso_submodel:
                print('ERROR Shp_to_Mo: expected start node for branch {}'.format(el.id))

            if el.end_node:
                seen_node_to.append(el.end_node.id)
                node_to = el.end_node.name + '.{}[{}]'.format(self.sh_dict['discharge in'],seen_node_to.count(el.end_node.id))
                terminalnode_to = el.end_node.name + '.{}'.format(self.sh_dict['discharge in'])
                reservoirnode_to = el.end_node.name + '.{}'.format(self.sh_dict['discharge in'])
                if el.end_node.mo_type == self.terminal_submodel:
                    if el.end_node.id in terminal_nodes:
                        print( 'ERROR Shp_to_Mo: multiple branches connect to terminal node {}, branch {}'.format(el.end_node.id, el.id))
                    else:
                        connectors_block.append(declaration(self.connector_label, nested_attributes=[branch_out, terminalnode_to],
                                                    annotation="annotation(Line)"))
                        terminal_nodes.append(el.end_node.id)
                elif el.end_node.mo_type == self.reservoir_submodel:
                    connectors_block.append(declaration(self.connector_label, nested_attributes=[branch_out, reservoirnode_to], annotation="annotation(Line)"))
                else:
                    connectors_block.append(declaration(self.connector_label, nested_attributes=[branch_out, node_to],
                            annotation="annotation(Line)"))

                if el.end_node.mo_type == self.node_submodel and not el.end_node.id in nodes_with_qin:
                    nodes_with_qin.append(el.end_node.id)
            elif el.conn_branch:
                seen_branch_lateral_in.append(el.conn_branch.id)
                # FIXME:Should also be alias_inputs block...
                p = "discharge out"
                branch_from = el.node + '.{}'.format(self.sh_dict[p])
                p = "discharge forcing"
                p = "discharge lateral"
                branch_lateral_in = el.conn_branch.name + '.{}[{}]'.format(self.sh_dict[p], seen_branch_lateral_in.count(
                    el.conn_branch.id))

                connectors_block.append(
                    declaration(self.connector_label, nested_attributes=[branch_from, branch_lateral_in],
                                annotation="annotation(Line)"))

            else:
                print('ERROR Shp_to_Mo: expected end node or end branch for branch {}').format(el.id)

        print('INFO finished generating connection blocks')
        print('INFO start checking completeness of connections')

        for node in all_qout_dict:
            for i in all_qout_dict[node][:-1]:
                p = 'discharge control'
                control_qin.append(i[1])
#                control_q_block.append(control_declaration(all_nodes[node], i, p))

        for el in self.network.nodes:
            if el.mo_type== self.node_submodel:
                if not el.id in nodes_with_qin:
                    logger.error('DistributionModel: node without in-port connection {}'.format(el.id))
                    print( 'ERROR: node without in-port connection {}'.format(el.id))
                if not el.id in nodes_with_qout:
                    logger.error('DistributionModel: node without out-port connection {}'.format(el.id))
                    print('ERROR: node without out-port connection {}'.format(el.id))

        for el in self.network.branches:

            if el.MO_TYPE == self.steady_submodel or el.MO_TYPE == self.integrator_submodel:

                p = "discharge in"
                if el.QIN_MAX is None or el.QIN_MIN is None:
                    print(
                        'WARNING Shp_to_Mo: no complete in-port range (min and max) defined for {}. Please fix'.format(
                            el.id))
                elif el.id + '_{}'.format(self.sh_dict[p]) in control_qin:
                    inrange_values = [el.QIN_MIN, el.QIN_MAX]
                    if el.QIN_MIN > el.QIN_MAX:
                        print('ERROR Please fix network.dbf and ensure QIN_MIN <= QIN_MAX for element {}'.format(el.id))
                    elif el.QIN_MIN == el.QIN_MAX:
                        if el.QIN_MIN == 0 and el.QOUT_MIN == el.QOUT_MAX and el.QOUT_MAX ==0:
                            print('WARNING Capacity-range 0 detected potentially causing model problems. Please give QIN_MIN/MAX or QOUT_MIN/MAX some capacity for element {}'.format(el.id))
                        equals_block.append(el.id + '_{} = {};'.format(self.sh_dict[p], el.QIN_MIN))
                        output_block.append(declaration(self.output_label, el.name + '_{}'.format(self.sh_dict[p]),
                                unit=self.unit_dict[p]))
                    else:
                        input_block.append(declaration(self.input_label, el.id + '_{}'.format(self.sh_dict[p]),
                                unit=self.unit_dict[p],attributes=self.range_attributes, values=inrange_values))
                else:
                    inrange_values = [el.QIN_MIN, el.QIN_MAX]
                    if el.QIN_MIN > el.QIN_MAX:
                        print('ERROR Please fix network.dbf and ensure QIN_MIN <= QIN_MAX for element {}'.format(el.id))
                    elif el.QIN_MIN == el.QIN_MAX:
                        equals_block.append(el.id + '_{} = {};'.format(self.sh_dict[p], el.QIN_MIN))

                        output_block.append(declaration(self.output_label, el.name + '_{}'.format(self.sh_dict[p]),
                                unit=self.unit_dict[p]))
                        if el.QIN_MIN == 0 and el.QOUT_MIN == el.QOUT_MAX and el.QOUT_MAX ==0:
                            print( 'WARNING Capacity-range 0 detected potentially causing model problems. Please give QIN_MIN/MAX or QOUT_MIN/MAX some capacity for element {}'.format(el.id))
                    else:
                        output_block.append(declaration(self.output_label, el.name + '_{}'.format(self.sh_dict[p]),
                                unit=self.unit_dict[p], attributes=self.range_attributes,values=inrange_values))
                    alias_outputs_q_block.append(link_declaration(el.name,p))
            if el.MO_TYPE == self.integrator_submodel or el.MO_TYPE == self.qso_submodel or self.steady_submodel:
                p = "discharge out"
                if el.QOUT_MAX is None or el.QOUT_MIN is None:
                    print('WARNING Shp_to_Mo: no complete out-port range (min and max) defined for {}. Please fix'.format(el.id))
                elif not el.id + '_{}'.format(self.sh_dict['discharge control']) in control_qin:

                    outrange_values = [el.QOUT_MIN,el.QOUT_MAX]
                    if el.QOUT_MIN > el.QOUT_MAX:
                        print('ERROR Please fix network.dbf and ensure QOUT_MIN <= QOUT_MAX for element {}'.format(el.id))
                    elif el.QOUT_MIN == el.QOUT_MAX:
                        equals_block.append(el.id + '_{} = {};'.format(self.sh_dict[p], el.QOUT_MIN))
                        output_block.append(declaration(self.output_label, el.name + '_{}'.format(self.sh_dict[p]),
                                                        unit=self.unit_dict[p]))
                        if el.QIN_MIN == 0 and el.QIN_MIN == el.QIN_MAX and el.QOUT_MAX ==0:
                            print( 'WARNING Capacity-range 0 detected potentially causing model problems. Please give QIN_MIN/MAX or QOUT_MIN/MAX some capacity for element {}'.format(el.id))
                    else:
                        output_block.append(declaration(self.output_label, el.name + '_{}'.format(self.sh_dict[p]), unit=self.unit_dict[p],
                                       attributes=self.range_attributes, values=outrange_values))
                    alias_outputs_q_block.append(link_declaration(el.name, p))
                if int(el.N_QFORC) == 1:
                    if self.model_schematisation_type == 'NHI':
                        if el.ROUTE_TYPE == "rivier" or el.ROUTE_TYPE == "rijkswater":
                            range_values = ['-200', '200']
                        else:
                            range_values = ['-50', '50']
                    else:
                        range_values = ['-1000', '1000']

                    nForc_value = int(el.N_QFORC)
                    p = "discharge forcing"
                    input_block.append(declaration(self.input_label, el.id + '_{}'.format(self.sh_dict[p]),
                            unit=self.unit_dict[p],attributes=self.range_attributes, values=range_values))
                    control_forc_block.append(link_declaration(el.id, p))
                elif int(el.N_QFORC) == 0:
                    nForc_value = int(el.N_QFORC)
                else:
                    nForc_value = '0'
                    print('WARNING Shp_to_Mo: missing N_QFORC field, assumed no forcing defined for {}.'.format(el.id))

            if el.MO_TYPE == self.integrator_submodel or el.MO_TYPE == self.qso_submodel:

                if el.V_MAX is None or el.V_MIN is None or el.V_NOMINAL is None:
                    print('WARNING Shp_to_Mo: no complete volume range (min, max, nominal) defined for {}. Please fix'.format(
                            el.id))
                elif float(el.V_NOMINAL) < 1:
                    print(
                        'WARNING Shp_to_Mo: recommendation to set nominal volume to at least 1 for {}. Please fix'.format(el.id))
                else:
                    nested_attributes = ["V(min= {}, max={}, nominal={})".format(el.V_MIN, el.V_MAX, el.V_NOMINAL)]
                    range_values = [el.V_MIN, el.V_MAX]
                    p = "volume"
                    output_block.append(declaration(self.output_label, el.name + '_{}'.format(self.sh_dict[p]), unit = self.unit_dict[p]))
                    alias_v_block.append(link_declaration(el.id,p))
            if el.MO_TYPE == self.steady_submodel:
                n_values = [nForc_value, el.n_QLateral]
                branches_block.append(declaration(el.MO_TYPE, el.name, self.branch_attributes, n_values))
            elif el.MO_TYPE == self.integrator_submodel:
                n_values = [nForc_value, el.n_QLateral]
                branches_block.append(declaration(el.MO_TYPE, el.name, self.branch_attributes, n_values, nested_attributes))
            elif el.MO_TYPE == self.qso_submodel:
                n_values = [nForc_value]
                branches_block.append(declaration(el.MO_TYPE, el.name, self.qso_attributes, n_values, nested_attributes))
            else:
                print('WARNING Shp_to_Mo: unknown MO_TYPE {}. Supported types: {}, {}, {}.'.format(el.MO_TYPE,
                    self.steady_submodel, self.integrator_submodel, self.qso_submodel))




        self.nodes_block           = nodes_block
        self.bc_block              = bc_block
        self.branches_block        = branches_block
        self.qso_block             = qso_block
        self.input_block           = input_block
        self.output_block          = output_block
        self.connectors_block      = connectors_block
        self.alias_inputs_block    = alias_inputs_block
        self.alias_v_block         = alias_v_block
        self.control_q_block       = control_q_block
        self.control_forc_block    = control_forc_block
        self.alias_outputs_q_block = alias_outputs_q_block
        self.equals_block          = equals_block
        
    def write_mo(self):
        # Write the declarations blocks constructed before
        fname = os.path.join(self.dst, self.model_name + '.mo')
        print (fname)
        f = open(fname, 'w')

        def write_line(line, indent=0, line_end=True, comment=False):
            f.write("  "*indent + ("// " if comment else "") + line + ("\n" if line_end else ""))

        def write_comment(line, indent=0, line_end=True):
            write_line(line, indent, line_end, comment=True)

        def write_block(block, indent=0, header_block=None, line_end=True, comment=False):
            if header_block is not None:
                for line in header_block:
                    write_comment(line, indent, line_end)
            block.sort()

            if len(block) > 0:
                for line in block:
                    write_line(line, indent, line_end, comment)
            else:
                print('Received an empty block. Not writing anything...')
            write_line("")

        def declaration(sub_model, el_id, attributes=None, values=None, nested_attributes=None, unit=None):
            string = sub_model
            if unit is not None:
                string += " {}".format(unit)
            string += " {}".format(el_id)

            sub_string = ""
            if attributes is not None or nested_attributes is not None:
                sub_string = " ("
                attr_strings = []
                if attributes is not None:
                    attr_strings += ['%s=%s' % t for t in zip(attributes, values)]
                if nested_attributes is not None:
                    attr_strings += nested_attributes
                sub_string += "{})".format(', '.join('%s' % t for t in attr_strings))
            return string + sub_string + ";"

        ### Model block
        write_line("model {}".format(self.model_name))

        ## Imports and general header if present
        indent=1
        if len(self.model_imports) > 0:
            write_block(self.model_imports, indent)
        else:
            print('INFO: Modelica imports block is empty. Not writing anything...')

        if not self.model_header: #cvk 2018
            print('INFO: Header block is empty. Not writing anything...')
        else:
            write_line(self.model_header)
            
        #if len(self.model_header) > 0:
            #write_line(self.model_header)
        #else:
            #print('INFO: Header block is empty. Not writing anything...')

        ## Boundary conditions block
        if len(self.bc_block) > 0:
            write_block(self.bc_block, indent, self.bc_header)
        else:
            print('INFO: Boundary conditions definition block is empty. Not writing anything...')


        ## Nodes block
        if len(self.nodes_block) > 0:
            write_block(self.nodes_block, indent, self.nodes_header)
        else:
            print('INFO: Nodes definition block is empty. Not writing anything...')


        ## Branches block
        if len(self.branches_block) > 0:
            write_block(self.branches_block, indent, self.branches_header)
        else:
            print('INFO: Branches definition block is empty. Not writing anything...')

        ## QSO block
#        if len(self.qso_block) > 0:
#            write_block(self.qso_block, indent, self.qso_header)
#        else:
#            print "INFO: QSO block is empty. Not writing anything..."


        ## Inputs block
        if len(self.input_block) > 0:
            write_block(self.input_block, indent, self.input_header)
        else:
            print('INFO: Input block is empty. Not writing anything...')

        ## Outputs block
        if len(self.output_block) > 0:
            write_block(self.output_block, indent, self.output_header)
        else:
            print('INFO: Output block is empty. Not writing anything...')

        ### Equation block
        indent=0
        write_line("equation", indent)
        indent=1

        ## Connectors block
        if len(self.connectors_block) > 0:
            write_block(self.connectors_block, indent, self.connectors_header)
        else:
            print('INFO: Connectors block is empty. Not writing anything...')

        ## Link inputs block
        if len(self.alias_inputs_block) > 0:
            write_block(self.alias_inputs_block, indent, self.alias_inputs_header)
        else:
            print('INFO: Aliasing inputs block is empty. Not writing anything...')

        ## Controls block
        if len(self.control_q_block) > 0:
            write_block(self.control_q_block, indent, self.control_q_header)
        else:
            print('INFO: Aliasing qout control block is empty. Not writing anything...')

        if len(self.control_forc_block) > 0:
            write_block(self.control_forc_block, indent, self.control_forc_header)
        else:
            print('INFO: Aliasing forcings control block is empty. Not writing anything...')

        if len(self.alias_v_block) > 0:
            write_block(self.alias_v_block, indent, self.alias_v_header)
        else:
            print('INFO: Aliasing volume block is empty. Not writing anything...')

        ## Link outputs block
        # Discharge
        if len(self.alias_outputs_q_block) > 0:
            write_block(self.alias_outputs_q_block, indent, self.alias_outputs_q_header)
        else:
            print('INFO: Aliasing non-controlled discharge block is empty. Not writing anything...')

        if len(self.equals_block) > 0:
            write_block(self.equals_block, indent, self.equals_header)
        else:
            print("INFO: non of the variables are constrained by equal min/max range. Not writing anything...")

        ### Close model
        indent=0
        write_line("end {};".format(self.model_name), indent)
        f.close
