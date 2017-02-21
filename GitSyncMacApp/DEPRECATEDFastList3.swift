import Foundation
@testable import Utils
@testable import Element

class FastList3:Element,IList{
    var itemHeight:CGFloat/*The list item height, each item must have the same height*/
    var dataProvider:DataProvider/*data storage*/
    var lableContainer:Container?/*holds the list items*/
    var maxVisibleItems:Int?/*this will be calculated on init and on setSize calls*/
    var prevVisibleRange:Range<Int>?/*PrevVisibleRange is set on each frame tick and is used to calc how many new items that needs to be rendered/removed*/
    //var visibleItems:[FastListItem] = []//fastlistitem also stores the absolute integer that cooresponds to the db.item
    var pool:[FastListItem] = []
    init(_ width:CGFloat, _ height:CGFloat, _ itemHeight:CGFloat = NaN,_ dataProvider:DataProvider? = nil, _ parent:IElement?, _ id:String? = nil){
        self.itemHeight = itemHeight
        self.dataProvider = dataProvider ?? DataProvider()/*<--if it's nil then a DB is created*/
        super.init(width, height, parent, id)
        self.dataProvider.event = self.onEvent/*Add event handler for the dataProvider*/
        //layer!.masksToBounds = true/*masks the children to the frame, I don't think this works...seem to work now*/
    
    }
    var greenRect:RectGraphic?/*green rect that represents the range to render (everything inside this rect must be rendered) (it goes in the itemContainer)*/
    var purpleRect:RectGraphic?/*purple rect that represents the buffer area, 1-item above top and 1-item bellow bottom*/
    
