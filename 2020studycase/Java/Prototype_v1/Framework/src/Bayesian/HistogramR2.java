/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      HistogramR2
 * Descripcion: Objeto para manejar Histogramas en R2
 * Autor:       Diego Garc??a
 * Fecha:       Mayo 29 de 2015
 *
 * Historial de modificaciones:
 * ---------------------------
 * 2015-05-29   Diego Garcia    Creacion.
 */

package Bayesian;

import javax.media.opengl.GL;

/**
 *
 * @author dgarcia
 */
public class HistogramR2 extends Histogram{
    // Properties    
    ClassInterval[][] c       = new ClassInterval[classes][classes];    
    
    public HistogramR2(){
        Init();
    }
    
    public HistogramR2(jMEF.PVector[] points ){    
        this();
        Load(points);
    }
    
    public HistogramR2(int n, float width, float startingPoints, float   endPoints){
        super(n, width, startingPoints, endPoints);
        Init();
    }
    
    public void Init(){
        for (int i=0; i<c.length; i++)
            for (int k=0; k<c[i].length; k++){
                c[i][k] = new ClassInterval(2);
                c[i][k].startPoint[0] = (i==0)? startingPoints : c[i-1][k].endPoint[0]; 
                c[i][k].startPoint[1] = (k==0)? startingPoints : c[i][k-1].endPoint[1]; 
                c[i][k].endPoint[0] = c[i][k].startPoint[0] + width;
                c[i][k].endPoint[1] = c[i][k].startPoint[1] + width;
            }        
    }
    
    public void Load(jMEF.PVector[] points){
        n = points.length;
        for(int j=0; j<n; j++)
            for (int i=0; i<c.length; i++)
                for (int k=0; k<c[i].length; k++)
                    if ( (points[j].array[0] >= c[i][k].startPoint[0] && points[j].array[0] < c[i][k].endPoint[0]) &&
                         (points[j].array[1] >= c[i][k].startPoint[1] && points[j].array[1] < c[i][k].endPoint[1])   )
                        c[i][k].frequency++;    
    }
        
    public float getRelativeFrecuency(jMEF.PVector point ){
        for (int i=0; i<c.length; i++)
            for (int k=0; k<c[i].length; k++)
                if ( (point.array[0] >= c[i][k].startPoint[0] && point.array[0] < c[i][k].endPoint[0]) &&
                     (point.array[1] >= c[i][k].startPoint[1] && point.array[1] < c[i][k].endPoint[1])   )
                    return ((float)c[i][k].frequency / (float)n);
        return 0f;
    }
    
    public float getDensity(jMEF.PVector point){
        return getRelativeFrecuency(point)/(width*width);
    }        
    
