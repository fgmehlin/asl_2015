package ethz.asl.middleware.app;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

public class DatabaseCommunication {

	private static final String URL = "jdbc:postgresql://localhost";
	private static final String USERNAME = "asl_pg";
	private static final String PASSWORD = "asl_asl_asl";

	private static DatabaseCommunication instance = null;

	protected DatabaseCommunication() {
	}

	public static DatabaseCommunication getInstance() {
		if (instance == null) {
			instance = new DatabaseCommunication();
		}
		return instance;
	}

	private Connection getConnection() {

		Connection conn = null;
		Properties connectionProps = new Properties();
		connectionProps.put("user", USERNAME);
		connectionProps.put("password", PASSWORD);

		try {
			conn = DriverManager.getConnection(URL, connectionProps);
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return conn;
	}

	public String getClients(int clientID) {
		Connection conn = null;
		PreparedStatement prepStmt = null;
		conn = getConnection();
		String result = "";
		String getClientSQL = "SELECT client_id FROM clients WHERE client_id NOT IN (-1, ?)";
		try {
			prepStmt = conn.prepareStatement(getClientSQL);
			prepStmt.setInt(1, clientID);
			ResultSet rs = prepStmt.executeQuery();

			while (rs.next()) {
				result = result + rs.getString("client_id") + "#";
			}

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				prepStmt.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}

		return result;
	}

	public String getQueues(int clientID) {
		Connection conn = null;
		PreparedStatement prepStmt = null;
		conn = getConnection();
		String result = "";
		String getQueuesSQL = "SELECT queue_id FROM queues";
		try {
			prepStmt = conn.prepareStatement(getQueuesSQL);
			prepStmt.setInt(1, clientID);
			ResultSet rs = prepStmt.executeQuery();

			while (rs.next()) {
				result = result + rs.getString("client_id") + "#";
			}

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				prepStmt.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}

		return result;
	}

	public void createQueue(int owner) {
		Connection conn = null;
		CallableStatement sndMsgProc = null;
		conn = getConnection();

		try {
			sndMsgProc = conn.prepareCall("{ call createqueue(?)}");
			sndMsgProc.setInt(1, owner);
			sndMsgProc.execute();

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				sndMsgProc.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public void deleteQueue() {

	}

	public void getMessage() {

	}

	public void peekMessage() {

	}

	public void sendMessage(int sender, int receiver, int queue, String message) {
		Connection conn = null;
		CallableStatement sndMsgProc = null;
		conn = getConnection();

		try {
			sndMsgProc = conn.prepareCall("{ call createmessage200(?)}");
			sndMsgProc.setInt(1, sender);
			sndMsgProc.setInt(2, receiver);
			sndMsgProc.setInt(3, queue);
			sndMsgProc.setString(4, message);
			sndMsgProc.execute();

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				sndMsgProc.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}

	}

}
