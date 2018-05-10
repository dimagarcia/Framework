install.packages("XMLRPC")
# package ‘XMLRPC’ is not available (for R version 3.3.2)
source("https://bioconductor.org/biocLite.R")
biocLite("RCytoscape")
biocLite()

# 2017-JUN-20 Build Lactose Control Network with RCytoscape
library("RCytoscape")
cy = CytoscapeConnection ()
pluginVersion (cy)

g <- new ('graphNEL', edgemode='directed')
g <- graph::addNode ('lacA', g)
g <- graph::addNode ('lacI', g)
g <- graph::addNode ('lacY', g)
g <- graph::addNode ('lacZ', g)
g <- graph::addNode ('rpoD', g)
g <- graph::addNode ('znuA', g)
cw <- new.CytoscapeWindow ('Module 34 – Lactose transport (GO:0015767)', graph=g, overwriteWindow=TRUE)
displayGraph (cw)
#
layoutNetwork (cw, layout.name='grid')
redraw (cw)
#
##
g <- cw@graph
g <- initEdgeAttribute (graph=g, attribute.name='edgeType',attribute.type='char',default.value='regulates to')
g <- initEdgeAttribute (graph=g, attribute.name='weight',attribute.type='numeric',default.value='unspecified')

g <- graph::addEdge ('lacA', 'lacI', g)
g <- graph::addEdge ('lacA', 'lacY', g)
g <- graph::addEdge ('lacA', 'lacZ', g)
g <- graph::addEdge ('lacA', 'rpoD', g)
g <- graph::addEdge ('lacA', 'znuA', g)
g <- graph::addEdge ('lacI', 'lacA', g)
g <- graph::addEdge ('lacI', 'lacY', g)
g <- graph::addEdge ('lacI', 'lacZ', g)
g <- graph::addEdge ('lacI', 'rpoD', g)
g <- graph::addEdge ('lacI', 'znuA', g)
g <- graph::addEdge ('lacY', 'lacA', g)
g <- graph::addEdge ('lacY', 'lacI', g)
g <- graph::addEdge ('lacY', 'lacZ', g)
g <- graph::addEdge ('lacY', 'rpoD', g)
g <- graph::addEdge ('lacY', 'znuA', g)
g <- graph::addEdge ('lacZ', 'lacA', g)
g <- graph::addEdge ('lacZ', 'lacI', g)
g <- graph::addEdge ('lacZ', 'lacY', g)
g <- graph::addEdge ('lacZ', 'rpoD', g)
g <- graph::addEdge ('lacZ', 'znuA', g)
g <- graph::addEdge ('rpoD', 'lacA', g)
g <- graph::addEdge ('rpoD', 'lacI', g)
g <- graph::addEdge ('rpoD', 'lacY', g)
g <- graph::addEdge ('rpoD', 'lacZ', g)
g <- graph::addEdge ('rpoD', 'znuA', g)
g <- graph::addEdge ('znuA', 'lacA', g)
g <- graph::addEdge ('znuA', 'lacI', g)
g <- graph::addEdge ('znuA', 'lacY', g)
g <- graph::addEdge ('znuA', 'lacZ', g)
g <- graph::addEdge ('znuA', 'rpoD', g)

#edgeData (g, 'A', 'B', 'edgeType') <- 'phosphorylates'
#edgeData (g, 'B', 'C', 'edgeType') <- 'promotes'
#edgeData (g, 'C', 'A', 'edgeType') <- 'indirectly activates'

