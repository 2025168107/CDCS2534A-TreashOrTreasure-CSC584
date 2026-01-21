<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.universityclub.beans.AdminBean" %>
<%@ page import="com.universityclub.DBConnection" %>
<%@ page import="java.sql.*" %>
<%
    AdminBean admin = (AdminBean) session.getAttribute("adminBean");
    if (admin == null) {
        response.sendRedirect("index.jsp?error=Please login as admin first");
        return;
    }
    
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    
    // Get admin avatar safely
    String adminAvatar = "A";
    if (admin.getUsername() != null && !admin.getUsername().isEmpty()) {
        adminAvatar = String.valueOf(admin.getUsername().charAt(0)).toUpperCase();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>University Club | Admin Dashboard</title>
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
            display: flex;
            min-height: 100vh;
        }
        
        /* SIDEBAR */
        .sidebar {
            width: 250px;
            background: #ffffff;
            border-right: 1px solid #dee2e6;
            padding: 20px 0;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
        }
        
        .logo {
            padding: 0 20px 30px;
            text-align: center;
            border-bottom: 1px solid #dee2e6;
            margin-bottom: 20px;
        }
        
        .logo h2 {
            color: #8B0000;
            font-size: 22px;
            margin-bottom: 5px;
        }
        
        .logo p {
            color: #6c757d;
            font-size: 12px;
        }
        
        .nav-section {
            margin-bottom: 25px;
            padding: 0 20px;
        }
        
        .nav-section h4 {
            color: #6c757d;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 15px;
        }
        
        .nav-link {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            color: #555;
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 5px;
            transition: all 0.3s;
            cursor: pointer;
        }
        
        .nav-link:hover, .nav-link.active {
            background: rgba(139, 0, 0, 0.08);
            color: #8B0000;
        }
        
        .nav-icon {
            margin-right: 12px;
            font-size: 16px;
            width: 20px;
            text-align: center;
        }
        
        /* MAIN CONTENT */
        .main-content {
            flex: 1;
            margin-left: 250px;
            padding: 20px;
        }
        
        /* HEADER */
        .top-header {
            background: #ffffff;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .user-avatar {
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, #8B0000, #B22222);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 18px;
        }
        
        .logout-btn {
            background: #8B0000;
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
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
        
        /* DASHBOARD CARDS */
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
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: #ffffff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            text-align: center;
            border-top: 4px solid #8B0000;
        }
        
        .stat-icon {
            font-size: 32px;
            color: #8B0000;
            margin-bottom: 15px;
        }
        
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #8B0000;
            margin: 10px 0;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 14px;
        }
        
        /* TABLES */
        .table-container {
            background: #ffffff;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        
        .table-container h3 {
            color: #8B0000;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #dee2e6;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
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
        
        /* FORMS */
        .form-popup {
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
        
        .form-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .close-btn {
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: #6c757d;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #2C3E50;
            font-size: 13px;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            font-size: 13px;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #8B0000;
            box-shadow: 0 0 0 3px rgba(139, 0, 0, 0.1);
        }
        
        /* BUTTONS */
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background: #8B0000;
            color: white;
        }
        
        .btn-secondary {
            background: #2C3E50;
            color: white;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn-success {
            background: #28a745;
            color: white;
        }
        
        .btn-sm {
            padding: 4px 8px;
            font-size: 12px;
        }
        
        /* MODAL OVERLAY */
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
        
        /* RESPONSIVE */
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                position: relative;
                height: auto;
                margin-bottom: 20px;
            }
            .main-content {
                margin-left: 0;
            }
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .form-popup {
                width: 95%;
                padding: 20px;
            }
        }
        
        @media (max-width: 480px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .top-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- SIDEBAR -->
        <div class="sidebar">
            <div class="logo">
                <h2><i class="fas fa-university"></i> University Club</h2>
                <p>Admin Dashboard</p>
            </div>
            
            <div class="nav-section">
                <h4>Main Menu</h4>
                <a class="nav-link active" onclick="showSection('dashboard')">
                    <span class="nav-icon"><i class="fas fa-tachometer-alt"></i></span>
                    Dashboard
                </a>
                <a class="nav-link" onclick="showForm('createActivityForm')">
                    <span class="nav-icon"><i class="fas fa-plus"></i></span>
                    Create Activity
                </a>
                <a class="nav-link" onclick="showForm('createAnnouncementForm')">
                    <span class="nav-icon"><i class="fas fa-edit"></i></span>
                    Post Announcement
                </a>
                <a class="nav-link" onclick="showForm('manageRolesForm')">
                    <span class="nav-icon"><i class="fas fa-user-tag"></i></span>
                    Assign Roles
                </a>
                <a class="nav-link" onclick="showSection('members')">
                    <span class="nav-icon"><i class="fas fa-user-friends"></i></span>
                    Club Members
                </a>
            </div>
        </div>
        
        <!-- MAIN CONTENT -->
        <div class="main-content">
            <!-- HEADER -->
            <div class="top-header">
                <div>
                    <h3 style="color: #8B0000;">Welcome, <%= admin.getUsername() %></h3>
                    <p style="color: #6c757d; font-size: 14px;">Club: <%= admin.getClubName() %></p>
                </div>
                <div class="user-info">
                    <div class="user-avatar"><%= adminAvatar %></div>
                    <a href="AuthServlet?action=logout" class="logout-btn">Logout</a>
                </div>
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
            
            <!-- DASHBOARD SECTION -->
            <div id="dashboard" class="content-section">
                <!-- WELCOME CARD -->
                <div class="welcome-card">
                    <h1>Club Management Dashboard</h1>
                    <p>Manage your club activities, announcements, and members from here.</p>
                </div>
                
                <!-- STATS -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fas fa-users"></i></div>
                        <div class="stat-number">
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    String sql = "SELECT COUNT(*) FROM MEMBERSHIP WHERE club_id = ?";
                                    PreparedStatement pstmt = con.prepareStatement(sql);
                                    pstmt.setInt(1, admin.getClubId());
                                    ResultSet rs = pstmt.executeQuery();
                                    if (rs.next()) out.print(rs.getInt(1));
                                    con.close();
                                } catch(Exception e) { out.print("0"); }
                            %>
                        </div>
                        <div class="stat-label">Club Members</div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fas fa-calendar-alt"></i></div>
                        <div class="stat-number">
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    String sql = "SELECT COUNT(*) FROM ACTIVITY WHERE club_id = ? AND date_time > CURRENT_TIMESTAMP";
                                    PreparedStatement pstmt = con.prepareStatement(sql);
                                    pstmt.setInt(1, admin.getClubId());
                                    ResultSet rs = pstmt.executeQuery();
                                    if (rs.next()) out.print(rs.getInt(1));
                                    con.close();
                                } catch(Exception e) { out.print("0"); }
                            %>
                        </div>
                        <div class="stat-label">Upcoming Activities</div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fas fa-bullhorn"></i></div>
                        <div class="stat-number">
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    String sql = "SELECT COUNT(*) FROM ANNOUNCEMENT WHERE club_id = ? AND posted_at >= CURRENT_TIMESTAMP - 7";
                                    PreparedStatement pstmt = con.prepareStatement(sql);
                                    pstmt.setInt(1, admin.getClubId());
                                    ResultSet rs = pstmt.executeQuery();
                                    if (rs.next()) out.print(rs.getInt(1));
                                    con.close();
                                } catch(Exception e) { out.print("0"); }
                            %>
                        </div>
                        <div class="stat-label">Recent Announcements</div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                        <div class="stat-number">
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    String sql = "SELECT COUNT(DISTINCT p.student_id) FROM PARTICIPATION p " +
                                               "JOIN ACTIVITY a ON p.activity_id = a.activity_id " +
                                               "WHERE a.club_id = ?";
                                    PreparedStatement pstmt = con.prepareStatement(sql);
                                    pstmt.setInt(1, admin.getClubId());
                                    ResultSet rs = pstmt.executeQuery();
                                    if (rs.next()) out.print(rs.getInt(1));
                                    con.close();
                                } catch(Exception e) { out.print("0"); }
                            %>
                        </div>
                        <div class="stat-label">Active Participants</div>
                    </div>
                </div>
                
                <!-- RECENT ACTIVITIES -->
                <div class="table-container">
                    <h3><i class="fas fa-calendar-alt"></i> Recent Activities</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Date & Time</th>
                                <th>Location</th>
                                <th>Participants</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    String sql = "SELECT a.*, " +
                                               "(SELECT COUNT(*) FROM PARTICIPATION p WHERE p.activity_id = a.activity_id) as participant_count " +
                                               "FROM ACTIVITY a WHERE a.club_id = ? ORDER BY a.date_time DESC";
                                    PreparedStatement pstmt = con.prepareStatement(sql);
                                    pstmt.setInt(1, admin.getClubId());
                                    ResultSet rs = pstmt.executeQuery();
                                    
                                    while (rs.next()) {
                            %>
                            <tr>
                                <td><strong><%= rs.getString("activity_title") %></strong></td>
                                <td><%= rs.getTimestamp("date_time") %></td>
                                <td><%= rs.getString("location") %></td>
                                <td><span class="btn" style="background: #e9ecef; color: #333; padding: 5px 10px;">
                                    <%= rs.getInt("participant_count") %> joined
                                </span></td>
                                <td>
                                    <button class="btn btn-primary" style="padding: 5px 10px; font-size: 12px; margin-right: 5px;"
                                            onclick="viewActivityParticipants(<%= rs.getInt("activity_id") %>, '<%= rs.getString("activity_title").replace("'", "\\'") %>')">
                                        <i class="fas fa-users"></i> View Participants
                                    </button>
                                    <button class="btn btn-danger" style="padding: 5px 10px; font-size: 12px;"
                                            onclick="deleteActivity(<%= rs.getInt("activity_id") %>, '<%= rs.getString("activity_title").replace("'", "\\'") %>')">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </td>
                            </tr>
                            <%
                                    }
                                    con.close();
                                } catch(Exception e) {
                            %>
                            <tr><td colspan="5">No activities found. Create your first activity!</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <!-- RECENT ANNOUNCEMENTS -->
                <div class="table-container">
                    <h3><i class="fas fa-bullhorn"></i> Recent Announcements</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Type</th>
                                <th>Posted Date</th>
                                <th>Content</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    String sql = "SELECT * FROM ANNOUNCEMENT WHERE club_id = ? ORDER BY posted_at DESC";
                                    PreparedStatement pstmt = con.prepareStatement(sql);
                                    pstmt.setInt(1, admin.getClubId());
                                    ResultSet rs = pstmt.executeQuery();
                                    
                                    while (rs.next()) {
                            %>
                            <tr>
                                <td><strong><%= rs.getString("title") %></strong></td>
                                <td>
                                    <span style="background: <%= rs.getString("announcement_type").equals("Activity") ? "#d4edda" : "#cce5ff" %>; 
                                          color: <%= rs.getString("announcement_type").equals("Activity") ? "#155724" : "#004085" %>; 
                                          padding: 3px 8px; border-radius: 4px; font-size: 12px;">
                                        <%= rs.getString("announcement_type") %>
                                    </span>
                                </td>
                                <td><%= rs.getTimestamp("posted_at") %></td>
                                <td><%= rs.getString("content").length() > 50 ? rs.getString("content").substring(0, 50) + "..." : rs.getString("content") %></td>
                                <td>
                                    <button class="btn btn-danger" style="padding: 5px 10px; font-size: 12px;"
                                            onclick="deleteAnnouncement(<%= rs.getInt("announcement_id") %>, '<%= rs.getString("title").replace("'", "\\'") %>')">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </td>
                            </tr>
                            <%
                                    }
                                    con.close();
                                } catch(Exception e) {
                            %>
                            <tr><td colspan="5">No announcements yet. Post your first announcement!</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- MEMBERS SECTION -->
            <div id="members" class="content-section" style="display: none;">
                <div class="table-container">
                    <h3><i class="fas fa-users"></i> Club Members</h3>
                    <%
                        String deleteMemberSuccess = request.getParameter("deleteMemberSuccess");
                        String deleteMemberError = request.getParameter("deleteMemberError");
                        
                        if (deleteMemberSuccess != null) {
                    %>
                    <div class="message success-message">
                        <i class="fas fa-check-circle"></i> <%= deleteMemberSuccess %>
                        <button class="close-message" onclick="this.parentElement.style.display='none'">×</button>
                    </div>
                    <% } %>
                    
                    <% if (deleteMemberError != null) { %>
                    <div class="message error-message">
                        <i class="fas fa-exclamation-circle"></i> <%= deleteMemberError %>
                        <button class="close-message" onclick="this.parentElement.style.display='none'">×</button>
                    </div>
                    <% } %>
                    
                    <table>
                        <thead>
                            <tr>
                                <th>Student ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Joined Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    String sql = "SELECT s.student_id, s.student_name, s.email, m.role_club, m.joined_at " +
                                               "FROM STUDENT s " +
                                               "JOIN MEMBERSHIP m ON s.student_id = m.student_id " +
                                               "WHERE m.club_id = ? " +
                                               "ORDER BY m.role_club DESC, s.student_name ASC";
                                    PreparedStatement pstmt = con.prepareStatement(sql);
                                    pstmt.setInt(1, admin.getClubId());
                                    ResultSet rs = pstmt.executeQuery();
                                    
                                    while (rs.next()) {
                                        String studentId = rs.getString("student_id");
                                        String studentName = rs.getString("student_name");
                                        String role = rs.getString("role_club");
                                        
                                        // Determine role color
                                        String roleColor = "#e9ecef"; // default
                                        if ("President".equals(role)) {
                                            roleColor = "#ffd700";
                                        } else if ("Vice President".equals(role)) {
                                            roleColor = "#c0c0c0";
                                        } else if ("Secretary".equals(role)) {
                                            roleColor = "#cd7f32";
                                        } else if ("Treasurer".equals(role)) {
                                            roleColor = "#87ceeb";
                                        } else if ("Committee Member".equals(role)) {
                                            roleColor = "#98fb98";
                                        }
                            %>
                            <tr>
                                <td><%= studentId %></td>
                                <td><strong><%= studentName %></strong></td>
                                <td><%= rs.getString("email") %></td>
                                <td>
                                    <span style="background: <%= roleColor %>; padding: 3px 8px; border-radius: 4px; font-size: 12px;">
                                        <%= role %>
                                    </span>
                                </td>
                                <td><%= rs.getTimestamp("joined_at") %></td>
                                <td>
                                    <div style="display: flex; gap: 5px;">
                                        <form action="ClubServlet" method="post" style="display: inline;" 
                                              onsubmit="return confirmRemoveMember('<%= studentName %>', '<%= role %>')">
                                            <input type="hidden" name="action" value="removemember">
                                            <input type="hidden" name="studentId" value="<%= studentId %>">
                                            <button type="submit" class="btn btn-danger btn-sm" title="Remove from club">
                                                <i class="fas fa-user-minus"></i> Remove
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                    con.close();
                                } catch(Exception e) {
                            %>
                            <tr><td colspan="6">No members yet.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    
    <!-- MODAL OVERLAY -->
    <div class="modal-overlay" id="modalOverlay" onclick="hideAllForms()"></div>
    
    <!-- CREATE ACTIVITY FORM -->
    <div id="createActivityForm" class="form-popup">
        <div class="form-header">
            <h3 style="color: #8B0000;"><i class="fas fa-plus"></i> Create New Activity</h3>
            <button class="close-btn" onclick="hideForm('createActivityForm')">×</button>
        </div>
        <form action="ActivityServlet" method="post" onsubmit="return validateActivityForm()">
            <input type="hidden" name="action" value="create">
            
            <div class="form-group">
                <label>Activity Title *</label>
                <input type="text" id="activityTitle" name="activityTitle" class="form-control" required maxlength="200">
            </div>
            
            <div class="form-group">
                <label>Description *</label>
                <textarea id="description" name="description" class="form-control" rows="3" required maxlength="1000"></textarea>
            </div>
            
            <div class="form-group">
                <label>Date & Time *</label>
                <input type="datetime-local" id="dateTime" name="dateTime" class="form-control" required>
            </div>
            
            <div class="form-group">
                <label>Location *</label>
                <input type="text" id="location" name="location" class="form-control" required maxlength="200">
            </div>
            
            <div style="display: flex; gap: 10px; margin-top: 25px;">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Create Activity
                </button>
                <button type="button" class="btn" onclick="hideForm('createActivityForm')" 
                        style="background: #dee2e6; color: #2C3E50;">Cancel</button>
            </div>
        </form>
    </div>
    
    <!-- CREATE ANNOUNCEMENT FORM -->
    <div id="createAnnouncementForm" class="form-popup">
        <div class="form-header">
            <h3 style="color: #8B0000;"><i class="fas fa-edit"></i> Post Announcement</h3>
            <button class="close-btn" onclick="hideForm('createAnnouncementForm')">×</button>
        </div>
        <form action="AnnouncementServlet" method="post" onsubmit="return validateAnnouncementForm()">
            <input type="hidden" name="action" value="create">
            
            <div class="form-group">
                <label>Announcement Type *</label>
                <select name="announcementType" class="form-control" onchange="toggleActivityField(this)" required>
                    <option value="">Select Type</option>
                    <option value="Information">Information Post</option>
                    <option value="Activity">Activity Announcement</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Title *</label>
                <input type="text" id="announcementTitle" name="title" class="form-control" required maxlength="200">
            </div>
            
            <div class="form-group">
                <label>Content *</label>
                <textarea id="announcementContent" name="content" class="form-control" rows="4" required maxlength="2000"></textarea>
            </div>
            
            <div class="form-group" id="activitySelectGroup" style="display: none;">
                <label>Related Activity (Optional)</label>
                <select name="activityId" class="form-control" id="activityIdSelect">
                    <option value="">Select Activity</option>
                    <%
                        try {
                            Connection con = DBConnection.getConnection();
                            String sql = "SELECT activity_id, activity_title FROM ACTIVITY WHERE club_id = ? ORDER BY date_time DESC";
                            PreparedStatement pstmt = con.prepareStatement(sql);
                            pstmt.setInt(1, admin.getClubId());
                            ResultSet rs = pstmt.executeQuery();
                            while (rs.next()) {
                    %>
                    <option value="<%= rs.getInt("activity_id") %>"><%= rs.getString("activity_title") %></option>
                    <%
                            }
                            con.close();
                        } catch(Exception e) { }
                    %>
                </select>
            </div>
            
            <div style="display: flex; gap: 10px; margin-top: 25px;">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-paper-plane"></i> Post Announcement
                </button>
                <button type="button" class="btn" onclick="hideForm('createAnnouncementForm')"
                        style="background: #dee2e6; color: #2C3E50;">Cancel</button>
            </div>
        </form>
    </div>
    
    <!-- MANAGE ROLES FORM -->
    <div id="manageRolesForm" class="form-popup">
        <div class="form-header">
            <h3 style="color: #8B0000;"><i class="fas fa-user-tag"></i> Assign Club Roles</h3>
            <button class="close-btn" onclick="hideForm('manageRolesForm')">×</button>
        </div>
        <form action="ClubServlet" method="post" onsubmit="return validateRoleForm()">
            <input type="hidden" name="action" value="updaterole">
            
            <div class="form-group">
                <label>Select Member *</label>
                <select name="studentId" class="form-control" id="studentIdSelect" required>
                    <option value="">Select Student</option>
                    <%
                        try {
                            Connection con = DBConnection.getConnection();
                            String sql = "SELECT s.student_id, s.student_name, m.role_club " +
                                       "FROM STUDENT s " +
                                       "JOIN MEMBERSHIP m ON s.student_id = m.student_id " +
                                       "WHERE m.club_id = ? " +
                                       "ORDER BY s.student_name";
                            PreparedStatement pstmt = con.prepareStatement(sql);
                            pstmt.setInt(1, admin.getClubId());
                            ResultSet rs = pstmt.executeQuery();
                            while (rs.next()) {
                    %>
                    <option value="<%= rs.getString("student_id") %>">
                        <%= rs.getString("student_name") %> - Current: <%= rs.getString("role_club") %>
                    </option>
                    <%
                            }
                            con.close();
                        } catch(Exception e) { }
                    %>
                </select>
            </div>
            
            <div class="form-group">
                <label>Assign Role *</label>
                <select name="roleClub" class="form-control" id="roleClubSelect" required>
                    <option value="">Select Role</option>
                    <option value="Member">Member</option>
                    <option value="President">President</option>
                    <option value="Vice President">Vice President</option>
                    <option value="Secretary">Secretary</option>
                    <option value="Treasurer">Treasurer</option>
                    <option value="Committee Member">Committee Member</option>
                </select>
            </div>
            
            <div style="display: flex; gap: 10px; margin-top: 25px;">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Update Role
                </button>
                <button type="button" class="btn" onclick="hideForm('manageRolesForm')"
                        style="background: #dee2e6; color: #2C3E50;">Cancel</button>
            </div>
        </form>
    </div>
    
    <!-- ACTIVITY PARTICIPANTS MODAL -->
    <div id="activityParticipantsModal" class="form-popup">
        <div class="form-header">
            <h3 style="color: #8B0000;"><i class="fas fa-users"></i> Activity Participants</h3>
            <button class="close-btn" onclick="hideForm('activityParticipantsModal')">×</button>
        </div>
        <div id="activityParticipantsContent">
            Loading participants...
        </div>
        <div style="margin-top: 20px; text-align: center;">
            <button class="btn" onclick="hideForm('activityParticipantsModal')"
                    style="background: #dee2e6; color: #2C3E50; padding: 10px 30px;">Close</button>
        </div>
    </div>          
                
    <script>
        // Initialize dashboard as active
        document.addEventListener('DOMContentLoaded', function() {
            showSection('dashboard');
        });
        
        // Section display functions
        function showSection(sectionId) {
            // Hide all sections
            document.querySelectorAll('.content-section').forEach(section => {
                section.style.display = 'none';
            });
            
            // Remove active class from all nav links
            document.querySelectorAll('.nav-link').forEach(link => {
                link.classList.remove('active');
            });
            
            // Show selected section
            document.getElementById(sectionId).style.display = 'block';
            
            // Activate clicked nav link
            event.target.classList.add('active');
            
            // Hide all forms
            hideAllForms();
            
            // Close any open messages after 5 seconds
            setTimeout(() => {
                document.querySelectorAll('.message').forEach(msg => {
                    msg.style.display = 'none';
                });
            }, 5000);
        }
        
        // Form display functions
        function showForm(formId) {
            document.getElementById(formId).style.display = 'block';
            document.getElementById('modalOverlay').style.display = 'block';
            
            // Remove active class from all nav links
            document.querySelectorAll('.nav-link').forEach(link => {
                link.classList.remove('active');
            });
            
            // Reset forms when showing
            if (formId === 'createActivityForm') {
                resetActivityForm();
            } else if (formId === 'createAnnouncementForm') {
                resetAnnouncementForm();
            } else if (formId === 'manageRolesForm') {
                resetRoleForm();
            }
        }
        
        function hideForm(formId) {
            document.getElementById(formId).style.display = 'none';
            document.getElementById('modalOverlay').style.display = 'none';
        }
        
        function hideAllForms() {
            document.querySelectorAll('.form-popup').forEach(form => {
                form.style.display = 'none';
            });
            document.getElementById('modalOverlay').style.display = 'none';
        }
        
        function toggleActivityField(select) {
            const activityGroup = document.getElementById('activitySelectGroup');
            if (select.value === 'Activity') {
                activityGroup.style.display = 'block';
            } else {
                activityGroup.style.display = 'none';
                document.getElementById('activityIdSelect').value = '';
            }
        }
        
        function closeMessage(messageId) {
            document.getElementById(messageId).style.display = 'none';
        }
        
        // Auto-close messages after 5 seconds
        setTimeout(() => {
            document.querySelectorAll('.message').forEach(msg => {
                msg.style.display = 'none';
            });
        }, 5000);
        
        // Form validation functions
        function validateActivityForm() {
            const title = document.getElementById('activityTitle').value.trim();
            const description = document.getElementById('description').value.trim();
            const dateTime = document.getElementById('dateTime').value;
            const location = document.getElementById('location').value.trim();
            
            if (!title || !description || !dateTime || !location) {
                alert('Please fill in all required fields');
                return false;
            }
            
            const selectedDate = new Date(dateTime);
            const now = new Date();
            if (selectedDate <= now) {
                alert('Activity date must be in the future');
                return false;
            }
            
            return true;
        }
        
        function validateAnnouncementForm() {
            const type = document.querySelector('select[name="announcementType"]').value;
            const title = document.getElementById('announcementTitle').value.trim();
            const content = document.getElementById('announcementContent').value.trim();
            
            if (!type || !title || !content) {
                alert('Please fill in all required fields');
                return false;
            }
            
            if (type === 'Activity') {
                const activityId = document.getElementById('activityIdSelect').value;
                if (!activityId) {
                    alert('Please select a related activity for Activity announcements');
                    return false;
                }
            }
            
            return true;
        }
        
        function validateRoleForm() {
            const studentId = document.getElementById('studentIdSelect').value;
            const role = document.getElementById('roleClubSelect').value;
            
            if (!studentId || !role) {
                alert('Please select both member and role');
                return false;
            }
            
            return true;
        }
        
        // Form reset functions
        function resetActivityForm() {
            document.getElementById('activityTitle').value = '';
            document.getElementById('description').value = '';
            document.getElementById('location').value = '';
            
            // Set default date to tomorrow 2 PM
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            tomorrow.setHours(14, 0, 0, 0);
            
            const dateTimeField = document.getElementById('dateTime');
            const formattedDate = tomorrow.toISOString().slice(0, 16);
            dateTimeField.value = formattedDate;
        }
        
        function resetAnnouncementForm() {
            document.getElementById('announcementTitle').value = '';
            document.getElementById('announcementContent').value = '';
            document.querySelector('select[name="announcementType"]').value = '';
            document.getElementById('activityIdSelect').value = '';
            document.getElementById('activitySelectGroup').style.display = 'none';
        }
        
        function resetRoleForm() {
            document.getElementById('studentIdSelect').value = '';
            document.getElementById('roleClubSelect').value = '';
        }
        
        function viewActivityParticipants(activityId, activityTitle) {
            // Create a simple modal for participants
            const modalHtml = `
                <div class="modal-overlay" style="display: block; z-index: 1000;"></div>
                <div class="form-popup" style="display: block; width: 600px;">
                    <div class="form-header">
                        <h3 style="color: #8B0000;"><i class="fas fa-users"></i> ${activityTitle} - Participants</h3>
                        <button class="close-btn" onclick="closeParticipantsModal()">×</button>
                    </div>
                    <div id="participantsContent" style="max-height: 400px; overflow-y: auto;">
                        <p><i class="fas fa-spinner fa-spin"></i> Loading participants...</p>
                    </div>
                    <div style="margin-top: 20px; text-align: center;">
                        <button class="btn" onclick="closeParticipantsModal()"
                                style="background: #dee2e6; color: #2C3E50; padding: 10px 30px;">Close</button>
                    </div>
                </div>
            `;

            // Create modal div
            const modalDiv = document.createElement('div');
            modalDiv.id = 'participantsModal';
            modalDiv.innerHTML = modalHtml;
            document.body.appendChild(modalDiv);

            // Fetch participants via AJAX
            fetch('ClubServlet?action=activityparticipants&activityId=' + activityId)
                .then(response => response.text())
                .then(data => {
                    document.getElementById('participantsContent').innerHTML = data;
                })
                .catch(error => {
                    document.getElementById('participantsContent').innerHTML = 
                        '<p style="color: red;"><i class="fas fa-exclamation-triangle"></i> Error loading participants: ' + error + '</p>';
                });
        }

        function closeParticipantsModal() {
            const modal = document.getElementById('participantsModal');
            if (modal) {
                modal.remove();
            }
        }
        
        function deleteActivity(activityId, activityTitle) {
            if (confirm('Are you sure you want to delete activity: "' + activityTitle + '"?')) {
                const form = document.createElement('form');
                form.method = 'post';
                form.action = 'ActivityServlet';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';
                form.appendChild(actionInput);
                
                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'activityId';
                idInput.value = activityId;
                form.appendChild(idInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function deleteAnnouncement(announcementId, title) {
            if (confirm('Are you sure you want to delete announcement: "' + title + '"?')) {
                const form = document.createElement('form');
                form.method = 'post';
                form.action = 'AnnouncementServlet';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';
                form.appendChild(actionInput);
                
                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'announcementId';
                idInput.value = announcementId;
                form.appendChild(idInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        // Confirm member removal
        function confirmRemoveMember(memberName, role) {
            let warning = '';
            if (role === 'President') {
                warning = '\n\nWARNING: This member is a President! Removing them may leave your club without leadership.';
            } else if (role === 'Vice President' || role === 'Secretary' || role === 'Treasurer') {
                warning = '\n\nNote: This member has a special role (' + role + ').';
            }
            
            return confirm('Are you sure you want to remove "' + memberName + '" from the club?' + warning);
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            if (event.target == document.getElementById('modalOverlay')) {
                hideAllForms();
            }
        }
    </script>
</body>
</html>