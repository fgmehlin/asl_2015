package ethz.asl.middleware.app;

import java.io.IOException;
import java.net.ServerSocket;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;


import java.util.concurrent.Executors;

public class MiddleWare {

	private static int NUMBER_OF_INBOX_PROCESSORS = 5;
	private static int NUMBER_OF_OUTBOX_PROCESSORS = 5;
	public static int clientIndex = 0;
	
	public static void main(String[] args) {

		if(args.length != 7){
			System.err.println("Usage: java MiddleWare <id> <db_@> <port number> <#IN> <#OUT> <poolSize> <nb_clients>");
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

		String mwID = args[0];
		String db_ip = args[1];
		int portNumber = Integer.parseInt(args[2]);
		NUMBER_OF_INBOX_PROCESSORS = Integer.parseInt(args[3]);
		NUMBER_OF_OUTBOX_PROCESSORS = Integer.parseInt(args[4]);
		int poolSize = Integer.parseInt(args[5]);
		int nbC = Integer.parseInt(args[6]);
		
		clientIndex = ((Integer.parseInt(mwID)-1)*nbC)+1;
		
		System.setProperty("mwID", mwID);
		
		ConnectionPoolManager dbManager = new ConnectionPoolManager(db_ip, poolSize);
		
		//ExecutorService executor = Executors.newFixedThreadPool(30);
		
		BlockingQueue<QueryObject> in = new LinkedBlockingQueue<QueryObject>();
	    BlockingQueue<QueryObject> out = new LinkedBlockingQueue<QueryObject>();
	    
	    InboxProcessingThread inboxProcessor;
	    OutboxProcessingThread outboxProcessor;
	    
	    for (int i = 1; i <= NUMBER_OF_INBOX_PROCESSORS; i++) {
	    	inboxProcessor = new InboxProcessingThread(Integer.parseInt(mwID), nbC, in, out, /*dbComm*/dbManager, i);
	    	(new Thread(inboxProcessor)).start();
		}
	    
	    for (int i = 1; i <= NUMBER_OF_OUTBOX_PROCESSORS; i++) {
	    	outboxProcessor = new OutboxProcessingThread(out, i);
	    	(new Thread(outboxProcessor)).start();
		}
	    
	   // OutboxProcessingThread outboxProcessor = new OutboxProcessingThread(out);
	    
	    
	  //  (new Thread(outboxProcessor)).start();
	    
		
			
			boolean listening = true;
			
			try(ServerSocket serverSocket = new ServerSocket(portNumber)){
				System.out.println("Server listening");
				while(listening){
					//start one thread for each new client
					//new ClientWorker(serverSocket.accept(), in , out).start();
					//executor.execute(new ClientWorker(serverSocket.accept(), in));
					(new Thread(new ClientWorker(serverSocket.accept(), in))).start();
				}
				
			//	executor.shutdown();
			} catch (IOException e){
				System.err.println("Error with port "+portNumber+"\nUnable to listen.");
				e.printStackTrace();
				System.exit(-1);
			}
		
	}

}
