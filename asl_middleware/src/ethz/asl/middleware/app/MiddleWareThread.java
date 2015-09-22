package ethz.asl.middleware.app;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

public class MiddleWareThread{
	private Socket clientSocket;
	/*private final BlockingQueue<String> outbox;
	private final BlockingQueue<String> inbox;*/
	private BufferedReader inStream;
	
	public MiddleWareThread(Socket socket){
		this.clientSocket = socket;
		System.out.println("Client connected");
		/*outbox = new LinkedBlockingQueue<String>();
		inbox = new LinkedBlockingQueue<String>();*/
		
		
	}

	public void start() {
		new Thread(new Runnable(){
			public void run(){
				try (PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
					 BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) 
				{
					String inputLine;
					
					System.out.println("waiting");
					 while ((inputLine = in.readLine()) != null) {
						 System.out.println(inputLine);
					 }
					
					
				} catch (IOException e) {
					e.printStackTrace();
				}
				
				System.out.println("end of run");
			}
		}).start();
	}
	

	
}
