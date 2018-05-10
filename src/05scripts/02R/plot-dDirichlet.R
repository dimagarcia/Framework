curve(dbeta(x,20,29),col="green")
install.packages("gtools")
library(gtools)

x <- rdirichlet(20, c(1,1,1) )
ddirichlet(x, c(1,1,1) )

# AQUI lOS PARAMETROS QUE NOS INTERESA
x <- rdirichlet(20, c(20,29) )
y <- c((0.1,0.9),
       (0.2,0.8),
       (0.3,0.7),
       (0.4,0.6),
       (0.5,0.5),
       (0.6,0.4),
       (0.7,0.3),
       (0.8,0.2),
       (0.9,0.1))

ptos <- matrix(ncol=2,nrow=(10*10)-1)
ptos[1,]
x=0.01
for(i in 1:99){
  ptos[i,] <- c(x*i,1-(x*i)) # point on grid
  i=i+1
}

library(gtools)
plot(ddirichlet(ptos, c(20,29) ))
plot(rdirichlet(100, c(20,29) ), col="red")

ddirichlet(x, c(20,29) )
plot(ddirichlet(x, c(20,29) ))

# curve(ddirichlet(x, c(20,29) ),col="red")

# 06-JUN-2017
t=dbeta(x=0.4,2,2)
t=dbeta(x=0.4,20,29)
w=c(0.4,0.6) # p, 1-p, alpha1, alpha2
z=ddirichlet(w, c(20,29) )

#######################################################################
ore.connect(user="BAYES", password="Hasting2016", conn_string="PDBORCL")
ore.doEval(function() { 123 })
ore.doEval(function() { myRandomRedDots()})
ore.scriptCreate("myRandomRedDots", function(divisor = 100){
  id <- 1:10
  plot(1:100, rnorm(100), pch = 21, bg = "red", cex = 2 )
  data.frame(id = id, val = id / divisor)
  })
ore.scriptList()
#
RandomRedDots <- function(divisor = 100){
  id<- 1:10
  plot(1:100, rnorm(100), pch = 21, bg = "red", cex = 2 )
  data.frame(id=id, val=id / divisor)
}
ore.doEval(RandomRedDots)
ore.doEval(RandomRedDots, divisor = 50)
ore.doEval(myRandomRedDots2, divisor=50, numDots=500)
ore.scriptDrop("myRandomRedDots")
ore.scriptCreate("myRandomRedDots", RandomRedDots)
res <- ore.doEval(FUN.NAME = "myRandomRedDots", divisor = 50)
class(res)
res.local <- ore.pull(res)
class(res.local)
#
res.of <- ore.doEval(FUN.NAME="myRandomRedDots", divisor = 50,
                     FUN.VALUE= data.frame(id = 1, val = 1))
class(res.of)
#
RandomRedDots2 <- function(divisor = 100, datastore.name = "myDatastore"){
  id <- 1:10
  plot(1:100, rnorm(100), pch = 21, bg = "red", cex = 2 )
  ore.load(datastore.name) # Contains the numeric variable myVar.
  data.frame(id = id, val = id / divisor, num = myVar)
}
myVar <- 5
ore.save(myVar, name = "datastore_1")
ore.doEval(RandomRedDots2, datastore.name = "datastore_1", ore.connect = TRUE)
####################################################
ore.doEval(function() {
  library(lattice)
  xyplot(mpg ~ hp | factor(cyl),
         data=mtcars,
         type=c("p", "r"),
         main="Fuel economy vs. Performance with Number of Cylinders",
         xlab="Performance (horse power)",
         ylab="Fuel economy (miles per gallon)",
         scales=list(cex=0.75))
})
########################################################
logD <- function(a) {
  sum(lgamma(a)) - lgamma(sum(a))
}
######################################################
ddirichlet<-function(x,alpha)
  ## probability density for the Dirichlet function, where x=vector of
  ## probabilities
  ## and (alpha-1)=vector of observed samples of each type
  ## ddirichlet(c(p,1-p),c(x1,x2)) == dbeta(p,x1,x2)
{
  s<-sum((alpha-1)*log(x))
  exp(sum(s)-logD(alpha))
}
######################################################
rdirichlet<-function(n,a)
  ## pick n random deviates from the Dirichlet function with shape
  ## parameters a
{
  l<-length(a);
  x<-matrix(rgamma(l*n,a),ncol=l,byrow=TRUE);
  sm<-x%*%rep(1,l);
  x/as.vector(sm);
}
######################################################
bf_ddirichlet<-function(x,alpha)
  ## probability density for the Dirichlet function, where x=vector of
  ## probabilities
  ## and (alpha-1)=vector of observed samples of each type
  ## ddirichlet(c(p,1-p),c(x1,x2)) == dbeta(p,x1,x2)
{
  s<-sum((alpha-1)*log(x))
  exp(sum(s)- (sum(lgamma(alpha)) - lgamma(sum(alpha)) ) )
}
########################################################
m=bf_ddirichlet(c(0.4,0.6),c(20,29))
class(m)
res <- ore.doEval(FUN.NAME = "myRandomRedDots", divisor = 50)
res2 <- ore.doEval(FUN.NAME = "BFDDirichlet", c(0.4,0.6),c(20,29))