edgeData (g, 'lacA', 'lacI', 'weight') <- 0.19
edgeData (g, 'lacA', 'lacY', 'weight') <- 0.56
edgeData (g, 'lacA', 'lacZ', 'weight') <- 0.5
edgeData (g, 'lacA', 'rpoD', 'weight') <- 0.2
edgeData (g, 'lacA', 'znuA', 'weight') <- 0.20
edgeData (g, 'lacI', 'lacA', 'weight') <- 0.8
edgeData (g, 'lacI', 'lacY', 'weight') <- 0.9
edgeData (g, 'lacI', 'lacZ', 'weight') <- 0.9
edgeData (g, 'lacI', 'rpoD', 'weight') <- 0.52
edgeData (g, 'lacI', 'znuA', 'weight') <- 0.51
edgeData (g, 'lacY', 'lacA', 'weight') <- 0.43
edgeData (g, 'lacY', 'lacI', 'weight') <- 0.1
edgeData (g, 'lacY', 'lacZ', 'weight') <- 0.43
edgeData (g, 'lacY', 'rpoD', 'weight') <- 0.13
edgeData (g, 'lacY', 'znuA', 'weight') <- 0.12
edgeData (g, 'lacZ', 'lacA', 'weight') <- 0.49
edgeData (g, 'lacZ', 'lacI', 'weight') <- 0.18
edgeData (g, 'lacZ', 'lacY', 'weight') <- 0.56
edgeData (g, 'lacZ', 'rpoD', 'weight') <- 0.19
edgeData (g, 'lacZ', 'znuA', 'weight') <- 0.18
edgeData (g, 'rpoD', 'lacA', 'weight') <- 0.79
edgeData (g, 'rpoD', 'lacI', 'weight') <- 0.47
edgeData (g, 'rpoD', 'lacY', 'weight') <- 0.86
edgeData (g, 'rpoD', 'lacZ', 'weight') <- 0.8
edgeData (g, 'rpoD', 'znuA', 'weight') <- 0.5
edgeData (g, 'znuA', 'lacA', 'weight') <- 0.79
edgeData (g, 'znuA', 'lacI', 'weight') <- 0.48
edgeData (g, 'znuA', 'lacY', 'weight') <- 0.87
edgeData (g, 'znuA', 'lacZ', 'weight') <- 0.81
edgeData (g, 'znuA', 'rpoD', 'weight') <- 0.5

cw@graph <- g
displayGraph (cw)
# setEdgeTargetArrowRule (cw, 'edgeType', edgeType.values, arrow.styles)
# attribute.names = eda.names (cw@graph)
# for (attribute.name in attribute.names)
#  result = setEdgeAttributes (cw, attribute.name)

# setEdgeAttributesDirect(obj, attribute.name, attribute.type, edge.names, values)
for (edge in g@nodes)
setEdgeAttributesDirect(cw, attribute.name='weight', 'numeric', edge.names = g@nodes, values)
displayGraph (cw)
#
layoutNetwork (cw, layout.name='grid')
redraw (cw)
#
eda.names (cw@graph)
attribute.names = eda.names (cw@graph)
 for (attribute.name in attribute.names)
  result = setEdgeAttributes (cw, attribute.name)
displayGraph (cw)
redraw (cw)
#
g <- cw@graph
#setEdgeLabelDirect(obj, edge.names, new.value)
setEdgeLabelDirect(cw, g@nodes, 'weight')
displayGraph (cw)
redraw (cw)
###########################################################################################
edges.of.interest = as.character (cy2.edge.names (cw@graph))
supported.arrow.shapes = getArrowShapes (cw)

# first try passing three edges and three arrow shapes
setEdgeTargetArrowShapeDirect (cw, edges.of.interest, supported.arrow.shapes [2:5])
redraw (cw)

Sys.sleep (1)

# now try passing three edges and one arrow.shapes
setEdgeTargetArrowShapeDirect (cw, edges.of.interest, supported.arrow.shapes [6])
redraw (cw)

# now loop through all of the arrow.shapes

for (shape in supported.arrow.shapes) {
  setEdgeTargetArrowShapeDirect (cw, edges.of.interest, shape)
  Sys.sleep (1)
  redraw (cw)
}
# set arrow
edges.of.interest = as.character (cy2.edge.names (cw@graph))
getArrowShapes (cw)
setEdgeTargetArrowShapeDirect (cw, edges.of.interest, 'Arrow')
redraw (cw)
# sort
layoutNetwork (cw, 'hierarchical')
redraw (cw)
# show weiht
getVisualStyleNames (cw)
setVisualStyle(cw, 'Sample1')
#setVisualStyle(cw, 'default')

###########################################################################################
# restore the default
setEdgeTargetArrowShapeDirect (cw, edges.of.interest, 'No Arrow')
redraw (cw)