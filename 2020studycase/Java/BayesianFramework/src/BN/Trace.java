/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        Trace
 * Description: Exception manages
 * Author:      Diego Garcia
 * Date:        17th September 2015
 *
 * Modification Log:
 * ---------------------------
 * 2015-09-17   Diego Garcia    Creation.
 */
package BN;

/**
 *
 * @author dgarcia
 */
public class Trace {
    static public boolean active = false;
    
    static public void trace(String mesg, int level){
        if (Trace.active){ 
            for (int i=0; i<level; i++)
                System.out.print("\t");
            System.out.println(mesg);
        }
    }
    
}
