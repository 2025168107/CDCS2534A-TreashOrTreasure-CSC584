<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>University Club | Student Registration</title>
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
        }

        .register-container {
            width: 100%;
            max-width: 500px;
        }

        .register-card {
            background: white;
            border-radius: 20px;
            padding: 48px 40px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.08);
            border: 1px solid #e9ecef;
        }

        .logo {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo-icon {
            width: 64px;
            height: 64px;
            background: linear-gradient(135deg, #8B0000, #B22222);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
            color: white;
            font-size: 24px;
            font-weight: 700;
        }

        .logo h1 {
            color: #1a1a1a;
            font-size: 28px;
            margin-bottom: 6px;
        }

        .logo p {
            color: #666;
            font-size: 14px;
            font-weight: 500;
        }

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
        }

        .form-input:focus {
            outline: none;
            border-color: #8B0000;
            background: white;
            box-shadow: 0 0 0 3px rgba(139, 0, 0, 0.1);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .register-btn {
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
        }

        .register-btn:hover {
            background: linear-gradient(135deg, #B22222, #8B0000);
        }

        .error {
            background: #ffe6e6;
            border: 1px solid #ffb3b3;
            color: #cc0000;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }

        .login-link {
            text-align: center;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }

        @media (max-width: 600px) {
            .form-row {
                grid-template-columns: 1fr;
                gap: 0;
            }
            .register-card {
                padding: 36px 24px;
            }
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-card">
            <div class="logo">
                <div class="logo-icon">U</div>
                <h1>Student Registration</h1>
                <p>Create your student account</p>
            </div>

            <% 
            String error = request.getParameter("error");
            if (error != null) { 
            %>
                <div class="error">
                    <%= error %>
                </div>
            <% } %>

            <form action="AuthServlet" method="post">
                <input type="hidden" name="action" value="register">
                <div class="form-row">
                    <div class="form-group">
                        <label for="studentId">Student ID *</label>
                        <input type="text" id="studentId" name="studentId" class="form-input" 
                               placeholder="e.g., 202312345" required>
                    </div>

                    <div class="form-group">
                        <label for="studentName">Full Name *</label>
                        <input type="text" id="studentName" name="studentName" class="form-input" 
                               placeholder="Enter your full name" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="username">Username *</label>
                        <input type="text" id="username" name="username" class="form-input" 
                               placeholder="Choose a username" required>
                    </div>

                    <div class="form-group">
                        <label for="email">Email *</label>
                        <input type="email" id="email" name="email" class="form-input" 
                               placeholder="example@uitm.edu.my" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="password">Password *</label>
                        <input type="password" id="password" name="password" class="form-input" 
                               placeholder="Create a password" required>
                    </div>

                    <div class="form-group">
                        <label for="yearOfStudy">Year of Study *</label>
                        <select id="yearOfStudy" name="yearOfStudy" class="form-input" required>
                            <option value="">Select Year</option>
                            <option value="1">Year 1</option>
                            <option value="2">Year 2</option>
                            <option value="3">Year 3</option>
                            <option value="4">Year 4</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="faculty">Faculty *</label>
                    <input type="text" id="faculty" name="faculty" class="form-input" 
                           placeholder="e.g., Computer Science" required>
                </div>

                <button type="submit" class="register-btn">Create Account</button>
            </form>

            <div class="login-link">
                <p>Already have an account? <a href="index.jsp" style="color: #8B0000; font-weight: 600;">Login here</a></p>
            </div>
        </div>
    </div>
</body>
</html>