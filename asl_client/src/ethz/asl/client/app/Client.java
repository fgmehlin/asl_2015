package ethz.asl.client.app;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Random;

import org.apache.log4j.Logger;


public class Client {

	private static int clientID;
	
	private static final String MESSAGE = "NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIo"
			+ "fDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nB"
			+ "Ck0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O";

	static boolean running = true;

	private static Random rand;
	
	private static Logger logger;
	

	public static void main(String[] args) {
		if (args.length != 3) {
			System.err.println("Usage: java Client <host name> <port number> <duration>");
			System.exit(1);
		}
		
		//PropertyConfigurator.configure("log4j.properties");

		
		
			
		int initClientID = -99;

		rand = new Random();

		

		String hostName = args[0];
		int portNumber = Integer.parseInt(args[1]);
		int duration = Integer.parseInt(args[2]);
		
		long start = System.currentTimeMillis();
		long end = start + duration * 1000;

		//System.out.println("hostname : " + hostName + ", port : " + portNumber);
		
		
		//get ClientID
		try (Socket clientSocket = new Socket(hostName, portNumber);
				PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
				BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) {
				
			initClientID = getClientID(out, in);
				
		}catch(IOException e){
			e.printStackTrace();
		}
		
		clientID = initClientID;
		System.setProperty("clientid", clientID+"");
		logger = Logger.getLogger(Client.class.getName());
		logger.info("Client started");	
		

		while (System.currentTimeMillis() < end) {

			int r = rand.nextInt(100);

			try (Socket clientSocket = new Socket(hostName, portNumber);
					PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
					BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) {

				if (r >= 0 && r < 30) {				// p(SM) = 0.30
					sendMessage(out, in);
				} else if (r >= 30 && r < 45) {		// p(PMBS) = 0.15 
					peekMessageBySender(out, in);
				} else if (r >= 45 && r < 60) {		// P(PMBQ) = 0.15
					peekMessageByQueue(out, in);
				} else if (r >= 60 && r < 78) {		// P(GMQ) = 0.18
					popMessageByQueue(out, in);
				} else if (r >= 78 && r < 96) {		// P(GMS) = 0.18
					popMessageBySender(out, in);
				} else if (r >= 96 && r < 97) {		// P(CQ) = 0.01
					createQueue(out, in);
				} else {							// P(DQ) = 0.03
					deleteQueue(out, in);
				}

			} catch (IOException e) {
				System.err.println("Couldn't get I/O for the connection to " + hostName);
				System.exit(1);
			}
		}

	}

	public static void sendMessage(PrintWriter out, BufferedReader in) throws IOException {
		int receiver = getClient(out, in);
		int queue = getQueue(out, in);
		if (queue > 0) {
			if (receiver > 0) {
				logger.info("Client "+ clientID + " Q send message to client(" + receiver + ") to queue("+queue+")");
				out.println("SM#"+clientID+"#" + receiver + "#" + queue
						+ "#"+MESSAGE);
				String sendStatus = in.readLine();
				logger.info("Client "+ clientID + " R send message to client(" + receiver + ") to queue("+queue+"). Status : " +sendStatus);
			} else {
				logger.info("No client to send a message for client: " + clientID);
				//System.out.println("No client available");
			}
		} else {
			logger.info("No queue to send a message for client: " + clientID);
			//System.out.println("No queue available");
		}

	}

	public static void peekMessageByQueue(PrintWriter out, BufferedReader in) throws IOException {
		int queue = getQueueWithMSG(out, in);
		logger.info("Client "+ clientID + " Q peek message by queue("+queue+")");
		out.println("PMQ#"+clientID+"#" + queue);
		String messagePeeked = in.readLine();
		if(messagePeeked==null || messagePeeked.equals("null")){
			logger.info("Client "+ clientID + " R peek message by queue("+queue+"). NO MSG AVAILABLE");
		}else{
			logger.info("Client "+ clientID + " R peek message by queue("+queue+"). Message="+messagePeeked);
		}
		//System.out.println("Message peeked from Queue "+queue+" :" + messagePeeked);
	}

	public static void peekMessageBySender(PrintWriter out, BufferedReader in) throws IOException {
		int sender = getClientWithMSG(out, in);
		logger.info("Client "+ clientID + " Q peek message by sender("+sender+")");
		out.println("PMS#"+clientID+"#" + sender);
		String messagePeeked = in.readLine();
		if(messagePeeked==null || messagePeeked.equals("null")){
			logger.info("Client "+ clientID + " R peek message by sender("+sender+"). NO MSG AVAILABLE");
		}else{
			logger.info("Client "+ clientID + " R peek message by sender("+sender+"). Message="+messagePeeked);
		}
		
		//System.out.println("Message peeked from Sender "+client+" :" + messagePeeked);
	}

