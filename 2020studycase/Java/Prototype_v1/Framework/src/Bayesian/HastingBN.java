/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      Hasting
 * Descripcion: Implementacion del Algoritmo Metropolis Hasting
 * Autor:       Diego Garcia
 * Fecha:       Junio 04 de 2015
 *
 * Historial de modificaciones:
 * ---------------------------
 * 2015-06-04   Diego Garcia    Creacion.
 * 2015-08-28   Diego Garcia    Modificacion del metodo metropolis:
 *                              se corrige logica del algoritmo de Hasting 
 */

package Bayesian;

/**
 *
 * @author dgarcia
 */
public class HastingBN {
    // Properties
    HistogramR2 result;
    HistogramR2 stationary;
    int t;    
    
    jMEF.MixtureModel q; // Proposal
    jMEF.PVector[] x;
    jMEF.PVector[] xp;

    public HastingBN (){}
    
    public HastingBN (jMEF.MixtureModel q){
       this.q = q; 
    }
    
    public void setProposal(jMEF.MixtureModel  mm, 
                            jMEF.ExponentialFamily ef,
                            jMEF.PVectorMatrix param){
        q = mm;
        q.EF = ef;
        q.weight[0] = 1;
        q.param[0]  = param;
    }
    
    public void metropolis(){
        // 1. Inicializacion Xo        
        jMEF.PVector[] _X = q.drawRandomPoints(1);
        x[0] = _X[0];
        
        for (int s=0; s < t-1; s++){ // 2. Iteracion            
            // 3. Define X = Xs
            jMEF.PVector X = x[s];            
            // 4. Sample Xp from proposal distribution
            jMEF.PVectorMatrix param = (jMEF.PVectorMatrix)q.param[0];
            param.v = X;
            q.param[0] = param;
            
            xp = q.drawRandomPoints(1);
            
            // 5. Compute acceptance probability (alpha)
            double Px  = stationary.getDensity(X);
            double Pxp = stationary.getDensity(xp[0]);
            double alpha = Pxp / Px; 
            
            double r = (alpha > 1)? 1.0 : alpha; // Compute r = min (1,alpha)
            
            if (alpha >= 1.0)
                x[s+1] = xp[0];
            else
            // 6. Sample u ~ U(0,1);
            // 7. Set new sample to
                // (u < r)? Xp : x[s];
                x[s+1] = (Math.random() < alpha)? xp[0] : x[s];
        }        
    }
    
}
