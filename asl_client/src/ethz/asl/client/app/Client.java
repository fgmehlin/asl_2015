package ethz.asl.client.app;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Scanner;

public class Client {
	
	static boolean running = true;

	public static void main(String[] args) {
		if (args.length != 2) {
            System.err.println(
                "Usage: java Client <host name> <port number>");
            System.exit(1);
        }
		
		String hostName = args[0];
		int portNumber = Integer.parseInt(args[1]);
		
		System.out.println("hostname : " + hostName + ", port : " + portNumber );
		
		try (
	            Socket clientSocket = new Socket(hostName, portNumber);
	            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
	            BufferedReader in = new BufferedReader(
	                new InputStreamReader(clientSocket.getInputStream()));
	        ){
			
			Scanner s = new Scanner(System.in);
			String command = "";
			System.out.println("Type \"list cmd\" to display the list of commands");
			
			String[] command_tokens;
			while(running){
				command = s.nextLine();
				//System.out.println("Wrote : " + command);
				command_tokens = command.split(" ");
				
				switch(command_tokens[0]){
					case "list":
						if(command_tokens[1].equals("-q")){
							// list queues where msg for client are waiting
							
							out.println("list queues");
						}else if(command_tokens[1].equals("-c")){
							// list clients
							out.println("list clients");
						}else if(command_tokens[1].equals("-cmd")){
							System.out.println("list cmds");
						}else{
							//error
							System.err.println("list error");
						}
						break;
					case "q":
						if(command_tokens[1].equals("-create")){
							// create a queue and return <queue_id> to client
							out.println("create queue");
						}else if(command_tokens[1].equals("-delete") && command_tokens.length==3){
							int q_id = Integer.parseInt(command_tokens[2]);
							out.println("delete queue id="+q_id);
						}else{
							//error
							System.err.println("q error");
						}
						break;
					case "getmsg":
						if(command_tokens[1].equals("-fromq") && command_tokens.length==3){
							// create a queue and return <queue_id> to client
							int q_id = Integer.parseInt(command_tokens[2]);
							out.println("get msg from queue id=" + q_id);
						}else if(command_tokens[1].equals("-fromc") && command_tokens.length==3){
							// delete a queue and return confirmation
							int c_id = Integer.parseInt(command_tokens[2]);
							out.println("get msg from client id=" + c_id);
						}else{
							//error
							System.err.println("getmsg error");
						}
						break;
					case "sndmsg":
						if(command_tokens.length >= 4){
							int client_id = Integer.parseInt(command_tokens[1]);
							String msg = command_tokens[command_tokens.length-1];
							String test = "send msg=\""+msg+"\" to client id="+client_id+" to queues ids=";
							int[] queues = new int[command_tokens.length-3];
							for (int i = 0; i < queues.length; i++) {
								queues[i] = Integer.parseInt(command_tokens[i+2]);
								test += queues[i] + " ";
							}
							out.println(test);
							
							//snd_msg
						}else{
							//error
							System.err.println("sndmsg error");
						}
						break;
					default:
						System.err.println("Bad command");
						break;
				}
			}
			
		}catch(IOException e){
			System.err.println("Couldn't get I/O for the connection to " +
	                hostName);
	            System.exit(1);
		}catch (NumberFormatException e) {
			System.err.println("Argument parsing exception. type list -cmd for command list");
		}

	}

}
