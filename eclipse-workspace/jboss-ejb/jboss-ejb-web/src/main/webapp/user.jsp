<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="com.sqlsamples.*,java.util.*,javax.naming.*"%>
<html>
<head>
<meta http-equiv="Content-Type"
	content="text/html; charset=windows-1252" />
<title>EJB3 Client</title>
</head>
<body>
	<%
        //Hashtable jndiProperties = new Hashtable();
       // jndiProperties.put(Context.URL_PKG_PREFIXES,"org.jboss.ejb.client.naming");
        Context context = new InitialContext();
        
		SessionBeanFacade bean = (SessionBeanFacade) context.lookup("java:app/jboss-ejb-ejb/SessionBeanFacade!com.sqlsamples.SessionBeanFacade");
        bean.createTestData();
        List<User> users = bean.getAllUsers();
        out.println("<br/>" + "List of Users" + "<br/>");
        for (User user : users) {
            out.println("User Id:");
            out.println(user.getId() + "<br/>");
            out.println("User name:");
            out.println(user.getFullName() + "<br/>");
        }

        List<Task> tasks = bean.getAllTasks();
        out.println("<br/>" + "List of Tasks" + "<br/>");
        for (Task task : tasks) {
            out.println(" Id:");
            out.println(task.getId() + "<br/>");
            out.println("Title:");
            out.println(task.getTitle() + "<br/>");
        }

        out.println("<br/>"+"Delete some Data" + "<br/>");
        bean.deleteSomeData();

        catalogs = bean.getAllCatalogs();
        List<Task> tasks = bean.getAllTasks();
        out.println("<br/>" + "List of Tasks" + "<br/>");
        for (Task task : tasks) {
            out.println(" Id:");
            out.println(task.getId() + "<br/>");
            out.println("Title:");
            out.println(task.getTitle() + "<br/>");
        }
    %>
</body>
</html>