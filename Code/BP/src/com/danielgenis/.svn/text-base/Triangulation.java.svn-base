package com.danielgenis;

import java.util.List;

public class Triangulation {
	private NodeInfo computedLocation;
	private NodeInfo realLocation;
	private int avgSecond; // approximate second timestamp of approximation
	// during time interval DELTA
	private List<NodeInfo> witnessList; // witness data used for triangulation
	private int totalDetections; // a count of all detected nodes by witnesses
		


	public Triangulation(NodeInfo computedLocation, NodeInfo realLocation,
			int avgSecond, List<NodeInfo> witnessList, int totalDetections) {
		super();
		this.computedLocation = computedLocation;
		this.realLocation = realLocation;
		this.avgSecond = avgSecond;
		this.witnessList = witnessList;
		this.totalDetections = totalDetections;
	}
	
	
	public NodeInfo getComputedLocation() {
		return computedLocation;
	}
	public void setComputedLocation(NodeInfo computedLocation) {
		this.computedLocation = computedLocation;
	}
	public NodeInfo getRealLocation() {
		return realLocation;
	}
	public void setRealLocation(NodeInfo realLocation) {
		this.realLocation = realLocation;
	}
	public int getAvgSecond() {
		return avgSecond;
	}
	public void setAvgSecond(int avgSecond) {
		this.avgSecond = avgSecond;
	}
	public List<NodeInfo> getWitnessList() {
		return witnessList;
	}
	public void setWitnessList(List<NodeInfo> witnessList) {
		this.witnessList = witnessList;
	}
	public int getTotalDetections() {
		return totalDetections;
	}


	public void setTotalDetections(int totalDetections) {
		this.totalDetections = totalDetections;
	}


}
