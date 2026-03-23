/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      Proposal
 * Descripcion: Propuesta de distribucion de probabilidad  (Q), empleada para el
 *              algoritmo metropolis Hasting 
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
abstract public class Proposal {
    //properties
    float mu;
    float sigma;
    
    //methods
    abstract public float getDensity(float x);
    abstract public float getSample();
    
}
