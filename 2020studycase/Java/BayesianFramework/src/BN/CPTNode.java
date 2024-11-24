/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        CPTNode
 * Description: Conditional Probability Table Node
 * Author:      Diego Garcia
 * Date:        09th September 2015
 *
 * Modification Log:
 * ---------------------------
 * 2015-09-09   Diego Garcia    Creation.
 */
package BN;

/**
 *
 * @author dgarcia
 */
public class CPTNode <T> {
    public float probability; 
    public List < T > parents; // = new List < T >();

    // constructor creates an empty List 
    public CPTNode()
    {
        parents = null;
    } // end List one-argument constructor    
    
}
