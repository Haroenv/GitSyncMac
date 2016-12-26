import Foundation

class CompileCommitListTest {
    /**
     *
     */
    func refresh(){
        let repoXML = FileParser.xml("~/Desktop/assets/xml/list.xml".tildePath)//~/Desktop/repo2.xml
        let repoList = XMLParser.toArray(repoXML)//or use dataProvider
        var sortableRepoList:[(repo:[String:String],freshness:CGFloat)] = []//we may need more precision than CGFloat, consider using Double or better
        
        repoList.forEach{/*sort the repoList based on freshness*/
            let localPath:String = $0["local-path"]!
            let freshness:CGFloat = CommitDBUtils.freshness(localPath)
            sortableRepoList.append(($0,freshness))
        }


        //sort repos by freshness: (makes the process of populating CommitsDB much faster)
        //we run the sorting algo on a bg thread as serial work (one by one) and then notifying mainThread on allComplete
        
        
        //get the 100 last commits from every repo:
            //we populate the CommitsDB on a bg thread as serial work (one by one) and then notifying mainThread on allComplete
            //for each repo in sortedRepos (aka sorted by freshness)
                //get commit count
                //retrive only commits that are newer than the most distante time in the CommitsDB 
        
        //add new commits to CommitDB with a binarySearch
        
    }
}
