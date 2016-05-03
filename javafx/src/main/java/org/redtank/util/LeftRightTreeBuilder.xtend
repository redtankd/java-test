package org.redtank.util

import java.util.List
import java.util.Stack

/**
 * the builder for the left-right tree, which has only a root node
 */
abstract class LeftRightTreeBuilder<NONLEAF, LEAF, TREEITEM extends LeftRightTreeItem>
{

	/**
	 * @return a new root node
	 */
	def abstract NONLEAF createRoot(TREEITEM leftRightTreeItem)

	/**
	 * 
	 * @return a new non-leaf node, the child of the parent non-leaf node
	 */
	def abstract NONLEAF createNonLeaf(NONLEAF parent,
		TREEITEM leftRightTreeItem)

	/**
	 * create a new leaf node, the child of the parent non-leaf node 
	 */
	def abstract void createLeaf(NONLEAF parent, TREEITEM leftRightTreeItem)

	def NONLEAF build(List<TREEITEM> leftRightTreeItems)
	{
		var NONLEAF root = null

		val nonLeafStack = new Stack<NONLEAF>
		var NONLEAF parent = null

		val leftRightTreeItemStack = new Stack<LeftRightTreeItem>
		var LeftRightTreeItem parentLeftRightTreeItem = null

		for (leftRightTreeItem : leftRightTreeItems)
		{
			while (parent != null && leftRightTreeItem.leftValue >
				parentLeftRightTreeItem.rightValue)
			{ // back to the up level
				if (nonLeafStack.empty())
				{
					parent = null
					parentLeftRightTreeItem = null
				}
				else
				{
					parent = nonLeafStack.pop()
					parentLeftRightTreeItem = leftRightTreeItemStack.pop()
				}
			}

			if (leftRightTreeItem.rightValue - leftRightTreeItem.leftValue > 1)
			{ // a non-leaf node
				if (root == null)
				{ //  the root node
					root = createRoot(leftRightTreeItem)
					parent = root
					parentLeftRightTreeItem = leftRightTreeItem
				}
				else
				{
					nonLeafStack.push(parent)
					leftRightTreeItemStack.push(parentLeftRightTreeItem)
					parent = createNonLeaf(parent, leftRightTreeItem)
					parentLeftRightTreeItem = leftRightTreeItem
				}
			}
			else if (leftRightTreeItem.rightValue - leftRightTreeItem.leftValue ==
				1)
			{ // a leaf node 
				createLeaf(parent, leftRightTreeItem)
			}
		}

		return root
	}
}

interface LeftRightTreeItem
{
	def int getLeftValue()

	def int getRightValue()

	def void setLeftValue(int value)

	def void setRightValue(int value)
}
