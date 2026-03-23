/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      Stationary
 * Descripcion: Stationary Distribution for Metropolis Hastings Algorithm
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
abstract public class Stationary {
    abstract public float getDensity(jMEF.PVector point);
}
