/*
 * Propiedad intelectual de la Universidad del Valle
 * Nombre:      CombinatorialNumber
 * Descripcion: Implementacion de numeros combinatorios   
 * Autor:       Diego García
 * Fecha:       Mayo 26 de 2015
 *
 * Historial de modificaciones:
 * ---------------------------
 * 2015-05-26   Diego Garcia    Creacion.
 */
package Bayesian;

/**
 *
 * @author dgarcia
 */
public class CombinatorialNumber {
    int n, k;
    public CombinatorialNumber(int n, int k){
        this.k = k;
        this.n = n;
    }
    public long factl(int n){    
        if (n<=1) return (long)1;
        return (long)n*factl(n-1);
    }    
    public float calcular(){
        return (float) factl(n) / (float) ( factl(k) * factl(n-k) ) ;        
    }
            
}
