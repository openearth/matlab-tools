package klmUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class KmlUtils {
	public static void main(String[] args){
//		System.out.println(toKmz("D:\\openEarth\\kml\\deltares\\tgg\\boreholedata\\before_2010.kml",
//				null,
//				"D:\\openEarth\\kml\\deltares\\tgg\\boreholedata\\before_2010.kmz",true));

//		System.out.println(toKmz("D:\\openEarth\\kml\\deltares\\tgg.kml",
//				new String[]{"D:\\openEarth\\kml\\deltares\\tgg"},
//				"D:\\openEarth\\kml\\deltares\\tgg.kmz",false));
		System.out.println(toKmz("D:\\openEarth\\kml\\deltares\\tgg_local.kml",
				new String[]{"D:\\openEarth\\kml\\deltares\\files"},
				"D:\\openEarth\\kml\\deltares\\tgg_standalone.kmz",false));
	}

	public static void writeHeader(FileWriter fw) throws IOException {
		fw.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n");
		fw.write("<kml xmlns=\"http://earth.google.com/kml/2.2\">\r\n");
		fw.write("	<Document>\r\n");
	}

	public static void writeFooter(FileWriter fw) throws IOException {
		fw.write("	</Document>\r\n");
		fw.write("</kml>\r\n");
	}

	/*public static void writeTimeSpan(FileWriter fw) throws IOException {
		fw.write("	</Document>\r\n");
		fw.write("</kml>\r\n");
	}*/

	/**
	 * write camera position for the Netherlands
	 * @param fw
	 * @throws IOException
	 */
	public static void writeCamera(FileWriter fw) throws IOException {
		writeCamera(fw, 5,52.5f,30000);
	}

	public static void writeCamera(FileWriter fw, float lat, float lon, float alt) throws IOException {
		fw.write("		<Camera>\r\n");
		fw.write("  		<longitude>"+lat+"</longitude>\r\n");
		fw.write("			<latitude>"+lon+"</latitude>\r\n");
		fw.write("			<altitude>"+alt+"</altitude>\r\n");
		fw.write("		</Camera>\r\n");
	}

	/**
	 * packs a kml with with optionally directories to a kmz. 
	 * based on http://www.devx.com/tips/Tip/14049
	 * @param source source kml file
	 * @param directories directories that have to be added to kmz. Provide null if there are no directories
	 * @param target path of target including .kmz
	 * @param deleteKml if true, the original kml and subsirectories are deleted. This is only done if zipping was successfull
	 * @return
	 */
	public static boolean toKmz(String source, String[] directories, String target, boolean deleteKml){

		//	public static boolean toZip(String dir, String name, String target){
		System.out.println("creating "+target+"...");
		try { 
			//create a ZipOutputStream to zip the data to 
			ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(target));
			//call the zipDir method 
			zipDir(source,new File(source).getName(), zos);
			if(directories!=null){
				for(int i=0;i<directories.length;i++){
					String dir=new File(directories[i]).getName();
					zipDir(directories[i],"./"+dir, zos); 
				}
			}
			//close the stream 
			zos.close(); 
			
			if(deleteKml){
				new File(source).delete();
				if(directories!=null){
					for(int i=0;i<directories.length;i++){
						deleteDir(new File(directories[i])); 
					}
				}
			}
			return true;
		} 
		catch(Exception e) { 
			return false;
		} 
	}

	public static void zipDir(String sourceDir, String targetDir,ZipOutputStream zos){ 
		try { 
			//create a new File object based on the directory we have to zip File    
			File zipDir = new File(sourceDir); 
			//get a listing of the directory content 
			String[] dirList = zipDir.list(); 
			byte[] readBuffer = new byte[2156]; 
			int bytesIn = 0; 
			//loop through dirList, and zip the files 
			if(zipDir.isFile()){
				FileInputStream fis = new FileInputStream(zipDir); 
				//create a new zip entry 
				ZipEntry anEntry = new ZipEntry(targetDir); 
				//place the zip entry in the ZipOutputStream object 
				zos.putNextEntry(anEntry); 
				//now write the content of the file to the ZipOutputStream 
				while((bytesIn = fis.read(readBuffer)) != -1) { 
					zos.write(readBuffer, 0, bytesIn); 
				} 
				//close the Stream 
				fis.close(); 
			}else{
				for(int i=0; i<dirList.length; i++) { 
					File f = new File(zipDir, dirList[i]); 
					if(f.isDirectory()) { 
						//if the File object is a directory, call this 
						//function again to add its content recursively 
						String filePath = f.getPath(); 
						zipDir(filePath, targetDir+File.separator+dirList[i],zos); 
						//loop again 
						continue; 
					} 
					//if we reached here, the File object f was not a directory 
					//create a FileInputStream on top of f 
					FileInputStream fis = new FileInputStream(f); 
					//create a new zip entry 
					ZipEntry anEntry = new ZipEntry(targetDir+File.separator+dirList[i]); 
					//place the zip entry in the ZipOutputStream object 
					zos.putNextEntry(anEntry); 
					//now write the content of the file to the ZipOutputStream 
					while((bytesIn = fis.read(readBuffer)) != -1) { 
						zos.write(readBuffer, 0, bytesIn); 
					} 
					//close the Stream 
					fis.close(); 
				} 
			}
		} 
		catch(Exception e) { 
			e.printStackTrace(); 
		} 
	}
	static public boolean deleteDir(File path) {
		if(path.exists() ) {
			File[] files = path.listFiles();
			for(File file:files) {
				if(file.isDirectory()) {
					deleteDir(file);
				}
				else {
					if(!file.delete()){
						System.out.println("could not delete "+file.getAbsolutePath());
					}
				}
			}
		}
		return(path.delete());
	}
}
