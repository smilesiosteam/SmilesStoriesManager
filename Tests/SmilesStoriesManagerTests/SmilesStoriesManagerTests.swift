import XCTest
import SmilesStoriesManager
import UIKit
import SmilesUtilities

public final class SmilesStoriesManagerTests: XCTestCase {
    var viewModel:StoriesViewModel?
    public override func setUpWithError() throws {
        viewModel = StoriesViewModel(baseURL: "", isGuestUser: false)
    }

    public override func tearDownWithError() throws {
        viewModel = nil
        IGCache.shared.removeObject(forKey: "multiply.circle.fill" as AnyObject)
    }
 
    func testParsing(){
        guard let stories = Stories.fromModuleFile() else {
            XCTFail("Stroies not parsed")
            return
        }
        guard stories.stories?.count ?? 0 > 0 else {
            XCTFail("No stories found")
            return
        }
        viewModel?.stories = stories
        XCTAssert(viewModel?.stories?.stories?.count ?? 0 > 0)
        IGVideoCacheManager.shared.clearCache()
    }
    
    func testConstants(){
        XCTAssert(IGScreen.width > 0, "IGScreen.width not initialized")
        XCTAssert(IGScreen.height > 0, "IGScreen.height not initialized")
        XCTAssert(IGTheme.redOrange == UIColor.rgb(from: 0xe95950), "IGTheme.redOrange not initialized")
    }
    
    
    func testCache(){
        IGCache.shared.setObject(UIImage(systemName: "multiply.circle.fill")!, forKey: "multiply.circle.fill" as AnyObject)
        XCTAssert(IGCache.shared.object(forKey: "multiply.circle.fill" as AnyObject) != nil, "IGTheme.redOrange not initialized")
    }
    
    func testVideoCache(){
        let fileName = "video.com/vid/123"
        guard let file = IGVideoCacheManager.shared.directoryFor(stringUrl: fileName) else {
            XCTFail("Directory couldn't be initialized")
            return
        }
        do{
            try "random".data(using: .utf8)?.write(to: file)
            XCTAssert(IGVideoCacheManager.shared.fileExists(for: fileName), "Video file not cached")
        }catch{
            XCTFail("Video file couldn't be written")
        }
    }
    
}
