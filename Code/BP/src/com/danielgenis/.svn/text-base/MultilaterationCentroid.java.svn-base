package com.danielgenis;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MultilaterationCentroid implements MultilaterationInterface {

	public Triangulation multilateration(ArrayList<ArrayList<NodeInfo>> data,
			HashMap<Integer, NodeInfo> targetData) {

		// get all witness nodes that are withinrange
		List<NodeInfo> witnessList = getWitnessNodesInRange(data, targetData); 


		if (witnessList.size() < MobilityParser.MINIMUM_WITNESSES) {
			if (MobilityParser.DEBUG > 1)
				System.out.println("Not enough witnesses. Witness count:" + witnessList.size());
			return null; // not enough witnesses for positioning
		}

		NodeInfo calculatedTargetPostion = computeLateration(witnessList);
		if (calculatedTargetPostion == null)
			return null;


		// take the average of all actual positions		
		NodeInfo actualPosition = averageAllPositions(targetData); 


		int totalDetections = -1;
		if (MobilityParser.DETECT_ALL) {
			totalDetections = countAllDetections(data);
		}

		if (actualPosition == null)
			return null;

		Triangulation result = new Triangulation(calculatedTargetPostion,
				actualPosition, actualPosition.getSecond(), witnessList,
				totalDetections);

		return result;
	}

	private static int countAllDetections(ArrayList<ArrayList<NodeInfo>> data) {
		int result = 0;
		for (ArrayList<NodeInfo> d : data) {
			for (NodeInfo n1 : d) {
				// if node is not a scanning node skip
				if (!MobilityParser.currentConf.getSCANNING_NODES()
						.containsKey(n1.getNodeId()))
					continue;

				// if the node is not supposed to scan right now, skip
				if (n1.getSecond()
						% MobilityParser.currentConf.getCHECK_INTERVAL() != MobilityParser.currentConf
						.getSCANNING_NODES().get(n1.getNodeId()))
					continue;

				for (NodeInfo n2 : d) {

					// if out of range. skip
					if ((Math.abs(n1.getX() - n2.getX()) > MobilityParser.currentConf
							.getRANGE()))
						continue;
					if ((Math.abs(n1.getY() - n2.getY()) > MobilityParser.currentConf
							.getRANGE()))
						continue;

					// if within range increase counter
					double distance = getDistance(n1, n2);
					if (distance <= MobilityParser.currentConf.getRANGE())
						result++;

				}
			}
		}

		return result;
	}

	private static NodeInfo computeLateration(List<NodeInfo> witnessData) {
		if (witnessData.size() == 1)
			return witnessData.get(0); // only 1 witness. return witness
										// position

		ArrayList<ArrayList<NodeInfo>> distinctWitnesses;

		// choose 3 distinct out of witnessData
		distinctWitnesses = selectThreeDistinctWitnesses((ArrayList<NodeInfo>) witnessData);

		// compute centroid of all three-tuples of witnesses
		return computeCentroids(distinctWitnesses);
	}

	private static ArrayList<ArrayList<NodeInfo>> selectThreeDistinctWitnesses(
			ArrayList<NodeInfo> witnessData) {
		ArrayList<ArrayList<NodeInfo>> result = new ArrayList<ArrayList<NodeInfo>>();

		if (3 == witnessData.size()) { // only 3 witnesses. return those
			result.add(witnessData);
			return result;
		}

		for (int i = 0; i < witnessData.size(); i++) {
			for (int j = 0; j < witnessData.size(); j++) {
				for (int k = 0; k < witnessData.size(); k++) {
					if (i != j && j != k && i != k) { // must be 3 different
														// witnesses
						ArrayList<NodeInfo> temp = new ArrayList<NodeInfo>();
						temp.add(witnessData.get(i));
						temp.add(witnessData.get(j));
						temp.add(witnessData.get(k));

						result.add(temp);
					}
				}
			}
		}

		return result;
	}

	private static NodeInfo computeCentroids(ArrayList<ArrayList<NodeInfo>> distinctWitnesses) {
		List<NodeInfo> centroidPositions = new ArrayList<NodeInfo>();

		// compute all centroids from three tuples of witnesses
		for (ArrayList<NodeInfo> w : distinctWitnesses) {
			centroidPositions.add(computeCentroidLocation(w));
		}

		// average all computed centroids
		return averageAllPositions(centroidPositions);
	}

	private static NodeInfo computeCentroidLocation(ArrayList<NodeInfo> w) {

		// insert ranges (r1,r2,r3) and compute distances d12,d13,d23
		// compute the cosinus and sinus to be used for computing circle
		// crossing points

		int r1, r2, r3;
		r1 = r2 = r3 = MobilityParser.currentConf.getRANGE();
		double d12 = computeDistance(w.get(0), w.get(1));
		double d13 = computeDistance(w.get(0), w.get(2));
		double d23 = computeDistance(w.get(1), w.get(2));

		double cosinusOmega1 = (pow(d12, 2) + pow(d13, 2) - pow(
				d23, 2) / (2 * d12 * d13));
		double cosinusOmega2 = -(pow(d12, 2) + pow(d23, 2) - Math
				.pow(d12, 2) / (2 * d12 * d13));
		double sinusOmega1 = Math.sqrt(1 - pow(cosinusOmega1, 2));
		double sinusOmega2 = Math.sqrt(1 - pow(cosinusOmega2, 2));

		// compute crossing points for circles

		// first crossing point
		double x12 = (pow(r1, 2) - pow(r2, 2) + pow(d12, 2))
				/ (2 * d12);
		double y12 = (1 / (2 * d12))
				* Math.sqrt(2
						* pow(d12, 2)
						* (pow(r1, 2)
								+ pow(r2, 2)
								- pow((pow(r1, 2) - pow(r2, 2)),
										2) - pow(d12, 4)));

		// second crossing point
		double x13 = (((pow(r1, 2) - pow(r3, 2) + pow(d13, 2)) / (2 * d13)) * cosinusOmega1)
				- ((-1) / (1 * d13))
				* Math.sqrt(2 * pow(d13, 2)
						* (pow(r1, 2) + pow(r3, 2))
						- pow((pow(r1, 2) - pow(r3, 2)), 2)
						- pow(d13, 4));
		double y13 = (((pow(r1,2) - pow(r3,2) + pow(d13,2)) / (2 * d13)) * sinusOmega1) +
						((-1)/(2 * d13)) * Math.sqrt(2 * pow(d13,2) * (pow(r3, 2) + pow(r3,2)) -
								(pow((pow(r1, 2) - pow(r3,2)),2) - pow(d13,4)));
		
		// third crossing point
		double x23 = (((pow(r2,2) - pow(r3, 3) + pow(d23,2)) / (2 * d23)) * cosinusOmega2) -
						((1/(2 * d23)) * Math.sqrt(2 * pow(d23, 2) * (pow(r2,2) + pow(r3,2)) -
								pow((pow(r2,2) - pow(r3,2)),2) - pow(d23,4)));
		double y23 = (((pow(r2,2) - pow(r3,2) + pow(d23,2)) / (2 * d23)) * sinusOmega2) +
						(1/(2 * d23)) * Math.sqrt(2 * pow(d13,2) *  (pow(r2,2) + pow(r3,2)) -
								pow((pow(r2,2) - pow(r3,2)),2) - pow(d23,4));

		float x = (float)(x12 + x23 + x13) / 3;
		float y = (float)(y12 + y23 + y13) / 3;
		float z = 0;
		int second = w.get(0).getSecond() + w.get(1).getSecond() + w.get(3).getSecond();
		second = Math.round(second/3);
		
		
		return new NodeInfo(MobilityParser.currentConf.getTARGET_NODE(), second, x, y, z);
	}

	private static double computeDistance(NodeInfo d1, NodeInfo d2) {
		return Math.sqrt(pow(Math.abs(d1.getX() - d2.getX()), 2)
				+ pow(Math.abs(d1.getY() - d2.getY()), 2));
	}
	
	private static double pow (double base, double exponent) {
		return Math.pow(base, exponent);
	}

	private static NodeInfo averageAllPositions(
			List<NodeInfo> temporaryLaterationData) {
		float x = 0, y = 0, z = 0;
		int i = 0, second = 0;

		if (temporaryLaterationData.size() == 0) {
			if (MobilityParser.DEBUG > 1)
				System.out.println("Error in averageAllPositions: temporaryLateration data is size 0");
			return null;
		}

		if (temporaryLaterationData.size() == 1)
			return temporaryLaterationData.get(0);

		// average all values for the lateration result
		for (NodeInfo n : temporaryLaterationData) {
			x += n.getX();
			y += n.getY();
			z += n.getZ();
			second += n.getSecond();
			i++;
		}

		x = x / i;
		y = y / i;
		z = z / i;
		second = Math.round(second / i);

		return new NodeInfo(MobilityParser.currentConf.getTARGET_NODE(),
				second, x, y, z);
	}

	private static NodeInfo averageAllPositions(
			HashMap<Integer, NodeInfo> temporaryLaterationData) {
		float x = 0, y = 0, z = 0;
		int i = 0, second = 0;

		if (temporaryLaterationData.size() == 0) {
			if (MobilityParser.DEBUG > 1)
				System.out
						.println("Error in averageAllPositions: temporaryLateration data is size 0");
			return null;
		}

		if (temporaryLaterationData.size() == 1)
			return temporaryLaterationData.get(0);

		// average all values for the lateration result
		for (NodeInfo n : temporaryLaterationData.values()) {
			x += n.getX();
			y += n.getY();
			z += n.getZ();
			second += n.getSecond();
			i++;
		}

		x = x / i;
		y = y / i;
		z = z / i;
		second = Math.round(second / i);

		return new NodeInfo(MobilityParser.currentConf.getTARGET_NODE(),
				second, x, y, z);
	}

	private static double getDistance(NodeInfo n1, NodeInfo n2) {
		double d = 0; // d is the distance between the 2 nodes: n1 and n2
		double diffX = Math.abs(n1.getX() - n2.getX());
		double diffY = Math.abs(n1.getY() - n2.getY());

		d = Math.sqrt((pow(diffX, 2) + pow(diffY, 2))); // pythagoras

		return d;
	}

	private static List<NodeInfo> getWitnessNodesInRange(
			ArrayList<ArrayList<NodeInfo>> data,
			HashMap<Integer, NodeInfo> targetData) {
		List<NodeInfo> output = new ArrayList<NodeInfo>();
		for (List<NodeInfo> nodeList : data) {
			int currentSecond = nodeList.get(0).getSecond();

			NodeInfo targetPosition = getPosition(currentSecond, targetData); // get
																				// target
																				// position
																				// data
			if (targetPosition == null)
				continue; // no target data. skip

			if (targetPosition.getX() == MobilityParser.OUT_OF_SIMULATION) {
				System.out.println("Target node is out of simulation area");
				continue; // target node is out of simulation ares. skipping
							// this second
			}

			for (NodeInfo node : nodeList) {

				// not a scanning node. skip
				if (!MobilityParser.currentConf.SCANNING_NODES.containsKey(node
						.getNodeId()))
					continue;

				// if observation is inbetween CHECK_INTERVAL. skip
				// the current node is not scanning right now
				if (node.getSecond()
						% MobilityParser.currentConf.getCHECK_INTERVAL() != MobilityParser.currentConf
						.getSCANNING_NODES().get(node.getNodeId()))
					continue;

				// out of range. skip
				if (Math.abs(node.getX() - targetPosition.getX()) > MobilityParser.currentConf
						.getRANGE())
					continue;
				if (Math.abs(node.getY() - targetPosition.getY()) > MobilityParser.currentConf
						.getRANGE())
					continue;

				double distance = getDistance(node, targetPosition);
				if (distance <= (MobilityParser.currentConf.getRANGE())) {
					output.add(node); // this witness node is within range of
										// target node
				}
			}
		}

		return output;
	}

	private static NodeInfo getPosition(int second,
			HashMap<Integer, NodeInfo> targetData) {
		return targetData.get(second);
	}

}
