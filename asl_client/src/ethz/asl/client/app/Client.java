package ethz.asl.client.app;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Random;
import java.util.Scanner;

public class Client {
	
	static boolean running = true;
	
	private static Random rand;

	public static void main(String[] args) {
		if (args.length != 2) {
            System.err.println(
                "Usage: java Client <host name> <port number>");
            System.exit(1);
        }
		
		rand = new Random();
		
		long start = System.currentTimeMillis();
		long end = start + 60*1000;
		
		String hostName = args[0];
		int portNumber = Integer.parseInt(args[1]);
		
		System.out.println("hostname : " + hostName + ", port : " + portNumber );
		
		
		while(System.currentTimeMillis() < end){
			
			int r = rand.nextInt(100);
			
		
			try (
		            Socket clientSocket = new Socket(hostName, portNumber);
		            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
		            BufferedReader in = new BufferedReader(
		                new InputStreamReader(clientSocket.getInputStream()));
		        ){
				
				if(r >= 0 && r < 25){
					sendMessage(out, in);
				}else if(r >= 25 && r < 45){
					peekMessage(out, in);
				}else if(r >= 45 && r < 61){
					getMessageFromQueue(out, in);
				}else if(r >= 61 && r < 77){
					getMessageFromSender(out, in);
				}else if(r >= 77 && r < 85){
					createQueue(out, in);
				}else{
					deleteQueue(out, in);
				}
	
		
				
			}catch(IOException e){
				System.err.println("Couldn't get I/O for the connection to " + hostName);
		            System.exit(1);
			}
		}

	}
	
	// Proba : 0.25
	public static void sendMessage(PrintWriter out, BufferedReader in) throws IOException{
		int client = getClient(out, in);
		int queue = getQueue(out, in);
		
		if(queue > 0){
			if(client > 0){
				out.println("SM#CLIENT_ID#"+client+"#"+queue+"#UFIBFAJSdJASNDIBASZDVBOAUSVAUFIASDBOVUZASVDZVASDVAOUS");
			}else{
				System.out.println("No client available");
			}
		}else{
			System.out.println("No queue available");
		}
		
	}
	
	
	// Proba : 0.20
	public static void peekMessage(PrintWriter out, BufferedReader in) throws IOException{
		int queue = getQueue(out, in);
		
		out.println("PM#CLIENTID#"+queue);
		String messagePeeked = in.readLine();
	}
	
	//Proba : 0.16
	public static void getMessageFromQueue(PrintWriter out, BufferedReader in) throws IOException{
		int queue = getQueue(out, in);
		out.println("GMQ#CLIENTID#"+queue);
		String messageFromQueue = in.readLine();
	}
	
	//Proba : 0.16
	public static void getMessageFromSender(PrintWriter out, BufferedReader in) throws IOException{
		int sender = getClient(out, in);
		out.println("GMS#CLIENTID#"+sender);
		String messageFromSender = in.readLine();
		
	}
	
	//Proba : 0.15
	public static void createQueue(PrintWriter out, BufferedReader in) throws IOException{
		out.println("CQ#CLIENT_ID");
	}
	
	// Able to delete queue containing messages ?
	//Proba : 0.08
	public static void deleteQueue(PrintWriter out, BufferedReader in) throws IOException{
		int queue = getQueue(out, in);
		if(queue >=0){
			out.println("DQ#"+queue);
		}else{
			System.out.println("No queue available for client ID=CLIENT_ID");
		}
	}
	

	private static int getClient(PrintWriter out, BufferedReader in) throws IOException{
		out.println("LC#CLIENT_ID");
		String clients = in.readLine();
		if(!clients.isEmpty()){
			int receiver_index = rand.nextInt(clients.split("#").length-1);
			return receiver_index;
		}else{
			return -1;
		}
	}
	
	private static int getQueue(PrintWriter out, BufferedReader in) throws IOException{
		out.println("LQ#CLIENT_ID");
		String queues = in.readLine();
		if(!queues.isEmpty()){
			int queue_index = rand.nextInt(queues.split("#").length-1);
			return queue_index;
		}else{
			return -1;
		}
	}
	
	private static int getQueueWithMSG(PrintWriter out, BufferedReader in) throws IOException{
		out.println("LQWM#CLIENT_ID");
		String queues = in.readLine();
		if(!queues.isEmpty()){
			int queue_index = rand.nextInt(queues.split("#").length-1);
			return queue_index;
		}else{
			return -1;
		}
	}

}
