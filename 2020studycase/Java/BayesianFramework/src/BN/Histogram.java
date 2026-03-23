/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        Histogram
 * Description: Histogram R^N. (Case Discrete)
 * Author:      Diego Garcia
 * Date:        22th September 2015
 *
 * Modification Log:
 * ---------------------------
 * 2015-09-22   Diego Garcia    Creation.
 */
package BN;

/**
 *
 * @author dgarcia
 */
public class Histogram<T> {
    public List<T> x[];
    public int frequency[];
    public int n=0;
    
    public Histogram(int k){
        frequency = new int[k];
        x = new List[k];
    }
    /*
    {{"L","H"},
     {"T","F"}}
    L T
    L F
    H T
    H F
    {{"L","H"},
     {"T","F"},
     {"T","F"}}
    L T T
    L T F
    L F T
    L F F
    H T T
    H T F
    H F T
    H F F
    */
    public void init(T[][] v){
//        int k=0;
//        for (int i=0; i<v.length; i++){
//            x[k] = new List<T>();
//            for (int j=0; j<v[i].length; j++){
//                x[k].insertAtBack(v[i][j]);
//            }
//        }
        //for (int k=0; k<Math.pow(2, v.length); k++){
        for (int k=0; k<v.length; k++){            
            x[k] = new List<T>();
            frequency[k] = 0;
            //for (int i=0; i<v.length; i++){
            for (int i=0; i<v[k].length; i++){
                x[k].insertAtBack(v[k][i]);
            }
        }
    }
    
    public boolean toCompareLists(List<String> l1, List<T> l2){
        // l1's rows are visited
        ListNode<String> l1node = l1.queryNodeFromFront(); 
        ListNode<T> l2node = l2.queryNodeFromFront();        
        while (l1node!=null && l2node!=null && 
               l1node.data.compareToIgnoreCase((String)l2node.data) == 0 ){
            
            l1node = l1node.nextNode;                
            l2node = l2node.nextNode;
            if (l1node == null && l2node == null) return true;                      
        }                    
        return false;
    }
    
    public void updateFrecuency(List<String> s){
        for (int k=0; k<x.length; k++)
            if ( toCompareLists(s, x[k] ) )
                frequency[k]++;
    }
    
    public void loadSamples(List<String> s[]){
        n = n + s.length;
        for (int t=0; t<s.length; t++)
            updateFrecuency(s[t]);
    }
    
    public float getRelativeFrecuency(List<String> s ){
        for (int k=0; k<x.length; k++)
            if ( toCompareLists(s, x[k] ) )
                return (float)frequency[k]/(float)n;        
        
        return 0f;
    }    
    
}
