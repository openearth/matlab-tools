package io;

import java.awt.Component;
import java.io.File;

import javax.swing.JFileChooser;
import javax.swing.JOptionPane;

public class FileSelector {
	/**
	 * gets all files from the selected directory
	 * @param path
	 * @param header
	 * @return
	 */
	public static File[] getFiles(String path,String header){
		File[] files=null;
		JFileChooser chooser = new JFileChooser(path);
		chooser.setDialogTitle(header);
		chooser.setMultiSelectionEnabled(true);
		if(chooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
			path=chooser.getSelectedFiles()[0].getPath();
			files = chooser.getSelectedFiles();
		}  
		return files;
	}

	/**
	 * gets all files from the selected directory
	 * @param path
	 * @param header
	 * @return
	 */
	public static File getFile(String path,String header){
		File file=null;
		JFileChooser chooser = new JFileChooser(path);
		chooser.setDialogTitle(header);
		chooser.setMultiSelectionEnabled(false);
		if(chooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
			path=chooser.getSelectedFile().getPath();
			file = chooser.getSelectedFile();
		}  
		return file;
	}

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
	
	/**
	 * a display that generates a weblocation.
	 * for instance, if path="D:\\openEarth\\openearthRawData\\deltares\\tgg\\boreholedata\\raw\\before_2010"
	 * en webRoot="https://repos.deltares.nl/repos/openearthrawdata/trunk/deltares/tgg/boreholedata/", the suggestion becomes
	 * "https://repos.deltares.nl/repos/openearthrawdata/trunk/deltares/tgg/boreholedata/raw/before_2010"
	 * 
	 * @param path 
	 * @param webRoot
	 * @param comp parent screen
	 * @return
	 */
	public static String getWebLoc(String path, String webRoot,Component comp){
		//path="D:\\openEarth\\openearthRawData\\deltares\\tgg\\boreholedata\\raw\\before_2010";
		//String webRoot="https://repos.deltares.nl/repos/openearthrawdata/trunk/deltares/tgg/boreholedata/";
		path=path.replace("\\", "/").toLowerCase();
		int webRootLength=webRoot.length();
		int pathLength=path.length();
		int i=Math.min(webRootLength,pathLength);
		String webLoc=webRoot;
		while(i>0){ //first try the longest possible overlap. if this fails, try a smaller one
			String webRootSub=webRoot.substring(webRootLength-i);
			if(path.contains(webRootSub)){
				int j=path.indexOf(webRootSub);
				webLoc=webRoot+path.substring(i+j);
				break;
			}
			i--;
		}
		
		return (String)JOptionPane.showInputDialog(
						comp,
		                    "select location at server",
		                    "Open Earth Tools",
		                    JOptionPane.PLAIN_MESSAGE,
		                    null,null,webLoc);
	}
}
