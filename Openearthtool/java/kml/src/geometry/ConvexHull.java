package geometry;

import java.awt.geom.Point2D;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;

/**
 * based on		http://www.dr-mikes-maths.com/DP-convex-hull-java-code.html
 * 
 * gathers points in a 2D cartesian plane, and calculates the convex hull around it.
 * While more and more points are added, the internal points which become superfluous are
 * removed. 
 * The class can also be used for spherical coordinates, but mind that it will ignore 
 * the poles and date line. Furthermore, the calculated area will be distorted.
 * 
 * 
 * @author ir. Marco Kleuskens
 */

public class ConvexHull {
	/**the convex hull, sorted counterclockwise, starting with the lowest point */
	private ArrayList<Point2D.Double> hull; 
	/**all points; if there are more than <batchSize> points, <calculateHull()> is invoked, which 
	 * eliminates all internal points. This is to prevent out of memory errors*/
	private ArrayList<Point2D.Double> points;

	/** if true, <hull> is the same as <points> */
	private boolean isUpdated;
	private int batchSize=1000;
<<<<<<< .mine
	/** the total number of points that are added. After <calculateHull()> is invoked, this number
	 * is larger than <points.size()>, because that consists only of the hull with unprocessed points.
	 */
	private int nPoints=0;
=======
	private long nPoints=0;
>>>>>>> .r4954
	private final static double twoPi=Math.PI*2;
	
	/**test script: builds a convexHull with a set of random points, and prints the convex hull as
	 * kml polygon to the screen
	 * @param args not used
	 */
	public static void main(String[] args){
		ConvexHull convexHull=new ConvexHull();
		//fill with points
		for(int i=0;i<1000;i++){
			convexHull.addPoint(new Point2D.Double(Math.random(),Math.random()));
			System.out.println("npoints "+convexHull.nPoints+" surface "+convexHull.getSurface()+
			           " length "+convexHull.getContourLength()+" density "+convexHull.getDensity());
//			System.out.println(convexHull.nPoints+" "+convexHull.getSurface()+
//			           " "+convexHull.getContourLength()+" "+convexHull.getDensity());
		}
		
		System.out.println(convexHull.getHullAsKmlPolygon());
		System.out.println(convexHull.getArea());
	}

	/**
	 * initialises with no points
	 */
	public ConvexHull(){
		points=new ArrayList<Point2D.Double>();
		isUpdated=false;
	}

	/**
	 * initialises with already a set of points. Hull is not yet calculated
	 */
	public ConvexHull(ArrayList<Point2D.Double> points){
		this.points=cloneArrayList(points);
		nPoints=points.size();
		isUpdated=false;
	}

	public void addPoints(List<Point2D.Double> points){
		isUpdated=false;
		nPoints+=points.size();
		for(int i=0;i<points.size();i++){
			this.points.add(points.get(i));
			if(this.points.size()>batchSize){ //prevent the cloud from becoming too large.
				calculateHull();
			}
		}
	}

	public void addPoint(Point2D.Double point){
		isUpdated=false;
		nPoints++;
		points.add(point);
		nPoints++;
		if(this.points.size()>batchSize){ //prevent the cloud from becoming too large.
			calculateHull();
		}
	}

	/**
	 * 
	 * @return the convex hull as List<Point2D.Double>
	 */
	public List<Point2D.Double> getHullAsList(){
		calculateHull();
		return hull;
	}

	public int getNPoints(){
		return nPoints;
	}
	
	/**
	 * 
	 * @return the area in the same unit as the 2D plane. Warning: this only works for 
	 * carthesian coordinates; the result of spherical coordinates will be distorded.
	 */
	public double getArea(){
		calculateHull();
		
		double area=0;
		for(int i=1;i<hull.size();i++){
			area+=getArea(hull.get(hull.size()-1),hull.get(i-1),hull.get(i));
		}
		return area;
	}
	
	/**
	 * @return the convex hull as double array: {{x1,y1},{x2,y2},...,{xn,yn}};
	 */
	public double[][] getHullAsArray(){
		calculateHull();
		double[][] array=new double[hull.size()][2];
		for(int i=0;i<hull.size();i++){
			Point2D.Double point=hull.get(i);
			array[i][0]=point.x;
			array[i][1]=point.y;
		}
		return array;
	}

	/**
	 * 
	 * @return the convex hull as kml polygon: x1,y1,0.00000 x2,y2,0.00000   xn,yn,0.00000;
	 */
	public String getHullAsKmlPolygon(){
		calculateHull();
		String ans="";
		 NumberFormat formatter = new DecimalFormat("###.######");  
	       for(int i=0;i<hull.size();i++){
			Point2D.Double point=hull.get(i);
			ans=ans.concat(formatter.format(point.x)+","+formatter.format(point.y)+",0.000000 ");
		}
		Point2D.Double point=hull.get(0);
		ans=ans.concat(formatter.format(point.x)+","+formatter.format(point.y)+",0.000000");
		return ans;
		
	}
	
	public double getContourLength(){
		calculateHull();
		if(hull.size()<2) return 0;
		double length=hull.get(0).distance(hull.get(hull.size()-1));
		for(int i=0;i<hull.size()-1;i++){
			length+=hull.get(i).distance(hull.get(i+1));
		}
		return length;
	}
	public long getNumberOfPoints(){
		return nPoints;
	}
	
