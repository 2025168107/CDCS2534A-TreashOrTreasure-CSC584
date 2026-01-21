package com.universityclub.servlets;

import com.universityclub.DBConnection;
import com.universityclub.beans.AdminBean;
import com.universityclub.beans.StudentBean;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ActivityServlet")
public class ActivityServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            handleCreateActivity(request, response);
        } else if ("join".equals(action)) {
            handleJoinActivity(request, response);
        } else if ("update".equals(action)) {
            handleUpdateActivity(request, response);
        } else if ("delete".equals(action)) {
            handleDeleteActivity(request, response);
        }
    }
    
    private void handleCreateActivity(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        AdminBean admin = (AdminBean) session.getAttribute("adminBean");
        
        if (admin == null) {
            response.sendRedirect("index.jsp?error=Please login as admin first");
            return;
        }
        
        int clubId = admin.getClubId();
        String title = request.getParameter("activityTitle");
        String description = request.getParameter("description");
        String dateTime = request.getParameter("dateTime");
        String location = request.getParameter("location");
        
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = DBConnection.getConnection();
            
            System.out.println("=== CREATE ACTIVITY ===");
            System.out.println("Club ID: " + clubId);
            System.out.println("Title: " + title);
            System.out.println("Description: " + description);
            System.out.println("DateTime: " + dateTime);
            System.out.println("Location: " + location);
            
            // Validate input
            if (title == null || title.trim().isEmpty() ||
                description == null || description.trim().isEmpty() ||
                dateTime == null || dateTime.trim().isEmpty() ||
                location == null || location.trim().isEmpty()) {
                
                response.sendRedirect("adminDashboard.jsp?error=All fields are required");
                return;
            }
            
            // Check if date is in the future
            try {
                java.time.LocalDateTime activityDateTime = java.time.LocalDateTime.parse(dateTime.replace("T", " "));
                java.time.LocalDateTime now = java.time.LocalDateTime.now();
                if (activityDateTime.isBefore(now)) {
                    response.sendRedirect("adminDashboard.jsp?error=Activity date must be in the future");
                    return;
                }
            } catch (Exception e) {
                System.err.println("Date parsing error: " + e.getMessage());
            }
            
            // Parse and format the date
            String formattedDateTime = dateTime.replace("T", " ") + ":00";
            System.out.println("Formatted DateTime: " + formattedDateTime);
            
            // Insert into database
            String sql = "INSERT INTO ACTIVITY (club_id, activity_title, description, date_time, location) " +
                         "VALUES (?, ?, ?, ?, ?)";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, clubId);
            pstmt.setString(2, title.trim());
            pstmt.setString(3, description.trim());
            
            try {
                // Try to parse as timestamp
                pstmt.setTimestamp(4, Timestamp.valueOf(formattedDateTime));
            } catch (IllegalArgumentException e) {
                // If timestamp fails, use string
                System.err.println("Timestamp parse error, using string: " + e.getMessage());
                pstmt.setString(4, formattedDateTime);
            }
            
            pstmt.setString(5, location.trim());
            
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("Rows inserted: " + rowsAffected);
            
            // Simple redirect back to dashboard
            response.sendRedirect("adminDashboard.jsp?success=Activity created successfully!");
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("SQL Error: " + e.getMessage());
            
            String errorMsg;
            if (e.getMessage().contains("date_time")) {
                errorMsg = "Invalid date/time format";
            } else if (e.getMessage().contains("Duplicate entry")) {
                errorMsg = "Activity with this title already exists";
            } else {
                errorMsg = "Database error: " + e.getMessage();
            }
            
            response.sendRedirect("adminDashboard.jsp?error=" + errorMsg);
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("General Error: " + e.getMessage());
            response.sendRedirect("adminDashboard.jsp?error=Error creating activity");
            
        } finally {
            // Close resources
            try {
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    private void handleJoinActivity(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        StudentBean student = (StudentBean) session.getAttribute("studentBean");
        
        if (student == null) {
            response.sendRedirect("index.jsp?error=Please login first");
            return;
        }
        
        String studentId = student.getStudentId();
        int activityId = Integer.parseInt(request.getParameter("activityId"));
        
        Connection con = null;
        PreparedStatement checkStmt = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            con = DBConnection.getConnection();
            
            // Check if already joined
            String checkSql = "SELECT COUNT(*) FROM PARTICIPATION WHERE student_id = ? AND activity_id = ?";
            checkStmt = con.prepareStatement(checkSql);
            checkStmt.setString(1, studentId);
            checkStmt.setInt(2, activityId);
            rs = checkStmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                response.sendRedirect("studentDashboard.jsp?error=Already joined this activity");
                return;
            }
            
            // Join the activity
            String sql = "INSERT INTO PARTICIPATION (student_id, activity_id, registered_at) VALUES (?, ?, CURRENT_TIMESTAMP)";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, studentId);
            pstmt.setInt(2, activityId);
            
            pstmt.executeUpdate();
            
            response.sendRedirect("studentDashboard.jsp?success=Successfully joined the activity!");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("studentDashboard.jsp?error=Error joining activity");
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    private void handleUpdateActivity(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("adminDashboard.jsp?error=Update feature coming soon");
    }
    
    private void handleDeleteActivity(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        AdminBean admin = (AdminBean) session.getAttribute("adminBean");
        
        if (admin == null) {
            response.sendRedirect("index.jsp?error=Please login as admin first");
            return;
        }
        
        int activityId = Integer.parseInt(request.getParameter("activityId"));
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = DBConnection.getConnection();
            
            // First, delete participation records for this activity
            String deleteParticipationSql = "DELETE FROM PARTICIPATION WHERE activity_id = ?";
            pstmt = con.prepareStatement(deleteParticipationSql);
            pstmt.setInt(1, activityId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Then delete the activity
            String deleteActivitySql = "DELETE FROM ACTIVITY WHERE activity_id = ? AND club_id = ?";
            pstmt = con.prepareStatement(deleteActivitySql);
            pstmt.setInt(1, activityId);
            pstmt.setInt(2, admin.getClubId());
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                response.sendRedirect("adminDashboard.jsp?success=Activity deleted successfully!");
            } else {
                response.sendRedirect("adminDashboard.jsp?error=Activity not found or you don't have permission to delete it");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminDashboard.jsp?error=Error deleting activity: " + e.getMessage());
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}