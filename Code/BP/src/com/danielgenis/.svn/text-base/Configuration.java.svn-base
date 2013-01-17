package com.danielgenis;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Random;


public class Configuration {
	private static final String SEP ="\t"; 
	public int CHECK_INTERVAL;
	public int DELTA;
	public int RANGE;
	public Hashtable<Integer,Integer> SCANNING_NODES; // contains scanning node subset. <NodeID,TIMEOFScanning>
									// time of scanning lies within  0 and (CheckInterval-1)
	public int PSEUDO_CHANGE_INTERVAL;
	
	private ArrayList<Triangulation> output;
	private ArrayList<NodeInfo> nodeDiscoveryList; // nodes that saw the witness 
	private HashMap<Integer,NodeInfo> targetData; // all mobility data of tracked target
	private ArrayList<ArrayList<NodeInfo>> data; // contains parsed raw data
	private final Random GENERATOR = new Random(System.nanoTime());
	private int MAX_NODE_ID;
	private int TARGET_NODE;
	private BufferedWriter bw;
	
	
	
	public Configuration(int checkIntveral, int delta, int range, int maxNodeId, double scanningNodePct, int pseudoKeyChangeInterval, int targetNodeId) {
		CHECK_INTERVAL = checkIntveral;
		DELTA = delta;
		RANGE = range;
		MAX_NODE_ID = maxNodeId;
		TARGET_NODE = targetNodeId;
		SCANNING_NODES = new Hashtable<Integer,Integer>();
		data = new ArrayList<ArrayList<NodeInfo>>();
		initializeScanningNodeSubset(maxNodeId, scanningNodePct);
		
		int percentage = (int) (100*scanningNodePct);
		
		bw = getFileWriter("triangulation-CI-" + Integer.toString(CHECK_INTERVAL) +
				"-D" + Integer.toString(DELTA) + "-R" + Integer.toString(RANGE) + "-PCT" + percentage + "-TGT" + Integer.toString(TARGET_NODE) + ".csv");
		
		try {
			bw.write("#second" + SEP + "computedX" + SEP + "computedY" + SEP + "computedZ" +
					SEP + "realX" + SEP + "realY" + SEP + "realZ" + SEP + "witnesscount" + SEP + "deviation" + SEP + "totalDetections" + "\r\n");
			bw.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		output = new ArrayList<Triangulation>();
		nodeDiscoveryList = new ArrayList<NodeInfo>();
		targetData = new HashMap<Integer,NodeInfo>();
		
	}
	
	private void initializeScanningNodeSubset(int maxNodeId, double scanningPct) {
		int amountOfScanningNodes = Math.round((float) (maxNodeId * scanningPct));
		int i = 0;
		while(i <= amountOfScanningNodes) {
			int tmp = GENERATOR.nextInt(MAX_NODE_ID);
			if(!SCANNING_NODES.containsKey(tmp)) {
				SCANNING_NODES.put(tmp, GENERATOR.nextInt(CHECK_INTERVAL)); //add key value
				i += 1; // increase only if a random scanning node id was drawn
			}
		}
	}
	
	private BufferedWriter getFileWriter(String outputFileName) {

		try {
			BufferedWriter bw = new BufferedWriter(new FileWriter(new File(outputFileName), false));
			return bw;
		} catch (IOException e) {
			System.out.println("Exception received. during file creation process");
			e.printStackTrace();
			System.exit(1);
		}

		return null;
	}
	
	public void flushOutput() {
		try {
			for (Triangulation t: output) {
				NodeInfo compLoc = t.getComputedLocation();
				NodeInfo realLoc = t.getRealLocation();
				
				double deviation = Math.sqrt(Math.pow(Math.abs(compLoc.getX() - realLoc.getX()), 2) + Math.pow(Math.abs(compLoc.getY() - realLoc.getY()), 2));
				
				String line = t.getAvgSecond() + SEP + 
						compLoc.getX() + SEP + compLoc.getY() + SEP + compLoc.getZ() + SEP +
						realLoc.getX() + SEP + realLoc.getY() + SEP + realLoc.getZ() + SEP +
						t.getWitnessList().size() + SEP + deviation + SEP + t.getTotalDetections() + "\r\n"; 

				bw.write(line);
				bw.flush(); // flush to disk
			}
			
			targetData.clear();
			output.clear(); // empty list
			data.clear(); // empty list

		} catch (IOException e) {
			System.out.println("IO Exception received during output writing");
			e.printStackTrace();
			System.exit(1);
		}
	}
	
	public int getCHECK_INTERVAL() {
		return CHECK_INTERVAL;
	}
	public int getDELTA() {
		return DELTA;
	}
	public int getRANGE() {
		return RANGE;
	}
	public Hashtable<Integer, Integer> getScanningNodeIds() {
		return SCANNING_NODES;
	}
	public int getPSEUDO_CHANGE_INTERVAL() {
		return PSEUDO_CHANGE_INTERVAL;
	}

	public BufferedWriter getBw() {
		return this.bw;
	}
	public ArrayList<Triangulation> getOutput() {
		return output;
	}
	public Hashtable<Integer, Integer> getSCANNING_NODES() {
		return SCANNING_NODES;
	}
	public ArrayList<NodeInfo> getNodeDiscoveryList() {
		return nodeDiscoveryList;
	}
	public HashMap<Integer,NodeInfo> getTargetData() {
		return targetData;
	}
	public Random getGenerator() {
		return this.GENERATOR;
	}
	public int getMAX_NODE_ID() {
		return this.MAX_NODE_ID;
	}
	public ArrayList<ArrayList<NodeInfo>> getData() {
		return data;
	}
	public void setData(ArrayList<ArrayList<NodeInfo>> data) {
		this.data = data;
	}
	public Random getGENERATOR() {
		return GENERATOR;
	}
	public void setCHECK_INTERVAL(int cHECK_INTERVAL) {
		CHECK_INTERVAL = cHECK_INTERVAL;
	}
	public void setDELTA(int dELTA) {
		DELTA = dELTA;
	}
	public void setRANGE(int rANGE) {
		RANGE = rANGE;
	}
	public void setSCANNING_NODES(Hashtable<Integer, Integer> sCANNING_NODES) {
		SCANNING_NODES = sCANNING_NODES;
	}
	public void setPSEUDO_CHANGE_INTERVAL(int pSEUDO_CHANGE_INTERVAL) {
		PSEUDO_CHANGE_INTERVAL = pSEUDO_CHANGE_INTERVAL;
	}
	public void setOutput(ArrayList<Triangulation> output) {
		this.output = output;
	}
	public void setNodeDiscoveryList(ArrayList<NodeInfo> nodeDiscoveryList) {
		this.nodeDiscoveryList = nodeDiscoveryList;
	}
	public void setTargetData(HashMap<Integer,NodeInfo> targetData) {
		this.targetData = targetData;
	}
	public void setMAX_NODE_ID(int mAX_NODE_ID) {
		MAX_NODE_ID = mAX_NODE_ID;
	}
	public void setBw(BufferedWriter bw) {
		this.bw = bw;
	}

	public int getTARGET_NODE() {
		return TARGET_NODE;
	}

	public void setTARGET_NODE(int tARGET_NODE) {
		TARGET_NODE = tARGET_NODE;
	}
	
	
}
