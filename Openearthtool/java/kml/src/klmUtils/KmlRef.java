package klmUtils;

import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

/**
 * builds a kml file that refers to other kml files
 * @author ir. Marco Kleuskens
 *
 */

public class KmlRef {
	ArrayList<String> list;
	String path;
	public KmlRef(String path){
		this.path=path;
		list=new ArrayList<String>();
	}
	public String getPath(){
		return path;
	}

	
	public void addKml(String path){
		System.out.println("adding "+path+" to "+this.path);
		path=path.replace("\\","/");
		list.add(path);
	}

	public boolean write(){
		if(list.size()>0){
			String kmlFile=path;
			System.out.println("creating "+kmlFile);
			FileWriter fw;
			try {
				fw = new FileWriter(kmlFile, false);

				KmlUtils.writeHeader(fw);
				//fw.write("<TimeSpan>\r\n");
				//fw.write("  <begin>1950</begin>\r\n");
				//fw.write("  <end>2015</end>    \r\n");
				//fw.write("</TimeSpan>\r\n");
				fw.write("<name>"+getName(path)+"</name>\r\n");
				fw.write("<description>all data of "+getName(path)+"</description>\r\n");
				fw.write("<visibility>1</visibility>\r\n");
				fw.write("<open>1</open>\r\n");

				writeNetWorkLinks(fw);

				KmlUtils.writeFooter(fw);

				fw.close();

			} catch (IOException e) {
				e.printStackTrace();
				return false;
			}
		}
		return true;
	}

	private void writeNetWorkLinks(FileWriter fw) throws IOException {
		for(int i=0;i<list.size();i++){
			fw.write("	<NetworkLink>\r\n");
			fw.write("		<name>"+getName(list.get(i))+"</name>\r\n");
			fw.write("		<Link>\r\n");
			fw.write("			<href>"+list.get(i)+"</href>\r\n");
			fw.write("		</Link>\r\n");
			fw.write("	</NetworkLink>\r\n");
		}
	}

	/**
	 * if input is "tgg\boreholedata.kml" the output is "boreholedata"
	 * @param string 
	 * @return
	 */
	private String getName(String string){
		int slashIndex=Math.max(string.lastIndexOf("/"),string.lastIndexOf("\\"));
		int pointIndex=string.lastIndexOf(".");
		if(slashIndex>0&&pointIndex>slashIndex){
			return string.substring(slashIndex+1,pointIndex);
		}else{
			return string;
		}
	}
}
