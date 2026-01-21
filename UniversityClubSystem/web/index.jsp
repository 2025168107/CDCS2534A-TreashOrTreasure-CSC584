<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>University Club | Login</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
        }

        body {
            background: #f8f9fa;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            background-image: linear-gradient(135deg, rgba(139, 0, 0, 0.05) 0%, rgba(178, 34, 34, 0.05) 100%);
        }

        .login-container {
            width: 100%;
            max-width: 420px;
        }

        .login-card {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.08);
            border: 1px solid #e9ecef;
        }

        /* LOGO SECTION */
        .logo-section {
            text-align: center;
            margin-bottom: 32px;
        }

        .university-logo {
            width: 150px;
            height: 150px;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .university-logo img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }

        .system-title {
            margin-bottom: 8px;
        }

        .system-title h1 {
            color: #8B0000;
            font-size: 32px;
            margin-bottom: 4px;
            font-weight: 700;
        }

        .system-title p {
            color: #666;
            font-size: 15px;
            font-weight: 500;
        }

        .welcome-text {
            text-align: center;
            margin-bottom: 28px;
        }

        .welcome-text h2 {
            color: #1a1a1a;
            font-size: 22px;
            margin-bottom: 6px;
        }

        .welcome-text p {
            color: #666;
            font-size: 14px;
            line-height: 1.5;
        }

        /* ROLE TABS */
        .role-tabs {
            display: flex;
            background: #f8f9fa;
            border-radius: 12px;
            padding: 6px;
            margin-bottom: 24px;
        }

        .role-tab {
            flex: 1;
            padding: 14px;
            text-align: center;
            border: none;
            background: transparent;
            color: #666;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            border-radius: 10px;
            transition: all 0.3s ease;
        }

        .role-tab:hover {
            background: rgba(139, 0, 0, 0.08);
            color: #8B0000;
        }

        .role-tab.active {
            background: linear-gradient(135deg, #8B0000, #B22222);
            color: white;
            box-shadow: 0 4px 12px rgba(139, 0, 0, 0.2);
        }

        /* FORM STYLES */
        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            color: #444;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: 500;
        }

        .form-input {
            width: 100%;
            padding: 14px 16px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            border-radius: 10px;
            color: #1a1a1a;
            font-size: 15px;
            transition: all 0.3s;
        }

        .form-input:focus {
            outline: none;
            border-color: #8B0000;
            background: white;
            box-shadow: 0 0 0 3px rgba(139, 0, 0, 0.1);
        }

        .login-btn {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #8B0000, #B22222);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
            transition: all 0.3s;
        }

        .login-btn:hover {
            background: linear-gradient(135deg, #B22222, #8B0000);
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(139, 0, 0, 0.2);
        }

        /* Role-specific placeholder hints */
        .role-hint {
            margin-top: 8px;
            color: #666;
            font-size: 13px;
            display: none;
        }

        .role-hint.active {
            display: block;
        }

        .error {
            background: #ffe6e6;
            border: 1px solid #ffb3b3;
            color: #cc0000;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
            display: none;
        }

        .error.active {
            display: block;
        }

        .success {
            background: #e6ffe6;
            border: 1px solid #b3ffb3;
            color: #006600;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }

        .register-link {
            text-align: center;
            margin-top: 24px;
            padding-top: 24px;
            border-top: 1px solid #eee;
        }

        .register-link p {
            color: #666;
            font-size: 14px;
        }

        .demo-section {
            margin-top: 20px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 10px;
            border: 1px solid #e9ecef;
        }

        .demo-title {
            font-weight: 600;
            color: #444;
            margin-bottom: 10px;
            font-size: 14px;
        }

        .demo-item {
            margin-bottom: 15px;
            font-size: 13px;
            color: #666;
        }

        .demo-fill-btn {
            margin-top: 8px;
            padding: 8px 12px;
            background: #8B0000;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 12px;
            cursor: pointer;
            margin-right: 8px;
            transition: all 0.3s;
        }

        .demo-fill-btn:hover {
            background: #B22222;
        }

        @media (max-width: 480px) {
            .login-card { 
                padding: 30px 20px; 
            }
            .system-title h1 { 
                font-size: 28px; 
            }
            .role-tab {
                padding: 12px;
                font-size: 14px;
            }
            .university-logo {
                width: 120px;
                height: 120px;
            }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-card">
            <!-- LOGO SECTION -->
            <div class="logo-section">
                <div class="university-logo">
                    <!-- Try the most likely paths for NetBeans 8.0 -->
                    <img src="ToT.png" alt="University Club Logo" 
                         onerror="this.onerror=null; this.src='images/ToT.png'; this.alt='University Logo';">
                </div>
                <div class="system-title">
                    <h1>University Club</h1>
                    <p>UITM Club Management System</p>
                </div>
            </div>

            <div class="welcome-text">
                <h2>Welcome</h2>
                <p>Sign in to access your club dashboard</p>
            </div>

            <% 
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            
            if (error != null) { 
            %>
                <div class="error active">
                    <%= error %>
                </div>
            <% } 
            
            if (success != null) { 
            %>
                <div class="success">
                    <%= success %>
                </div>
            <% } %>

            <form id="loginForm" action="AuthServlet" method="post">
                <input type="hidden" name="action" value="login">
                <input type="hidden" id="roleInput" name="role" value="student">
                
                <!-- ROLE TABS -->
                <div class="role-tabs">
                    <button type="button" class="role-tab active" data-role="student">
                        <i class="fas fa-user-graduate"></i> Student
                    </button>
                    <button type="button" class="role-tab" data-role="admin">
                        <i class="fas fa-user-tie"></i> Admin
                    </button>
                </div>

                <!-- USERNAME FIELD -->
                <div class="form-group">
                    <label for="username" id="usernameLabel">Student ID / Email / Student Name</label>
                    <input type="text" id="username" name="username" class="form-input" 
                           placeholder="Enter your student ID, email or student name" required>
                    <div class="role-hint active" id="studentHint">
                        <i class="fas fa-info-circle"></i> Use your student ID, registered email or student name
                    </div>
                    <div class="role-hint" id="adminHint">
                        <i class="fas fa-info-circle"></i> Use your admin username
                    </div>
                </div>

                <!-- PASSWORD FIELD -->
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-input" 
                           placeholder="Enter your password" required>
                </div>

                <!-- LOGIN BUTTON -->
                <button type="submit" class="login-btn">
                    <i class="fas fa-sign-in-alt"></i> Sign In
                </button>
            </form>

            <!-- REGISTER LINK -->
            <div class="register-link">
                <p>Don't have an account? <a href="register.jsp" style="color: #8B0000; font-weight: 600;">Register as Student</a></p>
            </div>
        </div>
    </div>

    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const studentTab = document.querySelector('[data-role="student"]');
            const adminTab = document.querySelector('[data-role="admin"]');
            const roleInput = document.getElementById('roleInput');
            const usernameField = document.getElementById('username');
            const usernameLabel = document.getElementById('usernameLabel');
            const studentHint = document.getElementById('studentHint');
            const adminHint = document.getElementById('adminHint');
            
            // Set initial state
            setActiveTab('student');
            
            // Student tab click
            studentTab.addEventListener('click', function() {
                setActiveTab('student');
                // Clear fields when switching tabs
                usernameField.value = '';
                document.getElementById('password').value = '';
                usernameField.focus();
            });
            
            // Admin tab click
            adminTab.addEventListener('click', function() {
                setActiveTab('admin');
                // Clear fields when switching tabs
                usernameField.value = '';
                document.getElementById('password').value = '';
                usernameField.focus();
            });
            
            function setActiveTab(role) {
                // Update tabs
                if (role === 'student') {
                    studentTab.classList.add('active');
                    adminTab.classList.remove('active');
                    roleInput.value = 'student';
                    
                    // Update form
                    usernameLabel.textContent = 'Student ID / Email / Student Name';
                    usernameField.placeholder = 'Enter your student ID, email or name';
                    
                    // Update hints
                    studentHint.classList.add('active');
                    adminHint.classList.remove('active');
                    
                } else if (role === 'admin') {
                    studentTab.classList.remove('active');
                    adminTab.classList.add('active');
                    roleInput.value = 'admin';
                    
                    // Update form
                    usernameLabel.textContent = 'Username';
                    usernameField.placeholder = 'Enter your admin username';
                    
                    // Update hints
                    studentHint.classList.remove('active');
                    adminHint.classList.add('active');
                }
            }
            
            // Form submission validation
            document.getElementById('loginForm').addEventListener('submit', function(e) {
                const username = usernameField.value.trim();
                const password = document.getElementById('password').value.trim();
                const role = roleInput.value;
                
                if (!username || !password) {
                    e.preventDefault();
                    alert('Please fill in all fields');
                    return;
                }
                
                // Show loading state
                const submitBtn = this.querySelector('.login-btn');
                const originalText = submitBtn.innerHTML;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Signing In...';
                submitBtn.disabled = true;
                
                // Re-enable button after 3 seconds in case submission fails
                setTimeout(() => {
                    submitBtn.innerHTML = originalText;
                    submitBtn.disabled = false;
                }, 3000);
            });
            
            // Fix for image path in NetBeans
            const logoImg = document.querySelector('.university-logo img');
            // Try to load the image with different paths
            const tryImagePaths = [
                'ToT.png',
                'images/ToT.png',
                './images/ToT.png',
                '../images/ToT.png',
                'web/images/ToT.png'
            ];
            
            let currentPathIndex = 0;
            function tryNextImagePath() {
                if (currentPathIndex < tryImagePaths.length) {
                    logoImg.src = tryImagePaths[currentPathIndex];
                    currentPathIndex++;
                    // Try next path if this one fails
                    logoImg.onerror = function() {
                        setTimeout(tryNextImagePath, 100);
                    };
                }
            }
            
            // Start trying paths
            tryNextImagePath();
        });
        
        // Function to fill demo credentials manually
        function fillDemoCredentials(role) {
            const usernameField = document.getElementById('username');
            const passwordField = document.getElementById('password');
            const studentTab = document.querySelector('[data-role="student"]');
            const adminTab = document.querySelector('[data-role="admin"]');
            
            if (role === 'student') {
                // Switch to student tab
                if (!studentTab.classList.contains('active')) {
                    studentTab.click();
                }
                // Try different formats
                usernameField.value = '202312345';
                passwordField.value = 'password123';
            } else if (role === 'admin') {
                // Switch to admin tab
                if (!adminTab.classList.contains('active')) {
                    adminTab.click();
                }
                usernameField.value = 'admin_prog';
                passwordField.value = 'admin123';
            }
            
            // Focus on password field after filling
            passwordField.focus();
        }
    </script>
</body>
</html>