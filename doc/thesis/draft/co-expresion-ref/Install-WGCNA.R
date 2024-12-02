source("http://bioconductor.org/biocLite.R")
biocLite(c("AnnotationDbi", "impute", "GO.db", "preprocessCore")) 
install.packages("WGCNA")
# install.packages("ggplot2")
# install.packages("rlang")

getwd()

install.packages(c("matrixStats", "Hmisc", "splines", "foreach", "doParallel", "fastcluster", "dynamicTreeCut", "survival")) 
source("http://bioconductor.org/biocLite.R") 
biocLite(c("GO.db", "preprocessCore", "impute"))

# export ALLOW_WGCNA_THREADS=2

orgCodes = c("Hs", "Mm", "Rn", "Pf", "Sc", "Dm", "Bt", "Ce", "Cf", "Dr", "Gg"); 
orgExtensions = c(rep(".eg", 4), ".sgd", rep(".eg", 6)); 
packageNames = paste("org.", orgCodes, orgExtensions, ".db", sep=""); 

biocLite(c("KEGG.db", "topGO", packageNames, "hgu133a.db", "hgu95av2.db", "annotate", "hgu133plus2.db", "SNPlocs.Hsapiens.dbSNP.20100427", "minet", "OrderedList"))

# 01-Ene-2019
install.packages('<package_name>', repo='http://nbcgib.uesc.br/mirrors/cran/')