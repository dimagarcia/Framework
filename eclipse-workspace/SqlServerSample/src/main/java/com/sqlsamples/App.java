// package com.sqlsamples;

// import java.sql.Connection;
// import java.sql.Statement;
// import java.sql.PreparedStatement;
// import java.sql.ResultSet;
// import java.sql.DriverManager;

// public class App {

//     public static void main(String[] args) {

//         System.out.println("Connect to SQL Server and demo Create, Read, Update and Delete operations.");

//         //Update the username and password below
//         //String connectionUrl = "jdbc:sqlserver://localhost:1433;databaseName=master;user=sa;password=your_password";
//         String connectionUrl = "jdbc:sqlserver://192.168.177.170:1433;databaseName=FactorWEB;user=User_Development;password=Sodoku_jdk/c#";
         

//         try {
//             // Load SQL Server JDBC driver and establish connection.
//             System.out.print("Connecting to SQL Server ... ");
//             try (Connection connection = DriverManager.getConnection(connectionUrl)) {
//                 System.out.println("Done.");

//                 // Create a sample database
//                 // System.out.print("Dropping and creating database 'SampleDB' ... ");
//                 String sql = "DROP DATABASE IF EXISTS [SampleDB]; CREATE DATABASE [SampleDB]";
//                 // try (Statement statement = connection.createStatement()) {
//                 //     statement.executeUpdate(sql);
//                 //     System.out.println("Done.");
//                 // }

//                 // Create a Table and insert some sample data
//                 System.out.print("Creating sample table with data, press ENTER to continue...");
//                 System.in.read();
//                 //sql = new StringBuilder().append("USE SampleDB; ").append("CREATE TABLE Employees ( ")
//                 sql = new StringBuilder().append("USE FactorWEB; ").append("CREATE TABLE Employees ( ")
//                         .append(" Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, ").append(" Name NVARCHAR(50), ")
//                         .append(" Location NVARCHAR(50) ").append("); ")
//                         .append("INSERT INTO Employees (Name, Location) VALUES ").append("(N'Jared', N'Australia'), ")
//                         .append("(N'Nikita', N'India'), ").append("(N'Tom', N'Germany'); ").toString();
//                 try (Statement statement = connection.createStatement()) {
//                     statement.executeUpdate(sql);
//                     System.out.println("Done.");
//                 }

//                 // INSERT demo
//                 System.out.print("Inserting a new row into table, press ENTER to continue...");
//                 System.in.read();
//                 sql = new StringBuilder().append("INSERT Employees (Name, Location) ").append("VALUES (?, ?);")
//                         .toString();
//                 try (PreparedStatement statement = connection.prepareStatement(sql)) {
//                     statement.setString(1, "Jake");
//                     statement.setString(2, "United States");
//                     int rowsAffected = statement.executeUpdate();
//                     System.out.println(rowsAffected + " row(s) inserted");
//                 }

//                 // UPDATE demo
//                 String userToUpdate = "Nikita";
//                 System.out.print("Updating 'Location' for user '" + userToUpdate + "', press ENTER to continue...");
//                 System.in.read();
//                 sql = "UPDATE Employees SET Location = N'United States' WHERE Name = ?";
//                 try (PreparedStatement statement = connection.prepareStatement(sql)) {
//                     statement.setString(1, userToUpdate);
//                     int rowsAffected = statement.executeUpdate();
//                     System.out.println(rowsAffected + " row(s) updated");
//                 }

//                 // DELETE demo
//                 String userToDelete = "Jared";
//                 System.out.print("Deleting user '" + userToDelete + "', press ENTER to continue...");
//                 System.in.read();
//                 sql = "DELETE FROM Employees WHERE Name = ?;";
//                 try (PreparedStatement statement = connection.prepareStatement(sql)) {
//                     statement.setString(1, userToDelete);
//                     int rowsAffected = statement.executeUpdate();
//                     System.out.println(rowsAffected + " row(s) deleted");
//                 }

