install.packages('R2OpenBUGS',type='source')

library(R2OpenBUGS)
sink("model1.txt")
cat("
model{
	# likelihood
	for(j in 1 : N) { y[j] ~ dnorm(mu, tau) }
	mu ~ dnorm(0,0.01)  # prior for mu
	tau ~ dgamma(0.01,0.01) # prior for tau
	# determnistic definition of variance
	sigma.squared <- 1/tau
	# deterministic definition of st.deviation
	sigma <- sqrt(sigma.squared)
}
",fill=TRUE)
sink()

datos=list(N=10, y = c(-1.76, 0.38, 1.23, -0.67, -0.47, -1.36, 1.41, -0.07, -1.23, 2.35))

parametros=list("mu","tau")

mod1 = bugs(data=datos, inits=NULL, parameters.to.save=parametros, model.file="model1.txt",n.iter=10000,n.bumin=100,n.chain=1,debug=TRUE)

mod1 = bugs(data=datos, inits=NULL, parameters.to.save=parametros, model.file="model1.txt",n.iter=10000,n.chain=1,debug=TRUE)

mod1 = bugs(data=datos, inits=NULL, parameters.to.save=parametros, model.file="model1.txt",n.iter=10000,n.chain=1)

mod1

mu1