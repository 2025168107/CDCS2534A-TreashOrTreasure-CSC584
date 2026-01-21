package com.universityclub.dao;

import com.universityclub.DBConnection;
import com.universityclub.beans.StudentBean;
import java.sql.*;

public class StudentDAO {
    
    public StudentBean loginStudent(String username, String password) {
        StudentBean student = null;
        String sql = "SELECT * FROM STUDENT WHERE (username = ? OR email = ? OR student_id = ?) AND password = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            pstmt.setString(2, username);
            pstmt.setString(3, username);
            pstmt.setString(4, password);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                student = new StudentBean();
                student.setStudentId(rs.getString("student_id"));
                student.setStudentName(rs.getString("student_name"));
                student.setUsername(rs.getString("username"));
                student.setEmail(rs.getString("email"));
                student.setPassword(rs.getString("password"));
                student.setYearOfStudy(rs.getInt("year_of_study"));
                student.setFaculty(rs.getString("faculty"));
                student.setStatus(rs.getString("status"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return student;
    }
    
    public boolean registerStudent(StudentBean student) {
        String sql = "INSERT INTO STUDENT (student_id, student_name, username, email, password, year_of_study, faculty) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            
            pstmt.setString(1, student.getStudentId());
            pstmt.setString(2, student.getStudentName());
            pstmt.setString(3, student.getUsername());
            pstmt.setString(4, student.getEmail());
            pstmt.setString(5, student.getPassword());
            pstmt.setInt(6, student.getYearOfStudy());
            pstmt.setString(7, student.getFaculty());
            
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean checkStudentExists(String studentId, String email, String username) {
        String sql = "SELECT COUNT(*) FROM STUDENT WHERE student_id = ? OR email = ? OR username = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            
            pstmt.setString(1, studentId);
            pstmt.setString(2, email);
            pstmt.setString(3, username);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    
}