/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      BinomialDistribution
 * Descripcion: Implementacion de distribucion de probabilidad  Binomial   
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
public class BinomialDistribution{
    // properties
    float p;
    int n;
    BernoulliDistribution[] b;
    // Methods
    public BinomialDistribution(int n, float p){
        this.p = p;
        this.n = n;
        for (int i=0; i<n; i++)
            b[i] = new BernoulliDistribution(p);
        
    }
    public float getDensity(int x){
        CombinatorialNumber comb_n_x = new CombinatorialNumber(n, x);
	return comb_n_x.calcular() * (float)Math.pow(p, x) * (float)Math.pow(1-p, n-x);        
    }
    public float[] getSample(){
        float[] x = new float[n];
        for (int i=0; i<n; i++)
            x[i] = b[i].getSample();
        return x; 
        
    }
    
}
