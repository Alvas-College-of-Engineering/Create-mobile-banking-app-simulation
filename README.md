🏦 NexaBank – Mobile Banking Web Application
A production-quality Mobile Banking Web Application built with:
Java Servlets (Controller layer)
JSP (View layer)
JDBC with PreparedStatement (DAO layer)
MySQL 8.0 (Database)
Apache Tomcat 9+ (Web Server)
Designed to run in VS Code without Eclipse.
---
📁 Project Structure
```
MobileBankingApp/
├── src/
│   └── com/bank/
│       ├── model/          → User.java, Account.java, Transaction.java
│       ├── dao/            → UserDAO.java, AccountDAO.java, TransactionDAO.java
│       ├── servlet/        → LoginServlet, DashboardServlet, TransferServlet,
│       │                     BillPayServlet, TransactionServlet, LogoutServlet
│       └── util/           → DBConnection.java
│
├── WebContent/
│   ├── css/style.css
│   ├── js/validation.js
│   ├── login.jsp
│   ├── dashboard.jsp
│   ├── transfer.jsp
│   ├── billpay.jsp
│   ├── history.jsp
│   └── error.jsp
│
├── WEB-INF/
│   └── web.xml
│
├── lib/
│   └── mysql-connector-j-8.x.x.jar
│
├── database.sql
└── README.md
```
---
⚙️ Prerequisites – What to Install
1. Java JDK 11 or 17
Download: https://adoptium.net/
After install, verify:
```
  java -version
  javac -version
  ```
Set `JAVA_HOME` environment variable to JDK install path.
2. Apache Tomcat 9.x
Download: https://tomcat.apache.org/download-90.cgi
Choose Core → zip (Windows) or .tar.gz (Linux/macOS)
Extract to a folder, e.g. `C:\tomcat9` or `/opt/tomcat9`
Do NOT install as a service for VS Code use.
3. MySQL 8.0
Download: https://dev.mysql.com/downloads/mysql/
During setup, set root password (remember it!)
Also install MySQL Workbench (optional but helpful)
4. MySQL Connector/J 8.x
Download: https://dev.mysql.com/downloads/connector/j/
Choose Platform Independent → ZIP
Extract and copy `mysql-connector-j-8.x.x.jar` into the project's `/lib/` folder.
---
🔌 VS Code Setup
Required Extensions
Install these from the Extensions panel (`Ctrl+Shift+X`):
Extension	Publisher	Purpose
Extension Pack for Java	Microsoft	Java dev tools
Tomcat for Java	adashen	Deploy to Tomcat
Community Server Connectors	Red Hat	(Alternative)
Add Tomcat Server in VS Code
Open VS Code
Press `Ctrl+Shift+P` → type "Tomcat: Add Tomcat Server"
Browse to your Tomcat installation folder (e.g. `C:\tomcat9`)
Tomcat will appear in the Tomcat Servers panel (bottom left)
---
🗄️ Database Setup
Step 1 – Open MySQL
```bash
mysql -u root -p
# Enter your MySQL root password
```
Step 2 – Run database.sql
```bash
source /full/path/to/MobileBankingApp/database.sql;
```
Or paste the contents of `database.sql` directly into MySQL Workbench and execute.
Step 3 – Verify
```sql
USE mobile_banking_db;
SHOW TABLES;
SELECT * FROM users;
SELECT * FROM accounts;
```
You should see 3 users and 3 accounts.
---
🔧 Configure Database Connection
Open `src/com/bank/util/DBConnection.java` and update:
```java
private static final String URL      = "jdbc:mysql://localhost:3306/mobile_banking_db?...";
private static final String USERNAME = "root";      // ← Your MySQL username
private static final String PASSWORD = "your_pass"; // ← Your MySQL password
```
---
🏗️ Build & Deploy in VS Code
Method 1 – Using Tomcat for Java Extension
Add MySQL Connector JAR to classpath:
Place `mysql-connector-j-8.x.x.jar` inside `/lib/`
In VS Code, open `settings.json` and add:
```json
     "java.project.referencedLibraries": [
         "lib/**/*.jar",
         "/path/to/tomcat9/lib/servlet-api.jar"
     ]
     ```
