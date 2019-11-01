package com.sqlsamples;

import java.util.Date;
import javax.persistence.*;
import java.text.SimpleDateFormat;
import java.io.Serializable;

@Entity
@Table(name = "Tasks")
@NamedQueries({
	  @NamedQuery(name="findTaskAll", query="SELECT t FROM  Tasks t"),
	  @NamedQuery(name="findTaskByUser", 
	      query="SELECT t FROM Tasks t WHERE t.user_id = :user_id")
	})
public class Task  implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    private Boolean isComplete;
    @Temporal(TemporalType.TIMESTAMP)
    private Date dueDate;

    // Specify a Many:1 mapping between Task and User
    @ManyToOne
    private User user;

    public Task() {
    }

    public Task(String title, Date dueDate) {
        this.title = title;
        this.dueDate = dueDate;
        this.isComplete = false;
    }

    public Task(String title, Date dueDate, User user) {
        this.title = title;
        this.dueDate = dueDate;
        this.isComplete = false;
        this.user = user;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return this.title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public User getUser() {
        return this.user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Date getDueDate() {
        return this.dueDate;
    }

    public void setDueDate(Date dueDate) {
        this.dueDate = dueDate;
    }

    @Override
    public String toString() {
        SimpleDateFormat ft = new SimpleDateFormat("E yyyy.MM.dd 'at' hh:mm:ss a zzz");
        return "Task [id=" + this.id + ", title=" + this.title + ", dueDate=" + ft.format(this.dueDate)
                + ", isComplete=" + this.isComplete.toString() + "]";
    }
}