    override func resolveSkin() {
        super.resolveSkin()
        maxVisibleItems = round(height / itemHeight).int//TODO: use floor not round
        lableContainer = addSubView(Container(width,height,self,"lable"))
        
        /*red rect above where the mask is*/
        let redFrame:CGRect = CGRect(1,1,width,height)
        let redRect = RectGraphic(redFrame.x,redFrame.y,redFrame.size.width,redFrame.size.height,nil,LineStyle(1,.red))
        addSubview(redRect.graphic)
        redRect.draw()
        
        /*blue rect above all the items in the itemContainer (use itemsHeight)*/
        let blueFrame:CGRect = CGRect(0,0,width,itemsHeight)
        let blueRect = RectGraphic(blueFrame.x,blueFrame.y,blueFrame.size.width,blueFrame.size.height,nil,LineStyle(1,.blue))
        lableContainer!.addSubview(blueRect.graphic)
        blueRect.draw()
        
        /*green rect that represents the range to render*/
        let greenFrame:CGRect = CGRect(0,0,width,height)
        greenRect = RectGraphic(greenFrame.x,greenFrame.y,greenFrame.size.width,greenFrame.size.height,nil,LineStyle(1,.green))
        lableContainer!.addSubview(greenRect!.graphic)
        greenRect!.draw()
        
        /*purple rect that represents the buffer area, 1-item above top and 1-item bellow bottom*/
        let purpleFrame:CGRect = CGRect(0,0,width,height)
        purpleRect = RectGraphic(purpleFrame.x,purpleFrame.y,purpleFrame.size.width,purpleFrame.size.height,nil,LineStyle(1,.purple))
        lableContainer!.addSubview(purpleRect!.graphic)
        purpleRect!.draw()
        
        let numOfItems:Int = Swift.min(maxVisibleItems!+1, dataProvider.count)
        let curVisibleRange:Range<Int> = 0..<numOfItems//<--this should be the same range as we set bellow no?
        prevVisibleRange = -1000..<0//this creates the correct diff later on.
        
        updatePool()//creates a pool of items ready to be used
        reUse(curVisibleRange)
        
    }   
    /**
     * PARAM: progress (0-1)
     */
    func setProgress(_ progress:CGFloat){
        ListModifier.scrollTo(self, progress)/*moves the labelContainer up and down*/
        let curVisibleRange = Utils.curVisibleItems(self, maxVisibleItems!+1)
        /*GreenRect*/
        let top:CGFloat = curVisibleRange.top
        let greenFrame:CGRect = CGRect(0,top,width,maxVisibleItems!*itemHeight)
        greenRect!.setPosition(greenFrame.origin)
        greenRect!.setSizeValue(greenFrame.size)
        greenRect!.draw()
        /*PurpleRect*/
        let purpleFrame:CGRect = CGRect(0,top-itemHeight,width,(maxVisibleItems!*itemHeight)+(itemHeight*2))
        purpleRect!.setPosition(purpleFrame.origin)
        purpleRect!.setSizeValue(purpleFrame.size)
        purpleRect!.draw()
        /**/
        if(curVisibleRange.range != prevVisibleRange){/*Optimization: only set if it's not the same as prev range*/
            reUse(curVisibleRange.range)/*spoof items in the new range*/
            prevVisibleRange = curVisibleRange.range
        }
    }
    /**
     * NOTE: This method grabs items from pool and append or prepend them
     */
    func reUse(_ cur:Range<Int>){
        Swift.print("reUse: " + "\(cur)")
        let prev = prevVisibleRange!/*we assign the value to a simpler shorter named variable*/
        Swift.print("prev: " + "\(prev)")
        let diff = prev.start - cur.start
        Swift.print("diff: " + "\(diff)")
        
        if(abs(diff) >= maxVisibleItems!+1){//spoof every item
            Swift.print("all")
            for i in 0..<pool.count {
                let idx = cur.start + i
                pool[i] = (pool[i].item, idx)
                reUse(pool[i])
            }
        }else if(diff.positive){//cur.start is less than prev.start
            Swift.print("prepend ")
            var bottomItems = pool.splice2(pool.count-diff, diff)//grab items from the bottom
            for i in 0..<bottomItems.count {
                bottomItems[i] = (bottomItems[i].item, cur.start + i);//and move them to the top
                reUse(bottomItems[i])
            }//assign correct absolute idx
            pool = bottomItems + pool/*prepend to list*/
        }else if(diff.negative){//cur.start is more than prev.start
            Swift.print("append")
            var topItems = pool.splice2(0, -1*(diff))//grab items from the top
            for i in 0..<topItems.count {
                topItems[i] = (topItems[i].item, prev.end + i)//and move them to the bottom
                reUse(topItems[i])
            }//assign correct absolute idx
            pool += topItems/*append to list*/
        }
    }
    /**
     * (spoof == apply/reuse)
     */
    func reUse(_ listItem:FastListItem){/*override this to use custom ItemList items*/
        Swift.print("reUse: " + "\(listItem.idx)")
        let item:SelectTextButton = listItem.item as! SelectTextButton
        let idx:Int = listItem.idx/*the index of the data in dataProvider*/
        let dpItem = dataProvider.items[idx]
        let title:String = dpItem["title"]!
        item.setTextValue(idx.string + " " + title)
        item.y = listItem.idx * itemHeight/*position the item*/
    }
    /**
     * Replensih / drain the pool (aka add / remove items)
     */
    func updatePool(){
        Swift.print("👉 updatePool  dp.count:  \(dp.count) pool.count:  \(pool.count)")
        let itemsToFillHeight:Int = floor(height / itemHeight).int + 1
        Swift.print("itemsToFillHeight: " + "\(itemsToFillHeight)")
        if(dp.count > pool.count && pool.count < itemsToFillHeight){
            let min:Int = Swift.min(dp.count,itemsToFillHeight)
            let numOfItemsNeeded =  min - pool.count
            Swift.print("💚 replenish pool: \(numOfItemsNeeded)")
            for _ in 0..<numOfItemsNeeded{
                let idx:Int = pool.count > 0 ? pool.last!.idx + 1 : 0
                Swift.print("Add pool itm at: " + "\(idx)")
                let item:FastListItem = (createPoolItem(),idx)
                pool.append(item)
                lableContainer!.addSubview(item.item)
            }
        }
        else if(dp.count < pool.count){
            let numOfItemsUnNeeded = pool.count - dp.count
            Swift.print("❤️️ drain pool: \(numOfItemsUnNeeded)")
            for _ in 0..<numOfItemsUnNeeded{
                let item:FastListItem? = pool.popLast()
                item!.item.removeFromSuperview()
            }
        }else{
            Swift.print("💛 pool doesn't need draining or filling")
        }
    }
    /**
     *
     */
    func createPoolItem()->Element{
        let item:SelectTextButton = SelectTextButton(getWidth(), itemHeight ,"", false, lableContainer)
        return item
    }
    /**
     * NOTE: reUses all items from the startIndex of the intersecting range unitl the end of visibleItems.range
     */
    func updateRange(_ range:Range<Int>){
        Swift.print("👉 updateRange" + "range: " + "\(range)")
        updatePool()/*Creates enough pool items*/
        if(pool.count == 0){return}//exit early
        let firstPoolIdx:Int = pool.first!.idx
        Swift.print("firstPoolIdx: " + "\(firstPoolIdx)")
        let lastPoolIdx:Int = pool.last!.idx
        Swift.print("lastPoolIdx: " + "\(lastPoolIdx)")
        Swift.print("range.start: " + "\(range.start)")
         
        if(range.start >= firstPoolIdx && range.start <= lastPoolIdx){//within TODO: use a RangeAsserter method here
            let min = range.start
            let max = Swift.min(lastPoolIdx + 1,dp.count)//clip to max possible idx, bug fix
            let mergableRange = min..<max
            Swift.print("mergableRange: " + "\(mergableRange)")
            for i in mergableRange{/*For loop because the act of adding an item doesn't require shuffling from top to bottoom or bottom to top*/
               // Swift.print("reuse: i: \(i)")
                let item:FastListItem? = ArrayParser.first(pool, i, {$0.idx == $1})
                reUse(item!)
            }
        }
    }
    /**
     * TODO: you need to update the float of the lables after an update
     */
    func onDataProviderEvent(_ event:DataProviderEvent){
        if(event.type == DataProviderEvent.add){/*This is called when a new item is added to the DataProvider instance*/
            let endIdx:Int = event.startIndex + event.items.count
            updateRange(event.startIndex..<endIdx)
        }else if(event.type == DataProviderEvent.remove){
            let endIdx:Int = event.startIndex + event.items.count
            updateRange(event.startIndex..<endIdx)
            
        }
    }
    override func onEvent(_ event:Event) {
        if(event is DataProviderEvent){onDataProviderEvent(event as! DataProviderEvent)}
        super.onEvent(event)// we stop propegation by not forwarding events to super. The ListEvents go directly to super so they wont be stopped.
    }
    override func getClassType() -> String {return "\(List.self)"}
    required init(coder:NSCoder) {fatalError("init(coder:) has not been implemented")}
}
private class Utils{
    /**
     *
     */
    static func curVisibleItems(_ list:IList,_ maxVisibleItems:Int)->(range:Range<Int>,top:CGFloat){
        let visibleItemsTop:CGFloat = abs(list.lableContainer!.y > 0 ? 0 : list.lableContainer!.y)//NumberParser.minMax(-1*lableContainer!.y, 0, itemHeight * dataProvider.count - height)
        //Swift.print("visibleItemsTop: " + "\(visibleItemsTop)")
        //let visibleBottom:CGFloat = visibleItemsTop + height
        //Swift.print("visibleBottom: " + "\(visibleBottom)")
        //var topItemY:CGFloat {let remainder = visibleItemsTop % itemHeight;return visibleItemsTop-itemHeight+remainder}
        //Swift.print("topItemY: " + "\(topItemY)")
        var topItemIndex:Int = (visibleItemsTop / list.itemHeight).int
        topItemIndex = topItemIndex < 0 ? 0 : topItemIndex
        //topItemIndex = NumberParser.minMax(topItemIndex, 0, dataProvider.count-maxVisibleItems!)//clamp the num between min and max
        //Swift.print("topItemIndex: " + "\(topItemIndex)")
        var bottomItemIndex:Int = topItemIndex + maxVisibleItems
        bottomItemIndex = bottomItemIndex > list.dataProvider.count-1 ? max(list.dataProvider.count-1,0) : bottomItemIndex//the max part forces the value to be no less than 0
        //if(bottomItemIndex >= dataProvider.count){bottomItemIndex = dataProvider.count-1}
        //Swift.print("bottomItemIndex: " + "\(bottomItemIndex)")
        //Swift.print("topItemIndex: " + "\(topItemIndex)")
        let curVisibleRange:Range<Int> = topItemIndex..<bottomItemIndex
        return (curVisibleRange,visibleItemsTop)
    }
    /**
     * When you add/remove items from a list, the list changes size. This method returns a value that lets you keep the same position of the list after a add/remove items change
     * EXAMPLE: let p = progress(100, 500, 0, 700)//(200,0.5)
     */
    static func progress(_ maskHeight:CGFloat,_ newItemsHeight:CGFloat, _ oldLableContainerY:CGFloat, _ oldItemsHeight:CGFloat)->(lableContainerY:CGFloat,progress:CGFloat){
        if(oldLableContainerY >= 0){//this should be more advance, like assert wether an item was inserted in the visiblepart of the view, and position the list accordingly, to be continued
            let progress = SliderParser.progress(oldLableContainerY, maskHeight, oldItemsHeight)
            return (oldLableContainerY,progress)}/*pins the list to the top if its already at the top*/
        let newItemsHeight = newItemsHeight
        let dist = -(newItemsHeight-oldItemsHeight)//dist <-> old and new itemsHeight
        let newProgress = (oldLableContainerY+dist)/(-(newItemsHeight-maskHeight))
        let newLableContainerY = -(newItemsHeight-maskHeight)*newProgress
        return (newLableContainerY,newProgress)
    }
}