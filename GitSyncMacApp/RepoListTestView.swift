import Cocoa
@testable import Utils
@testable import Element
@testable import GitSyncMac

class RepoListTestView:TitleView{
    var treeList:TreeList?
    override init(_ width:CGFloat, _ height:CGFloat, _ parent:IElement? = nil, _ id:String? = "") {
        //self.title = "Resolve merge conflict:"//Title: Resolve sync conflict:
        super.init(width, height, parent, "listTransitionTestView")
    }
    override func resolveSkin() {
        Swift.print("RepoListTestView.resolveSkin()")
        super.resolveSkin()
        Swift.print(ElementParser.stackString(self))
        createGUI()
    }
    func createGUI(){
        let xml:XML = FileParser.xml("~/Desktop/assets/xml/treelist.xml".tildePath)
        treeList = addSubView(SliderTreeList(140, 192, 24, Node(xml),self))
        
        treeList!.event = onTreeListEvent//add event listener
        
        
        Swift.print("selected: " + "\(TreeListParser.selected(treeList!))")
        Swift.print("selectedIndex: " + "\(TreeListParser.selectedIndex(treeList!))")//Output:  [2,2,0]
        Swift.print("selected Title: " + "\(XMLParser.attributesAt(treeList!.node.xml, TreeListParser.selectedIndex(treeList!))!["title"])")//Output: Oregano
        TreeListModifier.unSelectAll(treeList!)
        
        TreeListModifier.selectAt(treeList!, [2])
        TreeListModifier.collapseAt(treeList!, [])//closes the treeList
        TreeListModifier.explodeAt(treeList!,[])//opens the treeList
        
        _ = treeList!.node.removeAt([1])
        treeList!.node.addAt([1], "<item title=\"Fish\"/>".xml)/*new*/
    }
    func onTreeListEvent(event:Event) {//adds local event handler
        if(event.type == SelectEvent.select && event.immediate === treeList){
            Swift.print("event.origin: " + "\(event.origin)")
            
            let selectedIndex:Array = TreeListParser.selectedIndex(treeList!)
            Swift.print("selectedIndex: " + "\(selectedIndex)")
            //print("_scrollTreeList.database.xml.toXMLString(): " + _scrollTreeList.database.xml.toXMLString());
            let selectedXML:XML = XMLParser.childAt(treeList!.node.xml, selectedIndex)!
            //print("selectedXML: " + selectedXML);
            Swift.print("selectedXML.toXMLString():")
            Swift.print(selectedXML)//EXAMPLE output: <item title="Ginger"></item>
        }
    }
    override func mouseUpInside(_ event:MouseEvent) {
        Swift.print("mouseUpInside: " + "\(event)")
        super.mouseUpInside(event)
    }
    override func rightMouseUp(with event: NSEvent) {
        Swift.print("rightMouseUp: " + "\(event)")
        super.rightMouseUp(with:event)
        popUpMenu(event)
    }
    
    func newFolder(sender: AnyObject) {
        Swift.print("newFolder")
    }
    func newRepo(sender: AnyObject) {
        Swift.print("newRepo")
    }
    func rename(sender: AnyObject) {
        Swift.print("rename")
    }
    func cut(sender: AnyObject) {
        Swift.print("cut")
    }
    func paste(sender: AnyObject) {
        Swift.print("paste")
    }
    func delete(sender: AnyObject) {
        Swift.print("delete")
    }
    func popUpMenu(_ event:NSEvent) {
        Swift.print("popUpMenu: " + "\(popUpMenu)" )
        let menu = NSMenu(title: "Contextual menu")
        let menuItems:[(title:String,selector:Foundation.Selector)] = [("New folder", #selector(newFolder)),("New repo", #selector(newRepo)),("Rename", #selector(rename)),("Cut", #selector(cut)),("Paste", #selector(paste)),("Delete", #selector(delete))]
        menuItems.forEach{
            let action1MenuItem = NSMenuItem(title: $0.title, action: $0.selector, keyEquivalent: "")
            menu.addItem(action1MenuItem)
        }
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    required init(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}
