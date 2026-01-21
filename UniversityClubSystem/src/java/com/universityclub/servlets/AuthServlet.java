package com.universityclub.servlets;

import com.universityclub.beans.AdminBean;
import com.universityclub.beans.StudentBean;
import com.universityclub.dao.AdminDAO;
import com.universityclub.dao.StudentDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AuthServlet")
public class AuthServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("login".equals(action)) {
            handleLogin(request, response);
        } else if ("register".equals(action)) {
            handleRegister(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("logout".equals(action)) {
            handleLogout(request, response);
        }
    }
    
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        
        if ("admin".equals(role)) {
            AdminDAO adminDAO = new AdminDAO();
            AdminBean admin = adminDAO.loginAdmin(username, password);
            
            if (admin != null) {
                HttpSession session = request.getSession();
                session.setAttribute("admin", admin.getUsername());
                session.setAttribute("adminBean", admin);
                session.setAttribute("clubId", admin.getClubId());
                response.sendRedirect("adminDashboard.jsp");
            } else {
                response.sendRedirect("index.jsp?error=Invalid admin credentials");
            }
            
        } else if ("student".equals(role)) {
            StudentDAO studentDAO = new StudentDAO();
            StudentBean student = studentDAO.loginStudent(username, password);
            
            if (student != null) {
                HttpSession session = request.getSession();
                session.setAttribute("student", student.getUsername());
                session.setAttribute("studentBean", student);
                session.setAttribute("studentId", student.getStudentId());
                response.sendRedirect("studentDashboard.jsp");
            } else {
                response.sendRedirect("index.jsp?error=Invalid student credentials");
            }
        }
    }
    
    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String studentId = request.getParameter("studentId");
        String studentName = request.getParameter("studentName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        int yearOfStudy = Integer.parseInt(request.getParameter("yearOfStudy"));
        String faculty = request.getParameter("faculty");
        
        StudentDAO studentDAO = new StudentDAO();
        
        // Check if student already exists
        if (studentDAO.checkStudentExists(studentId, email, username)) {
            response.sendRedirect("register.jsp?error=Student ID, Email, or Username already exists");
            return;
        }
        
        StudentBean student = new StudentBean();
        student.setStudentId(studentId);
        student.setStudentName(studentName);
        student.setUsername(username);
        student.setEmail(email);
        student.setPassword(password);
        student.setYearOfStudy(yearOfStudy);
        student.setFaculty(faculty);
        student.setStatus("Active");
        
        boolean success = studentDAO.registerStudent(student);
        
        if (success) {
            response.sendRedirect("index.jsp?success=Registration successful! Please login.");
        } else {
            response.sendRedirect("register.jsp?error=Registration failed. Please try again.");
        }
    }
    
    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect("index.jsp");
    }
}