Compile the project:
```bash
   # From project root
   mkdir -p WebContent/WEB-INF/classes

   javac -cp "lib/mysql-connector-j-8.x.x.jar:/path/to/tomcat9/lib/servlet-api.jar" \
         -d WebContent/WEB-INF/classes \
         src/com/bank/util/DBConnection.java \
         src/com/bank/model/*.java \
         src/com/bank/dao/*.java \
         src/com/bank/servlet/*.java
   ```
> **Windows:** Replace `:` with `;` in the classpath.
Copy the JAR:
```bash
   mkdir -p WebContent/WEB-INF/lib
   cp lib/mysql-connector-j-8.x.x.jar WebContent/WEB-INF/lib/
   ```
Deploy using VS Code:
Right-click the project in Explorer → "Run on Tomcat Server"
OR right-click on the Tomcat server → "Add Deployment" → select project folder
Start the server:
Click ▶ next to the Tomcat server in the Servers panel
OR run: `/path/to/tomcat9/bin/startup.sh` (Linux/macOS) or `startup.bat` (Windows)
Method 2 – Manual WAR Deploy
Package the project as a WAR:
```bash
   cd MobileBankingApp
   jar -cvf MobileBankingApp.war -C WebContent .
   ```
Copy WAR to Tomcat webapps:
```bash
   cp MobileBankingApp.war /path/to/tomcat9/webapps/
   ```
Start Tomcat and access the app.
---
🚀 Running the Application
Start MySQL service
Start Tomcat (via VS Code or manually)
Open browser and navigate to:
```
   http://localhost:8080/MobileBankingApp/login
   ```
Or if deployed as ROOT:
```
   http://localhost:8080/login
   ```
---
🔑 Demo Login Credentials
Username	Password	Account No	Balance
alice	password123	ACC1001001	₹75,000.00
bob	password123	ACC1001002	₹42,500.50
charlie	password123	ACC1001003	₹1,20,000.00
---
✨ Features
Feature	Description
🔐 Login	Session-based authentication with SQL injection prevention
🏠 Dashboard	Account summary with balance, card view, quick actions
↔ Fund Transfer	Atomic debit/credit with validation and error handling
🧾 Bill Payment	10 bill categories with visual selector
📋 Transaction History	Full history with filter (All/Transfer/Bill/CR/DR) + search
⎋ Logout	Session invalidation with cache-control headers
⚠ Error Handling	Custom error.jsp for 404/500 and all exceptions
---
🛡️ Security Features
SQL Injection Prevention – All queries use `PreparedStatement` only
Session Validation – Every protected servlet checks session before serving
Session Fixation Prevention – Old session invalidated on login
Cache Prevention on Logout – Cache-Control headers set on logout
Atomic Transactions – Fund transfer uses DB transactions with rollback
Input Validation – Both client-side (JS) and server-side (Java)
---
🗂️ URL Mapping
URL	Servlet	Method
`/login`	LoginServlet	GET (show) / POST (authenticate)
`/dashboard`	DashboardServlet	GET
`/transfer`	TransferServlet	GET (show) / POST (process)
`/billpay`	BillPayServlet	GET (show) / POST (process)
`/history`	TransactionServlet	GET
`/logout`	LogoutServlet	GET
---
🐛 Troubleshooting
Problem	Solution
`ClassNotFoundException: com.mysql.cj.jdbc.Driver`	Place MySQL JAR in `WEB-INF/lib/`
`500 Error on login`	Check DB credentials in `DBConnection.java`
`404 on all pages`	Ensure `web.xml` is inside `WEB-INF/`
Tomcat won't start	Check port 8080 isn't in use; check `JAVA_HOME`
Can't compile	Ensure `servlet-api.jar` is in javac classpath
---
📦 Dependencies
Library	Version	Purpose
Apache Tomcat	9.x	Servlet container
MySQL Connector/J	8.0.x	JDBC driver for MySQL
Java Servlet API	4.0	Bundled with Tomcat 9
> **No Maven/Gradle required.** This is a classic servlet project using manual JAR management.
---
Built for educational purposes – Mobile Banking Web App Simulation using Java EE stack.
