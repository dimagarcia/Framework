/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      Histogram
 * Descripcion: Objeto para manejar Histogramas
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
public class Histogram{
    // Properties
    int     n               = 1000;
    float   width           = 0.2f;    
    float   startingPoints  = -4;
    float   endPoints       = 4;
    int     classes         = (int)((endPoints - startingPoints)/width);
    ClassInterval[] c       = new ClassInterval[classes];
    boolean visible         = true;
    // Methods
    public Histogram(int n, float width, float startingPoints, float   endPoints){
        this.n = n;
        this.width = width;
        this.startingPoints = startingPoints;
        this.endPoints = endPoints;
    }
    public Histogram(){
        for (int i=0; i<c.length; i++){
            c[i] = new ClassInterval(1);
            if (i==0)
                c[i].startPoint[0] = startingPoints;
            else
                c[i].startPoint[0] = c[i-1].endPoint[0];
            c[i].endPoint[0] = c[i].startPoint[0] + width;
        }
    }
    public Histogram(float[] x){
        this();
        n = x.length;
        for(int j=0; j<x.length; j++)
            for (int i=0; i<c.length; i++)
                if (x[j]>=c[i].startPoint[0] && x[j] < c[i].endPoint[0] )
                    c[i].frequency++;
    }
    public float getRelativeFrecuency(float x){
        for (int i=0; i<c.length; i++)
            if (x>= c[i].startPoint[0] && x<=c[i].endPoint[0])
                return ((float)c[i].frequency / (float)n);
        return 0f;
    }
    public float getDensity(float x){        
        return getRelativeFrecuency(x)/width;
    }        
    public void display(GL gl) {
        if (visible)
            for (int i=0; i<c.length; i++){
                gl.glBegin(GL.GL_LINES);
                    gl.glVertex3f(c[i].startPoint[0],       0f, 0f); // Bottom Left                
                    gl.glVertex3f(c[i].startPoint[0],       ((float)c[i].frequency/n)/width, 0f);  // Top Left
                    gl.glVertex3f(c[i].startPoint[0],       ((float)c[i].frequency/n)/width, 0f);  // Top Left
                    gl.glVertex3f(c[i].startPoint[0]+width,  ((float)c[i].frequency/n)/width, 0f);   // Top Right
                    gl.glVertex3f(c[i].startPoint[0]+width,  ((float)c[i].frequency/n)/width, 0f);   // Top Right
                    gl.glVertex3f(c[i].startPoint[0]+width,  0f, 0f);  // Bottom Right
                    gl.glVertex3f(c[i].startPoint[0]+width,  0f, 0f);  // Bottom Right
                    gl.glVertex3f(c[i].startPoint[0],       0f, 0f); // Bottom Left
                gl.glEnd();              
            }        
    }    
}
