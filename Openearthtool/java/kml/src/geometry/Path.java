package geometry;

import static java.lang.Math.PI;

import java.awt.geom.Point2D;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;


/**
 * this class builds a geometrical path, but omits all points that do not really change the shape.
 * This class can be used to simplify shapes of a river.
 * @author ir. Marco Kleuskens
 *
 */

public class Path {
	ArrayList<Point2D.Double> path;
	
	/**
	 * the miminum angle between 3 subsequent points. If the angle is smaller, the middle point is omitted
	 */
	private double angleDeg=1;
	private double angleRad;
	public final static double deg2rad = PI / 180.0;
	public final static double rad2deg = 180.0 / PI;

	public Path(double angle){
		path=new ArrayList<Point2D.Double>();
		setAngleDeg(angle);
	}

	public Path(){
		path=new ArrayList<Point2D.Double>();
	}
	
	public String toKmlPath(){
		String ans="";
		NumberFormat formatter = new DecimalFormat("###.######");  
	       for(int i=0;i<path.size();i++){
			Point2D.Double point=path.get(i);
			ans=ans.concat(formatter.format(point.x)+","+formatter.format(point.y)+",0.000000 ");
		}
		return ans;
	}

	public void addPoints(ArrayList<Point2D.Double> points){
		for(int i=0;i<points.size();i++){
			addPoint(points.get(i));
		}
	}
	
	public void addPoint(Point2D.Double point){
		path.add(point);
		checkTailOfPath();
	}

	private void checkTailOfPath(){
		if(path.size()>3){
			Point2D.Double point3=path.get(path.size()-1);
			Point2D.Double point2=path.get(path.size()-2);
			Point2D.Double point1=path.get(path.size()-3);
			if(Math.abs(getAngleRad(point1, point3)-getAngleRad(point1, point2))<angleRad){
				path.remove(path.size()-2);
				checkTailOfPath();
			}
		}
	}
	
	private double getAngleRad(Point2D.Double point1,Point2D.Double point2){
		return Math.atan2(point2.y-point1.y,point2.x-point1.x);
	}
	
		
	public void setAngleDeg(double angle){
		angleDeg=angle;
		angleRad=angleDeg*deg2rad;
	}
	
}
