package ethz.asl.middleware.app;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;

public class MiddleWare {

	private static int NUMBER_OF_INBOX_PROCESSORS;
	private static int NUMBER_OF_OUTBOX_PROCESSORS;
	
	public static void main(String[] args) {

		if(args.length != 5){
			System.err.println("Usage: java MiddleWare <id> <db_@> <port number> <#IN> <#OUT>");
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
		
		
		HashMap<Integer, Socket> mapClients = new HashMap<Integer, Socket>();
		ArrayList<Socket> connectedClients = new ArrayList<Socket>();

		String mwID = args[0];
		String db_ip = args[1];
		int portNumber = Integer.parseInt(args[2]);
		NUMBER_OF_INBOX_PROCESSORS = Integer.parseInt(args[3]);
		NUMBER_OF_OUTBOX_PROCESSORS = Integer.parseInt(args[4]);
		
		System.setProperty("mwID", mwID);
		
		ConnectionPoolManager dbManager = new ConnectionPoolManager(db_ip);
		
		//ExecutorService executor = Executors.newFixedThreadPool(30);
		
		
		
		BlockingQueue<QueryObject> in = new LinkedBlockingQueue<QueryObject>();
	    BlockingQueue<QueryObject> out = new LinkedBlockingQueue<QueryObject>();
	    
	    InboxProcessingThread inboxProcessor;
	    OutboxProcessingThread outboxProcessor;
	    
	    for (int i = 1; i <= NUMBER_OF_INBOX_PROCESSORS; i++) {
	    	inboxProcessor = new InboxProcessingThread(in, out, /*dbComm*/dbManager, i);
	    	(new Thread(inboxProcessor)).start();
		}
	    
	    for (int i = 1; i <= NUMBER_OF_OUTBOX_PROCESSORS; i++) {
	    	outboxProcessor = new OutboxProcessingThread(out, i);
	    	(new Thread(outboxProcessor)).start();
		}
	    
	    
	    ClientWorker cw = new ClientWorker(in, connectedClients);
	    
	    (new Thread(cw)).start();
	    
			boolean listening = true;
			
			try(ServerSocket serverSocket = new ServerSocket(portNumber)){
				System.out.println("Server listening");
				while(listening){
					//start one thread for each new client
					//new ClientWorker(serverSocket.accept(), in , out).start();
					//executor.execute(new ClientWorker(serverSocket.accept(), in));
					connectedClients.add(serverSocket.accept());
				}
				
			//	executor.shutdown();
			} catch (IOException e){
				System.err.println("Error with port "+portNumber+"\nUnable to listen.");
				e.printStackTrace();
				System.exit(-1);
			}
		
	}

}
