/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      ClassInterval
 * Descripcion: Objeto para manejar Intervalos de Clase de un Histograma
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
public class ClassInterval {
    float[]   startPoint;
    float[]   endPoint;
    int     frequency = 0;
    public ClassInterval(int n){
        startPoint = new float[n]; 
        endPoint = new float[n]; 
    }
}
