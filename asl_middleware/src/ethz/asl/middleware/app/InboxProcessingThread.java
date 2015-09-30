package ethz.asl.middleware.app;

import java.util.concurrent.BlockingQueue;

public class InboxProcessingThread implements Runnable{

	private final BlockingQueue<QueryObject> out;
	private final BlockingQueue<QueryObject> in;
	private final DatabaseCommunication dbComm;
	
	InboxProcessingThread(BlockingQueue<QueryObject> in, BlockingQueue<QueryObject> out, DatabaseCommunication dbComm){
		this.in = in;
		this.out = out;
		this.dbComm = dbComm;
		
	}
	
	@Override
	public void run() {
		while(true){
			// Look into in queue, process
			
			try {
				QueryObject query = in.take();
				String command = query.getCommand();
				
				String[] splittedCommand = command.split("#");
				String cmd = splittedCommand[0];
				int clientID = Integer.parseInt(splittedCommand[1]);
				int queueID = 0;
				int senderID = 0;
				
				switch(cmd){
					case "CQ":
						dbComm.createQueue(clientID);
						break;
					case "DQ":
						break;
					case "LC":
						query.setReply(dbComm.getClients(clientID));
						break;
					case "LQ":
						query.setReply(dbComm.getQueues());
						break;
					case "LQWM":
						query.setReply(dbComm.getQueuesWithMessages(clientID));
						break;
					case "PMQ":
						queueID = Integer.parseInt(splittedCommand[2]);
						query.setReply(dbComm.peekMessageByQueue(clientID, queueID));
						break;
					case "PMS":
						senderID = Integer.parseInt(splittedCommand[2]);
						query.setReply(dbComm.peekMessageByQueue(clientID, senderID));
						break;
					case "GMQ":
						queueID = Integer.parseInt(splittedCommand[2]);
						query.setReply(dbComm.popMessageByQueue(clientID, queueID));
						break;
					case "GMS":
						senderID = Integer.parseInt(splittedCommand[2]);
						query.setReply(dbComm.popMessageByQueue(clientID, senderID));
						break;
					case "SM":
						int receiverID = Integer.parseInt(splittedCommand[2]);
						queueID = Integer.parseInt(splittedCommand[3]);
						String message = splittedCommand[4];
						dbComm.sendMessage(clientID, receiverID, queueID, message);
						break;
				}
				
				
				out.put(query);
				
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		
		
		
	}

}
