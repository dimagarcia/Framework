library (RCytoscape)
cy = CytoscapeConnection ()
pluginVersion (cy)

g <- new ('graphNEL', edgemode='directed')
g <- graph::addNode ('iscA', g)
g <- graph::addNode ('iscR', g)
g <- graph::addNode ('iscS', g)
g <- graph::addNode ('iscU', g)
g <- graph::addNode ('iscX', g)
g <- graph::addNode ('nfuA', g)

cw <- new.CytoscapeWindow ('Minimal Ecoli Iron Sulfur Sample 6', graph=g, overwriteWindow=TRUE)
displayGraph (cw)
#
layoutNetwork (cw, layout.name='grid')
redraw (cw)

g <- cw@graph
g <- initEdgeAttribute (graph=g, attribute.name='edgeType',attribute.type='char',default.value='regulates to')
# g <- initEdgeAttribute (graph=g, attribute.name='weight',attribute.type='numeric',default.value='unspecified')
g <- initEdgeAttribute (graph=g, attribute.name='weight',attribute.type='char',default.value='unspecified')

g <- graph::addEdge ('iscR','iscA', g)
g <- graph::addEdge ('iscR','iscS', g)
g <- graph::addEdge ('iscR','iscU', g)
g <- graph::addEdge ('iscR','iscX', g)
g <- graph::addEdge ('iscR','nfuA', g)
g <- graph::addEdge ('iscS','iscA', g)
g <- graph::addEdge ('iscS','iscU', g)
g <- graph::addEdge ('iscU','iscA', g)
g <- graph::addEdge ('iscX','iscA', g)
g <- graph::addEdge ('iscX','iscS', g)
g <- graph::addEdge ('iscX','iscU', g)
g <- graph::addEdge ('iscX','nfuA', g)
g <- graph::addEdge ('nfuA','iscA', g)
g <- graph::addEdge ('nfuA','iscS', g)
g <- graph::addEdge ('nfuA','iscU', g)

edgeData (g, 'iscR','iscA','weight') <- '4_0.9'
edgeData (g, 'iscR','iscS','weight') <- '0_1'
edgeData (g, 'iscR','iscU','weight') <- '1_0.95'
edgeData (g, 'iscR','iscX','weight') <- '7_0.5'
edgeData (g, 'iscR','nfuA','weight') <- '8_0.66'
edgeData (g, 'iscS','iscA','weight') <- '6_0.66'
edgeData (g, 'iscS','iscU','weight') <- '9_0.5'
edgeData (g, 'iscU','iscA','weight') <- '5_0.62'
edgeData (g, 'iscX','iscA','weight') <- '3_0.94'
edgeData (g, 'iscX','iscS','weight') <- '0_1'
edgeData (g, 'iscX','iscU','weight') <- '0_1'
edgeData (g, 'iscX','nfuA','weight') <- '10_0.5'
edgeData (g, 'nfuA','iscA','weight') <- '2_0.94'
edgeData (g, 'nfuA','iscS','weight') <- '0_1'
edgeData (g, 'nfuA','iscU','weight') <- '0_1'


cw@graph <- g
displayGraph (cw)

# Weight attribute setting
for (edge in g@nodes)
  # setEdgeAttributesDirect(cw, attribute.name='weight', 'numeric', edge.names = g@nodes, values)
  setEdgeAttributesDirect(cw, attribute.name='weight', 'char', edge.names = g@nodes, values)
displayGraph (cw)
#
layoutNetwork (cw, layout.name='grid')
redraw (cw)

eda.names (cw@graph)
attribute.names = eda.names (cw@graph)
for (attribute.name in attribute.names)
  result = setEdgeAttributes (cw, attribute.name)
displayGraph (cw)
redraw (cw)

g <- cw@graph
#setEdgeLabelDirect(obj, edge.names, new.value)
setEdgeLabelDirect(cw, g@nodes, 'weight')
displayGraph (cw)
redraw (cw)
#
edges.of.interest = as.character (cy2.edge.names (cw@graph))
supported.arrow.shapes = getArrowShapes (cw)

# first try passing three edges and three arrow shapes
#setEdgeTargetArrowShapeDirect (cw, edges.of.interest, supported.arrow.shapes [2:5])
#redraw (cw)

#
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
#
layoutNetwork (cw, 'hierarchical')
redraw (cw)
# show weiht
getVisualStyleNames (cw)
setVisualStyle(cw, 'Sample1')
