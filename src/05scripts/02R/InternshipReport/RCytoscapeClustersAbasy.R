library("RCytoscape")
pluginVersion (cy)

# Module 34
g <- new ('graphNEL', edgemode='directed')
g <- graph::addNode ('lacA', g)
g <- graph::addNode ('lacY', g)
g <- graph::addNode ('lacZ', g)

# Module 40
#g <- new ('graphNEL', edgemode='directed')
g <- graph::addNode ('ttdA', g)
g <- graph::addNode ('ttdB', g)
g <- graph::addNode ('ttdT', g)

# Module 52
#g <- new ('graphNEL', edgemode='directed')
g <- graph::addNode ('zraR', g)
g <- graph::addNode ('zraS', g)

cw <- new.CytoscapeWindow ('E. coli simulation - Modules: 34(Lactose), 40(Sodium), 52(Phosphorelay)', graph=g, overwriteWindow=TRUE)
displayGraph (cw)

g <- cw@graph
g <- initEdgeAttribute (graph=g, attribute.name='edgeType',attribute.type='char',default.value='regulates to')
g <- initEdgeAttribute (graph=g, attribute.name='weight',attribute.type='numeric',default.value='unspecified')

# Module 34
g <- graph::addEdge ('lacA','lacY', g)
g <- graph::addEdge ('lacA','lacZ', g)
g <- graph::addEdge ('lacY','lacZ', g)
edgeData (g, 'lacA','lacY','weight') <- 0.5
edgeData (g, 'lacA','lacZ','weight') <- 0.5
edgeData (g, 'lacY','lacZ','weight') <- 0.5
# Module 40
g <- graph::addEdge ('ttdA','ttdB', g)
g <- graph::addEdge ('ttdA','ttdT', g)
g <- graph::addEdge ('ttdB','ttdT', g)
edgeData (g, 'ttdA','ttdB','weight') <- 0.5
edgeData (g, 'ttdA','ttdT','weight') <- 0.5
edgeData (g, 'ttdB','ttdT','weight') <- 0.5
# Module 52
g <- graph::addEdge ('zraR','zraS', g)
g <- graph::addEdge ('zraS','zraR', g)
edgeData (g, 'zraR','zraS','weight') <- 0.5
edgeData (g, 'zraS','zraR','weight') <- 0.5

cw@graph <- g
displayGraph (cw)

setVisualStyle(cw, 'Sample1')
layoutNetwork (cw, layout.name='degree-circle')
redraw (cw)

edges.of.interest = as.character (cy2.edge.names (cw@graph))
setEdgeTargetArrowShapeDirect (cw, edges.of.interest, 'Arrow')
redraw (cw)

