# 2017-JUN-22
getwd()
mydata = read.table("avg_E_coli_v4_Build_6_exps466probes4297.tab")
# Select data
lacA = mydata[1279, 2:467]
lacA <- as.numeric(as.character( t( lacA ) ))
lacl = mydata[1280, 2:467]
lacl <- as.numeric(as.character( t( lacl ) ))
lacY = mydata[1281, 2:467]
lacY <- as.numeric(as.character( t( lacY ) ))
lacZ = mydata[1282, 2:467]
lacZ <- as.numeric(as.character( t( lacZ ) ))
rpoD = mydata[2164, 2:467]
rpoD <- as.numeric(as.character( t( rpoD ) ))
znuA = mydata[4290, 2:467]
znuA <- as.numeric(as.character( t( znuA ) ))
# 22-JUN-2017
hns = mydata[1087, 2:467]
hns <- as.numeric(as.character( t( hns ) ))
crp = mydata[371, 2:467]
crp <- as.numeric(as.character( t( crp ) ))
# Module 40 GO:0006814	Sodium ion transport
ttdA = mydata[2547, 2:467]
ttdA <- as.numeric(as.character( t( ttdA ) ))
ttdB = mydata[2548, 2:467]
ttdB <- as.numeric(as.character( t( ttdB ) ))
ttdR = mydata[2549, 2:467]
ttdR <- as.numeric(as.character( t( ttdR ) ))
ttdT = mydata[2550, 2:467]
ttdT <- as.numeric(as.character( t( ttdT ) ))
# Module 52 GO:0000160	Phosphorelay signal transduction system
zraP = mydata[4293, 2:467]
zraP <- as.numeric(as.character( t( zraP ) ))
zraR = mydata[4294, 2:467]
zraR <- as.numeric(as.character( t( zraR ) ))
zraS = mydata[4295, 2:467]
zraS <- as.numeric(as.character( t( zraS ) ))
# Module 55 GO:0046685	Response to arsenic-containing substance
arsB = mydata[165, 2:467]
arsB <- as.numeric(as.character( t( arsB ) ))

lactose_ctr2 <-data.frame(cbind(lacA,lacl,lacY,lacZ,rpoD,znuA,
                                hns,crp,
                                ttdA,ttdB,ttdR,ttdT,
                                zraP,zraR,zraS,
                                arsB))

# Discretize
library(bnlearn)
dlactose_ctr2 <- discretize(lactose_ctr2, breaks = 3 , method = "quantile")
#
write.table(dlactose_ctr2, file = "dlactose_ctr2.txt")
# Write CSV in R
# write.csv(dlactose_ctr2, file = "dlactose_ctr2.csv")

# Load file re-labeled
#flactose_ctr2 = read.table("dlactose_ctr2_relabeled.txt", header = TRUE)
flactose_ctr2 = read.table("dlactose_ctr2_relabeled.txt")
library(ORE)
ore.connect(user="BAYES", password="Hasting2016", conn_string="PDBORCL")
#ore.create(flactose_ctr2, "FREQUENCY5")
ore.create(flactose_ctr2[2:467,], "SAMPLE2")
ore.sync()
#ore.drop(table='FREQUENCY5')
#ore.sync()
ore.disconnect()
ore.is.connected()

# Co-expression network
exps=466
genes=6
cormatrix_ctr <- matrix(ncol=genes,nrow=genes)
for (i in 1:(genes-1)){
  for (j in (i+1):genes){
    x = lactose_ctr[,i]
    y = lactose_ctr[,j]
    cormatrix_ctr[i,j] = cor(x, y, method = "pearson")
    j=j+1
  }
  i=i+1
}