/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        BayesianNode
 * Description: Generic Bayesian Node
 * Author:      Diego Garcia
 * Date:        08th September 2015
 *
 * Modification Log:
 * ---------------------------
 * 2015-09-08   Diego Garcia    Creation.
 */
package BN;

/**
 *
 * @author dgarcia
 */
public class BayesianNode< T > {
    public List < BayesianNode > children; // = new List < T >();
    public List < BayesianNode > parents; // = new List < T >();

    public CPT < T > cpt;

    public String name;
    
    public jMEF.MixtureModel cpd;
    public T sample;
    
    //public jMEF.PVector beta;
    public List < CoefNode > coef;
    
    // constructor creates an empty List 
    public BayesianNode()
    {
        parents = children = null;
        coef = null; cpt = null; sample = null;
    } // end List one-argument constructor
    
}
