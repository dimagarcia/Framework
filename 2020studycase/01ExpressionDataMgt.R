#getwd()
#mydata = read.table("avg_E_coli_v4_Build_6_exps466probes4297.tab")

# Select data
iscA = mydata[1229, 2:467]
iscR = mydata[1230, 2:467]
iscS = mydata[1231, 2:467]
iscU = mydata[1232, 2:467]
iscX = mydata[1233, 2:467]
nfuA = mydata[1626, 2:467]

iscA <- as.numeric(as.character( t( iscA ) ))
iscR <- as.numeric(as.character( t( iscR ) ))
iscS <- as.numeric(as.character( t( iscS ) ))
iscU <- as.numeric(as.character( t( iscU ) ))
iscX <- as.numeric(as.character( t( iscX ) ))
nfuA <- as.numeric(as.character( t( nfuA ) ))


# Create data frame
m8_22ironSulfur <- data.frame(cbind(iscA,iscR,iscS,iscU,iscX,nfuA))

# Discretize

#library(bnlearn)

dm8_22ironSulfur <- discretize(m8_22ironSulfur, breaks = 3 , method = "quantile")
write.table(dm8_22ironSulfur, file = "dm8_22ironSulfurT.txt")

# Load file re-labeled
dm8_22ironSulfur = read.table("dm8_22ironSulfur_relabeledT.txt")
library(ORE)
#ore.connect(user="BAYES", password="Bayesian2019", conn_string="PDBORCL")
#ore.connect(user="RBAYES", password="Bayesian2019", conn_string="ORCL")
#ore.connect(user="RBAYES", password="Bayesian2020", conn_string="orcl")
ore.connect(user="RBAYES", sid="orcl", host="localhost", password="Bayesian2020",port=1521, all=TRUE)
#ore.is.connected()
ore.create(dm8_22ironSulfur[2:467,], "SAMPLE_ECOLI8_22_T")
ore.sync()
ore.disconnect()