import Cocoa
@testable import Utils
@testable import Element
@testable import GitSyncMac

class TestView:TitleView{
    override init(_ width:CGFloat, _ height:CGFloat, _ parent:IElement? = nil, _ id:String? = "") {
        //self.title = "Resolve merge conflict:"//Title: Resolve sync conflict:
        super.init(width, height, parent, "listTransitionTestView")
    }
    override func resolveSkin(){
        Swift.print("ListTransitionTestView.resolveSkin()")
        super.resolveSkin()
        Swift.print(ElementParser.stackString(self))
        createGUI()
    }
    func createGUI(){
        //createGraph7Test()
        createGraph2()
    }
    func createGraph7Test(){
        let test = self.addSubView(Graph7(width,height-48,self))
        _ = test
    }
    func createGraph2(){
        let graph = self.addSubView(Graph2(width,height,nil))
        _ = graph
    }
    /**
     *
     */
    func timeTesting(){
        let a = Date.createDate(2017,12,31)!
        
        /**
         *
         */
        func printDate(_ a:Date){
            Swift.print("a.shortDate: " + "\(a.shortDate)")
            Swift.print("a.month: " + "\(a.month)")
            Swift.print("a.year: " + "\(a.year)")
            Swift.print("a.day: " + "\(a.day)")
            Swift.print("a: " + "\(a)")
        }
        printDate(a)
    }
    /**
     * CommitCount per day for all projects in the last 7 days where the user is "eonist"
     * NOTE: now support month,year, day
     */
    func commitCounterTest(){
        let commitCounter = CommitCounter()
        func onComplete(_ results:[Int]){
            Swift.print("Appdelegate.onComplete()")
            Swift.print("results.count: " + "\(results.count)")
            Swift.print("results: " + "\(results)")
        }
        commitCounter.onComplete = onComplete
        let from = Date().offsetByYears(-7)
        Swift.print("from: " + "\(from.year)")
        let until = Date()
        Swift.print("until: " + "\(until.year)")
        commitCounter.countCommits(from,until,.year)
    }
    func refreshReposTest(){
        func onComplete(){
            Swift.print("🏆🏆🏆 CommitDB finished!!! ")
        }
        //CommitDPRefresher.commitDP = CommitDPCache.read()
        //CommitDPRefresher.onComplete = onComplete
        //CommitDPRefresher.refresh()
    }
    func flattenRepoTest(){
        /*let repoList = RepoUtils.repoListFlattenedOverridden
         Swift.print(repoList.count)
         repoList.forEach{
         Swift.print("$0.title: " + "\($0.title)")
         }*/
        //it works, now activate this in a filter, if active is false then don't return repo, easy! test it first, then test gitpull
    }
    required init(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}