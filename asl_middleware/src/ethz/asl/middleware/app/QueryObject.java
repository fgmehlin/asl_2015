package ethz.asl.middleware.app;

import java.io.PrintWriter;

public class QueryObject {
	
	private String command;
	private String reply;
	private int clientID;
	private int errorType;
	private String errorMessage;
	private long startTime;
	

	public long getStartTime() {
		return startTime;
	}

	public void setStartTime(long startTime) {
		this.startTime = startTime;
	}

	private PrintWriter clientChannel;
	

	public QueryObject(String command, PrintWriter clientChannel){
		this.command = command;
		this.clientChannel = clientChannel;
	}
	
	public int getClientID() {
		return clientID;
	}

	public void setClientID(int clientID) {
		this.clientID = clientID;
	}

	public void setCommand(String command) {
		this.command = command;
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
	
	public int getErrorType() {
		return errorType;
	}

	public void setErrorType(int errorType) {
		this.errorType = errorType;
	}
	
	public String getErrorMessage(){
		return errorMessage;
	}
	
	public void setErrorMessage(String errorMessage){
		this.errorMessage = errorMessage;
	}

	/*public ClientWorker getClient() {
	return client;
	}

	public void setClient(ClientWorker client) {
		this.client = client;
	}*/
	
}
