#=====================================================================================
#
#  Code chunk 1
#
#=====================================================================================


# Display the current working directory
getwd();
# If necessary, change the path below to the directory where the data files are stored. 
# "." means current directory. On Windows use a forward slash / instead of the usual \.
workingDir = ".";
setwd(workingDir); 
# Load the WGCNA package
library(WGCNA)
# The following setting is important, do not omit.
options(stringsAsFactors = FALSE);
# Load the expression and trait data saved in the first part
lnames = load(file = "Ecoli-01-dataInput.RData");
#The variable lnames contains the names of loaded variables.
lnames
# Load network data saved in the second part.
lnames = load(file = "Ecoli-02-networkConstruction-auto.RData");
lnames

#=====================================================================================
#
#  Code chunk 4
#
#=====================================================================================


# Recalculate topological overlap if needed
TOM = TOMsimilarityFromExpr(datExpr, power = 6);
# Read in the annotation file
#annot = read.csv(file = "GeneAnnotation.csv");
# Select modules
#modules = c("brown", "red");
modules = moduleColors;
#modules = moduleColors[81:90];
#modules = moduleColors[41:90];
# Select module probes
probes = names(datExpr)
inModule = is.finite(match(moduleColors, modules));
modProbes = probes[inModule];
#modGenes = annot$gene_symbol[match(modProbes, annot$substanceBXH)];
modGenes = modProbes
# Select the corresponding Topological Overlap
modTOM = TOM[inModule, inModule];
dimnames(modTOM) = list(modProbes, modProbes)
# Export the network into edge and node list files Cytoscape can read
cyt = exportNetworkToCytoscape(modTOM,
                               #edgeFile = paste("EcoliCytoscapeInput-edges-", paste(modules, collapse="-"), ".txt", sep=""),
                               #nodeFile = paste("EcoliCytoscapeInput-nodes-", paste(modules, collapse="-"), ".txt", sep=""),
                               edgeFile = paste("EcoliCytoscapeInput-edges-all.txt", sep=""),
                               nodeFile = paste("EcoliCytoscapeInput-nodes-all.txt", sep=""),
                               weighted = TRUE,
                               threshold = 0.02,
                               nodeNames = modProbes,
                               altNodeNames = modGenes,
                               nodeAttr = moduleColors[inModule])


