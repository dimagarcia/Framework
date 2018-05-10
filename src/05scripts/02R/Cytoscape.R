install.packages("XMLRPC")
install.packages("RCytoscape")

install.packages("XMLRPC", repos= "http://www.omegahat.org/R", dependencies=TRUE)

## try http:// if https:// URLs are not supported
source("https://bioconductor.org/biocLite.R")
biocLite()

source ('http://bioconductor.org/biocLite.R')
biocLite ('RCytoscape')

library (RCytoscape)
cy = CytoscapeConnection ()
pluginVersion (cy)

library(RCytoscape)
g <- new ('graphNEL', edgemode='directed')
g <- graph::addNode ('A', g)
g <- graph::addNode ('B', g)
g <- graph::addNode ('C', g)
cw <- new.CytoscapeWindow ('vignette', graph=g)
displayGraph (cw)

layoutNetwork (cw, layout.name='grid')
redraw (cw)
##
g <- cw@graph # created above, in the section 'A minimal example'
g <- initNodeAttribute (graph=g, attribute.name='moleculeType', attribute.type='char', default.value='undefined')
g <- initNodeAttribute (graph=g, 'lfc', 'numeric', 0.0)
nodeData (g, 'A', 'moleculeType') <- 'kinase'
nodeData (g, 'B', 'moleculeType') <- 'TF'
nodeData (g, 'C', 'moleculeType') <- 'cytokine'
nodeData (g, 'A', 'lfc') <- -1.2
nodeData (g, 'B', 'lfc') <- 1.8
nodeData (g, 'C', 'lfc') <- 3.2
cw = setGraph (cw, g)
displayGraph (cw) # cw's graph is sent to Cytoscape
redraw (cw)
##
setDefaultNodeShape (cw, 'octagon')
setDefaultNodeColor (cw, '#AAFF88')
setDefaultNodeSize (cw, 80)
setDefaultNodeFontSize (cw, 40)
redraw (cw)
##
getNodeShapes (cw) # diamond, ellipse, trapezoid, triangle, etc.
print (noa.names (getGraph (cw))) # what data attributes are defined?
print (noa (getGraph (cw), 'moleculeType'))
attribute.values <- c ('kinase', 'TF', 'cytokine')
node.shapes <- c ('diamond', 'triangle', 'rect')
setNodeShapeRule (cw, node.attribute.name='moleculeType',attribute.values, node.shapes)
redraw (cw)
##
setNodeColorRule (cw, 'lfc', c (-3.0, 0.0, 3.0), c ('#00AA00', '#00FF00', '#FFFFFF', '#FF0000', '#AA0000'), mode='interpolate')

setNodeColorRule (cw, 'lfc', c (-3.0, 0.0, 3.0),c ('#00FF00', '#FFFFFF', '#FF0000'), mode='interpolate')

##
control.points = c (-1.2, 2.0, 4.0)
node.sizes = c (10, 20, 50, 200, 205)
setNodeSizeRule (cw, 'lfc', control.points, node.sizes, mode='interpolate')
##
g <- cw@graph
g <- initEdgeAttribute (graph=g, attribute.name='edgeType',attribute.type='char',default.value='unspecified')
g <- graph::addEdge ('A', 'B', g)
g <- graph::addEdge ('B', 'C', g)
g <- graph::addEdge ('C', 'A', g)
edgeData (g, 'A', 'B', 'edgeType') <- 'phosphorylates'
edgeData (g, 'B', 'C', 'edgeType') <- 'promotes'
edgeData (g, 'C', 'A', 'edgeType') <- 'indirectly activates'
cw@graph <- g
displayGraph (cw)
line.styles = c ('DOT', 'SOLID', 'SINEWAVE')
edgeType.values = c ('phosphorylates', 'promotes','indirectly activates')
setEdgeLineStyleRule (cw, 'edgeType', edgeType.values,line.styles)
redraw (cw)
arrow.styles = c ('Arrow', 'Delta', 'Circle')
setEdgeTargetArrowRule (cw, 'edgeType', edgeType.values,arrow.styles)
#######################################################
lfc = c (-3, 0, 3) 
names (lfc) =  c ('A', 'B', 'C')
barplot (lfc, main='log fold-change', cex.main=2, cex.axis=1.5, cex.names=1.5, col=c ('green', 'white', 'red'))
##
lfc = c (-3, 0, 3) 
names (lfc) =  c ('A', 'B', 'C')
png ('barplot.png')
barplot (lfc, main='log fold-change', cex.main=2, cex.axis=1.5, cex.names=1.5, col=c ('green', 'white', 'red'))
dev.off ()
##
window.title = 'barplot demo'
g = RCytoscape::makeSimpleGraph ()
g = graph::addNode ('lfc.plot', g)   # this is the new informational node
nodeData (g, 'lfc.plot', attr='label') = 'plotting surface'  # give it a good label, later hidden by the plot
cw = new.CytoscapeWindow (window.title, g)
hideAllPanels (cw) 
displayGraph (cw)
layoutNetwork (cw, 'jgraph-spring')
setWindowSize (cw, 800, 600)
fitContent (cw)
setZoom (cw, 0.9 * getZoom (cw))

setNodeLabelRule (cw, 'label')
node.attribute.values = c ("kinase",  "transcription factor")
colors =                c ('#A0AA00', '#FF0000')
setDefaultNodeBorderWidth (cw, 5)
setNodeBorderColorRule (cw, 'type', node.attribute.values, colors, mode='lookup', default.color='#000000')
count.control.points = c (2, 30, 100)
sizes                = c (20, 50, 100)
setNodeSizeRule (cw, 'count', count.control.points, sizes, mode='interpolate')
setNodeColorRule (cw, 'lfc', c (-3.0, 0.0, 3.0), c ('#00FF00', '#FFFFFF', '#FF0000'), mode='interpolate')
redraw (cw)

lfc.values = noa (g, 'lfc') [1:3]  # don't pick up the fourth node -- that's the informational one!
png ('barplot.png')
barplot (lfc.values, main='log fold-change', cex.main=2, cex.axis=1.5, cex.names=1.5, col=c ('green', 'white', 'red'))
dev.off ()
# the image file is, for now, in your working directory, with the name you gave it

setNodeImageDirect (cw, 'lfc.plot', sprintf ('file://%s/%s', getwd (), 'barplot.png'))
setNodeSizeDirect (cw, 'lfc.plot', 200)
layoutNetwork (cw, 'force-directed')
redraw (cw)