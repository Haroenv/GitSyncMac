import Foundation
@testable import Utils
@testable import Element

class FindPointOnCurveTest:Element{
    typealias P = CGPoint
    let p0 = P(0,100)  // The first point on curve
    let c0 = P(100,0)   // Controller for p0
    let c1 = P(100,150) // Controller for p1
    let p1 = P(200,50)  // The last point on curve
    
    override func resolveSkin() {
        StyleManager.addStyle("FindPointOnCurveTest{fill:green;fill-alpha:0.5;}")
        super.resolveSkin()
        addGraphLine()
        addGraphPoint()
    }
    override func mouseMoved(_ event: MouseEvent) {
        super.mouseMoved(event)
        Swift.print("event.loc: " + "\(event.loc)")
    }
}
extension FindPointOnCurveTest{
    func addGraphLine(){
        addGraphLineStyle()
        
        let pathData:[CGFloat] = [p0.x,p0.y,p1.x,p1.y,c0.x,c0.y,c1.x,c1.y]
        let commands:[Int] = [PathCommand.moveTo,PathCommand.cubicCurveTo]
        let path:IPath = Path(commands,pathData)
        let graphLine = self.addSubView(GraphLine(width,height,path))
        _ = graphLine
    }
    
    func addGraphPoint(){
        addGraphPointStyle()
        //let p = curveP(p0,c0,c1,p1,0.2)//P(100,100)
        let p = getCurvePoint(p0,p1,c0,c1,0.5)
        Swift.print("p: " + "\(p)")
        
        let graphPoint:Element = self.addSubView(Element(NaN,NaN,self,"graphPoint"))
        graphPoint.setPosition(p)
    }
    func getCurvePoint(_ anchor1:CGPoint,_ anchor2:CGPoint,_ control1:CGPoint,_ control2:CGPoint, _ u:CGFloat) -> CGPoint{
        let posX:CGFloat = pow(u,3)*(anchor2.x+3*(control1.x-control2.x)-anchor1.x)+3*pow(u,2)*(anchor1.x-2*control1.x+control2.x)+3*u*(control1.x-anchor1.x)+anchor1.x;
        let posY:CGFloat = pow(u,3)*(anchor2.y+3*(control1.y-control2.y)-anchor1.y)+3*pow(u,2)*(anchor1.y-2*control1.y+control2.y)+3*u*(control1.y-anchor1.y)+anchor1.y;
        return CGPoint(posX, posY);
    }
    /**
     * Finds points on a curve.
     * x0 = prevEndP, x1 = cp1, x2 = cp2, x3 = endP
     */
    func curveP(_ prevEndP:CGPoint,_ cp1:CGPoint,_ cp2:CGPoint,_ endP:CGPoint, _ t:CGFloat) -> CGPoint{//0-1
        //var square:Number = t*t;
        let cube:CGFloat = t*t*t
        let inv:CGFloat = 1 - t
        let invsquare:CGFloat = inv*inv
        let invcube:CGFloat = inv*inv*inv
        var point:CGPoint = CGPoint()
        point.x = invcube*prevEndP.x + 2*t*invsquare*cp1.x  + cube*endP.x
        point.y = invcube*prevEndP.y + 2*t*invsquare*cp1.y  + cube*endP.y
        return point
    }
    func addGraphLineStyle(){
        var css:String = "GraphLine{"
        css +=    "float:none;"
        css +=    "clear:none;"
        css +=    "line:#2AA3EF;"
        css +=    "line-alpha:1;"
        css +=    "line-thickness:0.5px;"
        css += "}"
        StyleManager.addStyle(css)
    }
    /**
     *
     */
    func addGraphPointStyle(){
        
        /*GraphPoint*/
        var css:String = ""
        css += "Element#graphPoint{"
        css +=     "float:none;"
        css +=     "clear:none;"
        css +=     "fill:#128BF2,#192633;"
        css +=     "width:12px,11px;"
        css +=     "height:12px,11px;"
        css +=     "margin-left:-6px,-5.5px;"
        css +=     "margin-right:6px,5.5px;"
        css +=     "margin-top:-6px,-5.5px;"
        css +=     "margin-bottom:6px,5.5px;"
        css +=     "drop-shadow:drop-shadow(1px 90 #000000 0.3 0.5 0.5 0 0 false);"
        css +=     "corner-radius:6px,5.5px;"
        css += "}"
        StyleManager.addStyle(css)
    }
}
