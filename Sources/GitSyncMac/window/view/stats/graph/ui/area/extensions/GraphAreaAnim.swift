import Foundation
@testable import Element
@testable import Utils

extension GraphComponent{
    /**
     * Interpolates between 0 and 1 while the duration of the animation
     * NOTE: ReCalc the hValue indicators (each week has a different max hValue etc)
     */
    func interpolateValue(_ val:CGFloat){
        //Swift.print("interpolateValue() val: " + "\(val)")
        var positions:[CGPoint] = []
        /*GraphPoints*/
        for i in 0..<points!.count{
            let pos:CGPoint = prevPoints![i].interpolate(points![i], val)/*interpolates from one point to another*/
            positions.append(pos)
            dots[i].setPosition(pos)//moves the points
        }
        /*GraphLine*/
        let path:IPath = PolyLineGraphicUtils.path(positions)/*convert points to a Path*/
        //TODO: Ideally we should create the CGPath from the points use CGPathParser.polyline
        let cgPath = CGPathUtils.compile(CGMutablePath(), path)//convert path to cgPath
        graphLine!.line!.cgPath = cgPath.clone()//applies the new path
        graphLine!.line!.draw()//draws the path
    }
}
