import Foundation
@testable import Element
@testable import Utils


//you need to research prevDelta more. you need to be accurate when determining direction. 
    //you dont want to go backwards when you just scrolled forward and stopped etc.

class SnappyRubberBand:RubberBand{
    var minVelocity:CGFloat = 2.6
    var snap:CGFloat = 100
    var prevDir:CGFloat = 0//-1,1 
    
    override func applyFriction() {
        //Swift.print("SnappyRubberBand.applyFriction() velocity: \(velocity) value: \(value)")
        if(velocity == 0){/*when scrollWheel exit and its abs(prevScrollDelta) < 3 then we set the velocity to 0*/
            //Swift.print("prevDir: " + "\(prevDir)")
            if(prevDir.isPositive){/*abs(mod) <= snap/2*/
                velocity = minVelocity
                //Swift.print("⬅️️ go backward velocity : \(velocity)")
            }else if(prevDir.isNegative) {
                //Swift.print("➡️️ go forward velocity : \(velocity)")
                velocity = -minVelocity
            }else{/*prevDir == 0*/
                velocity = 0
            }
            //value += velocity
        }
        if(abs(velocity) <= minVelocity && abs(value %% snap).isNear(0, minVelocity)){/*stop the value is close enough to target*/
            /*
             Swift.print("is close to target")
             Swift.print("hasStopped: " + "\(hasStopped)")
             Swift.print("value: " + "\(value)")
             Swift.print("snap: " + "\(snap)")
             Swift.print("prevDir: " + "\(prevDir)")
             Swift.print("result: " + "\(result)")
             */
            value = CGFloatModifier.roundTo(value, snap)/*set final destination*/
            //Swift.print("final value: " + "\(value)")
            callBack(value)//final tick
            hasStopped = true
            velocity = 0/*bug fix ⚠️️ could break things*/
            stop()
            /*super.onEvent(AnimEvent(AnimEvent.completed,self))*//*<-tempfix*/
        }else{
            if(abs(velocity) <= minVelocity){/*Velocity is bellow min allowed, add velocity keep anim alive*/
                //Swift.print("use minVelocity")
                velocity = prevDir.isNegative ? -minVelocity : minVelocity
                value += velocity
            }else{//else default to regular friction velocity
                //Swift.print("default friction: \(abs(velocity))")
                super.applyFriction()//regular friction
            }
        }
    }
}

//You need to detect dist to target on stationary scrollwheel exit.
//as it doesnt have direction
//you need to add some dist to target code 👈 🏀
//try to drag and drop it into position
//you need to calculate the direction on release. why?
//you need to set the final value so that it snaps to the perfect value✅
//find the round to method and round value to snap✅

