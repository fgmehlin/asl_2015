package ethz.asl.middleware.app;

import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;

public class InboxProcessingThread implements Runnable{

	private final BlockingQueue<QueryObject> out;
	private final BlockingQueue<QueryObject> in;
	private final DatabaseCommunication dbComm;
	private final int proc_id;
	private static Logger logger = Logger.getLogger(InboxProcessingThread.class.getName());
	
	InboxProcessingThread(BlockingQueue<QueryObject> in, BlockingQueue<QueryObject> out, DatabaseCommunication dbComm, int proc_id){
		this.in = in;
		this.out = out;
		this.dbComm = dbComm;
		this.proc_id = proc_id;
		logger.info("InboxProcessingThread No"+proc_id+" created");
		
	}
	
	@Override
	public void run() {
		while(true){
			// Look into in queue, process
			
			try {
				QueryObject query = in.take();
				String command = query.getCommand();
				logger.info("IP["+proc_id+"] Query with command "+command+" removed from inbox, size: " + in.size());
				
				
				
				String[] splittedCommand = command.split("#");
				String cmd = splittedCommand[0];
				int clientID = 0;
				
				if(!cmd.equals("ECHO")){
					clientID = Integer.parseInt(splittedCommand[1]);
				}
				
				int queueID = 0;
				int senderID = 0;
				boolean ok = false;
				
				switch(cmd){
					case "CQ":
						dbComm.createQueue();
						break;
					case "DQ":
						queueID = Integer.parseInt(splittedCommand[1]);
						ok = dbComm.deleteQueue(queueID);
						query.setReply("Queue="+queueID+" deletion status :"+ok);
						break;
					case "LC":
						query.setReply(dbComm.getClients(clientID));
						break;
					case "LCWM":
						query.setReply(dbComm.getClientsWithMessages(clientID));
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
						query.setReply(dbComm.peekMessageBySender(clientID, senderID));
						break;
					case "GMQ":
						queueID = Integer.parseInt(splittedCommand[2]);
						query.setReply(dbComm.popMessageByQueue(clientID, queueID));
						break;
					case "GMS":
						senderID = Integer.parseInt(splittedCommand[2]);
						query.setReply(dbComm.popMessageBySender(clientID, senderID));
						break;
					case "SM":
						int receiverID = Integer.parseInt(splittedCommand[2]);
						queueID = Integer.parseInt(splittedCommand[3]);
						String message = splittedCommand[4];
						ok = dbComm.sendMessage(clientID, receiverID, queueID, message);
						query.setReply("Message(receiver="+receiverID+", queue="+queueID+") send status="+ok);
						break;
					case "ECHO":
						clientID = dbComm.createClient();
						query.setReply(clientID+"");
						break;
				}
				
				
				out.put(query);
				logger.info("IP["+proc_id+"] Reply "+query.getReply()+" added to outbox, size: " + out.size());
				
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		
		
		
	}

}
