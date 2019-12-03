package klmUtils;

import java.awt.geom.Point2D;
import static java.lang.Math.*;

/**
 * coordinate conversion between latLon, UTM and RD
 * @author ir. Marco Kleuskens
 *
 */

public class Coordinates {
	public final static double sm_a = 6378137.0;
	public final static double sm_b = 6356752.314;
	public final static double sm_EccSquared = 6.69437999013e-03;
	public final static double UTMScaleFactor = 0.9996;

	public final static double deg2rad = PI / 180.0;
	public final static double rad2deg = 180.0 / PI;

	public static double[] latLon2xyz(Point2D.Double latLon){
		double lat=latLon.getY()*deg2rad;
		double lon=latLon.getX()*deg2rad;
		return new double[]{cos(lat)*cos(lon), cos(lat)*sin(lon), sin(lat)};
	}

	public static Point2D.Double xyz2LatLon(double[] v){
		if(v.length!=3) return null;
		double lat=asin(v[2])*rad2deg;
		double lon=atan2(v[1],v[0])*rad2deg;
		return new Point2D.Double(lon,lat);
	}

	/**
	 * http://www.gpsgek.nl/informatief/wgs84-rd-script.html
	 * @param latLon (lon=x,lat=y)
	 * @return rd
	 */
	public static Point2D.Double latLon2RD(Point2D.Double latLon){
		double dF = 0.36 * (latLon.getY() - 52.15517440);
		double dL = 0.36 * (latLon.getX() - 5.38720621);

		double SomX= (190094.945 * dL) + (-11832.228 * dF * dL) + 
		(-144.221 * dF*dF * dL) + (-32.391 * dL*dL*dL) + 
		(-0.705 * dF) + (-2.340 * pow(dF,3) * dL) + (-0.608 * dF * pow(dL,3)) + 
		(-0.008 * dL*dL) + (0.148 * dF*dF * pow(dL,3));
		double SomY = (309056.544 * dF) + (3638.893 * dL*dL) + 
		(73.077 * dF*dF ) + (-157.984 * dF * dL*dL) + 
		(59.788 * pow(dF,3) ) + (0.433 * dL) + (-6.439 * dF*dF * dL*dL) + 
		(-0.032 * dF * dL) + (0.092 * dL*dL*dL*dL) + (-0.054 * dF * pow(dL,4));

		return new Point2D.Double(155000 + SomX,463000 + SomY);
	}
	/**
	 * http://www.gpsgek.nl/informatief/wgs84-rd-script.html
	 * @param rd
	 * @return latlon (lon=x,lat=y)
	 */
	public static Point2D.Double rd2LatLon(Point2D.Double rd){
		double dX = (rd.x - 155000) /100000;
		double dY = (rd.y - 463000) /100000;

		double SomN = (3235.65389 * dY) + (-32.58297 * dX*dX) + 
		(-0.2475 * dY*dY) + (-0.84978 * dX* dX * dY) + 
		(-0.0655 * dY* dY* dY) + (-0.01709 * dX* dX * dY*dY) + 
		(-0.00738 * dX) + (0.0053 * pow(dX,4)) + (-0.00039 * dX*dX * dY*dY*dY) + 
		(0.00033 * pow(dX,4) * dY) + (-0.00012 * dX * dY);
		double SomE = (5260.52916 * dX) + (105.94684 * dX * dY) + 
		(2.45656 * dX * dY*dY) + (-0.81885 * dX*dX*dX) + 
		(0.05594 * dX * dY*dY*dY) + (-0.05607 * dX*dX*dX * dY) + 
		(0.01199 * dY) + (-0.00256 * dX*dX*dX * dY*dY) + (0.00128 * dX * pow(dY,4)) + 
		(0.00022 * dY*dY) + (-0.00022 * dX*dX) + (0.00026 * pow(dX,5));

		return new Point2D.Double(5.387206 + (SomE / 3600),52.15517 + (SomN / 3600));
	}

