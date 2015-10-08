package ethz.asl.middleware.app;

import java.io.IOException;
import java.net.ServerSocket;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import java.util.concurrent.Executors;

public class MiddleWare {

	
	
	
	public static void main(String[] args) {

		if(args.length != 1){
			System.err.println("Usage: java MiddleWare <port number>");
			System.exit(1);
		}
		
		//PropertyConfigurator.configure("classpath:log4j.properties");

		
		
		
		
		int portNumber = Integer.parseInt(args[0]);
		
		DatabaseCommunication dbComm = new DatabaseCommunication();
		
		ExecutorService executor = Executors.newFixedThreadPool(10);
		
		BlockingQueue<QueryObject> in = new LinkedBlockingQueue<QueryObject>();
	    BlockingQueue<QueryObject> out = new LinkedBlockingQueue<QueryObject>();
	    
	    InboxProcessingThread inboxProcessor = new InboxProcessingThread(in, out, dbComm);
	    OutboxProcessingThread outboxProcessor = new OutboxProcessingThread(out);
	    
	    (new Thread(inboxProcessor)).start();
	    (new Thread(outboxProcessor)).start();
	    
		
			
			boolean listening = true;
			
			try(ServerSocket serverSocket = new ServerSocket(portNumber)){
				while(listening){
					//start one thread for each new client
					//new ClientWorker(serverSocket.accept(), in , out).start();
					executor.execute(new ClientWorker(serverSocket.accept(), in));
				}
				
				executor.shutdown();
			} catch (IOException e){
				System.err.println("Error with port "+portNumber+"\nUnable to listen.");
				e.printStackTrace();
				System.exit(-1);
			}
		
	}

}
