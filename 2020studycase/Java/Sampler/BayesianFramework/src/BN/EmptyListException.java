/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        EmptyListException
 * Description: Class EmptyListException declaration (Ref. Java How to Program - Paul Deitel and Harvey Deitel)
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
public class EmptyListException extends RuntimeException {
    // no-argument constructor
    public EmptyListException()
    {
        this( "List" ); // call other EmptyListException constructor
    } // end EmptyListException no-argument constructor
    
    // one-argument constructor
    public EmptyListException( String name )
    {
        super( name + " is empty" ); // call superclass constructor
    } // end EmptyListException one-argument constructor
} // end class EmptyListException
