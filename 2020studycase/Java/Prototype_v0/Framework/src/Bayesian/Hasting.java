/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      Hasting
 * Descripcion: Implementación del Algoritmo Metropolis Hasting
 * Autor:       Diego García
 * Fecha:       Mayo 22 de 2015
 *
 * Historial de modificaciones:
 * ---------------------------
 * 2015-05-22   Diego Garcia    Creacion.
 */

package Bayesian;
import javax.media.opengl.GL;

/**
 *
 * @author dgarcia
 */
public class Hasting {
    // Properties
    float[] resultData;
    Histogram result;
    float[] stationaryData;
    Histogram stationary;
    Proposal q;
    int t;    
    float Xo;

    //Methods
    public void metropolis(){
        //**********************************************************************
        // implementación Algoritmo Metropolis Hasting - Mayo 20 de 2015 - Diego García
        //**********************************************************************        
        resultData = new float[t];        
        resultData[0] = Xo; // 1. Inicializacion Xo        
        for (int s=1; s < t; s++){ // 2. Iteracion

            float X = resultData[s-1];  // 3. Define X = Xs

            float Xp = q.getSample(); // 4. Sample Xp from proposal distribution Q

            // 5. Compute acceptance probability (alpha)
            float Px  = stationary.getDensity(X); 
            float Pxp = stationary.getDensity(Xp);
            float alpha = Pxp / Px; 
            
            double r = (alpha > 1)? 1.0 : Pxp/Px; // Compute r = min (1,alpha)
            
            // 7. Set new sample to
            if (alpha >= 1.0)
                resultData[s] = Xp;
            else        // Sample u ~ U(0,1);
                resultData[s] = (Math.random() < alpha)? Xp : resultData[s-1];
            //System.out.println(resultData[s]);
        }
        //**********************************************************************  
        result = new Histogram(resultData);
    }
    public void display(GL gl) {
        gl.glColor3f(1.0f, 1.0f, 1.0f);    // Set the current drawing color to white        
        stationary.display(gl);
        result.display(gl);
    }
}
