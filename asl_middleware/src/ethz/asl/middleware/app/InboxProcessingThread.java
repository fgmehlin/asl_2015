package ethz.asl.middleware.app;

import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;

public class InboxProcessingThread implements Runnable {

	private final BlockingQueue<QueryObject> out;
	private final BlockingQueue<QueryObject> in;
	private final DatabaseCommunication dbComm;
	private final int proc_id;
	private static Logger logger = Logger.getLogger(InboxProcessingThread.class.getName());
	private long startProcess;
	private long stopProcess;
	private MiddleWare middleware;

	InboxProcessingThread(BlockingQueue<QueryObject> in, BlockingQueue<QueryObject> out,
			ConnectionPoolManager poolManager, int proc_id) {
		this.in = in;
		this.out = out;
		this.dbComm = new DatabaseCommunication(poolManager);
		this.proc_id = proc_id;

	}

	@Override
	public void run() {

		while (true) {
			// Look into in queue, process

			try {
				QueryObject query = in.take();
				String command = query.getCommand();
				startProcess = System.currentTimeMillis();
				if(!command.contains("SM"))
					logger.info("[POPING_QUERY] " + command + " size(" + in.size() + ")");
				else 
					logger.info("[POPING_QUERY] " + "SM" + " size(" + in.size() + ")");

				String[] splittedCommand = command.split("#");
				String cmd = splittedCommand[0];
				int clientID = 0;

				
				if(cmd.equals("ECHO")){
					MiddleWare.clientIndex += 1;
					clientID = MiddleWare.clientIndex;
				}
				
				/*
				if (!cmd.equals("ECHO")) {
					clientID = Integer.parseInt(splittedCommand[1]);
				}
				
				

				int queueID = 0;
				int senderID = 0;
				boolean ok = false;
				String result = "";
				
				
				

				switch (cmd) {
				case "CQ":
					int queue = dbComm.createQueue();
					query.setReply(queue + "");
					break;
				case "DQ":
					queueID = Integer.parseInt(splittedCommand[1]);
					ok = dbComm.deleteQueue(queueID);
					query.setReply(ok + "");
					break;
				case "LC":
					query.setReply(dbComm.getClients(clientID));
					break;
				case "LCWM":
					result = dbComm.getClientsWithMessages(clientID);
					if (result.isEmpty())
						query.setReply("NONE");
					else
						query.setReply(result);
					break;
				case "LQ":
					result = dbComm.getQueues();
					if (result.isEmpty())
						query.setReply("NONE");
					else
						query.setReply(result);
					break;
				case "LQWM":
					result  = dbComm.getQueuesWithMessages(clientID);
					if (result.isEmpty())
						query.setReply("NONE");
					else
						query.setReply(result);
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
					query.setReply("" + ok);
					break;
				case "ECHO":
					System.out.println("Creation clientID");
					clientID = dbComm.createClient();
					query.setReply(clientID + "");
					System.out.println("CLIENT ID RETURNED : " + clientID);
					break;
				}
*/
				out.put(query);
				stopProcess = System.currentTimeMillis() - startProcess;
				if (query.getReply() != null)
					logger.info("[PUTTING_REPLY] " + stopProcess + " " + cmd + " " + query.getReply());
				else
					logger.info("[PUTTING_REPLY] " + stopProcess + " " + cmd + " EMPTY");

			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}

	}

}
