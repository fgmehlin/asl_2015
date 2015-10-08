package ethz.asl.client.app;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Random;
import java.util.Scanner;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;


public class Client {

	private static int clientID;
	
	private static final String MESSAGE = "NfrZkKrqk0SQnzPhBXfWzbFcJMi8RlKzcyko9ciBBPkYbPQiiSDiPB9QfKYKYIo"
			+ "fDUAvqUNiYQy1jbqIyJoMOAlQvIDHC93eBbsk77JcWO66tvwzYNJ8Ucvsb4ayE2nB"
			+ "Ck0IHHQ1KmFDIRwE5OQ2TnAK53KC9e5m9FcNBKyA5MAsQXGrDrhtxnNjiLDhcNGHYwXLF18O";

	static boolean running = true;

	private static Random rand;
	
	private static Logger logger = Logger.getLogger(Client.class.getName());
	

	public static void main(String[] args) {
		if (args.length != 2) {
			System.err.println("Usage: java Client <host name> <port number>");
			System.exit(1);
		}
		
		//PropertyConfigurator.configure("log4j.properties");

		logger.info(System.currentTimeMillis() +" Client started");		
		int initClientID = -99;

		rand = new Random();

		long start = System.currentTimeMillis();
		long end = start + 60 * 1000;

		String hostName = args[0];
		int portNumber = Integer.parseInt(args[1]);

		//System.out.println("hostname : " + hostName + ", port : " + portNumber);
		
		
		//get ClientID
		try (Socket clientSocket = new Socket(hostName, portNumber);
				PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
				BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) {
				
			initClientID = getClientID(out, in);
				
				//System.out.println("Client id given :"  + clientID);
				
		}catch(IOException e){
			e.printStackTrace();
		}
		
		clientID = initClientID;
		

		while (System.currentTimeMillis() < end) {

			int r = rand.nextInt(100);

			try (Socket clientSocket = new Socket(hostName, portNumber);
					PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
					BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) {

				if (r >= 0 && r < 25) {
					sendMessage(out, in);
				} else if (r >= 25 && r < 41) {
					peekMessageBySender(out, in);
				} else if (r >= 41 && r < 57) {
					peekMessageByQueue(out, in);
				} else if (r >= 57 && r < 70) {
					popMessageByQueue(out, in);
				} else if (r >= 70 && r < 83) {
					popMessageBySender(out, in);
				} else if (r >= 83 && r < 92) {
					createQueue(out, in);
				} else {
					deleteQueue(out, in);
				}

			} catch (IOException e) {
				System.err.println("Couldn't get I/O for the connection to " + hostName);
				System.exit(1);
			}
		}

	}

	// Proba : 0.25
	public static void sendMessage(PrintWriter out, BufferedReader in) throws IOException {
		int receiver = getClient(out, in);
		int queue = getQueue(out, in);
		logger.info(clientID + " sends a message to client=" + receiver + " to queue="+queue);
		//System.out.println("SEND MESSAGE : R: " + receiver + " | Q: " + queue);

		if (queue > 0) {
			if (receiver > 0) {
				out.println("SM#"+clientID+"#" + receiver + "#" + queue
						+ "#"+MESSAGE);
				// TODO get reply
				logger.info("Message sent by client: " + clientID);
			} else {
				logger.info("No client to send a message for client: " + clientID);
				//System.out.println("No client available");
			}
		} else {
			logger.info("No queue to send a message for client: " + clientID);
			//System.out.println("No queue available");
		}

	}

	// Proba : 0.16
	public static void peekMessageByQueue(PrintWriter out, BufferedReader in) throws IOException {
		int queue = getQueueWithMSG(out, in);

		out.println("PMQ#"+clientID+"#" + queue);
		String messagePeeked = in.readLine();
		logger.info(clientID+" peeked a message from queue="+queue+": " + messagePeeked);	
		//System.out.println("Message peeked from Queue "+queue+" :" + messagePeeked);
	}

