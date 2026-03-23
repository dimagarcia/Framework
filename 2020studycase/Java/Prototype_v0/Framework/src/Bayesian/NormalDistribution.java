/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      NormalDistribution
 * Descripcion: Implementacion de distribucion de probabilidad  Normal  
 * Autor:       Diego García
 * Fecha:       Mayo 22 de 2015
 *
 * Historial de modificaciones:
 * ---------------------------
 * 2015-05-22   Diego Garcia    Creacion.
 */
package Bayesian;

/**
 *
 * @author dgarcia
 */
public class NormalDistribution extends Proposal{
    // Properties
    float mu;
    float sigma;
    float tau;
    float sigma_squared;
    
    // Methods
    public NormalDistribution(float mu, float sigma_squared){
        this.mu = mu;
        this.sigma = (float)Math.sqrt(sigma_squared);
        this.tau = 1f / sigma_squared;
    }
    public float getDensity(float x){
	return (float)Math.sqrt(tau / (2f * (float)Math.PI)) * (float)Math.exp(-tau * (float)Math.pow(x - mu,2)/2);        
    }
    public float getSample(){
        double u1 = Math.random();
        double u2 = Math.random();
        double z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos( 2.0 * Math.PI * u2); //Math.sqrt(-2.0 * Math.log(u1)) * Math.sin( 2.0 * Math.PI * u2);
        return (float)z * sigma + mu; 
        
    }
    
}
