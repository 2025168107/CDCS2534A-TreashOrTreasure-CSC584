package com.universityclub.beans;

import java.io.Serializable;

public class StudentBean implements Serializable {
    private String studentId;
    private String studentName;
    private String username;
    private String email;
    private String password;
    private int yearOfStudy;
    private String faculty;
    private String status;
    
    public StudentBean() {}
    
    // Getters and Setters
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public int getYearOfStudy() { return yearOfStudy; }
    public void setYearOfStudy(int yearOfStudy) { this.yearOfStudy = yearOfStudy; }
    
    public String getFaculty() { return faculty; }
    public void setFaculty(String faculty) { this.faculty = faculty; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}