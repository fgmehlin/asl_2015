package ethz.asl.client.communication;

import java.util.LinkedList;
import java.util.Queue;

public class Outbox {

	Queue<Message> outboxQueue;
	
	public Outbox(){
		outboxQueue = new LinkedList<Message>();
		
	}
	
	public void sendMessage(int sender_id, int receiver_id, int queue_id, String message){
		
		
		
	}
	
	
}
