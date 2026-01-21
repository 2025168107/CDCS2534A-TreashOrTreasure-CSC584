package com.universityclub.beans;

import java.io.Serializable;

public class ClubBean implements Serializable {
    private int clubId;
    private String clubName;
    private String description;
    
    public ClubBean() {}
    
    public ClubBean(int clubId, String clubName, String description) {
        this.clubId = clubId;
        this.clubName = clubName;
        this.description = description;
    }
    
    // Getters and Setters
    public int getClubId() { return clubId; }
    public void setClubId(int clubId) { this.clubId = clubId; }
    
    public String getClubName() { return clubName; }
    public void setClubName(String clubName) { this.clubName = clubName; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}