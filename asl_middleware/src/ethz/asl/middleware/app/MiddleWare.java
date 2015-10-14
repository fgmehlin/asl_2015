package ethz.asl.middleware.app;

import java.io.IOException;
import java.net.ServerSocket;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;


import java.util.concurrent.Executors;

public class MiddleWare {

	private static final int NUMBER_OF_INBOX_PROCESSORS = 5;
	
	public static void main(String[] args) {

		if(args.length != 2){
			System.err.println("Usage: java MiddleWare <db_@> <port number>");
			System.exit(1);
		}
		
		
		Runtime.getRuntime().addShutdownHook(new Thread()
        {
            @Override
            public void run()
            {
                System.out.println("Server shutting down");
            }
        });

		
		String db_ip = args[0];
		int portNumber = Integer.parseInt(args[1]);
		
		//DatabaseCommunication dbComm = new DatabaseCommunication(db_ip);
		
		ConnectionPoolManager dbManager = new ConnectionPoolManager(db_ip);
		
		ExecutorService executor = Executors.newFixedThreadPool(10);
		
		BlockingQueue<QueryObject> in = new LinkedBlockingQueue<QueryObject>();
	    BlockingQueue<QueryObject> out = new LinkedBlockingQueue<QueryObject>();
	    
	    InboxProcessingThread inboxProcessor;
	    
	    for (int i = 1; i <= NUMBER_OF_INBOX_PROCESSORS; i++) {
	    	inboxProcessor = new InboxProcessingThread(in, out, /*dbComm*/dbManager, i);
	    	(new Thread(inboxProcessor)).start();
		}
	    
	    OutboxProcessingThread outboxProcessor = new OutboxProcessingThread(out);
	    
	    
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
