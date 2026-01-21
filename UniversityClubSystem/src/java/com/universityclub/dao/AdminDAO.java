package com.universityclub.dao;

import com.universityclub.DBConnection;
import com.universityclub.beans.AdminBean;
import java.sql.*;

public class AdminDAO {
    
    public AdminBean loginAdmin(String username, String password) {
        AdminBean admin = null;
        String sql = "SELECT a.*, c.club_name FROM ADMIN a " +
                     "JOIN CLUB c ON a.club_id = c.club_id " +
                     "WHERE a.username = ? AND a.password = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                admin = new AdminBean();
                admin.setAdminId(rs.getInt("admin_id"));
                admin.setClubId(rs.getInt("club_id"));
                admin.setUsername(rs.getString("username"));
                admin.setEmail(rs.getString("email"));
                admin.setPassword(rs.getString("password"));
                admin.setClubName(rs.getString("club_name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return admin;
    }
}