	public double getSurface(){
		calculateHull();
		if(hull.size()<3) return 0;
		double surface=0;
		for(int i=1;i<hull.size()-1;i++){
			surface+=getSurfaceOfTriangle(hull.get(0),hull.get(i),hull.get(i+1));
		}
		return surface;
	}
	
	/**
	 * gets the point density in points per unit length^2
	 * the method assumes a surface of getSurface() plus an extra rim based on getContourLength()
	 * @return
	 */
	
	public double getDensity(){
		calculateHull();
		if(hull.size()<3) return -1;
		double length=getContourLength();
		double surface=getSurface();
		return Math.pow((Math.sqrt(length*length/4d+4*surface*nPoints)-length/2d)/2d/surface,2);
	}

	/**
	 * calculates the convex hull. This method is invoked by all methods that need the actual hull.
	 * First, the lowest point is found (lowest y-value). Next the point is found with the smallest 
	 * angle wrt x-axis. Next, the point is found with the smallest angle with respect to the line 
	 * form the last two points
	 * 
	 */
	
	private void calculateHull(){
		if(!isUpdated){
			//System.out.print("the cloud has "+points.size()+" points; ");
			
			//find first point
			if(points.size()<3){
				hull=cloneArrayList(points);
			}else{
				hull=new ArrayList<Point2D.Double>();
				hull.add(getFirstPoint());

				double curAngle=0;
				boolean isOpen=true;
				
				while(isOpen&&points.size()>0){
					int indexOfBestPoint=-1;
					double bestRelAngle=twoPi;
				
					//find point with best relative angle
					for(int i=points.size()-1;i>=0;i--){
						if(points.get(i).distance(hull.get(hull.size()-1))<.0000001){
							points.remove(i); //this point is very close to the previous point; remove it
						}else{
							double relAngle=getAngle(points.get(i), hull.get(hull.size()-1),curAngle);
							if(relAngle<bestRelAngle){
								bestRelAngle=relAngle;
								indexOfBestPoint=i;
							}
						}
					}
					
					//finally  check if first point of polygon is maybe better;
					if(hull.size()>=2&&getAngle(hull.get(0), hull.get(hull.size()-1),curAngle)<bestRelAngle){
						isOpen=false; //polygon is closed!
					}else{
						hull.add(points.remove(indexOfBestPoint));
						curAngle+=bestRelAngle;
					}
				}					
				points=cloneArrayList(hull);
			}
			//System.out.println("the convex hull has: "+points.size()+" points; ");
			isUpdated=true;
		}
	}

	private Point2D.Double getFirstPoint(){
		int index=0;
		double yLow=points.get(index).y;
		for(int i=1;i<points.size();i++){
			double y=points.get(i).y;
			if(y<yLow){
				yLow=y;
				index=i;
			}
		}
		return points.remove(index); 
	}

	private double getAngle(Point2D.Double point1, Point2D.Double point2, double curAngle){
		double angle=Math.atan2(point1.y-point2.y, point1.x-point2.x)-curAngle;
		while(angle<0){
			angle+=twoPi;
		}
		return angle;
	}

	/**
	 * calculate area of a triangle. Warning, this only works for carthesian coordinates
	 * for polar coordinates, the result will be distorded
	 * @param point1
	 * @param point2
	 * @param point3
	 * @return
	 */
	private static double getArea(Point2D.Double point1, Point2D.Double point2,Point2D.Double point3){
		double outerSquare=(Math.max(Math.max(point1.x,point2.x),point3.x)-Math.min(Math.min(point1.x,point2.x),point3.x))*
			(Math.max(Math.max(point1.y,point2.y),point3.y)-Math.min(Math.min(point1.y,point2.y),point3.y));
		
		double triangle12=Math.abs(point1.x-point2.x)*Math.abs(point1.y-point2.y)/2;
		double triangle23=Math.abs(point2.x-point3.x)*Math.abs(point2.y-point3.y)/2;
		double triangle31=Math.abs(point3.x-point1.x)*Math.abs(point3.y-point1.y)/2;
		
		return outerSquare-triangle12-triangle23-triangle31;
	}
	
	private static ArrayList<Point2D.Double> cloneArrayList(ArrayList<Point2D.Double> list){
		ArrayList<Point2D.Double> listOut=new ArrayList<Point2D.Double>();
		for(int i=0;i<list.size();i++){
			listOut.add(list.get(i));
		}
		return listOut;
	}

	/**
	 * this method assumes a cartesian coordinate system, not a polar coordinate system. for small triangles, the difference is small
	 * http://www.tutorvista.com/math/surface-area-of-a-triangle
	 * @param point1
	 * @param point2
	 * @param point3
	 * @return
	 */
	private static double getSurfaceOfTriangle(Point2D.Double point1, Point2D.Double point2, Point2D.Double point3){
		double side1=point1.distance(point2);
		double side2=point2.distance(point3);
		double side3=point3.distance(point1);
		double s=(side1+side2+side3)/2d;
		return Math.sqrt(s*(s-side1)*(s-side2)*(s-side3));
	}
}
