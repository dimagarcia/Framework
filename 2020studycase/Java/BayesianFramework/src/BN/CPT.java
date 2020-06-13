/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        CPT
 * Description: Conditional Probability Table
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
public class CPT< T > {
    public List < CPTNode > rows; // = new List < CPTNode >();
    public T value;
    public float probability; 
    

    // constructor creates an empty List 
    public CPT()
    {
        rows = null;
    } // end List one-argument constructor    

    // insert item at Back of List    
    public void insert(T value,  float probability, T[] parents )
    {
        this.value = value;
        if (parents == null){// In case of the root nodes, it have no parents  
            this.probability = probability;            
        }
        else{//node have parent(s)
            // Intance of a row
            CPTNode<T> row = new BN.CPTNode<T>();
            row.probability = probability;    
            row.parents = new List < T >();
            for (int i=0; i<parents.length; i++)
                row.parents.insertAtBack(parents[i]);

            if ( isEmpty() ) // Instance row's list if it is empty
                rows = new BN.List<CPTNode>();
            // Insert row in list
            rows.insertAtBack(row);
        }
        
    } // end method insert

    // inserts item at Back of List    
    public void inserts(T value,  float[] p, T[][] parents )
    {        
        for (int i=0; i<p.length; i++)
            insert(value, p[i],parents[i]);        
    } // end method inserts
    
    // determine whether list is empty
    public boolean isEmpty()
    {
        return rows == null; // return true if list is empty
    } // end method isEmpty
    
    
}
