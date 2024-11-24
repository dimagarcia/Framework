/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      ClassInterval
 * Descripcion: Objeto para manejar Intervalos de Clase de un Histograma
 * Autor:       Diego Garcia
 * Fecha:       Mayo 22 de 2015
 *
 * Historial de modificaciones:
 * ---------------------------
 * 2015-05-22   Diego Garcia    Creacion.
 */
package BN;

/**
 *
 * @author dgarcia
 */
public class ClassInterval {
    public float[]   startPoint;
    public float[]   endPoint;
    public int     frequency = 0;
    int dim;
    public ClassInterval(int n){
        dim = n;
        startPoint = new float[dim]; 
        endPoint = new float[dim]; 
    }
}
