/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      MixtureDistribution
 * Descripcion: Implementacion Mezcla de distribucion de probabilidad    
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
public class MixtureDistribution {
// Properties
    float mu1, mu2;
    float sigma1, sigma2;
    float p;
    float tau1, tau2;
    float sigma_squared1, sigma_squared2;
    
    // Methods
    public MixtureDistribution(float mu1, float sigma_squared1, float mu2, float sigma_squared2, float p){
        this.mu1 = mu1;
        this.sigma1 = (float)Math.sqrt(sigma_squared1);
        this.tau1 = 1f / sigma_squared1;
        this.mu2 = mu2;
        this.sigma2 = (float)Math.sqrt(sigma_squared2);
        this.tau2 = 1f / sigma_squared2;
        this.p = p;
    }
    public float getDensity(float x){
	return (float)Math.sqrt(tau1 / (2f * (float)Math.PI)) * (float)Math.exp(-tau1 * (float)Math.pow(x - mu1,2)/2)*(1-p) +
                (float)Math.sqrt(tau1 / (2f * (float)Math.PI)) * (float)Math.exp(-tau1 * (float)Math.pow(x - mu1,2)/2)*p;        
    }
    public float getSample(){
        double u1 = Math.random();
        double u2 = Math.random();
        double z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos( 2.0 * Math.PI * u2); //Math.sqrt(-2.0 * Math.log(u1)) * Math.sin( 2.0 * Math.PI * u2);
        return ((float)z * sigma1 + mu1)*(p-1) + ((float)z * sigma2 + mu2)*p; 
        
    }    
    
}
