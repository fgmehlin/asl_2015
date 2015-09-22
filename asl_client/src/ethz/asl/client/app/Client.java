package ethz.asl.client.app;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class Client {

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
			
			
			int i = 0;
			while(true){
				System.out.println("Local try n°" + i);
				out.println("Try n°" + i);
				i++;
				Thread.sleep(1000);
			}
			
		}catch(IOException e){
			System.err.println("Couldn't get I/O for the connection to " +
	                hostName);
	            System.exit(1);
		} catch (InterruptedException e) {
			
			e.printStackTrace();
		}

	}

}
