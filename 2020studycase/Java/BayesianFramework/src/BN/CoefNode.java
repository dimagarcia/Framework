/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        CoefNode
 * Description: Coef Node
 * Author:      Diego Garcia
 * Date:        13th Octuber 2015
 *
 * Modification Log:
 * ---------------------------
 * 2015-10-13   Diego Garcia    Creation.
 */
package BN;

/**
 *
 * @author dgarcia
 */
public class CoefNode<T> {
    public BayesianNode<T> parent;
    public float coef;
    
    public CoefNode(BayesianNode<T> parent,
                    float coef){
        this.parent = parent;
        this.coef = coef;
    }
}
