package com.sqlsamples;

import javax.annotation.Resource;
import javax.faces.context.FacesContext;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.servlet.http.HttpServletRequest;
import javax.transaction.Transactional;


@Transactional
public class JPAUtil {


    private static EntityManagerFactory entityManagerFactory = buildEntityManagerFactory();


    private static EntityManagerFactory buildEntityManagerFactory() {
            entityManagerFactory =  Persistence.createEntityManagerFactory("primary");
            return entityManagerFactory;
    }

    public  EntityManager getEntityManager() {
        return entityManagerFactory.createEntityManager();
    }

    public static  EntityManagerFactory getEntityManagerFactory() {
        return entityManagerFactory;
    }

}