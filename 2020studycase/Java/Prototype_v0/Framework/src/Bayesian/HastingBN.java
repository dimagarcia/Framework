/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      Hasting
 * Descripcion: Implementación del Algoritmo Metropolis Hasting
 * Autor:       Diego García
 * Fecha:       Junio 04 de 2015
 *
 * Historial de modificaciones:
 * ---------------------------
 * 2015-06-04   Diego Garcia    Creacion.
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
    
    public void setProposal(jMEF.MixtureModel  mm, 
                            jMEF.ExponentialFamily ef,
                            jMEF.PVectorMatrix param){
        q = mm;
        q.EF = ef;
        q.weight[0] = 1;
        q.param[0]  = param;
    }
    
    public void metropolis(){
        for (int s=0; s < t-1; s++){ // 2. Iteracion            
            // 3. Define X = Xs
            // 4. Sample Xp from proposal distribution
            jMEF.PVectorMatrix param = (jMEF.PVectorMatrix)q.param[0];
            param.v = x[s];
            q.param[0] = param;
            xp = q.drawRandomPoints(1);
//            System.out.println("x["+s+"].array[0] = "+x[s].array[0]+", x["+s+"].array[1] = "+x[s].array[1]);
//            System.out.println("xp[0].array[0] = "+xp[0].array[0]+", xp[0].array[1] = "+xp[0].array[1]);
            // 5. Compute acceptance probability (alpha)
            double Px  = stationary.getDensity(x[s]);
            double Pxp = stationary.getDensity(xp[0]);
            double alpha = (Px == 0)? 1 : Pxp / Px; 
//            System.out.println("Px = "+ Px + ", Pxp = "+ Pxp + ", alpha = "+ alpha);
            
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
