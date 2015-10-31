package ethz.asl.middleware.app;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Vector;

class ConnectionPoolManager
{

	private String db_url = "";
	
	private final String USERNAME = "asl_pg";
	private final String PASSWORD = "asl_asl_asl";
	private int MAX_POOL_SIZE = 0;

	Vector<Connection> connectionPool = new Vector<Connection>();

	public ConnectionPoolManager(String databaseUrl, int poolSize)
	{
		this.db_url = "jdbc:postgresql://"+databaseUrl+"/asl";
		this.MAX_POOL_SIZE = poolSize;
		initialize();
	}

	private void initialize()
	{
		//Here we can initialize all the information that we need
		initializeConnectionPool();
	}

	private void initializeConnectionPool()
	{
		while(!checkIfConnectionPoolIsFull())
		{
			System.out.println("Connection Pool is NOT full. Proceeding with adding new connections");
			//Adding new connection instance until the pool is full
			connectionPool.addElement(createNewConnectionForPool());
		}
		System.out.println("Connection Pool is full.");
	}

	private synchronized boolean checkIfConnectionPoolIsFull()
	{
		//Check if the pool size is full
		if(connectionPool.size() < MAX_POOL_SIZE)
		{
			return false;
		}

		return true;
	}

	//Creating a connection
	private Connection createNewConnectionForPool()
	{
		Connection connection = null;

		try
		{
			//Class.forName("org.postgresql.Driver");
			connection = DriverManager.getConnection(db_url, USERNAME, PASSWORD);
		}
		catch(SQLException sqle)
		{
			System.err.println("SQLException: "+sqle);
			return null;
		}
		/*catch(ClassNotFoundException cnfe)
		{
			System.err.println("ClassNotFoundException: "+cnfe);
			return null;
		}*/

		return connection;
	}

	public synchronized Connection getConnectionFromPool()
	{
		Connection connection = null;

		//Check if there is a connection available. There are times when all the connections in the pool may be used up
		if(connectionPool.size() > 0)
		{
			connection = connectionPool.firstElement();
			connectionPool.removeElementAt(0);
		}
		//Giving away the connection from the connection pool
		return connection;
	}

	public synchronized void returnConnectionToPool(Connection connection)
	{
		//Adding the connection from the client back to the connection pool
		connectionPool.addElement(connection);
	}
}