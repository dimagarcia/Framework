#----------------------------------------------------------------------------------
# Ejemplo Metrópolis-Hasting:
#----------------------------------------------------------------------------------

x<-c(-2.5,2.5,2.5,-2.5,0)
y<-c(-2.5,2.5,-2.5,2.5,0)

# Inputs:
N=10000

d1=0
d2=0

rho=0.89

camino1.x=camino1.y=vector()
camino2.x=camino2.y=vector()

r1.x=r2.x=0
r1.y=r2.y=0

prob1.x=prob2.x=0
prob1.y=prob2.y=0

c1.x=c2.x=0
c1.y=c2.y=0

camino1.x[1]=-2.5
camino1.y[1]=-2.5

camino2.x[1]=2.5
camino2.y[1]=-2.5

salto1.x=salto1.y=0
salto2.x=salto2.y=0

f=2.4/sqrt(2)

# Generación de la secuencia de valores para los parámetros:

for(i in 2:N){
  salto1.x[i]=rnorm(1,d1+rho*(camino1.y[i-1]-d2),f*(1-rho^2))
  salto1.y[i]=rnorm(1,d2+rho*(camino1.x[i-1]-d1),f*(1-rho^2))
  camino1.x[i]=rnorm(1,d1+rho*(camino1.y[i-1]-d2),1-rho^2)
  camino1.y[i]=rnorm(1,d2+rho*(camino1.x[i-1]-d1),1-rho^2)
  r1.x[i]=(camino1.x[i]/salto1.x[i])/(camino1.x[i-1]/salto1.x[i-1])
  r1.y[i]=(camino1.y[i]/salto1.y[i])/(camino1.y[i-1]/salto1.y[i-1])
  prob1.x[i]=min(r1.x[i],1)
  c1.x[i]=1-min(r1.x[i],1)
  prob1.y[i]=min(r1.y[i],1)
  c1.y[i]=1-min(r1.y[i],1)
  if(prob1.x[i]>c1.x[i]){ 
    camino1.x[i]=rnorm(1,d1+rho*(camino1.y[i]-d2),1-rho^2)
  }else{
    camino1.x[i]=rnorm(1,d1+rho*(camino1.y[i-1]-d2),1-rho^2)
  }
  if(prob1.y[i]>c1.y[i]){
    camino1.y[i]=rnorm(1,d2+rho*(camino1.x[i]-d1),1-rho^2)
  }else{
    camino1.y[i]=rnorm(1,d1+rho*(camino1.y[i-1]-d2),1-rho^2)
  }
  salto2.x[i]=rnorm(1,d1+rho*(camino2.y[i-1]-d2),f*(1-rho^2))
  salto2.y[i]=rnorm(1,d2+rho*(camino2.x[i-1]-d1),f*(1-rho^2))
  camino2.x[i]=rnorm(1,d1+rho*(camino2.y[i-1]-d2),1-rho^2)
  camino2.y[i]=rnorm(1,d2+rho*(camino2.x[i-1]-d1),1-rho^2)
  r2.x[i]=(camino2.x[i]/salto2.x[i])/(camino2.x[i-1]/salto2.x[i-1])
  r2.y[i]=(camino2.y[i]/salto2.y[i])/(camino2.y[i-1]/salto2.y[i-1])
  prob2.x[i]=min(r2.x[i],1)
  c2.x[i]=1-min(r2.x[i],1)
  prob2.y[i]=min(r2.y[i],1)
  c2.y[i]=1-min(r2.y[i],1)
  if(prob2.x[i]>c2.x[i]){ 
    camino2.x[i]=rnorm(1,d1+rho*(camino2.y[i]-d2),1-rho^2)
  }else{
    camino2.x[i]=rnorm(1,d1+rho*(camino2.y[i-1]-d2),1-rho^2)
  }
  if(prob2.y[i]>c2.y[i]){
    camino2.y[i]=rnorm(1,d2+rho*(camino2.x[i]-d1),1-rho^2)
  }else{
    camino2.y[i]=rnorm(1,d1+rho*(camino2.y[i-1]-d2),1-rho^2)
  }
}

