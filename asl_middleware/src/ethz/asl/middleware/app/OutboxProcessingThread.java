package ethz.asl.middleware.app;

import java.io.PrintWriter;
import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;

public class OutboxProcessingThread implements Runnable{


	private final BlockingQueue<QueryObject> out;
	private static Logger logger = Logger.getLogger(OutboxProcessingThread.class.getName());
	
	OutboxProcessingThread(BlockingQueue<QueryObject> out){
		this.out = out;
		logger.info("OutboxProcessingThread created");
	}
	
	@Override
	public void run() {
		while(true){
			
			try {
				QueryObject query = out.take();
				logger.info("Reply removed from outbox, size: " + out.size());
				
				PrintWriter clientChannel = query.getClientChannel();
				// forward to client
				clientChannel.println(query.getReply());
				
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			
		}
		
	}

}