//                 // READ demo
//                 System.out.print("Reading data from table, press ENTER to continue...");
//                 System.in.read();
//                 sql = "SELECT Id, Name, Location FROM Employees;";
//                 try (Statement statement = connection.createStatement();
//                         ResultSet resultSet = statement.executeQuery(sql)) {
//                     while (resultSet.next()) {
//                         System.out.println(
//                                 resultSet.getInt(1) + " " + resultSet.getString(2) + " " + resultSet.getString(3));
//                     }
//                 }
//                 connection.close();
//                 System.out.println("All done.");
//             }
//         } catch (Exception e) {
//             System.out.println();
//             e.printStackTrace();
//         }
//     }
// }
package com.sqlsamples;

import java.sql.Connection;
import java.sql.Statement;
import java.sql.DriverManager;
import java.text.SimpleDateFormat;
import java.util.List;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

/**
 * Java CRUD sample with Hibernate and SQL Server
 *
 */
public class App {
    //String connectionUrl = "jdbc:sqlserver://192.168.177.170:1433"; // update me
    //String userName = "User_Development"; // update me
    //String password = "Sodoku_jdk/c#"; // update me
    //String sampleDatabaseName = "FactorWEB";
    //String connectionUrl = "jdbc:sqlserver://DESKTOP-B3QFUQA:1434"; // update me
    //String connectionUrl = "jdbc:sqlserver://192.168.1.53:1433"; // update me
    //String connectionUrl = "jdbc:sqlserver://localhost:1433"; // update me
    String connectionUrl = "jdbc:sqlserver://localhost\\MSSQL2008R2"; // update me
    String userName = "sa"; // update me
    String password = "system"; // update me
    String sampleDatabaseName = "Training";
    //String sampleDatabaseName = "master";

    // Main entry point
    public static void main(String[] args) {
        App app = new App();
        app.runDemo();
    }

    // Helper to run the demp app
    public void runDemo()
    {
        // Configure Hibernate logging to only log SEVERE errors
        @SuppressWarnings("unused")
        org.jboss.logging.Logger logger = org.jboss.logging.Logger.getLogger("org.hibernate");
        java.util.logging.Logger.getLogger("org.hibernate").setLevel(java.util.logging.Level.SEVERE);

        System.out.println("**Java CRUD sample with Hibernate and SQL Server **\n");
        try {
            // We're creating the Hibernate configuration via code. An alternative is to use a 'hibernate.cfg.xml' file.
            Configuration cfg = createHibernateConfiguration();

            // We're mapping POJO classes to Tables via Hibernate Annotations. An alternative is to use Hibernate mapping xml files.
            cfg.addAnnotatedClass(User.class);
            cfg.addAnnotatedClass(Task.class);

            // Hibernate needs an existing database. Use JDBC to create one for this sample.
            //createSampleDatabase();

            // Create the Hibernate SessionFactory and Session.
            // This causes Hibernate to create Tables and Relationships in the database from our Annotated classes.
            try (SessionFactory sessionFactory = cfg.buildSessionFactory();
                 Session session = sessionFactory.openSession()) {

                System.out.println("Created database schema from Java classes.\n");
                session.beginTransaction();

                // Create demo: Create a User instance and save it to the database
                User newUser = new User("Anna", "Shrestinian");
                session.save(newUser);
                System.out.println("Created User: " + newUser.toString());

                // Create demo: Create a Task instance and save it to the database
                SimpleDateFormat sdf = new SimpleDateFormat("MM-dd-yyyy");
                Task newTask = new Task("Ship Helsinki", sdf.parse("04-01-2017"));
                session.save(newTask);
                System.out.println("Created Task: " + newTask.toString());

                // Association demo: Assign task to user
                newTask.setUser(newUser);
                session.save(newTask);
                System.out.println("Assigned Task: '" + newTask.getTitle() + "' to user '" + newUser.getFullName() + "'\n");

                // Read demo: find incomplete tasks assigned to user 'Anna'
                System.out.println("Incomplete tasks assigned to 'Anna':");
                String hqlQuery = "from Task where isComplete = false and user.firstName = :paramFirstName";
                List<Task> incompleteTasks = session.createQuery(hqlQuery, Task.class)
                                             .setParameter("paramFirstName", "Anna")
                                             .getResultList();
                for(Task theTask : incompleteTasks) {
                    System.out.println(theTask.toString());
                }

                // Update demo: change the 'dueDate' of a task
                hqlQuery = "from Task";
                Task taskToUpdate = session.createQuery(hqlQuery, Task.class)
                                    .getResultList()
                                    .get(0); // get the first task
                System.out.println("\nUpdating task: " + taskToUpdate.toString());
                taskToUpdate.setDueDate(sdf.parse("06-30-2016"));
                session.save(taskToUpdate);
                System.out.println("dueDate changed: " + taskToUpdate.toString());

                // Delete demo: delete all tasks with a dueDate in 2016
                System.out.println("\nDeleting all tasks with a dueDate in 2016");
                hqlQuery = "from Task where dueDate < :paramDate";
                List<Task> tasksToDelete = session.createQuery(hqlQuery, Task.class)
                                           .setParameter("paramDate", sdf.parse("12-31-2016"))
                                           .getResultList();
                for(Task theTask : tasksToDelete) {
                    System.out.println("Deleting task:" + theTask.toString());
                    session.delete(theTask);
                }

                // Show tasks after the 'Delete' operation - there should be 0 tasks
                System.out.println("\nTasks after delete:");
                hqlQuery = "from Task";
                List<Task> tasksAfterDelete = session.createQuery(hqlQuery, Task.class)
                                              .getResultList();
                if(tasksAfterDelete.isEmpty()) {
                    System.out.println("[None]");
                }
                else {
                    for(Task theTask : tasksAfterDelete) {
                        System.out.println(theTask.toString());
                    }
                }

                session.getTransaction().commit();
            }
            System.out.println("All done.");

        } catch (Exception e) {
            System.out.println();
            e.printStackTrace();
        }
    }

