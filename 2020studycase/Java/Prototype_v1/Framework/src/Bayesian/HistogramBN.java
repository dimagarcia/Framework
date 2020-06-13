/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      HistogramBN
 * Descripcion: Objeto para manejar Histogramas en R^N
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
public class HistogramBN {
    jMEF.PVectorMatrix classInterval;
    int dim;
    
    public HistogramBN(){
        classInterval = new jMEF.PVectorMatrix(dim);
    }
    
}
