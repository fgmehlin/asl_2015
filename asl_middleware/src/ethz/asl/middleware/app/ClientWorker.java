package ethz.asl.middleware.app;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

public class ClientWorker implements Runnable{
	private Socket clientSocket;
	private final BlockingQueue<QueryObject> inbox;
	private BufferedReader inStream;
	private QueryObject clientQuery;
	
	public ClientWorker(Socket socket, BlockingQueue<QueryObject> inbox){
		this.clientSocket = socket;
		this.inbox = inbox;
	}


	public void run(){
		try (PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
			 BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) 
		{
			String inputLine;
	
			
			 while ((inputLine = in.readLine()) != null) {
				// System.out.println(inputLine);
				// inbox.put(inputLine);
				/* if(inputLine.contains("#")){
					 clientQuery.setClientID(Integer.parseInt(inputLine.split("#")[1]));
				 }*/
				 
				 clientQuery = new QueryObject(inputLine, out);
				 
				 inbox.put(clientQuery);
				 
			 }
					
					
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			// for blocking queue
			e.printStackTrace();
		}
				
	}
		
	
}
