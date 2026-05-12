package com.bank.dao;

import com.bank.model.User;
import com.bank.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * DAO class for User-related database operations.
 * Uses PreparedStatement exclusively to prevent SQL Injection.
 */
public class UserDAO {

    /**
     * Validates user credentials against the database.
     *
     * @param username the entered username
     * @param password the entered password
     * @return User object if valid, null otherwise
     */
    public User validateUser(String username, String password) {
        String sql = "SELECT id, username, password, full_name, email, phone FROM users WHERE username = ? AND password = ?";
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone"));
                return user;
            }

        } catch (SQLException e) {
            System.err.println("UserDAO.validateUser() error: " + e.getMessage());
        } finally {
            DBConnection.closeConnection(conn);
        }

        return null;
    }

    /**
     * Fetches a user by their ID.
     *
     * @param userId the user's primary key
     * @return User object or null
     */
    public User getUserById(int userId) {
        String sql = "SELECT id, username, full_name, email, phone FROM users WHERE id = ?";
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone"));
                return user;
            }

        } catch (SQLException e) {
            System.err.println("UserDAO.getUserById() error: " + e.getMessage());
        } finally {
            DBConnection.closeConnection(conn);
        }

        return null;
    }
}
