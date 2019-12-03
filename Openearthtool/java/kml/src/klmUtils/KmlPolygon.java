package klmUtils;

import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

/**
 * 
 * @author ir. Marco Kleuskens
 *
 */
public class KmlPolygon {
	ArrayList<Polygon> polygons;
	ArrayList<Style> styles;
	String path;

	public KmlPolygon(String path){
		this.path=path;
		polygons=new ArrayList<Polygon>();
		styles=new ArrayList<Style>();
	}

	public void addStyle(String styleName,String iconRefNormal,String iconRefHighlight){
		styles.add(new Style(styleName,iconRefNormal,iconRefHighlight));
	}

	public void addPolygon(String loc, boolean isClosed,String style,String name,String[][] descr, String[][] links, String timeStamp){
		polygons.add(new Polygon(loc,isClosed,style,name,descr,links,timeStamp));
	}
	public void addPolygon(String loc, boolean isClosed, String style,String name,String[][] descr, String[][] links){
		polygons.add(new Polygon(loc,isClosed,style,name,descr,links));
	}
	public void addPolygon(String loc, boolean isClosed, String style,String name,String[][] descr, String timeStamp){
		polygons.add(new Polygon(loc,isClosed,style,name,descr,timeStamp));
	}
	public void addPolygon(String loc, boolean isClosed, String style,String name,String[][] descr){
		polygons.add(new Polygon(loc,isClosed,style,name,descr));
	}
	/**
	 * adds a polygon/polyline to the last one. Both get the same description
	 * @param loc
	 * @param isClosed
	 */
	public void addPolygon(String loc, boolean isClosed){
		if(polygons.size()>0){
			polygons.get(polygons.size()-1).addData(loc,isClosed);
		}
	}

	public boolean write(){
		System.out.println("creating "+path);
		FileWriter fw;
		try {
			fw = new FileWriter(path, false);

			KmlUtils.writeHeader(fw);
			writeStyles(fw);
			writePlaceMarks(fw);
			KmlUtils.writeFooter(fw);
			fw.close();

		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}

	private void writePlaceMarks(FileWriter fw) throws IOException {
		for(int i=0;i<polygons.size();i++){
			polygons.get(i).write(fw);
		}
	}

	private void writeStyles(FileWriter fw) throws IOException {
		for(int i=0;i<styles.size();i++){
			styles.get(i).write(fw);
		}
	}

	public class Polygon{
		String name;
		String style;
		String timeStamp=null;
		String[][] desc=null;
		String[][] links=null;
		ArrayList<Boolean> isClosed=new ArrayList<Boolean>();
		ArrayList<String> coordinates=new ArrayList<String>();

		public Polygon(String loc, boolean isClosed, String style, String name,
				String[][] descr, String[][] links, String timeStamp) {
			addData(loc,isClosed,style,name,descr);
			this.links=links;
			this.timeStamp=timeStamp;
		}

		public Polygon(String loc, boolean isClosed, String style, String name,
				String[][] descr, String[][] links) {
			addData(loc,isClosed,style,name,descr);
			this.links=links;
		}

		public Polygon(String loc, boolean isClosed, String style, String name,
				String[][] descr, String timeStamp) {
			addData(loc,isClosed,style,name,descr);
			this.timeStamp=timeStamp;
		}

		public Polygon(String loc, boolean isClosed, String style, String name,
				String[][] descr) {
			addData(loc,isClosed,style,name,descr);
		}

		private void addData(String loc, boolean isClosed, String style, String name,
				String[][] descr) {
			addData(loc,isClosed);
			this.name=name;
			this.style=style;
			this.desc=descr;
		}
		private void addData(String loc, boolean isClosed) {
			this.isClosed.add(isClosed);
			this.coordinates.add(loc);
		}

		public void write(FileWriter fw) throws IOException{
			fw.write("		<Placemark>\r\n");
			fw.write("			<name>"+name+"</name>\r\n");
			if(timeStamp!=null){
				fw.write("			<TimeStamp><when>"+timeStamp+"</when></TimeStamp>\r\n");
			}
			fw.write("			<description><![CDATA[<hr>\r\n");
			if(links!=null){
				for(int i=0;i<links.length;i++){
					fw.write("			<br><A href = \""+links[i][0]+"\">"+links[i][1]+"</A>\r\n");
				}
				fw.write("			<br>\r\n");
			}	
			if(desc!=null){
				fw.write("			<br><table border=\"1\"> <tr>\r\n");
				for(int i=0;i<desc.length;i++){
					fw.write("			");
					for(int j=0;j<desc[i].length;j++){
						fw.write("<td>"+desc[i][j]+"</td>");
					}
					fw.write("</tr>\r\n");
				}
				fw.write("			</table>");
			}
			fw.write("			<br>Provided by:<img src=\"https://public.deltares.nl/download/attachments/16876019/OET?version=1\" " +
			"align=\"right\" width=\"100\"/>]]></description>\r\n");
			fw.write("			<styleUrl>#"+style+"</styleUrl>\r\n");
			for(int i=0;i<isClosed.size();i++){
				if(isClosed.get(i)){ //polygon
					fw.write("			<Polygon>\r\n");
					fw.write("				<extrude>1</extrude>\r\n");
					fw.write("				<altitudeMode>relativeToGround</altitudeMode>\r\n");
					fw.write("				<outerBoundaryIs><LinearRing><coordinates>"+coordinates.get(i)+"</coordinates></LinearRing></outerBoundaryIs>\r\n");
					fw.write("			</Polygon>\r\n");
				}else{  //line
					fw.write("			<LineString>\r\n");
					fw.write("				<coordinates>"+coordinates.get(i)+"</coordinates>\r\n");
					fw.write("			</LineString>\r\n");
				}
			}
			fw.write("		</Placemark>\r\n");
		}
	}

	public class Style{
		String id;
		String colorNormal;
		String colorHighlight;
		public Style(String id,String iconRefNormal,String iconRefHighlight){
			this.id=id;
			this.colorNormal=iconRefNormal;
			this.colorHighlight=iconRefHighlight;
		}

		public void write(FileWriter fw) throws IOException{
			fw.write("	<StyleMap id=\""+id+"\">\r\n");
			fw.write("		<Pair><key>normal</key><styleUrl>#"+id+"_normal</styleUrl></Pair>\r\n");
			fw.write("		<Pair><key>highlight</key><styleUrl>#"+id+"_highlight</styleUrl></Pair>\r\n");
			fw.write("	</StyleMap>\r\n");
			fw.write("	<Style id=\""+id+"_normal\">\r\n");
			fw.write("		 <LineStyle>\r\n");
			fw.write("			 <width>3</width>\r\n");
			fw.write("			 <color>"+colorNormal+"</color>\r\n");
			fw.write("		 </LineStyle>\r\n");
			fw.write("	</Style>\r\n");
			fw.write("	<Style id=\""+id+"_highlight\">\r\n");
			fw.write("		<BalloonStyle><text>\r\n");
			fw.write("			<h3>$[name]</h3> $[description]\r\n");
			fw.write("			</text>\r\n");
			fw.write("		</BalloonStyle>\r\n");
			fw.write("		 <LineStyle>\r\n");
			fw.write("			 <width>5</width>\r\n");
			fw.write("			 <color>"+colorHighlight+"</color>\r\n");
			fw.write("		 </LineStyle>\r\n");
			fw.write("	</Style>\r\n");
		}
	}	
}

