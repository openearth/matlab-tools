"""This script features the Tree class. Some of the methods are difficult to understand due to their recursive nature. It also is (not yet) perfect.

Credit for the one-line tree generation goes to https://gist.github.com/hrldcpr/2012250 . I turned it into a class and extended the class with some additional methods.

"""
from collections import defaultdict

class Tree:
    """Class to genenerate and show tree data structure.

    Notes
    -----
    Labeled nodes are created without actual values.
    This data structure is only useable for qualitative data.

    For a quick introduction to tree data structure, see for example
    http://pages.cs.wisc.edu/~skrentny/cs367-common/readings/Trees/
    I use the term 'branch' instead of 'path'

    The tree currently only works and is tested for a tree with unique nodes; that is, each node has a unique name. 
    For example, creating a tree with branches 'D>A' and 'B>A', will cause issues with some methods; for example the ones concerning finding the branch to a leaf. 
    One can of course always create a child class of this class and override methods that do do not work as wanted.
    """
    def __init__(self):
        """Initialize Tree. Uses a recursive function __tree().
        """
        self.tree = self.__tree()

    def __str__(self):
        """Method to print Tree. Uses recursive function __show().

        Returns
        -------
        self.showtree : string
            result of the recursive __show() function that returns a string representation of the tree.
        """
        self.showtree = ''
        return self.__show(self.tree)
         
    def __tree(self): 
        """Recursive function to generate Tree. This is the core method of this class. 

        Each node is a default dictionary, with its child node as its value.
        
        Defaultdict is used as it lets you add keys without values. In this case the values are added in the next recursive round.
        
        Returns
        -------
        Defaultdict (of a defaultdict of a defaultdict etc...)
        """        
        return defaultdict(self.__tree)
    
    def __add(self,t, branch):
        """Recursive helper method to add branches to a Tree. Looks inside a list and adds each element of the list to a default dictionary as the next node.

        This method looks confusing at first. 
        
        Parameters
        ----------           
        branch : list
            List with nodes as its elements; the order of the nodes in this list is important. List is given by add method.
        
        t : defaultdic
            The Tree.
        """
        for node in branch:
            t = t[node]
 
    def add(self,branch):
        """Method to add branch to Tree. Makes use of recursive helper method __add()

        Parameters
        ----------        
        branch : string
            String with a branch of the Tree. Parent nodes are seperated with >. Example: 'Permanent>Water>Peil_kanaal
        """
        self.__add(self.tree,branch.split('>'))
       
    def __leaf(self,t, depth = 0):
        """Helper method for leafs(). Adds leafs to a list by looking for nodes that do not have any keys anymore.

        Parameters
        ----------
        t : defaultdic
            The Tree
        
        depth : int
            Counter that keeps track of the depth of the current node
        """
        for k in t.keys():
            if not t[k].keys():
                self.leafs.append(k)
            depth += 1
            self.__leaf(t[k], depth)
            depth -= 1
        return self.leafs
            
    def leaf(self):
        """Method that calls a recursive helper method to find leafs and initiates a list to add these leafs.

        Returns
        -------
        A call to the recursive helper method __leaf() with self.tree as its value.
        """
        self.leafs = []
        return self.__leaf(self.tree)
        
    def __show(self,t, depth = 0):
        """Method to make a string representation of a tree. This can then be used by the __str__ method for printing.

        Parameters
        ----------
        t : defaultdic
            The tree
        
        depth : int
            Counter that keeps track of the depth of the current node
        
        Returns
        -------
        showtree : string
            String representation of the tree.
        """    
        for k in t.keys():
            self.showtree += "%s %2d %s" % ("".join(depth * ["    "]), depth, k) + '\n'
            depth += 1
            self.__show(t[k], depth)
            depth -= 1
        return self.showtree
    
    def get_branch(self,leaf):
        """Method to get the branch that leads to a leaf. 

        Parameters
        ----------
        leaf : string
            Name of the leaf of interest
        
        Returns
        -------
        Call to a recursive helper method that finds the branch belonging to a respective leaf and adds it to self.branch
        """
        self.branch = ''
        return self.__get_branch(self.tree,leaf)
    
    def __get_branch(self,t,leaf):
        """Recursive helper method to find the branch belonging to a leaf and add it to a string. 

        Parameters
        ----------
        t : defaultdic
            The tree
        
        leaf : string
            Name of the leaf of interest
            
        Returns
        -------
        self.branch : string
            The branch of interest
        """ 
        for k in t.keys():
            if leaf in t[k].keys():
                self.branch = k + '>' + self.branch
                self.__get_branch(self.tree,k)
            else:
                self.__get_branch(t[k],leaf)      
        return self.branch

    def apply_node(self):
        """Method that can be overrided to do something if check_node() returns True.
        """      
        pass
    
    def check_node(self,node):
        """Method to check whether a certain node is present in the tree. Calls the apply method if check is met. 

        Parameters
        ----------
        node : string
            Node of interest
        
        Returns
        -------
        c : boolean
            Flag that indicates whether a node is present in the tree or not.
        """            
        self.check = False
        c = self.__check_node(self.tree,node)
        if c == True:
            self.apply_node()
        return c
    
    def __check_node(self,t,node):
        """Recursive helper method that checks whether a node is present in a tree or not.

        Parameters
        ---------
        t : defaultdic
            The tree
        
        node : string
            Node of interest
        
        Returns
        -------
        self.check : boolean
            Flag that indicates whether a node is present in the tree or not.
        """               
        for k in t.keys():
            if node in t.keys():
                self.check = True
            else:
                self.__check_node(t[k],node)
        return self.check
    
