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

	private static String db_url = "";
	private static final String USERNAME = "asl_pg";
	private static final String PASSWORD = "asl_asl";

	private static DatabaseCommunication instance = null;

	protected DatabaseCommunication(String db_ip) {
		this.db_url = "jdbc:postgresql://"+db_ip+"/asl";
	}

	public static DatabaseCommunication getInstance(String db_ip) {
		if (instance == null) {
			instance = new DatabaseCommunication(db_ip);
		}
		return instance;
	}

	private Connection getConnection() {

		Connection conn = null;
		
		
		
		/*Properties connectionProps = new Properties();
		connectionProps.put("user", USERNAME);
		connectionProps.put("password", PASSWORD);

		try {
			conn = DriverManager.getConnection(db_url, connectionProps);
		} catch (SQLException e) {
			e.printStackTrace();
		}*/
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
	
	public String getClientsWithMessages(int clientID){
		Connection conn = null;
		PreparedStatement prepStmt = null;
		conn = getConnection();
		String result = "";
		String getQueuesSQL = "SELECT m.sender_id FROM clients as c, messages as m WHERE c.client_id = m.sender_id AND m.receiver_id in (-1, ?)";
		try {
			prepStmt = conn.prepareStatement(getQueuesSQL);
			prepStmt.setInt(1, clientID);
			ResultSet rs = prepStmt.executeQuery();

			while (rs.next()) {
				result = result + rs.getString("sender_id") + "#";
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

	public void createQueue() {
		Connection conn = null;
		CallableStatement createQueueProc = null;
		conn = getConnection();

		try {
			createQueueProc = conn.prepareCall("{ call createqueue()}");
			createQueueProc.execute();

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				createQueueProc.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public boolean deleteQueue(int queueID) {
		Connection conn = null;
		CallableStatement deleteQueueProc = null;
		conn = getConnection();
		boolean ok = false;

		try {
			deleteQueueProc = conn.prepareCall("{ ? = call deleteQueue(?)}");
			deleteQueueProc.setInt(2, queueID);
			deleteQueueProc.registerOutParameter(1, Types.BOOLEAN);
			deleteQueueProc.execute();
			ok = deleteQueueProc.getBoolean(1);

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				deleteQueueProc.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return ok;
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

	public boolean sendMessage(int sender, int receiver, int queue, String message) {
		Connection conn = null;
		CallableStatement sndMsgProc = null;
		conn = getConnection();
		boolean ok = false;

		try {
			sndMsgProc = conn.prepareCall("{? = call createmessage(?,?,?,?)}");
			sndMsgProc.setInt(2, sender);
			sndMsgProc.setInt(3, receiver);
			sndMsgProc.setInt(4, queue);
			sndMsgProc.setString(5, message);
			sndMsgProc.registerOutParameter(1, Types.BOOLEAN);
			sndMsgProc.execute();
			ok = sndMsgProc.getBoolean(1);

		} catch (SQLException e) {
			System.out.println("Message could not be sent");
			e.printStackTrace();
		} finally {
			try {
				sndMsgProc.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return ok;

	}
	
	public int createClient() {
		Connection conn = null;
		CallableStatement crtClient = null;
		conn = getConnection();
		int clientID = 0;

		try {
			crtClient = conn.prepareCall("{ ? = call createClient()}");
			crtClient.registerOutParameter(1, Types.INTEGER);
			crtClient.execute();
			clientID = crtClient.getInt(1);

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				crtClient.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		return clientID;
	}

}
