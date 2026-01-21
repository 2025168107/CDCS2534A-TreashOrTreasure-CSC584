package com.universityclub.servlets;

import com.universityclub.DBConnection;
import com.universityclub.beans.AdminBean;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AnnouncementServlet")
public class AnnouncementServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            handleCreateAnnouncement(request, response);
        } else if ("delete".equals(action)) {
            handleDeleteAnnouncement(request, response);
        }
    }
    
    private void handleCreateAnnouncement(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        AdminBean admin = (AdminBean) session.getAttribute("adminBean");
        
        if (admin == null) {
            response.sendRedirect("index.jsp?error=Please login as admin first");
            return;
        }
        
        int clubId = admin.getClubId();
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String type = request.getParameter("announcementType");
        String activityIdStr = request.getParameter("activityId");
        
        Integer activityId = null;
        if (activityIdStr != null && !activityIdStr.isEmpty()) {
            activityId = Integer.parseInt(activityIdStr);
        }
        
        try {
            Connection con = DBConnection.getConnection();
            String sql = "INSERT INTO ANNOUNCEMENT (club_id, title, content, announcement_type, activity_id) " +
                         "VALUES (?, ?, ?, ?, ?)";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, clubId);
            pstmt.setString(2, title);
            pstmt.setString(3, content);
            pstmt.setString(4, type);
            if (activityId != null) {
                pstmt.setInt(5, activityId);
            } else {
                pstmt.setNull(5, java.sql.Types.INTEGER);
            }
            
            pstmt.executeUpdate();
            con.close();
            
            response.sendRedirect("adminDashboard.jsp?success=Announcement posted successfully!");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminDashboard.jsp?error=Error posting announcement");
        }
    }
    
    private void handleDeleteAnnouncement(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        AdminBean admin = (AdminBean) session.getAttribute("adminBean");
        
        if (admin == null) {
            response.sendRedirect("index.jsp?error=Please login as admin first");
            return;
        }
        
        int announcementId = Integer.parseInt(request.getParameter("announcementId"));
        
        try {
            Connection con = DBConnection.getConnection();
            String sql = "DELETE FROM ANNOUNCEMENT WHERE announcement_id = ? AND club_id = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, announcementId);
            pstmt.setInt(2, admin.getClubId());
            
            int rows = pstmt.executeUpdate();
            con.close();
            
            if (rows > 0) {
                response.sendRedirect("adminDashboard.jsp?success=Announcement deleted successfully!");
            } else {
                response.sendRedirect("adminDashboard.jsp?error=Announcement not found or not authorized");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminDashboard.jsp?error=Error deleting announcement");
        }
    }
}