camino1<-data.frame(cbind(camino1.x,camino1.y))
camino2<-data.frame(cbind(camino2.x,camino2.y))

plot(density(camino1[,1]))
abline(v=0,col="red")
plot(density(camino1[,2]))
abline(v=0,col="red")

plot(density(camino2[,1]))
abline(v=0,col="red")
plot(density(camino2[,2]))
abline(v=0,col="red")


#plot(density(camino1.gibbs[,1]))
#abline(v=0,col="red")
#plot(density(camino1.gibbs[,2]))
#abline(v=0,col="red")

plot(x,y,type="p",xlim=c(-4,4),ylim=c(-4,4),xlab=" ",ylab=" ",lwd=4,main="Espacio Paramétrico",las=1)
points(camino1,col="black",type="p",xlim=c(-4,4),ylim=c(-4,4),xlab=" ",ylab=" ")
points(camino2,col="yellow",type="p",xlim=c(-4,4),ylim=c(-4,4),xlab=" ",ylab=" ")

plot(x,y,type="p",xlim=c(-4,4),ylim=c(-4,4),xlab=" ",ylab=" ",lwd=4,main="Espacio Paramétrico",las=1)
lines(camino1[,1],camino1[,2],col="red")
lines(camino2[,1],camino2[,2],col="yellow")

# Camino 1:

plot(ts(camino1.x),xlab="Número de iteraciones",ylab="Valor calculado")
lines(ts(camino2.x),col="lightblue",lty=2)
abline(h=0,col="red")

plot(ts(camino1.y),xlab="Número de iteraciones",ylab="Valor calculado")
lines(ts(camino2.y),col="gray",lty=2)
abline(h=0,col="red")

plot(ts(camino1.x),xlab="Número de iteraciones",ylab="Valor calculado",col="blue")
lines(ts(camino1.y),xlab="Número de iteraciones",ylab="Valor calculado",col="green")
abline(h=0,col="red")

camino1<-cbind(camino1.x,camino1.y)

smoothScatter(camino1)
smoothScatter(camino2)

acf(camino1.x,type="correlation",main="Autocorrelación camino1.x")
acf(camino1.y,type="correlation",main="Autocorrelación camino1.y")

acf(camino2.x,type="correlation",main="Autocorrelación camino2.x")
acf(camino2.y,type="correlation",main="Autocorrelación camino2.y")

boxplot(camino1.y)
boxplot(camino1.x)

# Muestreo de Gibbs:

warm.up=N/2
thin=40

#camino1.gibbs= cbind(camino1.x[seq(from=warm.up,to=N,by=thin)],camino1.y[seq(from=warm.up,to=N,by=thin)])

camino1.x.gibbs=camino1.x[seq(from=warm.up,to=N,by=thin)]

plot(density(camino1.x.gibbs),col="yellow")
density(camino1[,1])
abline(v=0,col="red")

acf(camino1.x.gibbs)

camino1.gibbs= cbind(camino1.x[seq(from=warm.up,to=N,by=thin)],camino1.y[seq(from=warm.up,to=N,by=thin)])

plot(x,y,type="p",xlim=c(-4,4),ylim=c(-4,4),xlab=" ",ylab=" ",lwd=4,main="Espacio Paramétrico",las=1)
points(camino1,col="black",type="p",xlim=c(-4,4),ylim=c(-4,4),xlab=" ",ylab=" ")
points(camino1.gibbs,col="yellow",type="p",xlim=c(-4,4),ylim=c(-4,4),xlab=" ",ylab=" ")

plot(ts(camino1.x),xlab="Número de iteraciones",ylab="Valor calculado",col="blue",lty=3)
lines(ts(camino1.x.gibbs),col="black",lty=2)
abline(h=0,col="red")