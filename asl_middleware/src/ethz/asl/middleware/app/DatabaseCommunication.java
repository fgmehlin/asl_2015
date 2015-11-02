package ethz.asl.middleware.app;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import org.apache.log4j.Logger;

import org.postgresql.util.PSQLException;



public class DatabaseCommunication {
	
//	private static Logger logger = Logger.getLogger(DatabaseCommunication.class.getName());

	String errorMessage = "";
	private final ConnectionPoolManager poolManager;
	private long startProcess;
	private long stopProcess;
	/*private static String db_url = "";
	private static final String USERNAME = "asl_pg";
	private static final String PASSWORD = "asl_asl";

	private static DatabaseCommunication instance = null;*/

	public DatabaseCommunication(ConnectionPoolManager poolManager) {
		this.poolManager = poolManager;
	}


	private Connection getConnection() {

		Connection conn = null;
		
		while(conn == null){
			conn = poolManager.getConnectionFromPool();
		}
		
		
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
	
	private void returnConnectionToPool(Connection connection){
		poolManager.returnConnectionToPool(connection);
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

		} catch (PSQLException e) {
			System.out.println("Could not get client list");
			errorMessage = e.getMessage();
			result = "ERROR";
			System.out.println(errorMessage);
		//	e.printStackTrace();
		}catch (SQLException e) {
			e.printStackTrace();
			result = "ERROR";
		} finally {
			try {
				prepStmt.close();
				//conn.close();
				
			} catch (SQLException e) {
				e.printStackTrace();
				result = "ERROR";
			}
			returnConnectionToPool(conn);
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
//			startProcess = System.currentTimeMillis();
			prepStmt = conn.prepareStatement(getQueuesSQL);
			ResultSet rs = prepStmt.executeQuery();

			int i = 0;
			while (rs.next() && i < 100) {
				result = result + rs.getString("queue_id") + "#";
				i++;
			}

		} catch (PSQLException e) {
			System.out.println("Could not get queue list");
			errorMessage = e.getMessage();
			result = "ERROR";
			System.out.println(errorMessage);
		//	e.printStackTrace();
		}catch (SQLException e) {
			e.printStackTrace();
			result = "ERROR";
		} finally {
			try {
				prepStmt.close();
				//conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				result = "ERROR";
			}
			returnConnectionToPool(conn);
		}

//		stopProcess = System.currentTimeMillis() - startProcess;
//		logger.info("[DBCOMM][CQ] " + stopProcess);
		
		return result;
	}
	
	public String getClientsWithMessages(int clientID){
		Connection conn = null;
		PreparedStatement prepStmt = null;
		conn = getConnection();
		String result = "";
		//String getQueuesSQL = "SELECT m.sender_id FROM clients as c, messages as m WHERE c.client_id = m.sender_id AND m.receiver_id = ?";
		String getQueuesSQL = "SELECT m.sender_id FROM messages as m WHERE m.receiver_id = ?";
		try {
//			startProcess = System.currentTimeMillis();
			prepStmt = conn.prepareStatement(getQueuesSQL);
			prepStmt.setInt(1, clientID);
			ResultSet rs = prepStmt.executeQuery();

			while (rs.next()) {
				result = result + rs.getString("sender_id") + "#";
			}

		} catch (PSQLException e) {
			System.out.println("Could not get Clients with messages");
			errorMessage = e.getMessage();
			result = "ERROR";
			System.out.println(errorMessage);
			//e.printStackTrace();
		}catch (SQLException e) {
			e.printStackTrace();
			result = "ERROR";
		} finally {
			try {
				prepStmt.close();
				//conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				result = "ERROR";
			}
			returnConnectionToPool(conn);
		}

//		stopProcess = System.currentTimeMillis() - startProcess;
//		logger.info("[DBCOMM][LCWM] " + stopProcess);
		
		return result;
		
	}
	
	public String getQueuesWithMessages(int clientID) {
		Connection conn = null;
		PreparedStatement prepStmt = null;
		conn = getConnection();
		String result = "";
		String getQueuesSQL = "SELECT queue_id FROM messages as m WHERE m.receiver_id in (-1, ?)";
		try {
//			startProcess = System.currentTimeMillis();
			prepStmt = conn.prepareStatement(getQueuesSQL);
			prepStmt.setInt(1, clientID);
			ResultSet rs = prepStmt.executeQuery();
			int i = 0;
			while (rs.next() && i < 100) {
				result = result + rs.getString("queue_id") + "#";
				i++;
			}

		} catch (PSQLException e) {
			System.out.println("Could not get queues with messages");
			errorMessage = e.getMessage();
			result = "ERROR";
			System.out.println(errorMessage);
		//	e.printStackTrace();
		}catch (SQLException e) {
			e.printStackTrace();
			result = "ERROR";
		} finally {
			try {
				prepStmt.close();
				//conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				result = "ERROR";
			}
			returnConnectionToPool(conn);
		}
//		stopProcess = System.currentTimeMillis() - startProcess;
//		logger.info("[DBCOMM][LQWM] " + stopProcess);
		return result;
	}