    public void display(GL gl) {
        if (visible)
            for (int i=0; i<c.length; i++)
//            for (int i=20; i<21; i++)
                for (int k=0; k<c[i].length; k++){
                    
                    gl.glBegin(GL.GL_LINES);
                    
//                        gl.glVertex3f(c[i][k].startPoint[0],       0f, c[i][k].startPoint[1]); // Bottom Left                
//                        gl.glVertex3f(c[i][k].startPoint[0],       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]);  // Top Left
//                        gl.glVertex3f(c[i][k].startPoint[0],       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]);  // Top Left
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]);   // Top Right
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]);   // Top Right
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  0f, c[i][k].startPoint[1]);  // Bottom Right
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  0f, c[i][k].startPoint[1]);  // Bottom Right
//                        gl.glVertex3f(c[i][k].startPoint[0],       0f, c[i][k].startPoint[1]); // Bottom Left
//                        
//                        gl.glVertex3f(c[i][k].startPoint[0],       0f, c[i][k].startPoint[1]+width); // Bottom Left Depht
//                        gl.glVertex3f(c[i][k].startPoint[0],       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]+width);  // Top Left  Depht
//                        gl.glVertex3f(c[i][k].startPoint[0],       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]+width);  // Top Left  Depht
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]+width);   // Top Right Depht
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]+width);   // Top Right Depht
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  0f, c[i][k].startPoint[1]+width);  // Bottom Right Depht
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  0f, c[i][k].startPoint[1]+width);  // Bottom Right Depht
//                        gl.glVertex3f(c[i][k].startPoint[0],       0f, c[i][k].startPoint[1]+width); // Bottom Left Depht
//
//                        gl.glVertex3f(c[i][k].startPoint[0],       0f, c[i][k].startPoint[1]); // Bottom Left                
//                        gl.glVertex3f(c[i][k].startPoint[0],       0f, c[i][k].startPoint[1]+width); // Bottom Left Depht
//                        gl.glVertex3f(c[i][k].startPoint[0],       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]);  // Top Left
//                        gl.glVertex3f(c[i][k].startPoint[0],       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]+width);  // Top Left  Depht
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]);   // Top Right
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[1]+width);   // Top Right Depht
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  0f, c[i][k].startPoint[1]);  // Bottom Right
//                        gl.glVertex3f(c[i][k].startPoint[0]+width,  0f, c[i][k].startPoint[1]+width);  // Bottom Right Depht

                        gl.glVertex3f(c[i][k].startPoint[1],       0f, c[i][k].startPoint[0]); // Bottom Left                
                        gl.glVertex3f(c[i][k].startPoint[1],       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]);  // Top Left
                        gl.glVertex3f(c[i][k].startPoint[1],       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]);  // Top Left
                        gl.glVertex3f(c[i][k].startPoint[1],  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]+width);   // Top Right
                        gl.glVertex3f(c[i][k].startPoint[1],  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]+width);   // Top Right
                        gl.glVertex3f(c[i][k].startPoint[1],  0f, c[i][k].startPoint[0]+width);  // Bottom Right
                        gl.glVertex3f(c[i][k].startPoint[1],  0f, c[i][k].startPoint[0]+width);  // Bottom Right
                        gl.glVertex3f(c[i][k].startPoint[1],       0f, c[i][k].startPoint[0]); // Bottom Left
                        
                        gl.glVertex3f(c[i][k].startPoint[1]+width,       0f, c[i][k].startPoint[0]); // Bottom Left Deph
                        gl.glVertex3f(c[i][k].startPoint[1]+width,       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]);  // Top Left  Deph
                        gl.glVertex3f(c[i][k].startPoint[1]+width,       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]);  // Top Left  Deph
                        gl.glVertex3f(c[i][k].startPoint[1]+width,  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]+width);   // Top Right Deph
                        gl.glVertex3f(c[i][k].startPoint[1]+width,  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]+width);   // Top Right Deph
                        gl.glVertex3f(c[i][k].startPoint[1]+width,  0f, c[i][k].startPoint[0]+width);  // Bottom Right Deph
                        gl.glVertex3f(c[i][k].startPoint[1]+width,  0f, c[i][k].startPoint[0]+width);  // Bottom Right Deph
                        gl.glVertex3f(c[i][k].startPoint[1]+width,       0f, c[i][k].startPoint[0]); // Bottom Left Deph

                        gl.glVertex3f(c[i][k].startPoint[1],       0f, c[i][k].startPoint[0]); // Bottom Left                
                        gl.glVertex3f(c[i][k].startPoint[1]+width,       0f, c[i][k].startPoint[0]); // Bottom Left Depht
                        gl.glVertex3f(c[i][k].startPoint[1],       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]);  // Top Left
                        gl.glVertex3f(c[i][k].startPoint[1]+width,       ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]);  // Top Left  Depht
                        gl.glVertex3f(c[i][k].startPoint[1],  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]+width);   // Top Right
                        gl.glVertex3f(c[i][k].startPoint[1]+width,  ((float)c[i][k].frequency/n)/(width*width), c[i][k].startPoint[0]+width);   // Top Right Depht
                        gl.glVertex3f(c[i][k].startPoint[1],  0f, c[i][k].startPoint[0]+width);  // Bottom Right
                        gl.glVertex3f(c[i][k].startPoint[1]+width,  0f, c[i][k].startPoint[0]+width);  // Bottom Right Depht
                        
                    gl.glEnd();              
                }        
    }    
    
}