	/**
	 * http://pygps.org/#LatLongUTMconversion
	 * @param utm
	 * @param zone (1-60)
	 * @param northern if is in northern hemisphere
	 * @return latlon (lon=x,lat=y)
	 */
	public static Point2D.Double utm2LatLon(Point2D.Double utm,int zone,boolean northern){
		//		def UTMtoLL(ReferenceEllipsoid, northing, easting, zone):
		//			"""converts UTM coords to lat/long.  Equations from USGS Bulletin 1532 
		//			East Longitudes are positive, West longitudes are negative. 
		//			North latitudes are positive, South latitudes are negative
		//			Lat and Long are in decimal degrees. 
		//			Written by Chuck Gantz- chuck.gantz@globalstar.com
		//			Converted to Python by Russ Nelson <nelson@crynwr.com>"""

		double e1 = 0.081819191;

		double x = utm.x - 500000.0; //remove 500,000 meter offset for longitude;
		double y = utm.y;

		if(!northern){
			y -= 10000000.0 ;
		}

		int LongOrigin = (zone - 1)*6 - 180 + 3;  // +3 puts origin in middle of zone

		double eccPrimeSquared = (sm_EccSquared)/(1-sm_EccSquared);

		double M = y / UTMScaleFactor;
		double mu = M/(sm_a*(1-sm_EccSquared/4-3*sm_EccSquared*sm_EccSquared/64-5*pow(sm_EccSquared,3)/256));

		double phi1Rad = (mu + (3*e1/2-27*e1*e1*e1/32)*sin(2*mu)
				+ (21*e1*e1/16-55*e1*e1*e1*e1/32)*sin(4*mu)
				+(151*e1*e1*e1/96)*Math.sin(6*mu));
		//double phi1 = phi1Rad*rad2deg;

		double N1 = sm_a/sqrt(1-sm_EccSquared*sin(phi1Rad)*sin(phi1Rad));
		double T1 = tan(phi1Rad)*tan(phi1Rad);
		double C1 = eccPrimeSquared*cos(phi1Rad)*cos(phi1Rad);
		double R1 = sm_a*(1-sm_EccSquared)/pow(1-sm_EccSquared*sin(phi1Rad)*sin(phi1Rad), 1.5);
		double D = x/(N1*UTMScaleFactor);

		double Lat = phi1Rad - (N1*tan(phi1Rad)/R1)*(D*D/2-(5+3*T1+10*C1-4*C1*C1-9*eccPrimeSquared)*pow(D,4)/24
				+(61+90*T1+298*C1+45*T1*T1-252*eccPrimeSquared-3*C1*C1)*pow(D,5)/720);
		Lat = Lat * rad2deg;

		double Long = (D-(1+2*T1+C1)*D*D*D/6+(5-2*C1+28*T1-3*C1*C1+8*eccPrimeSquared+24*T1*T1)
				*pow(D,5)/120)/cos(phi1Rad);
		Long = LongOrigin + Long * rad2deg;
		return new Point2D.Double(Long,Lat);
	}

	public static int latLon2UTMzone(Point2D.Double latLon){
		double LongTemp = (latLon.x+180)-(int)((latLon.x+180)/360)*360-180;// # -180.00 .. 179.9
		return  (int)(((LongTemp + 180)/6) + 1);
	}
	/**
	 * 
	 *	def LLtoUTM(ReferenceEllipsoid, Lat, Long, zone = None):
	 *		"""converts lat/long to UTM coords.  Equations from USGS Bulletin 1532 
	 *		East Longitudes are positive, West longitudes are negative. 
	 *		North latitudes are positive, South latitudes are negative
	 *		Lat and Long are in decimal degrees
	 **
	 * @param utm
	 * @param zone
	 * @param northern
	 * @return
	 */
	public static Point2D.Double latLon2UTM(Point2D.Double latLon,int ZoneNumber){
		//#Make sure the longitude is between -180.00 .. 179.9
		double LongTemp = (latLon.x+180)-(int)((latLon.x+180)/360)*360-180;// # -180.00 .. 179.9

		double    LatRad = latLon.y*deg2rad;
		double     LongRad = LongTemp*deg2rad;

		if(latLon.y >= 56.0 && latLon.y < 64.0 && LongTemp >= 3.0 && LongTemp < 12.0){
			ZoneNumber = 32;
		}

		double LongOrigin = (ZoneNumber - 1)*6 - 180 + 3; //#+3 puts origin in middle of zone
		double LongOriginRad = LongOrigin * deg2rad;

		double eccPrimeSquared = (sm_EccSquared)/(1-sm_EccSquared);
		double N = sm_a/sqrt(1-sm_EccSquared*sin(LatRad)*sin(LatRad));
		double T = tan(LatRad)*tan(LatRad);
		double C = eccPrimeSquared*cos(LatRad)*cos(LatRad);
		double A = cos(LatRad)*(LongRad-LongOriginRad);

		double M = sm_a*((1
				- sm_EccSquared/4
				- 3*sm_EccSquared*sm_EccSquared/64
				- 5*pow(sm_EccSquared,3)/256)*LatRad 
				- (3*sm_EccSquared/8
						+ 3*sm_EccSquared*sm_EccSquared/32
						+ 45*pow(sm_EccSquared,3)/1024)*sin(2*LatRad)
						+ (15*sm_EccSquared*sm_EccSquared/256 + 45*pow(sm_EccSquared,3)/1024)*Math.sin(4*LatRad) 
						- (35*pow(sm_EccSquared,3)/3072)*sin(6*LatRad));

		double UTMEasting = (UTMScaleFactor*N*(A+(1-T+C)*A*A*A/6
				+ (5-18*T+T*T+72*C-58*eccPrimeSquared)*pow(A,5)/120)
				+ 500000.0);

		double UTMNorthing = (UTMScaleFactor*(M+N*Math.tan(LatRad)*(A*A/2+(5-T+9*C+4*C*C)*pow(A,4)/24
				+ (61-58*T+T*T+600*C-330*eccPrimeSquared)*pow(A,5)/720)));

		if(latLon.y< 0){
			UTMNorthing = UTMNorthing + 10000000.0; //#10000000 meter offset for southern hemisphere
		}
		return new Point2D.Double(UTMEasting, UTMNorthing);
	}
}