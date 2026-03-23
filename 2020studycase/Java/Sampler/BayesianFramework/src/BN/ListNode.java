/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        ListNode
 * Description: Generic List Node (Ref. Java How to Program - Paul Deitel and Harvey Deitel)
 * Author:      Diego Garcia
 * Date:        08th September 2015
 *
 * Modification Log:
 * ---------------------------
 * 2015-09-08   Diego Garcia    Creation.
 */
// ListNode and List class declarations.
package BN;

/**
 *
 * @author dgarcia
 */
// class to represent one node in a list
public class ListNode< T > {
    // package access members; List can access these directly
    public T data; // data for this node
    public ListNode<T> nextNode; // reference to the next node in the list
    
    // constructor creates a ListNode that refers to object
    ListNode( T object )
    {
        this( object, null );
    } // end ListNode one-argument constructor

    // constructor creates ListNode that refers to the specified
    // object and to the next ListNode
    ListNode( T object, ListNode< T > node )
    {
        data = object;
        nextNode = node;
    } // end ListNode two-argument constructor  

    // return reference to data in node
    T getData()
    {
        return data; // return item in this node
    } // end method getData

    // return reference to next node in list
    ListNode< T > getNext()
    {
        return nextNode; // get next node
    } // end method getNext

} // end class ListNode< T >