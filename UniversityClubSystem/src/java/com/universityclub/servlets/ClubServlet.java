package com.universityclub.servlets;

import com.universityclub.DBConnection;
import com.universityclub.beans.AdminBean;
import com.universityclub.beans.StudentBean;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ClubServlet")
public class ClubServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("join".equals(action)) {
            handleJoinClub(request, response);
        } else if ("leave".equals(action)) {
            handleLeaveClub(request, response);
        } else if ("updaterole".equals(action)) {
            handleUpdateRole(request, response);
        } else if ("removemember".equals(action)) {
            handleRemoveMember(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("details".equals(action)) {
            handleClubDetails(request, response);
        } else if ("members".equals(action)) {
            handleClubMembers(request, response);
        } else if ("activityparticipants".equals(action)) {
            handleActivityParticipants(request, response);
        }
    }
    
    private void handleJoinClub(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        StudentBean student = (StudentBean) session.getAttribute("studentBean");
        
        if (student == null) {
            response.sendRedirect("index.jsp?error=Please login first");
            return;
        }
        
        String studentId = student.getStudentId();
        int clubId = Integer.parseInt(request.getParameter("clubId"));
        
        Connection con = null;
        PreparedStatement checkStmt = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            con = DBConnection.getConnection();
            
            // Check if already joined
            String checkSql = "SELECT COUNT(*) FROM MEMBERSHIP WHERE student_id = ? AND club_id = ?";
            checkStmt = con.prepareStatement(checkSql);
            checkStmt.setString(1, studentId);
            checkStmt.setInt(2, clubId);
            rs = checkStmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                response.sendRedirect("studentDashboard.jsp?error=Already joined this club");
                return;
            }
            
            // Join the club
            String sql = "INSERT INTO MEMBERSHIP (student_id, club_id, role_club, joined_at) VALUES (?, ?, 'Member', CURRENT_TIMESTAMP)";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, studentId);
            pstmt.setInt(2, clubId);
            
            pstmt.executeUpdate();
            
            response.sendRedirect("studentDashboard.jsp?success=Successfully joined the club!");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("studentDashboard.jsp?error=Error joining club");
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
    
    private void handleLeaveClub(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        StudentBean student = (StudentBean) session.getAttribute("studentBean");
        
        if (student == null) {
            response.sendRedirect("index.jsp?error=Please login first");
            return;
        }
        
        String studentId = student.getStudentId();
        int clubId = Integer.parseInt(request.getParameter("clubId"));
        
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = DBConnection.getConnection();
            
            // Check the role before leaving (students can't leave if they're President with no replacement)
            String checkRoleSql = "SELECT role_club FROM MEMBERSHIP WHERE student_id = ? AND club_id = ?";
            PreparedStatement roleStmt = con.prepareStatement(checkRoleSql);
            roleStmt.setString(1, studentId);
            roleStmt.setInt(2, clubId);
            ResultSet rs = roleStmt.executeQuery();
            
            if (rs.next()) {
                String role = rs.getString("role_club");
                
                // If the student is President, check if there's another President or Vice President
                if ("President".equals(role)) {
                    String checkAdminSql = "SELECT COUNT(*) FROM MEMBERSHIP WHERE club_id = ? AND role_club IN ('President', 'Vice President')";
                    PreparedStatement adminStmt = con.prepareStatement(checkAdminSql);
                    adminStmt.setInt(1, clubId);
                    ResultSet adminRs = adminStmt.executeQuery();
                    
                    if (adminRs.next() && adminRs.getInt(1) <= 1) {
                        // This is the only President/Vice President
                        response.sendRedirect("studentDashboard.jsp?error=Cannot leave as the only President. Assign a new President first.");
                        roleStmt.close();
                        adminStmt.close();
                        return;
                    }
                    adminStmt.close();
                }
            }
            roleStmt.close();
            
            // Leave the club
            String sql = "DELETE FROM MEMBERSHIP WHERE student_id = ? AND club_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, studentId);
            pstmt.setInt(2, clubId);
            
            int rows = pstmt.executeUpdate();
            
            if (rows > 0) {
                response.sendRedirect("studentDashboard.jsp?success=Left the club successfully!");
            } else {
                response.sendRedirect("studentDashboard.jsp?error=Error leaving club");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("studentDashboard.jsp?error=Error leaving club");
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
    
    private void handleUpdateRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        AdminBean admin = (AdminBean) session.getAttribute("adminBean");
        
        if (admin == null) {
            response.sendRedirect("index.jsp?error=Please login as admin first");
            return;
        }
        
        int clubId = admin.getClubId();
        String studentId = request.getParameter("studentId");
        String role = request.getParameter("roleClub");
        
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = DBConnection.getConnection();
            
            // Update the role
            String sql = "UPDATE MEMBERSHIP SET role_club = ? WHERE student_id = ? AND club_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, role);
            pstmt.setString(2, studentId);
            pstmt.setInt(3, clubId);
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                response.sendRedirect("adminDashboard.jsp?success=Role updated successfully!");
            } else {
                response.sendRedirect("adminDashboard.jsp?error=Failed to update role");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminDashboard.jsp?error=Error updating role");
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
    
    private void handleRemoveMember(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        AdminBean admin = (AdminBean) session.getAttribute("adminBean");
        
        if (admin == null) {
            response.sendRedirect("index.jsp?error=Please login as admin first");
            return;
        }
        
        int clubId = admin.getClubId();
        String studentId = request.getParameter("studentId");
        
        Connection con = null;
        PreparedStatement checkStmt = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            con = DBConnection.getConnection();
            
            // Check the role of the member being removed
            String checkRoleSql = "SELECT role_club FROM MEMBERSHIP WHERE club_id = ? AND student_id = ?";
            checkStmt = con.prepareStatement(checkRoleSql);
            checkStmt.setInt(1, clubId);
            checkStmt.setString(2, studentId);
            rs = checkStmt.executeQuery();
            
            String memberRole = "Member";
            if (rs.next()) {
                memberRole = rs.getString("role_club");
            }
            
            // If the member is President, check if there's another President or Vice President
            if ("President".equals(memberRole)) {
                String checkAdminSql = "SELECT COUNT(*) FROM MEMBERSHIP WHERE club_id = ? AND role_club IN ('President', 'Vice President')";
                PreparedStatement adminStmt = con.prepareStatement(checkAdminSql);
                adminStmt.setInt(1, clubId);
                ResultSet adminRs = adminStmt.executeQuery();
                
                if (adminRs.next() && adminRs.getInt(1) <= 1) {
                    // This is the only President/Vice President
                    response.sendRedirect("adminDashboard.jsp?deleteMemberError=Cannot remove the last President. Assign a new President first.");
                    adminStmt.close();
                    return;
                }
                adminStmt.close();
            }
            
            // Also check if the admin is trying to remove themselves
            String checkAdminIdSql = "SELECT admin_id FROM ADMIN WHERE club_id = ?";
            PreparedStatement adminIdStmt = con.prepareStatement(checkAdminIdSql);
            adminIdStmt.setInt(1, clubId);
            ResultSet adminIdRs = adminIdStmt.executeQuery();
            
            if (adminIdRs.next()) {
                // Check if this admin's student account matches the student being removed
                String checkStudentAdminSql = "SELECT student_id FROM STUDENT WHERE email = (SELECT email FROM ADMIN WHERE admin_id = ?)";
                PreparedStatement studentAdminStmt = con.prepareStatement(checkStudentAdminSql);
                studentAdminStmt.setInt(1, adminIdRs.getInt("admin_id"));
                ResultSet studentAdminRs = studentAdminStmt.executeQuery();
                
                if (studentAdminRs.next() && studentAdminRs.getString("student_id").equals(studentId)) {
                    response.sendRedirect("adminDashboard.jsp?deleteMemberError=Cannot remove yourself as admin. Contact system administrator.");
                    studentAdminStmt.close();
                    adminIdStmt.close();
                    return;
                }
                studentAdminStmt.close();
            }
            adminIdStmt.close();
            
            // Delete the member from club
            String sql = "DELETE FROM MEMBERSHIP WHERE student_id = ? AND club_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, studentId);
            pstmt.setInt(2, clubId);
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                response.sendRedirect("adminDashboard.jsp?deleteMemberSuccess=Member removed successfully!");
            } else {
                response.sendRedirect("adminDashboard.jsp?deleteMemberError=Failed to remove member");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("adminDashboard.jsp?deleteMemberError=Database error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminDashboard.jsp?deleteMemberError=Error removing member");
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
    
    private void handleClubDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String clubId = request.getParameter("clubId");
        
        response.setContentType("text/html");
        
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            con = DBConnection.getConnection();
            
            // Get club basic info
            String sql = "SELECT c.*, " +
                       "(SELECT COUNT(*) FROM MEMBERSHIP WHERE club_id = c.club_id) as member_count, " +
                       "(SELECT COUNT(*) FROM ACTIVITY WHERE club_id = c.club_id) as total_activities " +
                       "FROM CLUB c WHERE c.club_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(clubId));
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                response.getWriter().println("<h4>" + rs.getString("club_name") + "</h4>");
                response.getWriter().println("<p><strong>Description:</strong> " + rs.getString("description") + "</p>");
                response.getWriter().println("<p><strong>Total Members:</strong> " + rs.getInt("member_count") + "</p>");
                response.getWriter().println("<p><strong>Total Activities:</strong> " + rs.getInt("total_activities") + "</p>");
                
                // Get recent announcements (Derby doesn't support LIMIT, use FETCH FIRST)
                String announcementSql = "SELECT title, posted_at FROM ANNOUNCEMENT " +
                                       "WHERE club_id = ? ORDER BY posted_at DESC FETCH FIRST 3 ROWS ONLY";
                PreparedStatement announcementStmt = con.prepareStatement(announcementSql);
                announcementStmt.setInt(1, Integer.parseInt(clubId));
                ResultSet announcementRs = announcementStmt.executeQuery();
                
                boolean hasAnnouncements = false;
                while (announcementRs.next()) {
                    if (!hasAnnouncements) {
                        response.getWriter().println("<p><strong>Recent Announcements:</strong></p>");
                        response.getWriter().println("<ul>");
                        hasAnnouncements = true;
                    }
                    response.getWriter().println("<li>" + announcementRs.getString("title") + 
                                               " (" + announcementRs.getTimestamp("posted_at") + ")</li>");
                }
                if (hasAnnouncements) {
                    response.getWriter().println("</ul>");
                } else {
                    response.getWriter().println("<p><em>No recent announcements</em></p>");
                }
                
                announcementStmt.close();
                
                // Get upcoming activities (Derby doesn't support LIMIT, use FETCH FIRST)
                String activitySql = "SELECT activity_title, date_time, location FROM ACTIVITY " +
                                   "WHERE club_id = ? ORDER BY date_time ASC FETCH FIRST 3 ROWS ONLY";
                PreparedStatement activityStmt = con.prepareStatement(activitySql);
                activityStmt.setInt(1, Integer.parseInt(clubId));
                ResultSet activityRs = activityStmt.executeQuery();
                
                boolean hasActivities = false;
                while (activityRs.next()) {
                    if (!hasActivities) {
                        response.getWriter().println("<p><strong>Upcoming Activities:</strong></p>");
                        response.getWriter().println("<ul>");
                        hasActivities = true;
                    }
                    response.getWriter().println("<li>" + activityRs.getString("activity_title") + 
                                               " - " + activityRs.getTimestamp("date_time") + 
                                               " at " + activityRs.getString("location") + "</li>");
                }
                if (hasActivities) {
                    response.getWriter().println("</ul>");
                } else {
                    response.getWriter().println("<p><em>No upcoming activities</em></p>");
                }
                
                activityStmt.close();
            } else {
                response.getWriter().println("<p style='color: red;'><i class='fas fa-exclamation-circle'></i> Club not found</p>");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<p style='color: red;'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>");
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    private void handleClubMembers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String clubId = request.getParameter("clubId");
        
        response.setContentType("text/html");
        
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            con = DBConnection.getConnection();
            String sql = "SELECT s.student_id, s.student_name, s.email, s.faculty, s.year_of_study, m.role_club, m.joined_at " +
                       "FROM STUDENT s " +
                       "JOIN MEMBERSHIP m ON s.student_id = m.student_id " +
                       "WHERE m.club_id = ? " +
                       "ORDER BY m.role_club DESC, s.student_name ASC";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(clubId));
            rs = pstmt.executeQuery();
            
            response.getWriter().println("<div style='max-height: 400px; overflow-y: auto;'>");
            response.getWriter().println("<table style='width: 100%; border-collapse: collapse;'>");
            response.getWriter().println("<thead>");
            response.getWriter().println("<tr style='background: #f8f9fa;'>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Name</th>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Student ID</th>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Role</th>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Faculty</th>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Year</th>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Joined Date</th>");
            response.getWriter().println("</tr>");
            response.getWriter().println("</thead>");
            response.getWriter().println("<tbody>");
            
            boolean hasMembers = false;
            while (rs.next()) {
                hasMembers = true;
                String role = rs.getString("role_club");
                String roleColor = getRoleColor(role);
                
                response.getWriter().println("<tr>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>" + rs.getString("student_name") + "</td>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>" + rs.getString("student_id") + "</td>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>");
                response.getWriter().println("<span style='background: " + roleColor + "; padding: 3px 8px; border-radius: 4px; font-size: 12px;'>");
                response.getWriter().println(role);
                response.getWriter().println("</span>");
                response.getWriter().println("</td>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>" + rs.getString("faculty") + "</td>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>Year " + rs.getInt("year_of_study") + "</td>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>" + rs.getTimestamp("joined_at") + "</td>");
                response.getWriter().println("</tr>");
            }
            
            if (!hasMembers) {
                response.getWriter().println("<tr><td colspan='6' style='padding: 10px; text-align: center;'>No members found</td></tr>");
            }
            
            response.getWriter().println("</tbody>");
            response.getWriter().println("</table>");
            response.getWriter().println("</div>");
            
            // Add summary
            String countSql = "SELECT COUNT(*) as total_members FROM MEMBERSHIP WHERE club_id = ?";
            PreparedStatement countStmt = con.prepareStatement(countSql);
            countStmt.setInt(1, Integer.parseInt(clubId));
            ResultSet countRs = countStmt.executeQuery();
            
            if (countRs.next()) {
                response.getWriter().println("<div style='margin-top: 15px; padding: 10px; background: #f8f9fa; border-radius: 5px;'>");
                response.getWriter().println("<p><strong>Total Members:</strong> " + countRs.getInt("total_members") + "</p>");
                response.getWriter().println("</div>");
            }
            
            countStmt.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<p style='color: red;'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>");
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    private void handleActivityParticipants(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String activityId = request.getParameter("activityId");
        
        response.setContentType("text/html");
        
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            con = DBConnection.getConnection();
            String sql = "SELECT s.student_id, s.student_name, s.email, s.faculty, s.year_of_study, p.registered_at " +
                       "FROM STUDENT s " +
                       "JOIN PARTICIPATION p ON s.student_id = p.student_id " +
                       "WHERE p.activity_id = ? " +
                       "ORDER BY p.registered_at DESC";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(activityId));
            rs = pstmt.executeQuery();
            
            response.getWriter().println("<div style='max-height: 400px; overflow-y: auto;'>");
            response.getWriter().println("<table style='width: 100%; border-collapse: collapse;'>");
            response.getWriter().println("<thead>");
            response.getWriter().println("<tr style='background: #f8f9fa;'>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Name</th>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Student ID</th>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Email</th>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Faculty</th>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Year</th>");
            response.getWriter().println("<th style='padding: 10px; border: 1px solid #ddd;'>Registered Date</th>");
            response.getWriter().println("</tr>");
            response.getWriter().println("</thead>");
            response.getWriter().println("<tbody>");
            
            boolean hasParticipants = false;
            while (rs.next()) {
                hasParticipants = true;
                
                response.getWriter().println("<tr>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>" + rs.getString("student_name") + "</td>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>" + rs.getString("student_id") + "</td>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>" + rs.getString("email") + "</td>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>" + rs.getString("faculty") + "</td>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>Year " + rs.getInt("year_of_study") + "</td>");
                response.getWriter().println("<td style='padding: 10px; border: 1px solid #ddd;'>" + rs.getTimestamp("registered_at") + "</td>");
                response.getWriter().println("</tr>");
            }
            
            if (!hasParticipants) {
                response.getWriter().println("<tr><td colspan='6' style='padding: 10px; text-align: center;'>No participants yet</td></tr>");
            }
            
            response.getWriter().println("</tbody>");
            response.getWriter().println("</table>");
            response.getWriter().println("</div>");
            
            // Add summary
            String countSql = "SELECT COUNT(*) as total_participants FROM PARTICIPATION WHERE activity_id = ?";
            PreparedStatement countStmt = con.prepareStatement(countSql);
            countStmt.setInt(1, Integer.parseInt(activityId));
            ResultSet countRs = countStmt.executeQuery();
            
            if (countRs.next()) {
                response.getWriter().println("<div style='margin-top: 15px; padding: 10px; background: #f8f9fa; border-radius: 5px;'>");
                response.getWriter().println("<p><strong>Total Participants:</strong> " + countRs.getInt("total_participants") + "</p>");
                response.getWriter().println("</div>");
            }
            
            countStmt.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<p style='color: red;'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>");
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    private String getRoleColor(String role) {
        switch (role) {
            case "President": return "#ffd700"; // Gold
            case "Vice President": return "#c0c0c0"; // Silver
            case "Secretary": return "#cd7f32"; // Bronze
            case "Treasurer": return "#87ceeb"; // Sky blue
            case "Committee Member": return "#98fb98"; // Pale green
            default: return "#e0e0e0"; // Light gray for regular members
        }
    }
}