package ethz.asl.middleware.app;

import java.io.PrintWriter;

public class QueryObject {
	
	private String command;
	private String reply;
//	private ClientWorker client;
	private PrintWriter clientChannel;

	public QueryObject(String command, PrintWriter clientChannel){
		this.command = command;
		this.clientChannel = clientChannel;
	}
	
	public String getCommand() {
		return command;
	}

	public String getReply() {
		return reply;
	}

	public void setReply(String reply) {
		this.reply = reply;
	}

	public PrintWriter getClientChannel() {
		return clientChannel;
	}

	/*public ClientWorker getClient() {
	return client;
	}

	public void setClient(ClientWorker client) {
		this.client = client;
	}*/
	
}
