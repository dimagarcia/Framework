install.packages("bnlearn")
library(bnlearn)

getwd()
mydata = read.table("avg_E_coli_v4_Build_6_exps466probes4297.tab")
lacA = mydata[1279, 2:467]
class(lacA)

lacA <- as.numeric(as.character( t( lacA ) ))
class(lacA)
lacA<-data.frame(lacA)
class(lacA)
dlacA <- discretize(lacA, breaks = 3 , method = "quantile")
##
lacA = mydata[1279, 2:467]
lacA <- as.numeric(as.character( t( lacA ) ))
lacl = mydata[1280, 2:467]
lacl <- as.numeric(as.character( t( lacl ) ))
lacY = mydata[1281, 2:467]
lacY <- as.numeric(as.character( t( lacY ) ))
lacZ = mydata[1282, 2:467]
lacZ <- as.numeric(as.character( t( lacZ ) ))
##
lactose <-data.frame(cbind(lacA,lacl,lacY,lacZ))
dlactose <- discretize(lactose, breaks = 3 , method = "quantile")
##
library(ORE)
ore.connect(user="BAYES", password="Hasting2016", conn_string="PDBORCL")
ore.create(dlacA, "BF_EXPR_lacA")
ore.create(dlactose, "BF_EXPR_LAC")
ore.sync()

# 11-JUN-2017
breaks_to_use <- quantile(lacA, seq(1/3, 2/3))
discretized_training_data <- cut(lacA, breaks = breaks_to_use)
dlacA <-data.frame(discretized_training_data)


tfrequency = read.table("FLactose.txt", header = TRUE)
ore.create(tfrequency, "FREQUENCY3")

# 14-JUN-2017
ore.exists("FREQUENCY3")
ore.exists("BF_EXPR_lacA")
ore.exists("BF_EXPR_LAC")
ore.exists("BF_EXPR")
ore.ls("BAYES")
ore.rm(c("BF_EXPR", "BF_EXPR_lacA", "BF_EXPR_LAC"))
ore.sync()
ore.drop(table='BF_EXPR_LAC')
ore.drop(table='BF_EXPR_lacA')
ore.drop(table='BF_EXPR')
ore.disconnect()
ore.is.connected()

# 16-JUN-2017
##
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
##
lactose_ctr <-data.frame(cbind(lacA,lacl,lacY,lacZ,rpoD,znuA))
dlactose_ctr <- discretize(lactose_ctr, breaks = 3 , method = "quantile")

write.table(dlactose_ctr, file = "dlactose_ctr.txt")
# Write CSV in R
write.csv(dlactose_ctr, file = "dlactose_ctr.csv")


Flactose_ctr = read.table("Flactose_ctr.txt", header = TRUE)
library(ORE)
ore.connect(user="BAYES", password="Hasting2016", conn_string="PDBORCL")
ore.create(Flactose_ctr, "FREQUENCY4")
ore.sync()