    // Hibernate needs an existing database. Use JDBC to create one for this
    // sample.
    private void createSampleDatabase() throws java.sql.SQLException {
        // Load SQL Server JDBC driver and establish connection.
        String url = this.connectionUrl + ";databaseName=master;" + "user=" + this.userName + ";password="
                + this.password;
        System.out.print("Connecting to SQL Server ... ");
        try (Connection connection = DriverManager.getConnection(url)) {
            System.out.println("Done.");

            // Create a sample database
            System.out.print("Dropping and creating database '" + this.sampleDatabaseName + "' ... ");
            String sql = "DROP DATABASE IF EXISTS [" + this.sampleDatabaseName + "]; CREATE DATABASE ["
                    + this.sampleDatabaseName + "]";
            // try (Statement statement = connection.createStatement()) {
            //     statement.executeUpdate(sql);
            //     System.out.println("Done.\n");
            // }
        }
    }

    // Create Hibernate configuration via code instead of using a
    // 'hibernate.cfg.xml' file.
    private Configuration createHibernateConfiguration() {
        String url = this.connectionUrl + ";databaseName=" + this.sampleDatabaseName;
        Configuration cfg = new Configuration()
                .setProperty("hibernate.connection.driver_class", "com.microsoft.sqlserver.jdbc.SQLServerDriver")
                .setProperty("hibernate.connection.url", url)
                .setProperty("hibernate.connection.username", this.userName)
                .setProperty("hibernate.connection.password", this.password)
                .setProperty("hibernate.connection.autocommit", "true")
                .setProperty("hibernate.show_sql", "false");

        // Tell Hibernate to use the 'SQL Server' dialect when dynamically
        // generating SQL queries
        cfg.setProperty("hibernate.dialect", "org.hibernate.dialect.SQLServerDialect");

        // Tell Hibernate to show the generated T-SQL
        cfg.setProperty("hibernate.show_sql", "false");

        // This is ok during development, but not recommended in production
        // See: http://stackoverflow.com/questions/221379/hibernate-hbm2ddl-auto-update-in-production
        cfg.setProperty("hibernate.hbm2ddl.auto", "update");
        return cfg;
    }
}