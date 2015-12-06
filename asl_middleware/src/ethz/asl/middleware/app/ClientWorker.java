package ethz.asl.middleware.app;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class ClientWorker implements Runnable {
	private Socket clientSocket;
	private final DatabaseCommunication dbComm;

	public ClientWorker(Socket socket, ConnectionPoolManager poolManager) {
		this.clientSocket = socket;
		this.dbComm = new DatabaseCommunication(poolManager);
	}

	public void run() {
		try (PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
				BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) {
			String inputLine;

			while ((inputLine = in.readLine()) != null) {

				//query = new QueryObject(inputLine, out);

				// inbox.put(clientQuery);

				
				String command = inputLine;


				String[] splittedCommand = command.split("#");
				String cmd = splittedCommand[0];
				int clientID = 0;

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
					out.println(queue+"");
					break;
				case "DQ":
					queueID = Integer.parseInt(splittedCommand[1]);
					ok = dbComm.deleteQueue(queueID);
					out.println(ok+"");
					break;
				case "LC":
					out.println(dbComm.getClients(clientID));
					break;
				case "LCWM":
					result = dbComm.getClientsWithMessages(clientID);
					if (result.isEmpty())
						out.println("NONE");
					else
						out.println(result);
					break;
				case "LQ":
					result = dbComm.getQueues();
					if (result.isEmpty())
						out.println("NONE");
					else
						out.println(result);
					break;
				case "LQWM":
					result = dbComm.getQueuesWithMessages(clientID);
					if (result.isEmpty())
						out.println("NONE");
					else
						out.println(result);
					break;
				case "PMQ":
					queueID = Integer.parseInt(splittedCommand[2]);
					out.println(dbComm.peekMessageByQueue(clientID, queueID));
					break;
				case "PMS":
					senderID = Integer.parseInt(splittedCommand[2]);
					out.println(dbComm.peekMessageBySender(clientID, senderID));
					break;
				case "GMQ":
					queueID = Integer.parseInt(splittedCommand[2]);
					out.println(dbComm.popMessageByQueue(clientID, queueID));
					break;
				case "GMS":
					senderID = Integer.parseInt(splittedCommand[2]);
					out.println(dbComm.popMessageBySender(clientID, senderID));
					break;
				case "SM":
					int receiverID = Integer.parseInt(splittedCommand[2]);
					queueID = Integer.parseInt(splittedCommand[3]);
					String message = splittedCommand[4];
					ok = dbComm.sendMessage(clientID, receiverID, queueID, message);
					out.println(ok+"");
					break;
				case "ECHO":
					System.out.println("Creation clientID");
					clientID = dbComm.createClient();
					out.println(clientID + "");
					System.out.println("CLIENT ID RETURNED : " + clientID);
					break;
				}
				out.flush();

			}

		} catch (IOException e) {
			e.printStackTrace();
		}

	}

}
