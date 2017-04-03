import Cocoa
@testable import Utils
@testable import Element

extension Graph9 {
    var randomGraphPoints:[CGPoint]{
        typealias P = CGPoint
        var points:[P] = []
        let padding:CGFloat = 50
        for i in 0..<6{
            let x:CGFloat = padding+(100*i)
            let y:CGFloat = (0..<(height.int-32)).random.cgFloat
            let p = P(x,y)
            points.append(p)
        }
        return points
    }
}