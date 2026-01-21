<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.universityclub.beans.StudentBean" %>
<%@ page import="com.universityclub.DBConnection" %>
<%@ page import="java.sql.*" %>
<%
    StudentBean student = (StudentBean) session.getAttribute("studentBean");
    if (student == null) {
        response.sendRedirect("index.jsp?error=Please login as student first");
        return;
    }
    
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    
    // Get avatar initial safely
    String avatarInitial = "?";
    if (student.getStudentName() != null && !student.getStudentName().isEmpty()) {
        avatarInitial = String.valueOf(student.getStudentName().charAt(0)).toUpperCase();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>University Club | Student Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        body {
            background: #f8f9fa;
            color: #333;
            min-height: 100vh;
            font-size: 14px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        /* HEADER */
        .header {
            background: #ffffff;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .avatar {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, #8B0000, #B22222);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 28px;
        }
        
        .user-details h2 {
            color: #8B0000;
            margin-bottom: 5px;
            font-size: 22px;
        }
        
        .user-details p {
            color: #6c757d;
            font-size: 13px;
        }
        
        .logout-btn {
            background: #8B0000;
            color: white;
            border: none;
            padding: 10px 25px;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            display: inline-block;
        }
        
        /* MESSAGES */
        .message {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
            position: relative;
            animation: fadeIn 0.5s;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .success-message {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }
        
        .error-message {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }
        
        .close-message {
            position: absolute;
            right: 10px;
            top: 10px;
            background: none;
            border: none;
            color: inherit;
            cursor: pointer;
            font-size: 16px;
        }
        
        /* WELCOME CARD */
        .welcome-card {
            background: linear-gradient(135deg, #8B0000, #B22222);
            color: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
        }
        
        .welcome-card h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .welcome-card p {
            font-size: 15px;
        }
        
        /* TABS */
        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            flex-wrap: wrap;
            background: #ffffff;
            padding: 15px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        
        .tab {
            padding: 12px 25px;
            background: #ffffff;
            border: 2px solid #dee2e6;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .tab:hover {
            border-color: #8B0000;
            color: #8B0000;
        }
        
        .tab.active {
            background: #8B0000;
            color: white;
            border-color: #8B0000;
        }
        
        /* CONTENT SECTIONS */
        .content-section {
            display: none;
            animation: fadeIn 0.5s;
        }
        
        .content-section.active {
            display: block;
        }
        
        /* MODAL POPUP */
        .modal-popup {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            z-index: 1000;
            width: 500px;
            max-width: 90%;
            max-height: 90vh;
            overflow-y: auto;
        }
        
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 999;
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .modal-close {
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: #6c757d;
        }
        
        /* CARDS */
        .card {
            background: #ffffff;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        
        .card h3 {
            color: #8B0000;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #dee2e6;
            font-size: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        /* INFO GRID */
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .info-item {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #8B0000;
        }
        
        .info-label {
            font-size: 11px;
            color: #6c757d;
            margin-bottom: 8px;
            text-transform: uppercase;
            font-weight: 600;
        }
        
        .info-value {
            font-size: 15px;
            font-weight: 600;
            color: #2C3E50;
        }
        
        /* CLUB CARDS */
        .clubs-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        
        .club-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            border: 2px solid #dee2e6;
            transition: all 0.3s;
        }
        
        .club-card:hover {
            border-color: #8B0000;
            transform: translateY(-5px);
        }
        
        .club-card h4 {
            color: #8B0000;
            margin-bottom: 10px;
            font-size: 17px;
        }
        
        .club-card p {
            color: #6c757d;
            margin-bottom: 20px;
            font-size: 13px;
            line-height: 1.5;
        }
        
        .club-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        
        .btn-primary {
            background: #8B0000;
            color: white;
        }
        
        .btn-secondary {
            background: #2C3E50;
            color: white;
        }
        
        .btn-success {
            background: #28a745;
            color: white;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        /* TABLES */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        th {
            background: #f8f9fa;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #2C3E50;
            border-bottom: 2px solid #dee2e6;
            font-size: 13px;
        }
        
        td {
            padding: 12px;
            border-bottom: 1px solid #dee2e6;
            font-size: 13px;
        }
        
        tr:hover {
            background: #f8f9fa;
        }
        
        .badge {
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .badge-info {
            background: #cce5ff;
            color: #004085;
        }
        
        .badge-success {
            background: #d4edda;
            color: #155724;
        }
        
        /* ANNOUNCEMENT CARDS */
        .announcement-card {
            background: #ffffff;
            border-left: 4px solid #cce5ff;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 15px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        
        .announcement-card.activity {
            border-left-color: #d4edda;
        }
        
        .announcement-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            align-items: flex-start;
        }
        
        .announcement-title {
            color: #8B0000;
            font-weight: 600;
            font-size: 15px;
            margin: 0;
        }
        
        .announcement-type {
            padding: 3px 10px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 500;
        }
        
        .announcement-meta {
            color: #6c757d;
            font-size: 12px;
            margin-bottom: 10px;
        }
        
        .announcement-content {
            font-size: 13px;
            line-height: 1.5;
        }
        
        /* RESPONSIVE */
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }
            
            .user-info {
                flex-direction: column;
                text-align: center;
            }
            
            .tabs {
                justify-content: center;
            }
            
            .clubs-grid {
                grid-template-columns: 1fr;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 480px) {
            .container {
                padding: 10px;
            }
            
            .header {
                padding: 15px;
            }
            
            .tabs {
                flex-direction: column;
            }
            
            .tab {
                width: 100%;
                justify-content: center;
            }
            
            .club-actions {
                flex-direction: column;
            }
            
            .modal-popup {
                width: 95%;
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- HEADER -->
        <div class="header">
            <div class="user-info">
                <div class="avatar"><%= avatarInitial %></div>
                <div class="user-details">
                    <h2><%= student.getStudentName() %></h2>
                    <p>Student ID: <%= student.getStudentId() %> | Faculty: <%= student.getFaculty() %></p>
                    <p>Year <%= student.getYearOfStudy() %> | Status: <span style="color: green; font-weight: 600;"><%= student.getStatus() %></span></p>
                </div>
            </div>
            <a href="AuthServlet?action=logout" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i> Sign Out
            </a>
        </div>
        
        <% if (success != null) { %>
            <div class="message success-message" id="successMessage">
                <i class="fas fa-check-circle"></i> <%= success %>
                <button class="close-message" onclick="closeMessage('successMessage')">×</button>
            </div>
        <% } %>
        
        <% if (error != null) { %>
            <div class="message error-message" id="errorMessage">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
                <button class="close-message" onclick="closeMessage('errorMessage')">×</button>
            </div>
        <% } %>
        
        <!-- WELCOME CARD -->
        <div class="welcome-card">
            <h1>Welcome to University Club System!</h1>
            <p>Join clubs, participate in activities, and connect with other students.</p>
        </div>
        
        <!-- TABS -->
        <div class="tabs">
            <div class="tab active" onclick="showSection('profile')">
                <i class="fas fa-user"></i> My Profile
            </div>
            <div class="tab" onclick="showSection('clubs')">
                <i class="fas fa-university"></i> Available Clubs
            </div>
            <div class="tab" onclick="showSection('myClubs')">
                <i class="fas fa-check-circle"></i> My Clubs
            </div>
            <div class="tab" onclick="showSection('activities')">
                <i class="fas fa-calendar-alt"></i> My Activities
            </div>
            <div class="tab" onclick="showSection('announcements')">
                <i class="fas fa-bullhorn"></i> Club Announcements
            </div>
        </div>
        
        <!-- PROFILE SECTION -->
        <div id="profile" class="content-section active">
            <div class="card">
                <h3><i class="fas fa-id-card"></i> Personal Information</h3>
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Full Name</div>
                        <div class="info-value"><%= student.getStudentName() %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Student ID</div>
                        <div class="info-value"><%= student.getStudentId() %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Email Address</div>
                        <div class="info-value"><%= student.getEmail() %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Username</div>
                        <div class="info-value"><%= student.getUsername() %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Faculty</div>
                        <div class="info-value"><%= student.getFaculty() %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Year of Study</div>
                        <div class="info-value">Year <%= student.getYearOfStudy() %></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Account Status</div>
                        <div class="info-value" style="color: green;"><%= student.getStatus() %></div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- AVAILABLE CLUBS SECTION -->
        <div id="clubs" class="content-section">
            <div class="card">
                <h3><i class="fas fa-university"></i> Available Clubs to Join</h3>
                <div class="clubs-grid">
                    <%
                        try {
                            Connection con = DBConnection.getConnection();
                            // Get clubs that student hasn't joined yet
                            String sql = "SELECT c.* FROM CLUB c " +
                                       "WHERE c.club_id NOT IN (" +
                                       "SELECT club_id FROM MEMBERSHIP WHERE student_id = ?" +
                                       ") ORDER BY c.club_name";
                            PreparedStatement pstmt = con.prepareStatement(sql);
                            pstmt.setString(1, student.getStudentId());
                            ResultSet rs = pstmt.executeQuery();
                            
                            boolean hasClubs = false;
                            while (rs.next()) {
                                hasClubs = true;
                    %>
                    <div class="club-card">
                        <h4><%= rs.getString("club_name") %></h4>
                        <p><%= rs.getString("description") %></p>
                        <div class="club-actions">
                            <form action="ClubServlet" method="post" style="display: inline;" onsubmit="return confirmJoinClub('<%= rs.getString("club_name") %>')">
                                <input type="hidden" name="action" value="join">
                                <input type="hidden" name="clubId" value="<%= rs.getInt("club_id") %>">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-sign-in-alt"></i> Join Club
                                </button>
                            </form>
                            <button class="btn btn-secondary" onclick="viewClubDetails(<%= rs.getInt("club_id") %>)">
                                <i class="fas fa-info-circle"></i> View Details
                            </button>
                        </div>
                    </div>
                    <%
                            }
                            con.close();
                            
                            if (!hasClubs) {
                    %>
                    <div class="message" style="grid-column: 1/-1; text-align: center; padding: 30px;">
                        <i class="fas fa-check-circle" style="font-size: 48px; color: #28a745; margin-bottom: 15px;"></i>
                        <h3 style="color: #8B0000; margin-bottom: 10px;">You've joined all clubs!</h3>
                        <p style="color: #6c757d;">You're already a member of all available clubs. Check out your clubs in the "My Clubs" tab.</p>
                    </div>
                    <%
                            }
                        } catch(Exception e) {
                    %>
                    <div class="message error-message" style="grid-column: 1/-1;">
                        <i class="fas fa-exclamation-triangle"></i> Error loading clubs. Please try again later.
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
        
        <!-- MY CLUBS SECTION -->
        <div id="myClubs" class="content-section">
            <div class="card">
                <h3><i class="fas fa-check-circle"></i> Clubs I've Joined</h3>
                <%
                    try {
                        Connection con = DBConnection.getConnection();
                        String sql = "SELECT c.club_id, c.club_name, c.description, m.role_club, m.joined_at, " +
                                   "(SELECT COUNT(*) FROM MEMBERSHIP WHERE club_id = c.club_id) as member_count " +
                                   "FROM CLUB c " +
                                   "JOIN MEMBERSHIP m ON c.club_id = m.club_id " +
                                   "WHERE m.student_id = ? " +
                                   "ORDER BY m.joined_at DESC";
                        PreparedStatement pstmt = con.prepareStatement(sql);
                        pstmt.setString(1, student.getStudentId());
                        ResultSet rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                %>
                <table>
                    <thead>
                        <tr>
                            <th>Club Name</th>
                            <th>Your Role</th>
                            <th>Members</th>
                            <th>Joined Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            do {
                        %>
                        <tr>
                            <td>
                                <strong><%= rs.getString("club_name") %></strong><br>
                                <small style="color: #6c757d;"><%= rs.getString("description") %></small>
                            </td>
                            <td><span class="badge badge-success"><%= rs.getString("role_club") %></span></td>
                            <td><%= rs.getInt("member_count") %> members</td>
                            <td><%= rs.getTimestamp("joined_at") %></td>
                            <td>
                                <button class="btn btn-primary" onclick="viewClubMembers(<%= rs.getInt("club_id") %>, '<%= rs.getString("club_name") %>')">
                                    <i class="fas fa-users"></i> View Members
                                </form>
                            </td>
                        </tr>
                        <%
                            } while (rs.next());
                        %>
                    </tbody>
                </table>
                <%
                        } else {
                %>
                <div class="message" style="text-align: center; padding: 30px;">
                    <i class="fas fa-users" style="font-size: 48px; color: #6c757d; margin-bottom: 15px;"></i>
                    <h3 style="color: #8B0000; margin-bottom: 10px;">You haven't joined any clubs yet</h3>
                    <p style="color: #6c757d;">Visit the "Available Clubs" tab to explore and join clubs.</p>
                </div>
                <%
                        }
                        con.close();
                    } catch(Exception e) {
                %>
                <div class="message error-message">
                    <i class="fas fa-exclamation-triangle"></i> Error loading your clubs. Please try again later.
                </div>
                <% } %>
            </div>
        </div>
        
        <!-- ACTIVITIES SECTION -->
        <div id="activities" class="content-section">
            <!-- MY ACTIVITIES -->
            <div class="card">
                <h3><i class="fas fa-calendar-check"></i> My Activities</h3>
                <%
                    try {
                        Connection con = DBConnection.getConnection();
                        String sql = "SELECT a.activity_title, a.description, a.date_time, a.location, " +
                                   "c.club_name, p.registered_at " +
                                   "FROM PARTICIPATION p " +
                                   "JOIN ACTIVITY a ON p.activity_id = a.activity_id " +
                                   "JOIN CLUB c ON a.club_id = c.club_id " +
                                   "WHERE p.student_id = ? " +
                                   "ORDER BY a.date_time DESC";
                        PreparedStatement pstmt = con.prepareStatement(sql);
                        pstmt.setString(1, student.getStudentId());
                        ResultSet rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                %>
                <table>
                    <thead>
                        <tr>
                            <th>Activity</th>
                            <th>Club</th>
                            <th>Date & Time</th>
                            <th>Location</th>
                            <th>Registered On</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            do {
                        %>
                        <tr>
                            <td>
                                <strong><%= rs.getString("activity_title") %></strong><br>
                                <small style="color: #6c757d;"><%= rs.getString("description") %></small>
                            </td>
                            <td><%= rs.getString("club_name") %></td>
                            <td><%= rs.getTimestamp("date_time") %></td>
                            <td><%= rs.getString("location") %></td>
                            <td><%= rs.getTimestamp("registered_at") %></td>
                        </tr>
                        <%
                            } while (rs.next());
                        %>
                    </tbody>
                </table>
                <%
                        } else {
                %>
                <div class="message" style="text-align: center; padding: 20px;">
                    <i class="fas fa-calendar-times" style="font-size: 36px; color: #6c757d; margin-bottom: 10px;"></i>
                    <p style="color: #6c757d;">You haven't participated in any activities yet.</p>
                </div>
                <%
                        }
                        con.close();
                    } catch(Exception e) {
                %>
                <div class="message error-message">
                    <i class="fas fa-exclamation-triangle"></i> Error loading activities. Please try again later.
                </div>
                <% } %>
            </div>
            
            <!-- AVAILABLE ACTIVITIES -->
            <div class="card">
                <h3><i class="fas fa-calendar-plus"></i> Available Activities from My Clubs</h3>
                <%
                    try {
                        Connection con = DBConnection.getConnection();
                        // Get activities from clubs the student has joined
                    String sql = "SELECT a.*, c.club_name, " +
                               "(SELECT COUNT(*) FROM PARTICIPATION WHERE activity_id = a.activity_id) as participant_count " +
                               "FROM ACTIVITY a " +
                               "JOIN CLUB c ON a.club_id = c.club_id " +
                               "WHERE a.club_id IN (" +
                               "SELECT club_id FROM MEMBERSHIP WHERE student_id = ?" +
                               ") AND a.activity_id NOT IN (" +
                               "SELECT activity_id FROM PARTICIPATION WHERE student_id = ?" +
                               ") " +
                               "ORDER BY a.date_time";
                        PreparedStatement pstmt = con.prepareStatement(sql);
                        pstmt.setString(1, student.getStudentId());
                        pstmt.setString(2, student.getStudentId());
                        ResultSet rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                %>
                <table>
                    <thead>
                        <tr>
                            <th>Activity</th>
                            <th>Club</th>
                            <th>Date & Time</th>
                            <th>Participants</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            do {
                        %>
                        <tr>
                            <td>
                                <strong><%= rs.getString("activity_title") %></strong><br>
                                <small style="color: #6c757d;"><%= rs.getString("description") %></small>
                            </td>
                            <td><%= rs.getString("club_name") %></td>
                            <td><%= rs.getTimestamp("date_time") %></td>
                            <td><%= rs.getInt("participant_count") %> joined</td>
                            <td>
                                <form action="ActivityServlet" method="post" style="display: inline;" onsubmit="return confirmJoinActivity('<%= rs.getString("activity_title") %>')">
                                    <input type="hidden" name="action" value="join">
                                    <input type="hidden" name="activityId" value="<%= rs.getInt("activity_id") %>">
                                    <button type="submit" class="btn btn-success">
                                        <i class="fas fa-plus-circle"></i> Join Activity
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                            } while (rs.next());
                        %>
                    </tbody>
                </table>
                <%
                        } else {
                %>
                <div class="message" style="text-align: center; padding: 20px;">
                    <i class="fas fa-calendar-check" style="font-size: 36px; color: #6c757d; margin-bottom: 10px;"></i>
                    <p style="color: #6c757d;">No upcoming activities available from your clubs.</p>
                </div>
                <%
                        }
                        con.close();
                    } catch(Exception e) {
                %>
                <div class="message error-message">
                    <i class="fas fa-exclamation-triangle"></i> Error loading available activities.
                </div>
                <% } %>
            </div>
        </div>
        
        <!-- ANNOUNCEMENTS SECTION -->
        <div id="announcements" class="content-section">
            <div class="card">
                <h3><i class="fas fa-bullhorn"></i> Announcements from My Clubs</h3>
                <%
                    try {
                        Connection con = DBConnection.getConnection();
                        // Get announcements from clubs the student has joined
                        String sql = "SELECT an.*, c.club_name " +
                                   "FROM ANNOUNCEMENT an " +
                                   "JOIN CLUB c ON an.club_id = c.club_id " +
                                   "WHERE an.club_id IN (" +
                                   "SELECT club_id FROM MEMBERSHIP WHERE student_id = ?" +
                                   ") ORDER BY an.posted_at DESC";
                        PreparedStatement pstmt = con.prepareStatement(sql);
                        pstmt.setString(1, student.getStudentId());
                        ResultSet rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                            do {
                                String type = rs.getString("announcement_type");
                                boolean isActivity = "Activity".equals(type);
                                String typeClass = isActivity ? "activity" : "";
                                String typeColor = isActivity ? "#d4edda" : "#cce5ff";
                                String textColor = isActivity ? "#155724" : "#004085";
                %>
                <div class="announcement-card <%= typeClass %>">
                    <div class="announcement-header">
                        <h4 class="announcement-title"><%= rs.getString("title") %></h4>
                        <span class="announcement-type" style="background: <%= typeColor %>; color: <%= textColor %>;">
                            <%= type %>
                        </span>
                    </div>
                    <div class="announcement-meta">
                        From: <strong><%= rs.getString("club_name") %></strong> | 
                        Posted: <%= rs.getTimestamp("posted_at") %>
                    </div>
                    <div class="announcement-content">
                        <%= rs.getString("content") %>
                    </div>
                    <%
                        if (isActivity && rs.getObject("activity_id") != null) {
                    %>
                    <div style="background: #f8f9fa; padding: 10px; border-radius: 6px; margin-top: 15px;">
                        <small style="color: #6c757d;">Related Activity:</small><br>
                        <%
                            // Get activity details
                            String activitySql = "SELECT activity_title FROM ACTIVITY WHERE activity_id = ?";
                            PreparedStatement activityStmt = con.prepareStatement(activitySql);
                            activityStmt.setInt(1, rs.getInt("activity_id"));
                            ResultSet activityRs = activityStmt.executeQuery();
                            if (activityRs.next()) {
                        %>
                        <strong><%= activityRs.getString("activity_title") %></strong>
                        <%
                            }
                            activityStmt.close();
                        %>
                    </div>
                    <%
                        }
                    %>
                </div>
                <%
                            } while (rs.next());
                        } else {
                %>
                <div class="message" style="text-align: center; padding: 30px;">
                    <i class="fas fa-bullhorn" style="font-size: 48px; color: #6c757d; margin-bottom: 15px;"></i>
                    <h3 style="color: #8B0000; margin-bottom: 10px;">No announcements yet</h3>
                    <p style="color: #6c757d;">There are no announcements from your clubs at the moment.</p>
                </div>
                <%
                        }
                        con.close();
                    } catch(Exception e) {
                %>
                <div class="message error-message">
                    <i class="fas fa-exclamation-triangle"></i> Error loading announcements.
                </div>
                <% } %>
            </div>
        </div>
    </div>
    
    <!-- MODAL OVERLAY -->
    <div class="modal-overlay" id="modalOverlay" onclick="hideAllModals()"></div>
    
    <!-- CLUB DETAILS MODAL -->
    <div id="clubDetailsModal" class="modal-popup">
        <div class="modal-header">
            <h3 style="color: #8B0000;"><i class="fas fa-info-circle"></i> Club Details</h3>
            <button class="modal-close" onclick="hideModal('clubDetailsModal')">×</button>
        </div>
        <div id="clubDetailsContent">
            Loading club details...
        </div>
        <div style="margin-top: 20px; text-align: center;">
            <button class="btn" onclick="hideModal('clubDetailsModal')"
                    style="background: #dee2e6; color: #2C3E50; padding: 10px 30px;">Close</button>
        </div>
    </div>
    
    <!-- CLUB MEMBERS MODAL -->
    <div id="clubMembersModal" class="modal-popup">
        <div class="modal-header">
            <h3 style="color: #8B0000;"><i class="fas fa-users"></i> Club Members</h3>
            <button class="modal-close" onclick="hideModal('clubMembersModal')">×</button>
        </div>
        <div id="clubMembersContent">
            Loading members...
        </div>
        <div style="margin-top: 20px; text-align: center;">
            <button class="btn" onclick="hideModal('clubMembersModal')"
                    style="background: #dee2e6; color: #2C3E50; padding: 10px 30px;">Close</button>
        </div>
    </div>
    
    <script>
        // Initialize profile section as active
        document.addEventListener('DOMContentLoaded', function() {
            showSection('profile');
            
            // Auto-close messages after 5 seconds
            setTimeout(() => {
                document.querySelectorAll('.message').forEach(msg => {
                    msg.style.display = 'none';
                });
            }, 5000);
        });
        
        function showSection(sectionId) {
            // Hide all sections
            document.querySelectorAll('.content-section').forEach(section => {
                section.classList.remove('active');
            });
            
            // Remove active class from all tabs
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Show selected section
            document.getElementById(sectionId).classList.add('active');
            
            // Activate clicked tab
            event.target.classList.add('active');
            
            // Hide all modals
            hideAllModals();
        }
        
        function closeMessage(messageId) {
            document.getElementById(messageId).style.display = 'none';
        }
        
        // Modal functions
        function showModal(modalId) {
            document.getElementById(modalId).style.display = 'block';
            document.getElementById('modalOverlay').style.display = 'block';
        }
        
        function hideModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
            document.getElementById('modalOverlay').style.display = 'none';
        }
        
        function hideAllModals() {
            document.querySelectorAll('.modal-popup').forEach(modal => {
                modal.style.display = 'none';
            });
            document.getElementById('modalOverlay').style.display = 'none';
        }
        
        // Confirmation functions
        function confirmJoinClub(clubName) {
            return confirm('Are you sure you want to join "' + clubName + '"?');
        }
        
        function confirmLeaveClub(clubName) {
            return confirm('Are you sure you want to leave "' + clubName + '"?');
        }
        
        function confirmJoinActivity(activityName) {
            return confirm('Are you sure you want to join the activity: "' + activityName + '"?');
        }
        
        // Club details function
        function viewClubDetails(clubId) {
            // Show loading
            document.getElementById('clubDetailsContent').innerHTML = '<p><i class="fas fa-spinner fa-spin"></i> Loading club details...</p>';
            showModal('clubDetailsModal');
            
            // Fetch club details via AJAX
            fetch('ClubServlet?action=details&clubId=' + clubId)
                .then(response => response.text())
                .then(data => {
                    document.getElementById('clubDetailsContent').innerHTML = data;
                })
                .catch(error => {
                    document.getElementById('clubDetailsContent').innerHTML = 
                        '<p style="color: red;"><i class="fas fa-exclamation-triangle"></i> Error loading club details: ' + error + '</p>';
                });
        }
        
        // Club members function
        function viewClubMembers(clubId, clubName) {
            // Show loading
            document.getElementById('clubMembersContent').innerHTML = 
                '<h4>' + clubName + ' Members</h4>' +
                '<p><i class="fas fa-spinner fa-spin"></i> Loading members...</p>';
            showModal('clubMembersModal');
            
            // Fetch members via AJAX
            fetch('ClubServlet?action=members&clubId=' + clubId)
                .then(response => response.text())
                .then(data => {
                    document.getElementById('clubMembersContent').innerHTML = data;
                })
                .catch(error => {
                    document.getElementById('clubMembersContent').innerHTML = 
                        '<p style="color: red;"><i class="fas fa-exclamation-triangle"></i> Error loading members: ' + error + '</p>';
                });
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            if (event.target == document.getElementById('modalOverlay')) {
                hideAllModals();
            }
        }
    </script>
</body>
</html>