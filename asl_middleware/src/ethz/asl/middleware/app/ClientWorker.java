package ethz.asl.middleware.app;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.net.Socket;
import java.util.ArrayList;
import java.util.concurrent.BlockingQueue;

public class ClientWorker implements Runnable{
	//private Socket clientSocket;
	private final BlockingQueue<QueryObject> inbox;
	private ArrayList<Socket> connectedClients;
	private BufferedReader inStream;
	private QueryObject clientQuery;
	
	public ClientWorker(BlockingQueue<QueryObject> inbox, ArrayList<Socket> connectedClients){
		//this.clientSocket = socket;
		this.connectedClients = connectedClients;
		this.inbox = inbox;
	}


	public void run(){
		
		int i = 0;
		int size = connectedClients.size();
		Socket clientSocket;
		int bytesEstimate = 0;
		
		InputStream clientStream = null;
		
		while(true){
			size = connectedClients.size();
			clientSocket = connectedClients.get(i);
			
			
			
			if(i>=size-1)
				i = 0;
			else
				i++;
			
			
		
			
		}
		
//		
//		try (PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
//			 BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) 
//		{
//			String inputLine;
//	
//			
//			 while ((inputLine = in.readLine()) != null) {
//				 clientQuery = new QueryObject(inputLine, out);
//				 inbox.put(clientQuery);
//			 }
//					
//					
//		} catch (IOException e) {
//			e.printStackTrace();
//		} catch (InterruptedException e) {
//			// for blocking queue
//			e.printStackTrace();
//		}
				
	}
		
	
}
