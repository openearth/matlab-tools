import javax.swing.JTree;
import javax.swing.tree.DefaultTreeCellRenderer;
import javax.swing.ImageIcon;
import java.awt.Component;

public class MTestTreeNodesRenderer extends DefaultTreeCellRenderer 
{
		public MTestTreeNodesRenderer() 
        {
        }

        public Component getTreeCellRendererComponent(JTree tree,Object value,boolean sel,boolean expanded,boolean leaf,int row,boolean hasFocus) 
        {
            super.getTreeCellRendererComponent(tree, value, sel,expanded, leaf, row,hasFocus);

            if ((value instanceof MTestMutableTreeNode) != true)
            	return this;
            
            MTestMutableTreeNode node = (MTestMutableTreeNode)value;
            
            if (node.getText() != null)
            {
            	setText(node.getText());
            }
            
            if (node.getIconUrl() != null)
            {
            	setIcon(new ImageIcon(node.getIconUrl()));
            }
            
            if (node.getToolTipText() != null)
            {
            	setToolTipText(node.getToolTipText());
            }
            
            return this;
        }
}