	// Proba : 0.16
	public static void peekMessageBySender(PrintWriter out, BufferedReader in) throws IOException {
		int client = getClient(out, in);

		out.println("PMS#"+clientID+"#" + client);
		String messagePeeked = in.readLine();
		logger.info(clientID + " peeked a message from sender="+client+": " + messagePeeked);
		//System.out.println("Message peeked from Sender "+client+" :" + messagePeeked);
	}

	// Proba : 0.10 ==> 0.13
	public static void popMessageByQueue(PrintWriter out, BufferedReader in) throws IOException {
		int queue = getQueueWithMSG(out, in);
		out.println("GMQ#"+clientID+"#" + queue);
		String messageFromQueue = in.readLine();
		logger.info(clientID+" poped a message from queue="+queue+": " + messageFromQueue);
		//System.out.println("Message poped from Queue "+queue+" :" + messageFromQueue);
	}

	// Proba : 0.10 ==> 0.13
	public static void popMessageBySender(PrintWriter out, BufferedReader in) throws IOException {
		int sender = getClient(out, in);
		out.println("GMS#"+clientID+"#" + sender);
		String messageFromSender = in.readLine();
		logger.info(clientID+" peeked a message from sender="+sender+" :" + messageFromSender);
		//System.out.println("Message peeked from Sender "+sender+" :" + messageFromSender);

	}

	// Proba : 0.15 ==> 0.09
	public static void createQueue(PrintWriter out, BufferedReader in) throws IOException {
		out.println("CQ#"+clientID+"");
		logger.info(clientID + " created a queue");
		// TODO get reply
	}

	// Proba : 0.08
	public static void deleteQueue(PrintWriter out, BufferedReader in) throws IOException {
		int queue = getQueue(out, in);
		if (queue >= 0) {
			out.println("DQ#" + queue);
			// TODO get reply
			logger.info(clientID +" deleted a queue");
		} else {
			//System.out.println("No queue available for client ID=CLIENT_ID");
			logger.info("No queues to delete for client="+clientID);
		}
	}

	private static int getClient(PrintWriter out, BufferedReader in) throws IOException {
		out.println("LC#"+clientID+"");
		String clients = in.readLine();
		logger.info("Client list returned for client="+clientID);
		String[] clientList = clients.split("#");
		if (!clients.isEmpty()) {
			int receiver_index = rand.nextInt(clientList.length);
			return Integer.parseInt(clientList[receiver_index]);
		} else {
			logger.info("Client list empty for client="+clientID);
			return -1;
		}
	}

	private static int getQueue(PrintWriter out, BufferedReader in) throws IOException {
		out.println("LQ#"+clientID);
		String queues = in.readLine();
		logger.info("Queue list returned for client="+clientID);
		String[] queueList = queues.split("#");
		if (!queues.isEmpty()) {
			int queue_index = rand.nextInt(queueList.length);
			return Integer.parseInt(queueList[queue_index]);
		} else {
			logger.info("Queue list empty for client="+clientID);
			return -1;
		}
	}

	private static int getQueueWithMSG(PrintWriter out, BufferedReader in) throws IOException {
		out.println("LQWM#"+clientID);
		String queues = in.readLine();
		String[] queueList = queues.split("#");
		if (!queues.isEmpty()) {
			logger.info("Queues with messages returned for client"+clientID+", queue size:" + queueList.length);
			int queue_index = rand.nextInt(queueList.length);
			return Integer.parseInt(queueList[queue_index]);
		} else {
			logger.info("Queue list with messages empty for client="+clientID);
			return -1;
		}
	}
	
	private static int getClientID(PrintWriter out, BufferedReader in) throws IOException{
		out.println("ECHO");
		String clientID = in.readLine();
		logger.info("Client id returned : " + clientID);
		return Integer.parseInt(clientID);
	}

}
