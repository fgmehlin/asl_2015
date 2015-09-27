package ethz.asl.middleware.app;

import java.util.concurrent.BlockingQueue;

public class InboxProcessingThread implements Runnable{

	private final BlockingQueue<QueryObject> out;
	private final BlockingQueue<QueryObject> in;
	
	InboxProcessingThread(BlockingQueue<QueryObject> in, BlockingQueue<QueryObject> out){
		this.in = in;
		this.out = out;
		
	}
	
	@Override
	public void run() {
		while(true){
			// Look into in queue, process
			
			try {
				QueryObject query = in.take();
				String command = query.getCommand();
				
				// process cmd
				String reply = "reply madafaka";
				query.setReply(reply);
				
				out.put(query);
				
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		
		
		
	}

}
