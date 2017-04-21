import Cocoa
@testable import Element
@testable import Utils

class TreeList3:ScrollFastList3{
    var treeDP:TreeDP2 {return dp as! TreeDP2}
    override func reUse(_ listItem:FastListItem) {
        let idx3d:[Int] = treeDP.hashList[listItem.idx]
        listItem.item.id = idx3d.count.string/*the indentation level (from 1 and up)*/
        listItem.item.setSkinState(listItem.item.getSkinState())
        
        if let checkable = listItem.item as? ICheckable, let isOpenStr = TreeDP2Parser.getProp(treeDP, idx3d, "isOpen"){
            let isChecked = isOpenStr == "true"
            checkable.setChecked(isChecked)/*Sets correct open/close icon*/
        }
        super.reUse(listItem)/*sets text and position and select state*/
    }
    override func createItem(_ index:Int) -> Element {
        let hasChildren:Bool = TreeDP2Asserter.hasChildren(treeDP, index)
        return hasChildren ? Utils.createTreeListItem(itemSize,contentContainer!) : super.createItem(index)/*Create SelectTextButton*/
    }
    override func onEvent(_ event: Event) {
        if(event.type == CheckEvent.check /*&& event.immediate === itemContainer*/){onItemCheck(event as! CheckEvent)}
        else if(event.type == SelectEvent.select /*&& event.immediate === itemContainer*/){onItemSelect(event as! SelectEvent)}
        super.onEvent(event)
    }
    override func getClassType() -> String {
        return "\(TreeList3.self)"
    }
}
extension TreeList3{
    /**
     * NOTE: This method gets all CheckEvent's from all decending ICheckable instances
     */
    func onItemCheck(_ event:CheckEvent) {
        Swift.print("onItemCheck")
        Swift.print("event.origin: " + "\(event.origin)")
        let idx2d:Int = contentContainer!.indexOf(event.origin as! NSView)
        let isOpen:Bool = TreeDP2Parser.getProp(treeDP, idx2d, "isOpen") == "true"
        if(isOpen){
            Swift.print("close 🚫")
            TreeDP2Modifier.close(treeDP, idx2d)
        }else{
            Swift.print("open ✅")
            TreeDP2Modifier.open(treeDP, idx2d)
        }
        
        /*if let element = event.origin as? IElement{
         Swift.print("Stack: " + "\(ElementParser.stackString(element))")
         //Swift.print("element.id: " + "\(element.id)")
         }*/
        //onEvent(TreeListEvent(TreeListEvent.change,self))
    }
    func onItemSelect(_ event:SelectEvent){
        Swift.print("onItemSelect")
    }
}
private class Utils{
    /*create TreeItem*/
    static func createTreeListItem(_ itemSize:CGSize, _ parent:Element) -> TreeList3Item{
        let item:TreeList3Item = TreeList3Item(itemSize.width, itemSize.height ,"", false, false, parent)
        parent.addSubview(item)
        return item
    }
}
