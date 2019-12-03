import re

import networkx as nx
from networkx.drawing.nx_agraph import read_dot


regex = r'^{([a-zA-Z0-9_]+).*}'

G = read_dot('callgraph_final.dot')
for u, v in G.edges():
    source_se = re.search(regex, G._node[u]['label'])
    target_se = re.search(regex, G._node[v]['label'])
    print (source_se.group(1) + ":" + target_se.group(1))
