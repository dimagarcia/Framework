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
g <- graph::addNode ('hns', g)
g <- graph::addNode ('crp', g)
g <- graph::addNode ('ttdA', g)
g <- graph::addNode ('ttdB', g)
g <- graph::addNode ('ttdR', g)
g <- graph::addNode ('ttdT', g)
g <- graph::addNode ('zraP', g)
g <- graph::addNode ('zraR', g)
g <- graph::addNode ('zraS', g)
g <- graph::addNode ('arsB', g)

cw <- new.CytoscapeWindow ('Abasy E. coli (strong) - Modules: 34(Lactose), 37(Zinc), 40(Sodium), 52(Phosphorelay), 55(arsenic)', graph=g, overwriteWindow=TRUE)
displayGraph (cw)

#layoutNetwork (cw, layout.name='grid')
#redraw (cw)

g <- cw@graph
g <- initEdgeAttribute (graph=g, attribute.name='edgeType',attribute.type='char',default.value='regulates to')
g <- initEdgeAttribute (graph=g, attribute.name='weight',attribute.type='numeric',default.value='unspecified')
# Module 34
g <- graph::addEdge ('lacI','lacA', g)
g <- graph::addEdge ('lacI','lacY', g)
g <- graph::addEdge ('lacI','lacZ', g)
g <- graph::addEdge ('rpoD','lacA', g)
g <- graph::addEdge ('rpoD','lacI', g)
g <- graph::addEdge ('rpoD','lacY', g)
g <- graph::addEdge ('rpoD','lacZ', g)
g <- graph::addEdge ('rpoD','hns', g)
g <- graph::addEdge ('rpoD','crp', g)
g <- graph::addEdge ('hns','lacA', g)
g <- graph::addEdge ('hns','lacY', g)
g <- graph::addEdge ('hns','lacZ', g)
g <- graph::addEdge ('crp','lacA', g)
g <- graph::addEdge ('crp','lacI', g)
g <- graph::addEdge ('crp','lacY', g)
g <- graph::addEdge ('crp','lacZ', g)
g <- graph::addEdge ('lacA','crp', g)
g <- graph::addEdge ('lacY','crp', g)
g <- graph::addEdge ('lacZ','crp', g)
# Module 37
# Module 40
g <- graph::addEdge ('ttdR','ttdA', g)
g <- graph::addEdge ('ttdR','ttdB', g)
g <- graph::addEdge ('ttdR','ttdT', g)
# Module 52
g <- graph::addEdge ('zraR','zraP', g)
g <- graph::addEdge ('zraR','zraS', g)
# Module 55
g <- graph::addEdge ('rpoD','arsB', g)

#edgeData (g, 'lacI','lacA','weight') <- 1

cw@graph <- g
displayGraph (cw)

edges.of.interest = as.character (cy2.edge.names (cw@graph))
setEdgeTargetArrowShapeDirect (cw, edges.of.interest, 'Arrow')
redraw (cw)

setVisualStyle(cw, 'Sample1')
layoutNetwork (cw, layout.name='degree-circle')
redraw (cw)
#getVisualStyleNames (cw)
#getLayoutNames(cw)


