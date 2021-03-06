import Cocoa
@testable import Element
@testable import Utils

class Graph9:Element{
    /*Debug*/
    //lazy var gestureHUD:GestureHUD = GestureHUD(self)
    /*UI*/
    var timeBar:TimeBar?
    var valueBar:ValueBar?
    var graphComponent:GraphComponent?
    var dateIndicator:DateIndicator?
    /*Date vars*/
    let range:Range<Int> = {return Date().year - 6..<Date().year}()//rename to yearRange
    /*Zooming vars*/
    var curZoom:Int = TimeType.year.rawValue
    var zoom:CGFloat = 0/*interim var*/
    var prevZoom:Int?
    /*State related*/
    var prevRange:Range<Int>?//animation state stop
    var prevRangeScrollChange:Range<Int>?//Panning state change
    
    override func resolveSkin(){
        super.resolveSkin()
        createUI()
        /*Debug*/
        //acceptsTouchEvents = true/*Enables gestures*/
        //wantsRestingTouches = true/*Makes sure all touches are registered. Doesn't register when used in playground*/
    }
    override func onEvent(_ event:Event) {
        if(event === (AnimEvent.stopped, timeBar!.mover!)){
            //Swift.print("event.origin: " + "\(event.origin)")
            //Swift.print("event.type: " + "\(event.type)")
            //Swift.print("event.origin: " + "\(event.origin)")
            Swift.print("🍊 timeBar!.visibleItemRange: " + "\(timeBar!.visibleItemRange)")
            let isVelocityZero:Bool = timeBar!.mover!.velocity == 0//quick fix
            //Swift.print("isVelocityZero: " + "\(isVelocityZero)")
            if(isVelocityZero && hasPanningChanged(&prevRange)){
                Swift.print("✅ a change has happened")
                update()
            }else{
                Swift.print("🚫 a change has not happened")
            }
        }
        super.onEvent(event)
    }
}
