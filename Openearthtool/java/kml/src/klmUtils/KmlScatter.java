package klmUtils;

import java.awt.Point;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

public class KmlScatter {
	ArrayList<Placemark> placemarks;
	ArrayList<Style> styles;
	String path;

	public KmlScatter(String path){
		this.path=path;
		placemarks=new ArrayList<Placemark>();
		styles=new ArrayList<Style>();
	}

	public void addStyle(String styleName,String iconRefNormal,String iconRefHighlight){
		styles.add(new Style(styleName,iconRefNormal,iconRefHighlight));
	}

	public void addPlaceMark(float x, float y, String style,String name,String[][] descr, String[][] links, String timeStamp){
		placemarks.add(new Placemark(x,y,style,name,descr,links,new String[]{timeStamp}));
	}
	public void addPlaceMark(float x, float y, String style,String name,String[][] descr, String[][] links, String[] timeSpan){
		placemarks.add(new Placemark(x,y,style,name,descr,links,timeSpan));
	}
	public void addPlaceMark(float x, float y, String style,String name,String[][] descr, String[][] links){
		placemarks.add(new Placemark(x,y,style,name,descr,links));
	}
	public void addPlaceMark(float x, float y, String style,String name,String[][] descr, String timeStamp){
		placemarks.add(new Placemark(x,y,style,name,descr,new String[]{timeStamp}));
	}
	public void addPlaceMark(float x, float y, String style,String name,String[][] descr, String[] timeSpan){
		placemarks.add(new Placemark(x,y,style,name,descr,timeSpan));
	}
	public void addPlaceMark(float x, float y, String style,String name,String[][] descr){
		placemarks.add(new Placemark(x,y,style,name,descr));
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
		for(int i=0;i<placemarks.size();i++){
			placemarks.get(i).write(fw);
		}
	}

	private void writeStyles(FileWriter fw) throws IOException {
		for(int i=0;i<styles.size();i++){
			styles.get(i).write(fw);
		}
	}

	public class Placemark{
		String name;
		String style;
		String coordinates;
		String[] timeStamp=null;
		String[][] desc=null;
		String[][] links=null;

		public Placemark(float x, float y, String style, String name,
				String[][] descr, String[][] links, String[] timeStamp) {
			this.name=name;
			this.style=style;
			coordinates=x+","+y+",0.000000";
			this.desc=descr;
			this.links=links;
			this.timeStamp=timeStamp;
		}

		public Placemark(float x, float y, String style, String name,
				String[][] descr, String[][] links) {
			this.name=name;
			this.style=style;
			coordinates=x+","+y+",0.000000";
			this.desc=descr;
			this.links=links;
		}
		
		public Placemark(float x, float y, String style, String name,
				String[][] descr, String[] timeStamp) {
			this.name=name;
			this.style=style;
			coordinates=x+","+y+",0.000000";
			this.desc=descr;
			this.timeStamp=timeStamp;
		}

		public Placemark(float x, float y, String style, String name,
				String[][] descr) {
			this.name=name;
			this.style=style;
			coordinates=x+","+y+",0.000000";
			this.desc=descr;
		}

		public void write(FileWriter fw) throws IOException{
			fw.write("		<Placemark>\r\n");
			fw.write("			<name>"+name+"</name>\r\n");
			if(timeStamp!=null){
				if(timeStamp.length>1){
					fw.write("			<TimeSpan><begin>"+timeStamp[0]+"</begin>\r\n");
					fw.write("			<end>"+timeStamp[1]+"</end></TimeSpan>\r\n");
				}else{
				fw.write("			<TimeStamp><when>"+timeStamp[0]+"</when></TimeStamp>\r\n");
				}
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
			fw.write("			<Point>\r\n");
			fw.write("				<coordinates>"+coordinates+"</coordinates>\r\n");
			fw.write("			</Point>\r\n");
			fw.write("		</Placemark>\r\n");
		}
	}

	public class Style{
		String id;
		String iconRefNormal;
		String iconRefHighlight;
		public Style(String id,String iconRefNormal,String iconRefHighlight){
			this.id=id;
			this.iconRefNormal=iconRefNormal;
			this.iconRefHighlight=iconRefHighlight;
		}

		public void write(FileWriter fw) throws IOException{
			fw.write("	<StyleMap id=\""+id+"\">\r\n");
			fw.write("		<Pair><key>normal</key><styleUrl>#"+id+"_normal</styleUrl></Pair>\r\n");
			fw.write("		<Pair><key>highlight</key><styleUrl>#"+id+"_highlight</styleUrl></Pair>\r\n");
			fw.write("	</StyleMap>\r\n");
			fw.write("	<Style id=\""+id+"_normal\">\r\n");
			fw.write("		 <IconStyle>\r\n");
			fw.write("			 <scale>1</scale>\r\n");
			fw.write("			 <Icon><href>"+iconRefNormal+"</href></Icon>\r\n");
			fw.write("		 </IconStyle>\r\n");
			fw.write("		 <LabelStyle><color>000000ff</color><scale>0</scale></LabelStyle>\r\n");
			fw.write("	</Style>\r\n");
			fw.write("	<Style id=\""+id+"_highlight\">\r\n");
			fw.write("		<BalloonStyle><text>\r\n");
			fw.write("			<h3>$[name]</h3> $[description]\r\n");
			fw.write("			</text>\r\n");
			fw.write("		</BalloonStyle>\r\n");
			fw.write("		<IconStyle>\r\n");
			fw.write("			<scale>2</scale>\r\n");
			fw.write("		 	<Icon><href>"+iconRefHighlight+"</href></Icon>\r\n");
			fw.write("		</IconStyle>\r\n");
			fw.write("	</Style>\r\n");
		}
	}	
}
