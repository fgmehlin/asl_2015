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
	
	private static final String MESSAGE_2000 = "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";

	static boolean running = true;

	private static Random rand;

	private static Logger logger;
	private static long startQuery;
	private static long responseTime;
	private static int workLoad;
	private static int peer;
	private static int noOfClients;
	private static int personalQueueId;
	private static int messType;
	private static String textSend;

	public static void main(String[] args) {
		if (args.length != 6) {
			System.err
					.println("Usage: java Client <host name> <port number> <duration> <work_load> <number_of_clients> <mess_type>");
			System.exit(1);
		}

		int[] pi = new int[12];

		System.out.println("Client started");
		int initClientID = -99;

		rand = new Random();

		String hostName = args[0];
		int portNumber = Integer.parseInt(args[1]);
		int duration = Integer.parseInt(args[2]);
		workLoad = Integer.parseInt(args[3]);
		noOfClients = Integer.parseInt(args[4]);
		messType = Integer.parseInt(args[5]);
		
		if(messType == 1){
			textSend = MESSAGE;
		}else{
			textSend = MESSAGE_2000;
		}

		long start = System.currentTimeMillis();
		long end = start + duration * 1000;


		try (Socket clientSocket = new Socket(hostName, portNumber);
				PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
				BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) {

			System.out.println("Requesting clientID");
			initClientID = getClientID(out, in);
			System.out.println("Got clientID(" + initClientID + ")");

			clientID = initClientID;
			System.setProperty("clientid", clientID + "");
			logger = Logger.getLogger(Client.class.getName());

			
			personalQueueId = createQueue(out, in); // Each client creates a queue in the beginning
			
			if (workLoad == 1) { // Standard "random" workload
				pi[0] = 0;
				pi[1] = 30;
				pi[2] = 45;
				pi[3] = 60;
				pi[4] = 78;
				pi[5] = 96;
				pi[6] = 97;
			} else if (workLoad == 2 || workLoad == 3) { // Write & Read workload
				pi[0] = 0;
				pi[1] = 100;
				pi[2] = 100;
				pi[3] = 100;
				pi[4] = 100;
				pi[5] = 100;
				pi[6] = 100;
			} else if (workLoad == 4) { // 1-to-1 mapping, no probabilities
				if (clientID > noOfClients / 2) {
					peer = (noOfClients / 2) - (noOfClients % clientID);
				} else {
					peer = clientID + (noOfClients / 2);
				}
				System.out.println("My clientID = " + clientID+" and my peer = " +peer);
				Thread.sleep(10000);
			} else {
				System.err.println("Work load not defined");
				System.exit(-1);
			}
			

			while (System.currentTimeMillis() < end) {

				if (workLoad != 4) {

					if(workLoad == 3 && ((System.currentTimeMillis() - start) > ((end-start)/2))){
						switchWriteToRead(pi);
					}
					
					
					int r = rand.nextInt(100);

					if (r >= pi[0] && r < pi[1]) { // p(SM) = 0.30
						sendMessage(out, in);
					} else if (r >= pi[1] && r < pi[2]) { // p(PMBS) = 0.15
						peekMessageBySender(out, in);
					} else if (r >= pi[2] && r < pi[3]) { // P(PMBQ) = 0.15
						peekMessageByQueue(out, in);
					} else if (r >= pi[3] && r < pi[4]) { // P(GMQ) = 0.18
						popMessageByQueue(out, in);
					} else if (r >= pi[4] && r < pi[5]) { // P(GMS) = 0.18
						popMessageBySender(out, in);
					} else if (r >= pi[5] && r < pi[6]) { // P(CQ) = 0.01
						createQueue(out, in);
					} else { // P(DQ) = 0.03
						deleteQueue(out, in);
					}

				}else{
					sendMessage(out, in);
					peekMessageBySender(out, in);
					popMessageBySender(out, in);
				}
				out.flush();
			}

		} catch (IOException e) {
			System.err.println("Couldn't get I/O for the connection to " + hostName);
			System.exit(1);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public static void sendMessage(PrintWriter out, BufferedReader in) throws IOException {
		int receiver = -1;
		int queue = -1;
		if(workLoad != 4)
		{
			receiver = getClient(out, in);
			queue = getQueue(out, in);
		}else{
			receiver = peer;
			queue = personalQueueId;
		}
		
		
		if (queue > 0) {
			if (receiver > 0) {
				//logger.info("[QUERY][SM] client(" + receiver + ") queue(" + queue + ")");
				startQuery = System.currentTimeMillis();

				out.println("SM#" + clientID + "#" + receiver + "#" + queue + "#" + textSend);
				String sendStatus = in.readLine();

				responseTime = System.currentTimeMillis() - startQuery;
				logger.info("[RESPONSE][SM] " + responseTime + " [" + sendStatus + "]");
			} else {
			}
		} else {
		}

	}

	public static void peekMessageByQueue(PrintWriter out, BufferedReader in) throws IOException {
		int queue = getQueueWithMSG(out, in);
		
		if(queue != -1){
		
			//logger.info("[QUERY][PMQ] queue(" + queue + ")");
			startQuery = System.currentTimeMillis();
			out.println("PMQ#" + clientID + "#" + queue);
			String messagePeeked = in.readLine();
			responseTime = System.currentTimeMillis() - startQuery;
			if (messagePeeked == null || messagePeeked.equals("null")) {
				logger.info("[RESPONSE][PMQ] " + responseTime + " [EMPTY]");
			} else {
				logger.info("[RESPONSE][PMQ] " + responseTime + " [" + messagePeeked.length() + "]");
			}
		}
	}

	public static void peekMessageBySender(PrintWriter out, BufferedReader in) throws IOException {
		int sender = -1;
		
		if(workLoad != 4)
		{
			sender =  getClientWithMSG(out, in);
		}else{
			sender = peer;
		}
		
		if(sender != -1){
			//logger.info("[QUERY][PMS] sender(" + sender + ")");
			startQuery = System.currentTimeMillis();
			out.println("PMS#" + clientID + "#" + sender);
			String messagePeeked = in.readLine();
			responseTime = System.currentTimeMillis() - startQuery;
	
			if (messagePeeked == null || messagePeeked.equals("null")) {
				logger.info("[RESPONSE][PMS] " + responseTime + " [EMPTY]");
			} else {
				logger.info("[RESPONSE][PMS] " + responseTime + " [" + messagePeeked.length() + "]");
			}
		}

	}

	public static void popMessageByQueue(PrintWriter out, BufferedReader in) throws IOException {
		int queue = getQueueWithMSG(out, in);
		
		if(queue != -1){
		
			//logger.info("[QUERY][GMQ] queue(" + queue + ")");
			startQuery = System.currentTimeMillis();
	
			out.println("GMQ#" + clientID + "#" + queue);
			String messageFromQueue = in.readLine();
	
			responseTime = System.currentTimeMillis() - startQuery;
			if (messageFromQueue == null || messageFromQueue.equals("null")) {
				logger.info("[RESPONSE][GMQ] " + responseTime + " [EMPTY]");
			} else {
				logger.info("[RESPONSE][GMQ] " + responseTime + " [" + messageFromQueue.length() + "]");
			}
		}

	}

	public static void popMessageBySender(PrintWriter out, BufferedReader in) throws IOException {
		int sender = -1;
	
		if(workLoad != 4)
		{
			sender =  getClientWithMSG(out, in);
		}else{
			sender = peer;
		}
		
		if(sender != -1){
			//logger.info("[QUERY][GMS] sender(" + sender + ")");
			startQuery = System.currentTimeMillis();
	
			out.println("GMS#" + clientID + "#" + sender);
			String messageFromSender = in.readLine();
			responseTime = System.currentTimeMillis() - startQuery;
	
			if (messageFromSender == null || messageFromSender.equals("null")) {
				logger.info("[RESPONSE][GMS] " + responseTime + " [EMPTY]");
			} else {
				logger.info("[RESPONSE][GMS] " + responseTime + " [" + messageFromSender.length() + "]");
			}
		}


	}

	public static int createQueue(PrintWriter out, BufferedReader in) throws IOException {
		//logger.info("[QUERY][CQ]");
		startQuery = System.currentTimeMillis();

		out.println("CQ#" + clientID + "");
		String queueid = in.readLine();

		responseTime = System.currentTimeMillis() - startQuery;
		
		logger.info("[RESPONSE][CQ] " + responseTime + " [" + queueid + "]");
		
		return Integer.parseInt(queueid);
	}

	public static void deleteQueue(PrintWriter out, BufferedReader in) throws IOException {
		int queueid = getQueue(out, in);
		if (queueid >= 0) {
			//logger.info("[QUERY][DQ] queue(" + queueid + ")");
			startQuery = System.currentTimeMillis();

			out.println("DQ#" + queueid);
			String response = in.readLine();

			responseTime = System.currentTimeMillis() - startQuery;
			logger.info("[RESPONSE][DQ] " + responseTime + " [" + response + "]");

		} else {
		}
	}

	private static int getClient(PrintWriter out, BufferedReader in) throws IOException {
		return rand.nextInt(noOfClients)+1;
		
//		logger.info("[QUERY][LC]");
//		startQuery = System.currentTimeMillis();
//
//		out.println("LC#" + clientID + "");
//		String clients = in.readLine();
//
//		responseTime = System.currentTimeMillis() - startQuery;
//
//		String[] clientList = clients.split("#");
//		logger.info("[RESPONSE][LC] " + responseTime + " [" + clientList.length + "]");
//
//		if (!clients.isEmpty()) {
//			int receiver_index = rand.nextInt(clientList.length);
//			return Integer.parseInt(clientList[receiver_index]);
//		} else {
//			return -1;
//		}
	}

	private static int getClientWithMSG(PrintWriter out, BufferedReader in) throws IOException {
		//logger.info("[QUERY][LCWM]");
		startQuery = System.currentTimeMillis();

		out.println("LCWM#" + clientID + "");
		String clients = in.readLine();

		responseTime = System.currentTimeMillis() - startQuery;

		if (!clients.equals("NONE") ) {
			String[] clientList = clients.split("#");
			logger.info("[RESPONSE][LCWM] " + responseTime + " [" + clientList.length + "]");
			
			int receiver_index = rand.nextInt(clientList.length);
			return Integer.parseInt(clientList[receiver_index]);
		} else {
			logger.info("[RESPONSE][LCWM] " + responseTime + " [" + clients + "]");
			return -1;
		}
	}

	private static int getQueue(PrintWriter out, BufferedReader in) throws IOException {
		//logger.info("[QUERY][LQ]");
		startQuery = System.currentTimeMillis();

		out.println("LQ#" + clientID);
		String queues = in.readLine();

		responseTime = System.currentTimeMillis() - startQuery;

		if (!queues.equals("NONE")) {
			String[] queueList = queues.split("#");
			logger.info("[RESPONSE][LQ] " + responseTime + " [" + queueList.length + "]");
			
			int queue_index = rand.nextInt(queueList.length);
			return Integer.parseInt(queueList[queue_index]);
		} else {
			logger.info("[RESPONSE][LQ] " + responseTime + " [" + queues + "]");
			return -1;
		}
	}

	private static int getQueueWithMSG(PrintWriter out, BufferedReader in) throws IOException {
		//logger.info("[QUERY][LQWM]");
		startQuery = System.currentTimeMillis();

		out.println("LQWM#" + clientID);
		String queues = in.readLine();

		responseTime = System.currentTimeMillis() - startQuery;

		

		if (!queues.equals("NONE")) {
			String[] queueList = queues.split("#");
			logger.info("[RESPONSE][LQWM] " + responseTime + " [" + queueList.length + "]");
			int queue_index = rand.nextInt(queueList.length);
			return Integer.parseInt(queueList[queue_index]);
		} else {
			logger.info("[RESPONSE][LQWM] " + responseTime + " [" + queues + "]");
			return -1;
		}
	}

	private static int getClientID(PrintWriter out, BufferedReader in) throws IOException {
		out.println("ECHO");
		String clientID = in.readLine();
		return Integer.parseInt(clientID);
	}
	
	private static int[] switchWriteToRead(int[] pi){
		pi[0] = -1;
		pi[1] = 0;
		pi[2] = 25;
		pi[3] = 50;
		pi[4] = 75;
		pi[5] = 100;
		pi[6] = 101;
		
		return pi;
	}

}
