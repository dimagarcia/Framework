ore.connect(user="BAYES", password="Hasting2016", conn_string="PDBORCL")
mydata = read.table("avg_E_coli_v4_Build_6_exps466probes4297.tab")

#
ore.create(mydata, "BF_EXPR")

# Push the mydata data frame to the database.
mydata_of <- ore.push(mydata)
class(mydata_of)
# Filter one column of the data set.
mydata_of_gene <- mydata_of[mydata_of$V1 == "aaaD_b4634_3", ]
mydata_of_gene <- mydata_of[2, ]

# Pull the selected column into the local R client memory.
local_gene = ore.pull(mydata_of_gene)
local_gene = mydata[2, 2:467]
# Convert to numeric data type
x=local_gene[2:467]
x <- t(x)
x <- as.numeric(as.character(x))

mycor = cor(x, y, method = "pearson")

# Test
x = mydata[2, 2:467]

# Construct of Gene Co-Expression Network
exps=466
genes=4297
cormatrix <- matrix(ncol=genes,nrow=genes)
for (i in 2:genes){
  for (j in i+1:genes+1){
    x = mydata[i, 2:exps+1]
    x <- as.numeric(as.character( t( x ) ))
    
    y = mydata[j, 2:exps+1]
    y <- as.numeric(as.character( t( y ) ))
    
    cormatrix[i][j] = cor(x, y, method = "pearson")
    j=j+1
  }
  i=i+1
}

# 2015-06-15 Construct of Gene Co-Expression Network
exps=466
genes=4
cormatrix <- matrix(ncol=genes,nrow=genes)
for (i in 1:(genes-1)){
  for (j in (i+1):genes){
    x = mydata[i+1279-1, 2:exps+1]
    x <- as.numeric(as.character( t( x ) ))
    
    y = mydata[j+1279-1, 2:exps+1]
    y <- as.numeric(as.character( t( y ) ))
    
    cormatrix[i,j] = cor(x, y, method = "pearson")
    j=j+1
  }
  i=i+1
}
# 15-JUN-2017
mydata_gene <- mydata[mydata$V1 == "aaaD_b4634_3", ]

lacl_on <- lactose[lactose$lacl>8.29,]
exps=151
genes=4
cormatrix2 <- matrix(ncol=genes,nrow=genes)
for (i in 1:(genes-1)){
  for (j in (i+1):genes){
    x = lacl_on[,i]
    y = lacl_on[,j]
    cormatrix2[i,j] = cor(x, y, method = "pearson")
    j=j+1
  }
  i=i+1
}
#
exps=466
genes=4
cormatrix3 <- matrix(ncol=genes,nrow=genes)
for (i in 1:(genes-1)){
  for (j in (i+1):genes){
    x = lactose[,i]
    y = lactose[,j]
    cormatrix3[i,j] = cor(x, y, method = "pearson")
    j=j+1
  }
  i=i+1
}
#
lacl_mid <- lactose[lactose$lacl>8.06,]
exps=311
genes=4
cormatrix4 <- matrix(ncol=genes,nrow=genes)
for (i in 1:(genes-1)){
  for (j in (i+1):genes){
    x = lacl_mid[,i]
    y = lacl_mid[,j]
    cormatrix4[i,j] = cor(x, y, method = "pearson")
    j=j+1
  }
  i=i+1
}
#
lacl_low <- lactose[lactose$lacl<8.06,]
exps=155
genes=4
cormatrix5 <- matrix(ncol=genes,nrow=genes)
for (i in 1:(genes-1)){
  for (j in (i+1):genes){
    x = lacl_low[,i]
    y = lacl_low[,j]
    cormatrix5[i,j] = cor(x, y, method = "pearson")
    j=j+1
  }
  i=i+1
}