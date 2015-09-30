package ethz.asl.middleware.app;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Properties;

public class DatabaseCommunication {

	private static final String URL = "jdbc:postgresql://localhost/asl";
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

	public String getQueues() {
		Connection conn = null;
		PreparedStatement prepStmt = null;
		conn = getConnection();
		String result = "";
		String getQueuesSQL = "SELECT queue_id FROM queues";
		try {
			prepStmt = conn.prepareStatement(getQueuesSQL);
			ResultSet rs = prepStmt.executeQuery();

			while (rs.next()) {
				result = result + rs.getString("queue_id") + "#";
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
	
	public String getQueuesWithMessages(int clientID) {
		Connection conn = null;
		PreparedStatement prepStmt = null;
		conn = getConnection();
		String result = "";
		String getQueuesSQL = "SELECT queue_id FROM messages as m, message_queue as mq WHERE m.message_id = mq.message_id AND m.receiver_id in (-1, ?)";
		try {
			prepStmt = conn.prepareStatement(getQueuesSQL);
			prepStmt.setInt(1, clientID);
			ResultSet rs = prepStmt.executeQuery();

			while (rs.next()) {
				result = result + rs.getString("queue_id") + "#";
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

	public String popMessageBySender(int clientid, int senderid) {
		Connection conn = null;
		CallableStatement popMsgProc = null;
		conn = getConnection();
		String message = "";

		try {
			popMsgProc = conn.prepareCall("{ ? = call popMessageBySender(?,?)}");
			popMsgProc.setInt(2, clientid);
			popMsgProc.setInt(3, senderid);
			popMsgProc.registerOutParameter(1, Types.VARCHAR);
			popMsgProc.execute();
			message = popMsgProc.getString(1);

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				popMsgProc.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		return message;
	}
	
	public String popMessageByQueue(int clientid, int queueid) {
		Connection conn = null;
		CallableStatement popMsgProc = null;
		conn = getConnection();
		String message = "";

		try {
			popMsgProc = conn.prepareCall("{ ? = call popMessageByQueue(?,?)}");
			popMsgProc.setInt(2, clientid);
			popMsgProc.setInt(3, queueid);
			popMsgProc.registerOutParameter(1, Types.VARCHAR);
			popMsgProc.execute();
			message = popMsgProc.getString(1);

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				popMsgProc.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		return message;
	}

	public String peekMessageBySender(int clientid, int senderid) {
		Connection conn = null;
		CallableStatement peekMsgProc = null;
		conn = getConnection();
		String message = "";

		try {
			peekMsgProc = conn.prepareCall("{ ? = call peekMessageBySender(?,?)}");
			peekMsgProc.setInt(2, clientid);
			peekMsgProc.setInt(3, senderid);
			peekMsgProc.registerOutParameter(1, Types.VARCHAR);
			peekMsgProc.execute();
			message = peekMsgProc.getString(1);

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				peekMsgProc.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		return message;
	}
	
	public String peekMessageByQueue(int clientid, int queueid) {
		Connection conn = null;
		CallableStatement peekMsgProc = null;
		conn = getConnection();
		String message = "";

		try {
			peekMsgProc = conn.prepareCall("{ ? = call peekMessageBySender(?,?)}");
			peekMsgProc.setInt(2, clientid);
			peekMsgProc.setInt(3, queueid);
			peekMsgProc.registerOutParameter(1, Types.VARCHAR);
			peekMsgProc.execute();
			message = peekMsgProc.getString(1);

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				peekMsgProc.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		return message;
	}

	public void sendMessage(int sender, int receiver, int queue, String message) {
		Connection conn = null;
		CallableStatement sndMsgProc = null;
		conn = getConnection();

		try {
			sndMsgProc = conn.prepareCall("{ call createmessage(?,?,?,?)}");
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