curve(dbeta(x,2,2),col="green")
curve(dbeta(x,20,29),col="red")
######################################################################
## 2017-06-12
ptos <- matrix(ncol=2,nrow=(10*10)-1)
ptos[1,]
x=0.01
for(i in 1:99){
  ptos[i,] <- c(x*i,1-(x*i)) # point on grid
  i=i+1
}
# library(gtools)
plot(ddirichlet(ptos, c(20,29) ))
dirich <- ddirichlet(ptos, c(20,29) )
class(dirich)
dfrmdirich <-data.frame(cbind(ptos[,1],dirich))
plot(dfrmdirich)

for(i in 1:99){
  dfrmdirich[i,2]=log(dfrmdirich[i,2])
}
class(dfrmdirich)
plot(dfrmdirich,col="blue")
# 2017-JUN-13
plot(dfrmdirich,col="blue",ylab="Log(ddirich(Theta))",xlab="Theta",type="l")
points(dfrmdirich, pch=2, col="red")
points(dfrmdirich, pch=3, col="green")
legend("topright",legend=c("Log","Dirichlet"),
       col=c("red","green"),pch=c(2,3))
##
plot(data.frame(cbind(ptos[,1],dirich)),col="blue",pch=1,
     xlab="Theta",ylab="PDF",ylim=c(-4,6),
     main="PDF and Log(PDF) functions vs Theta parameter")
points(dfrmdirich, pch=2, col="red")
legend("topright",legend=c("PDF(E[Theta])","Log(PDF(E[Theta]))"),
       col=c("blue","red"),pch=c(1,2))
##
par(mfrow=c(2,2))
hist(lactose[,1],col="grey",xlab="lacA Expression",
     main="lacA Density",border="blue",breaks=seq(from=2,to=12,by=0.5))
hist(lactose[,2],col="grey",xlab="lacl Expression",
     main="lacl Density",border="blue",breaks=seq(from=4,to=15,by=0.5))
hist(lactose[,3],col="grey",xlab="Expression",
     main="lacY Density",border="blue",breaks=seq(from=3,to=13,by=0.5))
hist(lactose[,4],col="grey",xlab="Expression",
     main="lacZ Density",border="blue",breaks=seq(from=4,to=15,by=0.5))

par(mfrow=c(2,2))
hist(lactose[,1],col="grey",xlab="lacA Expression",
     main="lacA Density",border="blue")
hist(lactose[,2],col="grey",xlab="lacl Expression",
     main="lacl Density",border="blue")
hist(lactose[,3],col="grey",xlab="Expression",
     main="lacY Density",border="blue")
hist(lactose[,4],col="grey",xlab="Expression",
     main="lacZ Density",border="blue")
# 14-JUN-2017
curve(dbeta(x,20,29),col="green")

plot(data.frame(cbind(ptos[,1],ddirichlet(ptos, c(2,2) ))),
     col="blue",ylab="Density",xlab="Theta",
     ylim=c(0,6),
     main="Approximating Theta parameter")
points(data.frame(cbind(ptos[,1],ddirichlet(ptos, c(20,29) ))), 
       pch=2, col="red")
legend("topright",legend=c("Dir(Alpha1 = 2, Alpha2 = 2)",
        "Dir(Alpha1 = 20, Alpha2 = 29)"),
       col=c("blue","red"),pch=c(1,2))
##
plot(data.frame(cbind(ptos[,1],dirich)),col="red",pch=2,
     xlab="Theta",ylab="Density",ylim=c(-4,6),
     main="PDF and Log(PDF) functions vs Theta parameter")
points(dfrmdirich, pch=3, col="green")
legend("topright",legend=c("PDF( E[Theta])","Log( PDF( E[Theta]))"),
       col=c("red","green"),pch=c(2,3))

################
ddirichlet(c(0.4,0.6),c(20,29))
ddirichlet(c(0.4,0.6),c(2,2))