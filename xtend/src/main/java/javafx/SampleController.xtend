package javafx;

import javafx.fxml.FXML
import javafx.scene.control.Menu
import javafx.scene.control.MenuBar
import javafx.scene.control.MenuItem
import org.redtank.util.LeftRightTreeBuilder
import org.redtank.util.LeftRightTreeItem
import javafx.scene.control.TreeView
import javafx.scene.control.TreeItem

class SampleController
{
	@FXML
	protected MenuBar menuBar;

	@FXML
	protected TreeView<String> treeView;

	protected def addMenu()
	{
		menuBar.menus.get(1).text = "ok"
	}

	val menuInfos = #[
		new MenuTreeItem(1, "Menu Bar", 1, 18),
		new MenuTreeItem(2, "食品", 2, 11),
		new MenuTreeItem(3, "肉类", 3, 6),
		new MenuTreeItem(4, "猪肉", 4, 5),
		new MenuTreeItem(5, "蔬菜类", 7, 10),
		new MenuTreeItem(6, "白菜", 8, 9),
		new MenuTreeItem(7, "电器", 12, 17),
		new MenuTreeItem(8, "电视机", 13, 14),
		new MenuTreeItem(9, "电冰箱", 15, 16)
	]

	def init()
	{
		val menuBuilder = new MenuTreeBuilder()
		val menu = menuBuilder.build(menuInfos)
		for (menuItem : menu.items)
			menuBar.menus.add(menuItem as Menu)
		menuBar.useSystemMenuBar = true

		val treeItemBuilder = new TreeViewItemBuilder()
		val treeItem = treeItemBuilder.build(menuInfos)
		treeItem.expanded = true
		treeView.root = treeItem
		treeView.editable = true
	}
}

class TreeViewItemBuilder extends LeftRightTreeBuilder<TreeItem<String>, TreeItem<String>, MenuTreeItem>
{

	override createRoot(MenuTreeItem leftRightTreeItem)
	{
		val treeItem = new TreeItem(leftRightTreeItem.text)
		return treeItem
	}

	override createNonLeaf(TreeItem<String> parent,
		MenuTreeItem leftRightTreeItem)
	{
		val treeItem = new TreeItem(leftRightTreeItem.text)
		parent.children.add(treeItem)
		return treeItem
	}

	override createLeaf(TreeItem<String> parent, MenuTreeItem leftRightTreeItem)
	{
		val treeItem = new TreeItem(leftRightTreeItem.text)
		parent.children.add(treeItem)
	}

}

class MenuTreeBuilder extends LeftRightTreeBuilder<Menu, MenuItem, MenuTreeItem>
{
	override createRoot(MenuTreeItem leftRightTreeItem)
	{
		val menu = new Menu(leftRightTreeItem.text)
		menu.userData = leftRightTreeItem
		return menu
	}

	override createNonLeaf(Menu parent, MenuTreeItem leftRightTreeItem)
	{
		val menu = new Menu(leftRightTreeItem.text)
		menu.userData = leftRightTreeItem
		parent.items.add(menu)
		return menu
	}

	override createLeaf(Menu parent, MenuTreeItem leftRightTreeItem)
	{
		val menuItem = new MenuItem(leftRightTreeItem.text)
		menuItem.userData = leftRightTreeItem
		parent.items.add(menuItem)
	}
}

class MenuTreeItem implements LeftRightTreeItem
{
	@Property
	int id

	@Property
	String text

	@Property
	int leftValue

	@Property
	int rightValue

	new(int id, String text, int leftValue, int rightValue)
	{
		this.id = id
		this.text = text
		this.leftValue = leftValue
		this.rightValue = rightValue
	}
}
