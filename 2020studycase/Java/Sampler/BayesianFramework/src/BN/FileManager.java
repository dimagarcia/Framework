/*
 * Propiedad intelectual de la Universidad del Valle
 * Name:        FileManager
 * Description: File manages
 * Author:      Diego Garcia
 * Date:        18th September 2015
 *
 * Modification Log:
 * ---------------------------
 * 2015-09-18   Diego Garcia    Creation.
 */
package BN;

import java.io.File;
import java.io.FileNotFoundException;
import java.lang.IllegalStateException;
import java.lang.SecurityException;
import java.util.Formatter;
import java.util.FormatterClosedException;
import java.util.NoSuchElementException;
import java.util.Scanner;

/**
 *
 * @author dgarcia
 */
public class FileManager {
   static public String fileName = "samples.txt"; 
   static public String separator = " "; 
   static public List<String> X[];
   static public List<BayesianNode> aTopologicalOrder;
   
   static public void writeSamples(List<BayesianNode> aTopologicalOrder,
                                   List<String> X[] ){
       FileManager.X = X;
       FileManager.aTopologicalOrder = aTopologicalOrder;
       CreateTextFile file = new CreateTextFile();
       file.openFile();
       file.addRecords();
       file.closeFile();
   }
}

// The following classes were taken from the book "Java How to Program" by Deitel & Deitel

// Writing data to a sequential text file with class Formatter.
class CreateTextFile{
    private Formatter output; // object used to output text to file

    // enable user to open file
    public void openFile(){
        try
        {
            output = new Formatter( FileManager.fileName ); // open the file
        } // end try
        catch ( SecurityException securityException )
        {
            System.err.println("You do not have write access to this file." );
            System.exit( 1 ); // terminate the program
        } // end catch
        catch ( FileNotFoundException fileNotFoundException )
        {
            System.err.println( "Error opening or creating file." );
            System.exit( 1 ); // terminate the program
        } // end catch
    } // end method openFile

    // add records to file
    public void addRecords(){
        // object to be written to file
//        AccountRecord record = new AccountRecord();
//        Scanner input = new Scanner( System.in );

//        System.out.printf( "%s\n%s\n%s\n%s\n\n",
//            "To terminate input, type the end-of-file indicator ",
//            "when you are prompted to enter input.",
//            "On UNIX/Linux/Mac OS X type <ctrl> d then press Enter",
//            "On Windows type <ctrl> z then press Enter" );

//        System.out.printf( "%s\n%s",
//            "Enter account number (> 0), first name, last name and balance.",
//            "? " );

        BN.ListNode<BN.BayesianNode> node = FileManager.aTopologicalOrder.queryNodeFromFront();
        while (node != null){
            output.format( "%s", node.data.name);
            node = node.nextNode;
            if (node != null) output.format(FileManager.separator);
        }
        output.format("\n");
      
        
//        while( input.hasNext() ){// loop until end-of-file indicator
        for (int i=0; i < FileManager.X.length; i++){
            try{ // output values to file
                // retrieve data to be output
//                record.setAccount( input.nextInt() ); // read account number
//                record.setFirstName( input.next() ); // read first name
//                record.setLastName( input.next() ); // read last name
//                record.setBalance( input.nextDouble() ); // read balance

//                if ( record.getAccount() > 0 ){
//                    // write new record
//                    output.format( "%d %s %s %.2f\n", record.getAccount(),
//                        record.getFirstName(), record.getLastName(),
//                        record.getBalance() );
//                } // end if
//                else{
//                    System.out.println(
//                        "Account number must be greater than 0." );
//                } // end else
                ListNode<String> sample = FileManager.X[i].queryNodeFromFront();
                while (sample != null){
                    output.format( "%s", sample.data);
                    sample = sample.nextNode;
                    if (sample != null) output.format(FileManager.separator);
                }
                output.format("\n");
            } // end try
            catch ( FormatterClosedException formatterClosedException ){
                System.err.println( "Error writing to file." );
                return;
            } // end catch
//            catch ( NoSuchElementException elementException ){
//                System.err.println( "Invalid input. Please try again." );
//                input.nextLine(); // discard input so user can try again
//            } // end catch
//            System.out.printf( "%s %s\n%s", "Enter account number (>0),",
//                "first name, last name and balance.", "? " );
        } // end while
    } // end method addRecords     

    // close file
    public void closeFile(){
        if ( output != null )
            output.close();
    } // end method closeFile

} // end class CreateTextFile

// This program reads a text file and displays each record
class ReadTextFile{
    private Scanner input;

    // enable user to open file
    public void openFile(){
        try{
            input = new Scanner( new File( FileManager.fileName ) );
        } // end try
        catch ( FileNotFoundException fileNotFoundException ){
            System.err.println( "Error opening file." );
            System.exit( 1 );
        } // end catch
    } // end method openFile

    // read record from file
    public void readRecords(){
        // object to be written to screen
//        AccountRecord record = new AccountRecord();
//
//        System.out.printf( "%-10s%-12s%-12s%10s\n", "Account",
//        "First Name", "Last Name", "Balance" );

        try{ // read records from file using Scanner object
            while( input.hasNext() ){
//                record.setAccount( input.nextInt() ); // read account number
//                record.setFirstName( input.next() ); // read first name
//                record.setLastName( input.next() ); // read last name
//                record.setBalance( input.nextDouble() ); // read balance
//                // display record contents
//                System.out.printf( "%-10d%-12s%-12s%10.2f\n",
//                    record.getAccount(), record.getFirstName(),
//                    record.getLastName(), record.getBalance() );
            } // end while
        } // end try
        catch ( NoSuchElementException elementException ){
            System.err.println( "File improperly formed." );
            input.close();
            System.exit( 1 );
        } // end catch
        catch ( IllegalStateException stateException ){
            System.err.println( "Error reading from file." );
            System.exit( 1 );
        } // end catch
    } // end method readRecords

    // close file and terminate application
    public void closeFile(){
        if ( input != null )
            input.close(); // close file
    } // end method closeFile
    
} // end class ReadTextFile