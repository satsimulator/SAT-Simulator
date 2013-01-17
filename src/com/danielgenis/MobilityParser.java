package com.danielgenis;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MobilityParser {

	/////// static variables //////////////
	public static final int MAX_NODE_ID = 9056; // highest node_id simulated
	public static final String KEEP_LINE = "MOBILE-HOST"; // if the line is a base station. should skip it. only keep "MOBILE-HOST" lines
	public static final double OUT_OF_SIMULATION = 1500000.0; // the coordinates used when a node is outside the simulation area
	public static final int MINIMUM_WITNESSES = 3; // minimum amount of witnesses for computing target location
	public static final int PSEUDO_KEY_CHANGE_INTERVAL = 60; // target node obtains new pseudo key in this interval [seconds]
	public static final int READ_BUFFER = 9000*300; // bytes
	public static final int DEBUG = 0; // 0 = no debug info.  1 = some debug info. 2 = most debug info, 4 = insane debug info
	public static final int TOTAL_SECONDS = 86400; // last record. allows computation of progress percentage

	private static final String INPUT_FILE = "24h-chicago-9blk.mobility"; // mobility simulation input
		 

	/////// dynamically used variables /////////
	static int beginSecond = 0; // seconds
	static int currentSecond= 0; // seconds
	static int endSecond = 0; // seconds
	int percentComplete = 0; // in percent.

	// dynamic variable settings
	public final int[] CHECK_INTERVAL_VALUES = {15}; //  how often do nodes scan/search for other notes. in seconds
	public final int[] DELTA_VALUES = {30}; // how many seconds are considered "1 time interval"
	public final int[] RANGE_VALUES = {15}; // scanning range in meters.
	public final double[] SCANNING_NODE_PERCENTAGE = {0.1}; // 0.1 = 10 percent of all nodes are witness nodes
	//public final int[] TARGET_ID_VALUES = {11,229,1159,2208,3211,4339,5120,6051,7073,8184}; // the node id which  get's "scanned/searched" for
	public final int[] TARGET_ID_VALUES = {11}; // the node id which  get's "scanned/searched" for
	

	

	BufferedReader br; // input reader
	boolean loop = true;
	 
	
	 // data holder for NodeID information
	public static ArrayList<Configuration> conf; // contains the configurations for experiment
	public static Configuration currentConf;



	////////////// end variables //////////////


	public MobilityParser() {
		start(); // start program
	}

	public void start() {
		init(); // set variables to initial state
	
		System.out.println("Running simulation(s)");

		while(loop) computeTracking(); // compute multilateration for current settings this function also breaks the loop
		//if(DEBUG > 1) printOutput(output);
		
		System.out.println("Writing simulation data to disk");

		for(Configuration c : conf) {
			try {
				c.getBw().close(); // close output writer
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			//c.flushOutput(); //write simuldation data to disk.
		}
		
		System.out.println("Simulation finished.");

	}

	private void init() {
		// input output reader/writer
		this.br = getFileReader(); // input reader
		
		// reset variables to initial state
		conf = new ArrayList<Configuration>(); // holds all config data
		generateConfigurations();
	}

	private void generateConfigurations() {
		
		// loop through all configuration possibilities and generate respective
		// data structures
		
		for (int ci : CHECK_INTERVAL_VALUES) { // loop through all check interval settings
			for (int de : DELTA_VALUES) { // loop through all delta values
				for (int ra : RANGE_VALUES) { // loop through all range values
					for(double pct : SCANNING_NODE_PERCENTAGE) { // loop through scanning node percentages
						for(int tgt : TARGET_ID_VALUES) {
							conf.add(new Configuration(ci, de, ra, MAX_NODE_ID, pct, PSEUDO_KEY_CHANGE_INTERVAL, tgt));
		}	}	}	}	}
	}

	@SuppressWarnings("unused")
	private void computeTracking() {
		// parse current second data into list
		// when end of input is reached list will be empty. break loop

		if(!ParserClass.parseSecond(currentSecond, br)) {
			loop = false;
			return;
		}

		
		for(Configuration c : conf) {
			// remove last element. to keep list size equal to DELTA
			if(c.getData().size() > c.getDELTA()) c.getData().remove(c.getData().size()-1);
		

			if(currentSecond % c.getDELTA() == 0 && currentSecond != 0) { // got a full data set
				currentConf = c;
				Triangulation tmp = MultilaterationClass.multilateration(c.getData(), c.getTargetData());
				if(null != tmp) c.getOutput().add(tmp);
				c.flushOutput(); // flush output to disk. 
								// also empties all data structures inside Configuration c
								// to save memory consumption
			}
			
			if(DEBUG > 3) printOutput(c.getOutput());
		}
		
		if(DEBUG < 1) { // print progress output
			if(currentSecond % 10 == 0) System.out.print(".");
			if(currentSecond % ((int)(TOTAL_SECONDS/100)) == 0 && currentSecond != 0) {
				percentComplete += 1;
				System.out.print("\r\n" + percentComplete + "%");
			}
		}

		endSecond = currentSecond; // remember last second seen
		currentSecond += 1; // increment second reader
	}

	private void printOutput(List<Triangulation> data) {
		for(Triangulation t: data) {
			System.out.println("Time:" + t.getAvgSecond() + "\t Estimated X:"+ t.getComputedLocation().getX() +" \t Y:" + t.getComputedLocation().getY() +
					"\t Actual X: " + t.getRealLocation().getX() + "\t Y:"+ t.getRealLocation().getY() + "\t Wittnesscount:" + t.getWitnessList().size());
		}
	}


	// get file reader for parsing
	private BufferedReader getFileReader() {
		try {
			FileInputStream fstream = new FileInputStream(INPUT_FILE);
			DataInputStream in = new DataInputStream(fstream);
			
			
			
			BufferedReader br = new BufferedReader(new InputStreamReader(in), READ_BUFFER);

			
			
			return br;

		} catch (IOException e) {
			System.out.println("Exception in getFileReader():\n");
			System.out.println(e.getMessage());

			System.exit(1); // end program

		}
		return null;
	}


	public static void main(String argv[]) {
		new MobilityParser();
	}
}