	public int createQueue() {
		Connection conn = null;
		CallableStatement createQueueProc = null;
		conn = getConnection();
		int queueid = 0;
		try {
//			startProcess = System.currentTimeMillis();
			createQueueProc = conn.prepareCall("{ ? = call createqueue()}");
			createQueueProc.registerOutParameter(1, Types.INTEGER);
			createQueueProc.execute();
			queueid = createQueueProc.getInt(1);

		} catch (PSQLException e) {
			System.out.println("Creation of queue failed");
			errorMessage = e.getMessage();
			queueid = -99;
			System.out.println(errorMessage);
		//	e.printStackTrace();
		}catch (SQLException e) {
			e.printStackTrace();
			queueid = -99;
		} finally {
			try {
				createQueueProc.close();
				//conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				queueid = -99;
			}
			returnConnectionToPool(conn);
		}
//		stopProcess = System.currentTimeMillis() - startProcess;
//		logger.info("[DBCOMM][CQ] " + stopProcess);
		return queueid;
	}

	public boolean deleteQueue(int queueID) {
		Connection conn = null;
		CallableStatement deleteQueueProc = null;
		conn = getConnection();
		boolean ok = false;
//		startProcess = System.currentTimeMillis();
		try {
			deleteQueueProc = conn.prepareCall("{ ? = call deleteQueue(?)}");
			deleteQueueProc.setInt(2, queueID);
			deleteQueueProc.registerOutParameter(1, Types.BOOLEAN);
			deleteQueueProc.execute();
			ok = deleteQueueProc.getBoolean(1);

		} catch (PSQLException e) {
			System.out.println("Queue could not be deleted");
			errorMessage = e.getMessage();
			ok = false;
			System.out.println(errorMessage);
		//	e.printStackTrace();
		}catch (SQLException e) {
			e.printStackTrace();
			ok = false;
		} finally {
			try {
				deleteQueueProc.close();
				//conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				ok = false;
			}
			returnConnectionToPool(conn);
		}
//		stopProcess = System.currentTimeMillis() - startProcess;
//		logger.info("[DBCOMM][DQ] " + stopProcess+ " queue="+queueID);
		return ok;
	}

	public String popMessageBySender(int clientid, int senderid) {
		Connection conn = null;
		CallableStatement popMsgProc = null;
		conn = getConnection();
		String message = "";

		try {
//			startProcess = System.currentTimeMillis();
			popMsgProc = conn.prepareCall("{ ? = call popMessageBySender(?,?)}");
			popMsgProc.setInt(2, clientid);
			popMsgProc.setInt(3, senderid);
			popMsgProc.registerOutParameter(1, Types.VARCHAR);
			popMsgProc.execute();
			message = popMsgProc.getString(1);

		} catch (PSQLException e) {
			System.out.println("Message could not be poped");
			errorMessage = e.getMessage();
			message = "ERROR";
			System.out.println(errorMessage);
		//	e.printStackTrace();
		}catch (SQLException e) {
			e.printStackTrace();
			message = "ERROR";
		} finally {
			try {
				popMsgProc.close();
				//conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				message = "ERROR";
			}
			returnConnectionToPool(conn);
		}
//		stopProcess = System.currentTimeMillis() - startProcess;
//		logger.info("[DBCOMM][GMS] " + stopProcess + " clientid="+clientid+" senderid="+senderid);
		return message;
	}
	
	public String popMessageByQueue(int clientid, int queueid) {
		Connection conn = null;
		CallableStatement popMsgProc = null;
		conn = getConnection();
		String message = "";

		try {
//			startProcess = System.currentTimeMillis();
			popMsgProc = conn.prepareCall("{ ? = call popMessageByQueue(?,?)}");
			popMsgProc.setInt(2, clientid);
			popMsgProc.setInt(3, queueid);
			popMsgProc.registerOutParameter(1, Types.VARCHAR);
			popMsgProc.execute();
			message = popMsgProc.getString(1);

		} catch (PSQLException e) {
			System.out.println("Message could not be poped");
			errorMessage = e.getMessage();
			message = "ERROR";
			System.out.println(errorMessage);
		//	e.printStackTrace();
		}catch (SQLException e) {
			e.printStackTrace();
			message = "ERROR";
		} finally {
			try {
				popMsgProc.close();
				//conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				message = "ERROR";
			}
			returnConnectionToPool(conn);
		}
//		stopProcess = System.currentTimeMillis() - startProcess;
//		logger.info("[DBCOMM][GMQ] " + stopProcess + " clientid="+clientid+" queueid="+queueid);
		return message;
	}

