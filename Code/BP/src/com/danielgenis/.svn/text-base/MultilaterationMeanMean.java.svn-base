package com.danielgenis;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MultilaterationMeanMean implements MultilaterationInterface {
	
	
	@SuppressWarnings("unused")
	public Triangulation multilateration(ArrayList<ArrayList<NodeInfo>> data, HashMap<Integer,NodeInfo> targetData) {
		
		
		List<NodeInfo> witnessList = getWitnessNodesInRange(data,targetData); // get all witness nodes that are within range
		
		if (witnessList.size() < MobilityParser.MINIMUM_WITNESSES) {
			if(MobilityParser.DEBUG > 1) System.out.println("Not enough witnesses. Witness count:" + witnessList.size());
			return null; // not enough witnesses for positioning 
		}
		
		NodeInfo calculatedTargetPostion = computeLateration(witnessList);
		if(calculatedTargetPostion == null) return null;
		
		NodeInfo actualPosition = averageAllPositions(targetData); // take the average of all actual positions
		
		int totalDetections = -1;
		if(MobilityParser.DETECT_ALL) {
			totalDetections = countAllDetections(data);
		}
		
		if(actualPosition == null) return null;

		
		Triangulation result = new Triangulation(
				calculatedTargetPostion,
				actualPosition,
				actualPosition.getSecond(),
				witnessList,
				totalDetections
		);
		
		return result;
	}

	private static int countAllDetections(ArrayList<ArrayList<NodeInfo>> data) {
		int result = 0;
		for (ArrayList<NodeInfo> d : data) {
			for(NodeInfo n1 : d) {
				// if node is not a scanning node skip
				if(!MobilityParser.currentConf.getSCANNING_NODES().containsKey(n1.getNodeId())) continue;
				
				// if the node is not supposed to scan right now, skip
				if(n1.getSecond() % MobilityParser.currentConf.getCHECK_INTERVAL() !=
						MobilityParser.currentConf.getSCANNING_NODES().get(n1.getNodeId())) continue;
				
				
				for(NodeInfo n2 : d) {
					
					// if out of range. skip
					if((Math.abs(n1.getX() - n2.getX()) > MobilityParser.currentConf.getRANGE())) continue;
					if((Math.abs(n1.getY() - n2.getY()) > MobilityParser.currentConf.getRANGE())) continue;
				
					
					// if within range increase counter
					double distance = getDistance(n1, n2);
					if(distance <= MobilityParser.currentConf.getRANGE()) result++;
					
				}
			}
		}
		
		return result;
	}

	private static NodeInfo computeLateration(List<NodeInfo> witnessData) {
		if(witnessData.size() == 1) return witnessData.get(0); // only 1 witness. return witness position
		
		return averageAllPositions(witnessData);
	}

	@SuppressWarnings("unused")
	private static NodeInfo averageAllPositions(List<NodeInfo> temporaryLaterationData) {
		float x = 0,y = 0,z = 0;
		int i = 0, second = 0;
		
		if(temporaryLaterationData.size() == 0) {
			if(MobilityParser.DEBUG > 1) System.out.println("Error in averageAllPositions: temporaryLateration data is size 0");
			return null;
		}
		
		if(temporaryLaterationData.size() == 1) return temporaryLaterationData.get(0);
		
		// average all values for the lateration result
		for (NodeInfo n: temporaryLaterationData) {
			x += n.getX();
			y += n.getY();
			z += n.getZ();
			second += n.getSecond(); 
			i++;
		}
		
		x = x/i;
		y = y/i;
		z = z/i;
		second = Math.round(second/i);
		
		return new NodeInfo(MobilityParser.currentConf.getTARGET_NODE(),second, x, y, z);
	}
	
	@SuppressWarnings("unused")
	private static NodeInfo averageAllPositions(HashMap<Integer,NodeInfo> temporaryLaterationData) {
		float x = 0,y = 0,z = 0;
		int i = 0, second = 0;
		
		if(temporaryLaterationData.size() == 0) {
			if(MobilityParser.DEBUG > 1) System.out.println("Error in averageAllPositions: temporaryLateration data is size 0");
			return null;
		}
		
		if(temporaryLaterationData.size() == 1) return temporaryLaterationData.get(0);
		
		// average all values for the lateration result
		for (NodeInfo n: temporaryLaterationData.values()) {
			x += n.getX();
			y += n.getY();
			z += n.getZ();
			second += n.getSecond(); 
			i++;
		}
		
		x = x/i;
		y = y/i;
		z = z/i;
		second = Math.round(second/i);
		
		return new NodeInfo(MobilityParser.currentConf.getTARGET_NODE(),second, x, y, z);
	}

	private static double getDistance(NodeInfo n1, NodeInfo n2) {
		double d = 0; // d is the distance between the 2 nodes: n1 and n2
		double diffX = Math.abs(n1.getX() - n2.getX());
		double diffY = Math.abs(n1.getY() - n2.getY());
		
		d = Math.sqrt((Math.pow(diffX, 2) + Math.pow(diffY, 2))); // pythagoras
		
		return d;
	}
	
	
	private static List<NodeInfo> getWitnessNodesInRange(ArrayList<ArrayList<NodeInfo>> data, HashMap<Integer,NodeInfo> targetData) {
		List<NodeInfo> output = new ArrayList<NodeInfo>(); 
		for(List<NodeInfo> nodeList: data) {
			int currentSecond = nodeList.get(0).getSecond();
			
			
			NodeInfo targetPosition = getPosition(currentSecond,targetData); // get target position data
			if(targetPosition == null) continue; // no target data. skip
			
			if(targetPosition.getX() == MobilityParser.OUT_OF_SIMULATION) {
				System.out.println("Target node is out of simulation area");
				continue; // target node is out of simulation ares. skipping this second
			}
			
			for (NodeInfo node: nodeList) {
				
				// not a scanning node. skip
				if(!MobilityParser.currentConf.SCANNING_NODES.containsKey(node.getNodeId())) continue;
				
				// if observation is inbetween CHECK_INTERVAL. skip
				// the current node is not scanning right now
				if(node.getSecond() % MobilityParser.currentConf.getCHECK_INTERVAL() != 
						MobilityParser.currentConf.getSCANNING_NODES().get(node.getNodeId()))	continue;
				
				// out of range. skip
				if(Math.abs(node.getX() - targetPosition.getX()) > MobilityParser.currentConf.getRANGE()) continue;
				if(Math.abs(node.getY() - targetPosition.getY()) > MobilityParser.currentConf.getRANGE()) continue;
				
			
				double distance = getDistance(node, targetPosition);
				if (distance <= (MobilityParser.currentConf.getRANGE())) {
					output.add(node); // this witness node is within range of target node
				}
			}
		}
		
		return output;
	}
	
	private static NodeInfo getPosition(int second, HashMap<Integer,NodeInfo> targetData) {
		return targetData.get(second);
	}

}
