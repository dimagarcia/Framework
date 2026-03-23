/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      BernoulliDistribution
 * Descripcion: Implementacion de distribucion de probabilidad  Bernoulli   
 * Autor:       Diego García
 * Fecha:       Mayo 26 de 2015
 *
 * Historial de modificaciones:
 * ---------------------------
 * 2015-05-26   Diego Garcia    Creacion.
 */
package Bayesian;

/**
 *
 * @author dgarcia
 */
public class BernoulliDistribution{
    // properties
    float p;
    // Methods
    public BernoulliDistribution(float p){
        this.p = p;
    }
    public float getDensity(float x){
	return (float)Math.pow(p, x) * (float)Math.pow(1f-p, 1f-x);        
    }
    public float getSample(){
        double u = Math.random();
        if (u<=p) return 1f;
        return 0f; 
        
    }
    
}
