import javax.swing.tree.DefaultMutableTreeNode;

public class MTestMutableTreeNode extends DefaultMutableTreeNode 
{
	private String nodeText;
	private String iconUrl;
	private String toolTipText;

	public MTestMutableTreeNode()
	{
	}
	
	public MTestMutableTreeNode(String text)
	{
		setText(text);
	}
	
	public void setText(String text)
	{
		nodeText = text;
	}
	public String getText()
	{
		return nodeText;
	}
	
	public void setToolTipText(String text)
	{
		toolTipText = text;
	}
	
	public String getToolTipText()
	{
		return toolTipText;
	}
	
	public void setIconUrl(String url)
	{
		iconUrl = url;
	}
	
	public String getIconUrl()
	{
		return iconUrl;
	}
}
