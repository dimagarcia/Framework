package com.sqlsamples;

import javax.ejb.*;
import javax.persistence.*;
import java.util.*;

@Stateless
public class SessionBeanFacade {
	@PersistenceContext(unitName = "primary", type = PersistenceContextType.EXTENDED) //"em")
	private EntityManager em; // = JPAUtil.buildEntityManagerFactory().getEntityManager();
	@TransactionAttribute(TransactionAttributeType.REQUIRES_NEW)
	public List<User> getAllUsers() {
		ArrayList<User> users = new ArrayList<User>();
		Query q = em.createNamedQuery("findUserAll");
		for (Object usr : q.getResultList()) {
			users.add((User) usr);
		}
		return users;
	}
	public List<Task> getAllTasks() {
		ArrayList<Task> tasks = new ArrayList<Task>();
		Query q = em.createNamedQuery("findTasñAll");
		for (Object tsk : q.getResultList()) {
			tasks.add((Task) tsk);
		}
		return users;
	}

	public void createTestData() {
		
        // Create demo: Create a User instance and save it to the database
        User newUser = new User("Anna", "Shrestinian");
		em.persist(newUser);
		//em.flush();

        // Create demo: Create a Task instance and save it to the database
        SimpleDateFormat sdf = new SimpleDateFormat("MM-dd-yyyy");
        Task newTask = new Task("Ship Helsinki", sdf.parse("04-01-2017"));
		em.persist(newTask);

        // Association demo: Assign task to user
        newTask.setUser(newUser);
        em.persist(newTask);
		
		
	}

	public void deleteSomeData() {
		// remove a catalog
		Query q = em.createNamedQuery("findTaskByUser");
		q.setParameter("user_id", "1");
		List<Task> tasks = q.getResultList();
		//ArrayList<Catalog> catalogList = new ArrayList<Catalog>();
		for (Task task : tasks) {
			 
			em.remove(task);
		//	em.flush();
		}
	}
}