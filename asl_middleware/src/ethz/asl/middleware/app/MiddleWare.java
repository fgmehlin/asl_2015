package ethz.asl.middleware.app;

import java.io.IOException;
import java.net.ServerSocket;

public class MiddleWare {

	public static void main(String[] args) {

		if(args.length != 1){
			System.err.println("Usage: java MiddleWare <port number>");
			System.exit(1);
		}
		
			int portNumber = Integer.parseInt(args[0]);
			boolean listening = true;
			
			try(ServerSocket serverSocket = new ServerSocket(portNumber)){
				while(listening){
					//start one thread for each new client
					new MiddleWareThread(serverSocket.accept()).start();
				}
			} catch (IOException e){
				System.err.println("Error with port "+portNumber+"\nUnable to listen.");
				e.printStackTrace();
				System.exit(-1);
			}
		
	}

}
