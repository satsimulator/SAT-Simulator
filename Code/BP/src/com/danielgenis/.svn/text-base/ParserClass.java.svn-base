package com.danielgenis;

import java.io.BufferedReader;
import java.io.CharArrayReader;
import java.io.IOException;
import java.util.ArrayList;


public class ParserClass {
	
	
	// parse 1 second of Node information. all records
	@SuppressWarnings("unused")
	public static boolean parseSecond(int currentSecond, BufferedReader br) {
		boolean loop = true;
		while(loop) {
			try {	
				br.mark(500);
				String line = br.readLine();
				
				if(line == null) {
					if(MobilityParser.DEBUG > 3) System.out.println("Reading data finished");
					loop = false; 
					return false; // end of input exit
								// this function breaks the input reading
				}
				

				NodeInfo lineDetails = parseLine(line);
				
				if(lineDetails == null) continue; // skip to next line
				
				if(lineDetails.getSecond() != currentSecond) {
					br.reset(); // reset to before line was read so it can be re-read again
					loop = false; 
					continue; // normal exit. complete data was read for current second
				}
				


				if(MobilityParser.DEBUG > 3) { //debug code
					System.out.println("Input:" + line);
					System.out.println("Parsed: nodeid:" + lineDetails.getNodeId() + " second:" + lineDetails.getSecond() + " x:" + lineDetails.getX() + " y:" + lineDetails.getY() + " z:" + lineDetails.getZ());
				}
				
				for(Configuration c : MobilityParser.conf) { // loop through experiment configuration
					if(lineDetails.getNodeId() == c.getTARGET_NODE()) { // if nodeid is the target. store and keep record
						c.getTargetData().put(lineDetails.getSecond(),lineDetails);  
													  // do not store in the node list since it's the target ID
						continue;					  // therefore break loop and read next line. 
					}
					
					if(!MobilityParser.DETECT_ALL) { // only add if needed for detect all. otherwise if it's not a scanning node skip
						if(c.getSCANNING_NODES().get(lineDetails.getNodeId()) == null) continue; // node is not a scanning node. skip
						
						// skip if node is not supposed to scan right now
						if(lineDetails.getSecond() % c.getCHECK_INTERVAL() != c.getSCANNING_NODES().get(lineDetails.getNodeId())) continue;
					}
					
					
					if(lineDetails.getX() == MobilityParser.OUT_OF_SIMULATION) continue; // node is outside simulation zone. skip
				

					// ADD node to output list
					if(c.getData().contains(currentSecond)) {
						if(!c.getData().get(currentSecond).add(lineDetails)) throw new Exception("adding Nodeinfo failed");
					} else {
						ArrayList<NodeInfo> tmp = new ArrayList<NodeInfo>();
						tmp.add(lineDetails);
						if(!c.getData().add(tmp)) throw new Exception("adding Nodeinfo failed");
					}
				}
			
				
				
			} catch (IOException e) {
				System.out.println("IOException in parseSecond():\n");
				e.printStackTrace();
				System.exit(1); // end program				
			} catch (Exception e) {
				System.out.println("Exception in parseSecond():\n");
				e.printStackTrace();
				System.exit(1); // end program
			}
			
		}
		
		return true;
	}
	
	// parse a given Line, return data as NodeInfo object
	@SuppressWarnings("unused")
	private static NodeInfo parseLine(String line) {
		int nodeId; // node ID
		int second; // second of simulation
		float x; //coords
		float y; //coords
		float z; //coords
		
		if(!line.contains(MobilityParser.KEEP_LINE)) {
			if(MobilityParser.DEBUG > 1) System.out.println("Skip line. not a mobile host\n");
			return null;
		}
		
		CharArrayReader reader = new CharArrayReader(line.toCharArray());
		
		// parse line to NodeInfo
		nodeId = ParserClass.parseInteger(reader);
		second = ParserClass.parseInteger(reader);
			
		float[] tmp = ParserClass.parseLocation(reader);
		
		x = tmp[0];
		y = tmp[1];
		z = tmp[2];
		
		NodeInfo output = new NodeInfo(nodeId,second,x,y,z);

		return output;
	}	
	
	
	private static float[] parseLocation(CharArrayReader r) {
		float[] result = new float[3];
		try {
			char c = (char)r.read();
			if (!String.valueOf(c).equals("(")) throw new Exception("Parsing error in parseLocation. Expected \"(\" got \"" + c +"\"");
			
			result[0] = parseFloat(r); // parse X
			result[1] = parseFloat(r); // parse Y
			result[2] = parseFloat(r); // parse Z
			

		} catch (IOException e) {
			System.out.println("IO Error in parseLocation\n");
			System.out.println(e.getMessage());
			System.exit(1);
		} catch (Exception e) {
			System.out.println("Error in parseLocation\n");
			System.out.println(e.toString());
			System.exit(1);
		}
		
		
		return result;
	}
	
	
	private static float parseFloat(CharArrayReader r) throws Exception {
		float result = 0;
		char c;
		
		//parse first digit
		c = (char)r.read();
		if(!Character.isDigit(c)) throw new Exception("Parsing error in parseFloat. Expected initial digit got \"" + c +"\"");
		result = (float)Character.getNumericValue(c); // store first digit
		
		//read more digits
		while(true) {
			c = (char)r.read();
			if(!Character.isDigit(c)) break; // break loop. inspect c check that it's a dot
			result = (float)((result * 10) + Character.getNumericValue(c));
		}
		
		// check if last char read is the dot "."
		if(!String.valueOf(c).equals(".")) throw new Exception("Parsing error in parseFloat. Expected a dot \".\" instead got \"" + c +"\"");
		
		int i = 1; // needed to divide digit by power of 10
		
		// read post decimal digit
		c = (char)r.read();
		if(!Character.isDigit(c)) throw new Exception("Parsing error in parseFloat. Expected a digit got \"" + c +"\"");
		result = (float)result + ((float)Character.getNumericValue(c)/(float)10); // store first decimal
		i += 1;
		
		// read more digits
		while(true) {
			c = (char)r.read();
			if(!Character.isDigit(c)) break; // break loop. inspect c for issue before returning the result
			result = result + (float)(Character.getNumericValue(c)/(10^i)); // store more decimal values
			i += 1;
		}
		
		if(!String.valueOf(c).equals(",") && !String.valueOf(c).equals(")")) throw new Exception("Parsing error in parseFloat. Expected a comma \",\" or a close bracket \")\" got \"" + c +"\"");
		
		
		
		return result;
	}


	private static int parseInteger(CharArrayReader r) {
		int nodeId = -1;
		
		try {
			nodeId = readInteger(r);

		} catch (Exception e) {
			System.out.println("Exception in parseInteger");
			e.printStackTrace();
			System.exit(1);
		} 
		
		return nodeId;
	}
	
	
	// first char must be a digit
	private static int readInteger(CharArrayReader r) throws Exception {
		int result = 0;
		int i = 0;
		while(true) {
			char c = (char)r.read();
			
			if(Character.isWhitespace(c) && i != 0) break; // finished. read integer 
			
			if(!Character.isDigit(c)) throw new Exception("Parsing error in readInteger(). Digit expected got \"" + c +"\"");
		
			result = (result * 10) + Character.getNumericValue(c);
			
			i += 1; // increment i

		}
		
		return result;
	}


	

}
