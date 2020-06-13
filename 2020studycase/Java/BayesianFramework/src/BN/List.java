/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        List
 * Description: Generic List (Ref. Java How to Program - Paul Deitel and Harvey Deitel)
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
// class List definition
public class List< T >
{
    private ListNode< T > firstNode;
    private ListNode< T > lastNode;
    private String name; // string like "list" used in printing
    
    // constructor creates empty List with "list" as the name
    public List()
    {
        this( "list" );
    } // end List no-argument constructor
    
    // constructor creates an empty List with a name
    public List( String listName )
    {
        name = listName;
        firstNode = lastNode = null;
    } // end List one-argument constructor
    
    // insert item at front of List
    public void insertAtFront( T insertItem )
    {
        if ( isEmpty() ) // firstNode and lastNode refer to same object
            firstNode = lastNode = new ListNode< T >( insertItem );
        else // firstNode refers to new node
            firstNode = new ListNode< T >( insertItem, firstNode );
    } // end method insertAtFront
    
    // insert item at end of List
    public void insertAtBack( T insertItem )
    {
        if ( isEmpty() ) // firstNode and lastNode refer to same object
            firstNode = lastNode = new ListNode< T >( insertItem );
        else // lastNode's nextNode refers to new node
            lastNode = lastNode.nextNode = new ListNode< T >( insertItem );
    } // end method insertAtBack
    
    // remove first node from List
    public T removeFromFront() throws EmptyListException
    {
        if ( isEmpty() ) // throw exception if List is empty
            throw new EmptyListException( name );
        
        T removedItem = firstNode.data; // retrieve data being removed
        
        // update references firstNode and lastNode
        if ( firstNode == lastNode )
            firstNode = lastNode = null;
        else
            firstNode = firstNode.nextNode;
        
        return removedItem; // return removed node data
    } // end method removeFromFront
    
    // query first node from List
    public T queryFromFront() throws EmptyListException
    {
        if ( isEmpty() ) // throw exception if List is empty
            throw new EmptyListException( name );
        
        T queryItem = firstNode.data; // retrieve data being queried
        
        return queryItem; // return removed node data
    } // end method queryFromFront    

        // query first node from List
    public ListNode<T> queryNodeFromFront() throws EmptyListException
    {
        if ( isEmpty() ) // throw exception if List is empty
            throw new EmptyListException( name );
                
        return firstNode; // return removed node data
    } // end method queryFromFront    

    
    // remove last node from List
    public T removeFromBack() throws EmptyListException
    {
        if ( isEmpty() ) // throw exception if List is empty
            throw new EmptyListException( name );

        T removedItem = lastNode.data; // retrieve data being removed

        // update references firstNode and lastNode
        if ( firstNode == lastNode )
            firstNode = lastNode = null;
        else // locate new last node
        {
            ListNode< T > current = firstNode;
            
            // loop while current node does not refer to lastNode
            while ( current.nextNode != lastNode )
                current = current.nextNode;

            lastNode = current; // current is new lastNode
            current.nextNode = null;
        } // end else
        return removedItem; // return removed node data
    } // end method removeFromBack

    // query last node from List
    public T queryFromBack() throws EmptyListException
    {
        if ( isEmpty() ) // throw exception if List is empty
            throw new EmptyListException( name );

        T queryItem = lastNode.data; // retrieve data being queried

        return queryItem; // return query node data
    } // end method queryFromBack

    // query last node from List
    public ListNode<T> queryNodeFromBack() throws EmptyListException
    {
        if ( isEmpty() ) // throw exception if List is empty
            throw new EmptyListException( name );

        return lastNode; // return query node data
    } // end method queryFromBack
    
    // determine whether list is empty
    public boolean isEmpty()
    {
        return firstNode == null; // return true if list is empty
    } // end method isEmpty
    
    // output list contents
    public void print()
    {
        if ( isEmpty() )
        {
            System.out.printf( "Empty %s\n", name );
            return;
        } // end if
        System.out.printf( "The %s is: ", name );
        ListNode< T > current = firstNode;
        
        // while not at end of list, output current node's data
        while ( current != null )
        {
            System.out.printf( "%s ", current.data );
            current = current.nextNode;
        } // end while
        
        System.out.println( "\n" );
    } // end method print
} // end class List< T >