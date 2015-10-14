package ethz.asl.middleware.app;

import java.io.IOException;
import java.net.ServerSocket;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;


import java.util.concurrent.Executors;

public class MiddleWare {

	
	
	public static void main(String[] args) {

		if(args.length != 2){
			System.err.println("Usage: java MiddleWare <db_@> <port number>");
			System.exit(1);
		}
		/*InetAddress localAdd = null;
		try {
			localAdd = InetAddress.getLocalHost();
		} catch (UnknownHostException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}*/
		
		//System.out.println("host @:"+localAdd.getHostAddress()+" hostN:"+localAdd.getHostName());
		
		//PropertyConfigurator.configure("classpath:log4j.properties");

		
		String db_ip = args[0];
		int portNumber = Integer.parseInt(args[1]);
		
		DatabaseCommunication dbComm = new DatabaseCommunication(db_ip);
		
		ExecutorService executor = Executors.newFixedThreadPool(10);
		
		BlockingQueue<QueryObject> in = new LinkedBlockingQueue<QueryObject>();
	    BlockingQueue<QueryObject> out = new LinkedBlockingQueue<QueryObject>();
	    
	    InboxProcessingThread inboxProcessor = new InboxProcessingThread(in, out, dbComm);
	    OutboxProcessingThread outboxProcessor = new OutboxProcessingThread(out);
	    
	    (new Thread(inboxProcessor)).start();
	    (new Thread(outboxProcessor)).start();
	    
		
			
			boolean listening = true;
			
			try(ServerSocket serverSocket = new ServerSocket(portNumber)){
				System.out.println("Server listening");
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
