package com.bank.model;

/**
 * Model class representing a bank user.
 */
public class User {

    private int    id;
    private String username;
    private String password;
    private String fullName;
    private String email;
    private String phone;

    public User() {}

    public User(int id, String username, String password, String fullName, String email, String phone) {
        this.id       = id;
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email    = email;
        this.phone    = phone;
    }

    // Getters and Setters
    public int    getId()          { return id; }
    public void   setId(int id)    { this.id = id; }

    public String getUsername()              { return username; }
    public void   setUsername(String u)      { this.username = u; }

    public String getPassword()              { return password; }
    public void   setPassword(String p)      { this.password = p; }

    public String getFullName()              { return fullName; }
    public void   setFullName(String fn)     { this.fullName = fn; }

    public String getEmail()                 { return email; }
    public void   setEmail(String e)         { this.email = e; }

    public String getPhone()                 { return phone; }
    public void   setPhone(String ph)        { this.phone = ph; }
}
