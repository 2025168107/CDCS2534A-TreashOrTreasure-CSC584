package com.universityclub.dao;

import com.universityclub.DBConnection;
import com.universityclub.beans.ClubBean;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClubDAO {
    
    public List<ClubBean> getAllClubs() {
        List<ClubBean> clubs = new ArrayList<>();
        String sql = "SELECT * FROM CLUB ORDER BY club_name";
        
        try (Connection con = DBConnection.getConnection();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                ClubBean club = new ClubBean();
                club.setClubId(rs.getInt("club_id"));
                club.setClubName(rs.getString("club_name"));
                club.setDescription(rs.getString("description"));
                clubs.add(club);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return clubs;
    }
    
    public ClubBean getClubById(int clubId) {
        ClubBean club = null;
        String sql = "SELECT * FROM CLUB WHERE club_id = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            
            pstmt.setInt(1, clubId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                club = new ClubBean();
                club.setClubId(rs.getInt("club_id"));
                club.setClubName(rs.getString("club_name"));
                club.setDescription(rs.getString("description"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return club;
    }
}