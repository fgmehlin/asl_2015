package ethz.asl.middleware.app;

import java.io.PrintWriter;
import java.util.concurrent.BlockingQueue;

public class OutboxProcessingThread implements Runnable{


	private final BlockingQueue<QueryObject> out;
	
	OutboxProcessingThread(BlockingQueue<QueryObject> out){
		this.out = out;
		
	}
	
	@Override
	public void run() {
		while(true){
			
			try {
				QueryObject query = out.take();
				
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