	public String peekMessageBySender(int clientid, int senderid) {
		Connection conn = null;
		CallableStatement peekMsgProc = null;
		conn = getConnection();
		String message = "";

		try {
//			startProcess = System.currentTimeMillis();
			peekMsgProc = conn.prepareCall("{ ? = call peekMessageBySender(?,?)}");
			peekMsgProc.setInt(2, clientid);
			peekMsgProc.setInt(3, senderid);
			peekMsgProc.registerOutParameter(1, Types.VARCHAR);
			peekMsgProc.execute();
			message = peekMsgProc.getString(1);

		} catch (PSQLException e) {
			System.out.println("Message could not be peeked");
			errorMessage = e.getMessage();
			message = "ERROR";
			System.out.println(errorMessage);
		//	e.printStackTrace();
		}catch (SQLException e) {
			e.printStackTrace();
			message = "ERROR";
		} finally {
			try {
				peekMsgProc.close();
				//conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				message = "ERROR";
			}
			returnConnectionToPool(conn);
		}
//		stopProcess = System.currentTimeMillis() - startProcess;
//		logger.info("[DBCOMM][PMS] " + stopProcess + " clientid="+clientid+" senderid="+senderid);
		return message;
	}
	
	public String peekMessageByQueue(int clientid, int queueid) {
		Connection conn = null;
		CallableStatement peekMsgProc = null;
		conn = getConnection();
		String message = "";

		try {
//			startProcess = System.currentTimeMillis();
			peekMsgProc = conn.prepareCall("{ ? = call peekMessageBySender(?,?)}");
			peekMsgProc.setInt(2, clientid);
			peekMsgProc.setInt(3, queueid);
			peekMsgProc.registerOutParameter(1, Types.VARCHAR);
			peekMsgProc.execute();
			message = peekMsgProc.getString(1);

		} catch (PSQLException e) {
			System.out.println("Message could not be peeked");
			errorMessage = e.getMessage();
			message = "ERROR";
			System.out.println(errorMessage);
			//e.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
			message = "ERROR";
		} finally {
			try {
				peekMsgProc.close();
				//conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
				message = "ERROR";
			}
			returnConnectionToPool(conn);
		}
//		stopProcess = System.currentTimeMillis() - startProcess;
//		logger.info("[DBCOMM][PMQ] " + stopProcess + " clientid="+clientid+" senderid="+queueid);
		return message;
	}

	public boolean sendMessage(int sender, int receiver, int queue, String message) {
		Connection conn = null;
		CallableStatement sndMsgProc = null;
		conn = getConnection();
		boolean ok = false;

		try {
//			startProcess = System.currentTimeMillis();
			sndMsgProc = conn.prepareCall("{? = call createmessage(?,?,?,?)}");
			sndMsgProc.setInt(2, sender);
			sndMsgProc.setInt(3, receiver);
			sndMsgProc.setInt(4, queue);
			sndMsgProc.setString(5, message);
			sndMsgProc.registerOutParameter(1, Types.BOOLEAN);
			sndMsgProc.execute();
			ok = sndMsgProc.getBoolean(1);

		} catch (PSQLException e) {
			System.out.println("Message insertion failed");
			errorMessage = e.getMessage();
			System.out.println(errorMessage);
			ok = false;
			//e.printStackTrace();
		}catch (SQLException e) {
			System.out.println("Message could not be sent");
			e.printStackTrace();
			ok = false;
		}  finally {
			try {
				sndMsgProc.close();
				//conn.close();
				
			} catch (SQLException e) {
				e.printStackTrace();
				ok = false;
			}
			returnConnectionToPool(conn);
		}
//		stopProcess = System.currentTimeMillis() - startProcess;
//		logger.info("[DBCOMM][PMQ] " + stopProcess + " senderid="+sender+" receiverid="+receiver);
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

		} catch (PSQLException e) {
			System.out.println("Client could not be created");
			errorMessage = e.getMessage();
			System.out.println(errorMessage);
		//	e.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				crtClient.close();
				//conn.close();
				
			} catch (SQLException e) {
				e.printStackTrace();
			}
			returnConnectionToPool(conn);
		}
		
		return clientID;
	}

}
