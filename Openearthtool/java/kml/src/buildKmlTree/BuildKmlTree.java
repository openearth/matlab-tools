package buildKmlTree;

import io.FileSelector;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.ZipOutputStream;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.UIManager;

import klmUtils.KmlRef;
import klmUtils.KmlUtils;

/**
 * This program gathers all kmls in a directory structure by grouping them per directory.
 * for instance:
 * 
 *
 * <ul>
 * <li>tgg
 * <ul><li>boreholedata
 *	<ul><li>before_2010.kml
 *		<li>2011.kml
 *	</ul><li>side_scan_sonar
 *	<ul><li>		projectA.kml
 *		<li>	projectB.kml
 *</ul></ul></ul>
 * <p>
 *
 * if tgg is selected, the folowing kml's are made:
 * 
 *	<ul><li>tgg.kml, containing tgg\boreholedata.kml and tgg\side_scan_sonar.kml
 *	<li>tgg
 *	<ul><li>	boreholedata.kml, containing boreholedata\before_2010.kml and boreholedata\2011.kml
 *	<li>	boreholedata
 *	<ul><li>		before_2010.kml
 *	<li>		2011.kml
 *	</ul><li>	side_scan_sonar.kml containing side_scan_sonar\projectA.kml and side_scan_sonar\projectB.kml
 *	<li>	side_scan_sonar
 *	<ul><li>		projectA.kml
 *	<li>	projectB.kml
 *</ul></ul></ul>
 * <p>
 *
 *WARNING: if a directory contains a kml file and a subdirectory with the same name, the kml file is overwritten!!!
 *
 */

public class BuildKmlTree {
	public static void main(String[] args) {
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());


			boolean debug=true;

			File dir=null;
			String dirName=null;
			String reposLoc=null;

			if(debug){
				dir=new File("D:\\openearth\\kml\\deltares\\tgg");
				dirName=dir.getName();
				reposLoc="http://kml.deltares.nl/kml/deltares/tgg";
			}else{
				RedirectedFrame outputFrame = new RedirectedFrame(true, false, null, 700, 600, JFrame.EXIT_ON_CLOSE);

				dir=getDir("", "select a directory that contains kml files");
				dirName=dir.getName();
				String webRoot="http://kml.deltares.nl/kml/deltares/tgg";
				reposLoc=FileSelector.getWebLoc(dir.getAbsolutePath(), webRoot,outputFrame);
			}

			//delete old linked files
			deleteRefKmls(dir.getParentFile());

			//copy directory tree into [name]_local
			File filesDir=new File(dir.getAbsoluteFile()+"_local");
			copyDirectory(dir, filesDir);


			processDir(dir.getAbsolutePath(),reposLoc);
			processDir(filesDir.getAbsolutePath(),null);

			//store everything into zip.
			String target=filesDir.getAbsolutePath()+".zip";
			String kmlLocal=filesDir.getAbsolutePath()+".kml";
			System.out.println("creating "+target+"...");
			//create a ZipOutputStream to zip the data to 
			ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(target));
			//call the zipDir method 
			KmlUtils.zipDir(kmlLocal,new File(kmlLocal).getName(), zos);
			KmlUtils.zipDir(filesDir.getAbsolutePath(),filesDir.getName(), zos); 
			//close the stream 
			zos.close(); 
			KmlUtils.deleteDir(filesDir);
			new File(kmlLocal).delete();
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}

	private static boolean processDir(String dir, String reposLoc){
		System.out.println("searching in "+dir);
		File file=new File(dir);
		String[] children=file.list();

		//first, process all directories;
		for(String child:children){
			if(new File(dir+File.separator+child).isDirectory()){
				if(reposLoc==null){
					processDir(dir+File.separator+child,null);
				}else{
					processDir(dir+File.separator+child,reposLoc+"/"+child);
				}
			}
		}
		
		children=file.list();
		//next, add all kml files.
		KmlRef kmlRef=new KmlRef(dir+".kml");
		for(String child:children){
			if(child.endsWith(".kml")||child.endsWith(".kmz")){
				if(reposLoc==null){
					kmlRef.addKml(file.getName()+"/"+child);
				}else{
					kmlRef.addKml(reposLoc+"/"+child);
				}
			}
		}
		kmlRef.write(); //this happens only when kmlRef contains 1 or more kmls.
		return true;
	}

	/*	private static boolean processDir(String dir){
		System.out.println("searching in "+dir);
		File file=new File(dir);
		String[] children=file.list();

		//first, process all directories;
		for(String child:children){
			if(new File(dir+File.separator+child).isDirectory()){
				processDir(dir+File.separator+child);
			}
		}
		//next, add all kml files.
		KmlRef kmlRef=new KmlRef(dir+".kml");
		for(String child:children){
			if(child.endsWith(".kml")){
				kmlRef.addKml(file.getName()+File.separator+child);
			}
		}
		kmlRef.write(); //this happens only when kmlRef contains 1 or more kmls.
		return true;
	}*/

	public static File getDir(String path,String header){
		File file=null;
		JFileChooser chooser = new JFileChooser(path);
		chooser.setDialogTitle(header);
		chooser.setMultiSelectionEnabled(false);
		chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		if(chooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
			path=chooser.getSelectedFile().getPath();
			file = chooser.getSelectedFile();
		}  
		return file;
	}

	// If targetLocation does not exist, it will be created.
	//http://www.java-tips.org/java-se-tips/java.io/how-to-copy-a-directory-from-one-location-to-another-loc.html
	public static void copyDirectory(File sourceLocation , File targetLocation)
	throws IOException {

		if (sourceLocation.isDirectory()) {
			if (!targetLocation.exists()) {
				targetLocation.mkdir();
			}

			String[] children = sourceLocation.list();
			for (int i=0; i<children.length; i++) {
				copyDirectory(new File(sourceLocation, children[i]),
						new File(targetLocation, children[i]));
			}
		} else {

			InputStream in = new FileInputStream(sourceLocation);
			OutputStream out = new FileOutputStream(targetLocation);

			// Copy the bits from instream to outstream
			byte[] buf = new byte[1024];
			int len;
			while ((len = in.read(buf)) > 0) {
				out.write(buf, 0, len);
			}
			in.close();
			out.close();
		}
	}

	public static void deleteRefKmls(File sourceLocation)throws IOException{
		if (sourceLocation.isDirectory()) {
			String[] children = sourceLocation.list();
			for (int i=0; i<children.length; i++) {
				if(children[i].endsWith(".kml")){
					File file=new File(sourceLocation,children[i].replace(".kml", ""));
					if(file.isDirectory()){
						new File(sourceLocation,children[i]).delete();
					}
				}else{
					File file=new File(sourceLocation,children[i]);
					if(file.isDirectory()){
						deleteRefKmls(file);
					}
				}
			}
		}
	}
}
