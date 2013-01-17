package com.danielgenis;


public class NodeInfo {
	private int nodeId; // node ID
	private int second; // second of simulation
	private float x; //coords
	private float y; //coords
	private float z; //coords

	
	
	public NodeInfo(int nodeId, int second, float x, float y, float z) {
		super();
		this.nodeId = nodeId;
		this.second = second;
		this.x = x;
		this.y = y;
		this.z = z;
	}



	public int getNodeId() {
		return nodeId;
	}



	public void setNodeId(int nodeId) {
		this.nodeId = nodeId;
	}



	public int getSecond() {
		return second;
	}



	public void setSecond(int second) {
		this.second = second;
	}



	public float getX() {
		return x;
	}



	public void setX(float x) {
		this.x = x;
	}



	public float getY() {
		return y;
	}



	public void setY(float y) {
		this.y = y;
	}



	public float getZ() {
		return z;
	}



	public void setZ(float z) {
		this.z = z;
	}

}