	public static void popMessageByQueue(PrintWriter out, BufferedReader in) throws IOException {
		int queue = getQueueWithMSG(out, in);
		logger.info("Client "+ clientID + " Q pop message by queue("+queue+")");
		out.println("GMQ#"+clientID+"#" + queue);
		String messageFromQueue = in.readLine();
		if(messageFromQueue==null || messageFromQueue.equals("null")){
			logger.info("Client "+ clientID + " R pop message by sender("+queue+"). NO MSG AVAILABLE");
		}else{
			logger.info("Client "+ clientID + " R pop message by sender("+queue+"). Message="+messageFromQueue);
		}
		
		//System.out.println("Message poped from Queue "+queue+" :" + messageFromQueue);
	}

	public static void popMessageBySender(PrintWriter out, BufferedReader in) throws IOException {
		int sender = getClientWithMSG(out, in);
		logger.info("Client "+ clientID + " Q pop message by sender("+sender+")");
		out.println("GMS#"+clientID+"#" + sender);
		String messageFromSender = in.readLine();
		if(messageFromSender==null || messageFromSender.equals("null")){
			logger.info("Client "+ clientID + " R pop message by sender("+sender+"). NO MSG AVAILABLE");
		}else{
			logger.info("Client "+ clientID + " R pop message by sender("+sender+"). Message="+messageFromSender);
		}
		
		//System.out.println("Message peeked from Sender "+sender+" :" + messageFromSender);

	}

	public static void createQueue(PrintWriter out, BufferedReader in) throws IOException {
		logger.info("Client "+ clientID + " Q create a queue");
		out.println("CQ#"+clientID+"");
		String queueid = in.readLine();
		logger.info("Client "+ clientID + " R create a queue. Queue ID : " + queueid);
	}

	public static void deleteQueue(PrintWriter out, BufferedReader in) throws IOException {
		int queue = getQueue(out, in);
		if (queue >= 0) {
			logger.info("Client "+ clientID +" Q delete queue No"+queue);
			out.println("DQ#" + queue);
			String response = in.readLine();
			logger.info("Client "+ clientID +" R delete queue No"+queue+" status="+response);
		} else {
			//System.out.println("No queue available for client ID=CLIENT_ID");
			logger.info("No queues to delete for client="+clientID);
		}
	}

	private static int getClient(PrintWriter out, BufferedReader in) throws IOException {
		logger.info("Client " + clientID + " Q list of clients.");
		out.println("LC#"+clientID+"");
		String clients = in.readLine();
		String[] clientList = clients.split("#");
		if (!clients.isEmpty()) {
			logger.info("Client " + clientID + " R list of clients. List size : " + clientList.length);
			int receiver_index = rand.nextInt(clientList.length);
			return Integer.parseInt(clientList[receiver_index]);
		} else {
			logger.info("Client " + clientID + " R list of clients. List size : 0");
			return -1;
		}
	}
	
	private static int getClientWithMSG(PrintWriter out, BufferedReader in) throws IOException {
		logger.info("Client " + clientID + " Q list of clients with messages.");
		out.println("LCWM#"+clientID+"");
		String clients = in.readLine();
		String[] clientList = clients.split("#");
		if (!clients.isEmpty()) {
			logger.info("Client " + clientID + " R list of clients with messages. List size : " + clientList.length);
			int receiver_index = rand.nextInt(clientList.length);
			return Integer.parseInt(clientList[receiver_index]);
		} else {
			logger.info("Client " + clientID + " R list of clients with messages. List size : 0");
			return -1;
		}
	}

	private static int getQueue(PrintWriter out, BufferedReader in) throws IOException {
		logger.info("Client " + clientID + " Q list of queues");
		out.println("LQ#"+clientID);
		String queues = in.readLine();
		
		String[] queueList = queues.split("#");
		if (!queues.isEmpty()) {
			logger.info("Client " + clientID + " R list of queues. List size : " + queueList.length);
			int queue_index = rand.nextInt(queueList.length);
			return Integer.parseInt(queueList[queue_index]);
		} else {
			logger.info("Client " + clientID + " R list of queues. List size : 0");
			return -1;
		}
	}

	private static int getQueueWithMSG(PrintWriter out, BufferedReader in) throws IOException {
		logger.info("Client " + clientID + " R list of queues with messages ");
		out.println("LQWM#"+clientID);
		String queues = in.readLine();
		String[] queueList = queues.split("#");
		if (!queues.isEmpty()) {
			logger.info("Client " + clientID + " Q list of queues with messages. List size : " + queueList.length);
			int queue_index = rand.nextInt(queueList.length);
			return Integer.parseInt(queueList[queue_index]);
		} else {
			logger.info("Client " + clientID + " R list of queues with messages. List size : 0");
			return -1;
		}
	}
	
	private static int getClientID(PrintWriter out, BufferedReader in) throws IOException{
		out.println("ECHO");
		String clientID = in.readLine();
		//logger.info("Client id returned : " + clientID);
		return Integer.parseInt(clientID);
	}

}
