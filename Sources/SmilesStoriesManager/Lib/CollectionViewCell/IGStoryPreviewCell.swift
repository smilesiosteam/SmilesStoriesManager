import UIKit
import AVKit
import SmilesLanguageManager
import LottieAnimationManager

protocol StoryPreviewProtocol: AnyObject {
    func didCompletePreview()
    func moveToPreviousStory()
    func dismiss()
}
enum SnapMovementDirectionState {
    case forward
    case backward
}
//Identifiers
fileprivate let snapViewTagIndicator: Int = 8

final class IGStoryPreviewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    //MARK: - Delegate
    public weak var delegate: StoryPreviewProtocol? {
        didSet { storyHeaderView.delegate = self }
    }
    
    //MARK:- Private iVars
    private lazy var storyHeaderView: IGStoryPreviewHeaderView = {
        let v = IGStoryPreviewHeaderView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var storyHeaderShadowView: StoriesSZGradientView = {
        let v = StoriesSZGradientView(frame: .zero)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alpha = 0.6
        v.direction = 2
        v.updateColors(locations: [0.23, 0.71, 1], colors: [UIColor.black.cgColor, UIColor.black.withAlphaComponent(0.45).cgColor,UIColor.clear.cgColor])
        return v
    }()
    
    var primaryButtonAction:((Int)->Void)? = nil
    var infoButtonAction:((Int)->Void)? = nil
    var shareButtonAction:((Int)->Void)? = nil
    var favouriteButtonAction:((Int)->Void)? = nil
    
    private lazy var storyFooterView: StoryPreviewFooterView = {
        let v = StoryPreviewFooterView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var scrollViewHeight:NSLayoutConstraint!
    
    private lazy var longPress_gesture: UILongPressGestureRecognizer = {
        let lp = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2
        lp.delegate = self
        return lp
    }()
    private lazy var tap_gesture: UITapGestureRecognizer = {
        let tg = UITapGestureRecognizer(target: self, action: #selector(didTapSnap(_:)))
        tg.cancelsTouchesInView = false;
        tg.numberOfTapsRequired = 1
        tg.delegate = self
        return tg
    }()
    private var previousSnapIndex: Int {
        return snapIndex - 1
    }
    private var snapViewXPos: CGFloat {
        return (snapIndex == 0) ? 0 : scrollview.subviews[previousSnapIndex].frame.maxX
//        let total = (story?.snaps?.count ?? 0).toFloat * scrollview.frame.width
//        var x = (snapIndex == 0) ? 0 : scrollview.subviews[previousSnapIndex].frame.maxX
//        if isRightToLeft {
//            x = (snapIndex == 0) ? total : scrollview.subviews[previousSnapIndex].frame.minX
//        }
//        return x
    }
    private var videoSnapIndex: Int = 0
    private var handpickedSnapIndex: Int = 0
    var retryBtn: IGRetryLoaderButton!
    var longPressGestureState: UILongPressGestureRecognizer.State?
    
    //MARK:- Public iVars
    public var direction: SnapMovementDirectionState = .forward
    public let scrollview: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.isScrollEnabled = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.semanticContentAttribute = .forceLeftToRight
        return sv
    }()
    public var getSnapIndex: Int {
        return snapIndex
    }
    public var snapIndex: Int = 0 {
        didSet {
            storyHeaderView.snapIndex = snapIndex
            storyFooterView.snapIndex = snapIndex
            scrollview.isUserInteractionEnabled = true
            switch direction {
                case .forward:
                if snapIndex < story?.snaps?.count ?? 0 {
                        if let snap = story?.snaps?[snapIndex] {
                            switch snap.type {
                            case .image,.unknown:
                                if let snapView = getSnapview() {
                                    startRequest(snapView: snapView, with: snap.mediaUrl)
                                } else {
                                    let snapView = createSnapView()
                                    startRequest(snapView: snapView, with: snap.mediaUrl)
                                }
                            case .video:
                                if let videoView = getVideoView(with: snapIndex) {
                                    startPlayer(videoView: videoView, with: snap.mediaUrl)
                                }else {
                                    let videoView = createVideoView()
                                    startPlayer(videoView: videoView, with: snap.mediaUrl)
                                }
                            case .animation:
                                if let snapView = getSnapview() {
                                    startAnimationRequest(snapView: snapView, with: snap.mediaUrl)
                                } else {
                                    let snapView = createSnapView()
                                    startAnimationRequest(snapView: snapView, with: snap.mediaUrl)
                                }
                            }
                        }
                }
                case .backward:
                if snapIndex < story?.snaps?.count ?? 0 {
                        if let snap = story?.snaps?[snapIndex] {
                            switch snap.type {
                                
                            case .image, .unknown:
                                if let snapView = getSnapview() {
                                    self.startRequest(snapView: snapView, with: snap.mediaUrl)
                                }
                            case .video:
                                if let videoView = getVideoView(with: snapIndex) {
                                    startPlayer(videoView: videoView, with: snap.mediaUrl)
                                }
                                else {
                                    let videoView = self.createVideoView()
                                    self.startPlayer(videoView: videoView, with: snap.mediaUrl)
                                }
                            case .animation:
                                if let snapView = getSnapview() {
                                    self.startAnimationRequest(snapView: snapView, with: snap.mediaUrl)
                                }
                            }
                        }
                }
            }
            setNeedsLayout()
        }
    }
    public var story: Story? {
        didSet {
            storyHeaderView.story = story
            storyFooterView.story = story
        }
    }
    
    fileprivate func setupActions() {
        storyFooterView.primaryButtonAction = {
            self.primaryButtonAction?(self.snapIndex)
        }
        storyFooterView.infoButtonAction = {
            self.infoButtonAction?(self.snapIndex)
        }
        storyFooterView.shareButtonAction = {
            self.shareButtonAction?(self.snapIndex)
        }
        storyFooterView.favouriteButtonAction = {
            self.favouriteButtonAction?(self.snapIndex)
        }
    }

    //MARK: - Overriden functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollview.frame = bounds
        loadUIElements()
        installLayoutConstraints()
        setupActions()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        direction = .forward
        clearScrollViewGarbages()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Private functions
    private func loadUIElements() {
        scrollview.delegate = self
        scrollview.isPagingEnabled = true
        scrollview.backgroundColor = .black
        contentView.addSubview(scrollview)
        contentView.addSubview(storyHeaderShadowView)
        contentView.addSubview(storyHeaderView)
        contentView.addSubview(storyFooterView)
        scrollview.addGestureRecognizer(longPress_gesture)
        scrollview.addGestureRecognizer(tap_gesture)
    }
    
    private func installLayoutConstraints() {
        //Setting constraints for scrollview
        scrollViewHeight = scrollview.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            storyFooterView.igLeadingAnchor.constraint(equalTo: contentView.igLeadingAnchor),
            contentView.igTrailingAnchor.constraint(equalTo: storyFooterView.igTrailingAnchor),
            storyFooterView.bottomAnchor.constraint(equalTo: contentView.igBottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            scrollview.igLeadingAnchor.constraint(equalTo: contentView.igLeadingAnchor),
            contentView.igTrailingAnchor.constraint(equalTo: scrollview.igTrailingAnchor),
            scrollview.igTopAnchor.constraint(equalTo: contentView.igTopAnchor),
            scrollview.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0),
            scrollViewHeight
        ])
        NSLayoutConstraint.activate([
            storyHeaderView.igLeadingAnchor.constraint(equalTo: contentView.igLeadingAnchor),
            contentView.igTrailingAnchor.constraint(equalTo: storyHeaderView.igTrailingAnchor),
            storyHeaderView.igTopAnchor.constraint(equalTo: contentView.igTopAnchor),
            storyHeaderView.heightAnchor.constraint(equalToConstant: 110)
        ])
        
        NSLayoutConstraint.activate([
            storyHeaderShadowView.igLeadingAnchor.constraint(equalTo: contentView.igLeadingAnchor),
            contentView.igTrailingAnchor.constraint(equalTo: storyHeaderShadowView.igTrailingAnchor),
            storyHeaderShadowView.igTopAnchor.constraint(equalTo: contentView.igTopAnchor),
            storyHeaderShadowView.heightAnchor.constraint(equalToConstant: 110)
        ])
        
    }
    private func createSnapView() -> UIImageView {
        let snapView = UIImageView()
        snapView.contentMode = .scaleAspectFill
        snapView.translatesAutoresizingMaskIntoConstraints = false
        snapView.tag = snapIndex + snapViewTagIndicator
        snapView.backgroundColor = .black
        /**
         Delete if there is any snapview/videoview already present in that frame location. Because of snap delete functionality, snapview/videoview can occupy different frames(created in 2nd position(frame), when 1st postion snap gets deleted, it will move to first position) which leads to weird issues.
         - If only snapViews are there, it will not create any issues.
         - But if story contains both image and video snaps, there will be a chance in same position both snapView and videoView gets created.
         - That's why we need to remove if any snap exists on the same position.
         */
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()
        
        scrollview.addSubview(snapView)
        
        /// Setting constraints for snap view.
        NSLayoutConstraint.activate([
            snapView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ? scrollview.leadingAnchor : scrollview.subviews[previousSnapIndex].trailingAnchor),
            snapView.igTopAnchor.constraint(equalTo: scrollview.igTopAnchor),
            snapView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            snapView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.igBottomAnchor.constraint(equalTo: snapView.igBottomAnchor)
        ])
        if(snapIndex != 0) {
            NSLayoutConstraint.activate([
                snapView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: CGFloat(snapIndex)*scrollview.width)
            ])
        }
        return snapView
    }
    
    func removeObserver(){
        NotificationCenter.default.removeObserver(self)
    }

    private func getSnapview() -> UIImageView? {
        if let imageView = scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first as? UIImageView {
            return imageView
        }
        return nil
    }
    private func createVideoView() -> IGPlayerView {
        let videoView = IGPlayerView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.tag = snapIndex + snapViewTagIndicator
        videoView.playerObserverDelegate = self
        
        /**
         Delete if there is any snapview/videoview already present in that frame location. Because of snap delete functionality, snapview/videoview can occupy different frames(created in 2nd position(frame), when 1st postion snap gets deleted, it will move to first position) which leads to weird issues.
         - If only snapViews are there, it will not create any issues.
         - But if story contains both image and video snaps, there will be a chance in same position both snapView and videoView gets created.
         - That's why we need to remove if any snap exists on the same position.
         */
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()
        
        scrollview.addSubview(videoView)
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ? scrollview.leadingAnchor : scrollview.subviews[previousSnapIndex].trailingAnchor),
            videoView.igTopAnchor.constraint(equalTo: scrollview.igTopAnchor),
            videoView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            videoView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.igBottomAnchor.constraint(equalTo: videoView.igBottomAnchor)
        ])
        if(snapIndex != 0) {
            NSLayoutConstraint.activate([
                videoView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: CGFloat(snapIndex)*scrollview.width),
            ])
        }
        return videoView
    }
    private func getVideoView(with index: Int) -> IGPlayerView? {
        if let videoView = scrollview.subviews.filter({$0.tag == index + snapViewTagIndicator}).first as? IGPlayerView {
            return videoView
        }
        return nil
    }
    
    private func startRequest(snapView: UIImageView, with url: String) {
        snapView.setImage(url: url, style: .squared) { result in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1){ [weak self] in
                guard let strongSelf = self else { return}
                switch result {
                    case .success(_):
                        /// Start progressor only if handpickedSnapIndex matches with snapIndex and the requested image url should be matched with current snapIndex imageurl
                        if(strongSelf.handpickedSnapIndex == strongSelf.snapIndex && url == strongSelf.story!.snaps?[strongSelf.snapIndex].mediaUrl) {
                            strongSelf.startProgressors()
                    }
                    case .failure(_):
                        strongSelf.showRetryButton(with: url, for: snapView)
                }
            }
        }
    }
    
    private func startAnimationRequest(snapView: UIImageView, with url: String) {
        if let animationURL = URL(string: url) {
            LottieAnimationManager.showAnimationFromUrl(FromUrl: animationURL, animationBackgroundView: snapView,loopMode: .loop) { animation in
                if animation != nil {
                    OperationQueue.main.addOperation{
                        /// Start progressor only if handpickedSnapIndex matches with snapIndex and the requested image url should be matched with current snapIndex imageurl
                        if(self.handpickedSnapIndex == self.snapIndex && url == self.story!.snaps?[self.snapIndex].mediaUrl) {
                            self.startProgressors()
                        }else {
                            self.showRetryButton(with: url, for: snapView)
                        }
                    }
                }
            } completion: { done in
                
            }
        }
    }
                                         
    private func showRetryButton(with url: String, for snapView: UIImageView) {
        self.retryBtn = IGRetryLoaderButton.init(withURL: url)
        self.retryBtn.translatesAutoresizingMaskIntoConstraints = false
        self.retryBtn.delegate = self
        self.isUserInteractionEnabled = true
        snapView.addSubview(self.retryBtn)
        NSLayoutConstraint.activate([
            self.retryBtn.igCenterXAnchor.constraint(equalTo: snapView.igCenterXAnchor),
            self.retryBtn.igCenterYAnchor.constraint(equalTo: snapView.igCenterYAnchor)
        ])
    }
    private func startPlayer(videoView: IGPlayerView, with url: String) {
        longPress_gesture.isEnabled = false
        tap_gesture.isEnabled = false
        longPress_gesture.isEnabled = true
        tap_gesture.isEnabled = true
        
        if scrollview.subviews.count > 0 {
            if story?.isCompletelyVisible == true {
                videoView.startAnimating()
                IGVideoCacheManager.shared.getFile(for: url) { [weak self] (result) in
                    guard let strongSelf = self else { return }
                    switch result {
                        case .success(let videoURL):
                            /// Start progressor only if handpickedSnapIndex matches with snapIndex
                            if(strongSelf.handpickedSnapIndex == strongSelf.snapIndex) {
                                let videoResource = VideoResource(filePath: videoURL.absoluteString)
                                videoView.play(with: videoResource)
                        }
                        case .failure(let error):
                            videoView.stopAnimating()
                            debugPrint("Video error: \(error)")
                    }
                }
            }
        }
    }
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        longPressGestureState = sender.state
        if sender.state == .began ||  sender.state == .ended {
            if(sender.state == .began) {
                pauseEntireSnap()
            } else {
                resumeEntireSnap()
            }
        }
    }
    @objc private func didTapSnap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(ofTouch: 0, in: self.scrollview)
        
        if let snapCount = story?.snaps?.count {
            var n = snapIndex
            /*!
             * Based on the tap gesture(X) setting the direction to either forward or backward
             */
            if let snap = story?.snaps?[n], snap.type == .image, getSnapview()?.image == nil {
                //Remove retry button if tap forward or backward if it exists
                if let snapView = getSnapview(), let btn = retryBtn, snapView.subviews.contains(btn) {
                    snapView.removeRetryButton()
                }
                fillupLastPlayedSnap(n)
            }else {
                //Remove retry button if tap forward or backward if it exists
                if let videoView = getVideoView(with: n), let btn = retryBtn, videoView.subviews.contains(btn) {
                    videoView.removeRetryButton()
                }
                if getVideoView(with: n)?.player?.timeControlStatus != .playing {
                    fillupLastPlayedSnap(n)
                }
            }
            if (SmilesLanguageManager.shared.currentLanguage == .en && touchLocation.x < scrollview.contentOffset.x + (scrollview.frame.width/2)) ||
                SmilesLanguageManager.shared.currentLanguage == .ar && touchLocation.x > scrollview.contentOffset.x + (scrollview.frame.width/2){
                direction = .backward
                if snapIndex >= 1 && snapIndex <= snapCount {
                    clearLastPlayedSnaps(n)
                    stopSnapProgressors(with: n)
                    n -= 1
                    resetSnapProgressors(with: n)
                    willMoveToPreviousOrNextSnap(n: n)
                } else {
                    delegate?.moveToPreviousStory()
                }
            } else {
                if snapIndex >= 0 && snapIndex <= snapCount {
                    //Stopping the current running progressors
                    stopSnapProgressors(with: n)
                    direction = .forward
                    n += 1
                    willMoveToPreviousOrNextSnap(n: n)
                }
            }
        }
    }
    @objc private func didEnterForeground() {
        if let snap = story?.snaps?[snapIndex] {
            if snap.type == .video {
                let videoView = getVideoView(with: snapIndex)
                startPlayer(videoView: videoView!, with: snap.mediaUrl)
            }else {
                startSnapProgress(with: snapIndex)
            }
        }
    }
    @objc private func didEnterBackground() {
        if let snap = story?.snaps?[snapIndex] {
            if snap.type == .video {
                stopPlayer()
            }
        }
        resetSnapProgressors(with: snapIndex)
    }
    private func willMoveToPreviousOrNextSnap(n: Int) {
        if let count = story?.snaps?.count {
            if n < count {
                //Move to next or previous snap based on index n
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = n
                handpickedSnapIndex = n
                snapIndex = n
            } else {
                delegate?.didCompletePreview()
            }
        }
    }
    @objc private func didCompleteProgress() {
        let n = snapIndex + 1
        if let count = story?.snaps?.count {
            if n < count {
                //Move to next snap
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = n
                direction = .forward
                handpickedSnapIndex = n
                snapIndex = n
            }else {
                stopPlayer()
                delegate?.didCompletePreview()
            }
        }
    }
    private func fillUpMissingImageViews(_ sIndex: Int) {
        if sIndex != 0 {
            for i in 0..<sIndex {
                snapIndex = i
            }
            let xValue = sIndex.toFloat * scrollview.frame.width
            scrollview.contentOffset = CGPoint(x: xValue, y: 0)
        }
    }
    //Before progress view starts we have to fill the progressView
    private func fillupLastPlayedSnap(_ sIndex: Int) {
        if let snap = story?.snaps?[sIndex], snap.type == .video {
            videoSnapIndex = sIndex
            stopPlayer()
        }
        if let holderView = self.getProgressIndicatorView(with: sIndex),
            let progressView = self.getProgressView(with: sIndex){
            progressView.widthConstraint?.isActive = false
            progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor, multiplier: 1.0)
            progressView.widthConstraint?.isActive = true
        }
    }
    private func fillupLastPlayedSnaps(_ sIndex: Int) {
        //Coz, we are ignoring the first.snap
        if sIndex != 0 {
            for i in 0..<sIndex {
                if let holderView = self.getProgressIndicatorView(with: i),
                    let progressView = self.getProgressView(with: i){
                    progressView.widthConstraint?.isActive = false
                    progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor, multiplier: 1.0)
                    progressView.widthConstraint?.isActive = true
                }
            }
        }
    }
    private func clearLastPlayedSnaps(_ sIndex: Int) {
        if let _ = self.getProgressIndicatorView(with: sIndex),
            let progressView = self.getProgressView(with: sIndex) {
            progressView.widthConstraint?.isActive = false
            progressView.widthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
            progressView.widthConstraint?.isActive = true
        }
    }
    private func clearScrollViewGarbages() {
        scrollview.contentOffset = CGPoint(x: 0, y: 0)
        if scrollview.subviews.count > 0 {
            var i = 0 + snapViewTagIndicator
            var snapViews = [UIView]()
            scrollview.subviews.forEach({ (imageView) in
                if imageView.tag == i {
                    snapViews.append(imageView)
                    i += 1
                }
            })
            if snapViews.count > 0 {
                snapViews.forEach({ (view) in
                    view.removeFromSuperview()
                })
            }
        }
    }
    private func gearupTheProgressors(type: MediaType, playerView: IGPlayerView? = nil) {
        if let holderView = getProgressIndicatorView(with: snapIndex),
            let progressView = getProgressView(with: snapIndex){
            progressView.story_identifier = self.story?.storyID
            progressView.snapIndex = snapIndex
            if type == .image || type == .animation{
                progressView.start(with: self.story?.snaps?[self.snapIndex].length?.double ?? 5.0, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                    print("Completed snapindex: \(snapIndex)")
                    if isCancelledAbruptly == false {
                        self.didCompleteProgress()
                    }
                })
            }else {
                //Handled in delegate methods for videos
            }
        }
    }
    
    //MARK:- Internal functions
    func startProgressors() {
        if self.scrollview.subviews.count > 0 {
            //                let imageView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? UIImageView
            // Didend displaying will call this startProgressors method. After that only isCompletelyVisible get true. Then we have to start the video if that snap contains video.
            guard self.story?.isCompletelyVisible ?? false else {return}
            if self.story?.snaps?[self.snapIndex].type == .video {
                let videoView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? IGPlayerView
                let snap = self.story?.snaps?[self.snapIndex]
                if let vv = videoView, self.story?.isCompletelyVisible == true {
                    self.startPlayer(videoView: vv, with: snap!.mediaUrl)
                }
            }else{
                self.gearupTheProgressors(type:self.story?.snaps?[self.snapIndex].type ?? .unknown)
            }
        }
    }
    func getProgressView(with index: Int) -> IGSnapProgressView? {
        let progressView = storyHeaderView.getProgressView
        if progressView.subviews.count > 0 {
            let pv = getProgressIndicatorView(with: index)?.subviews.first as? IGSnapProgressView
            guard let currentStory = self.story else {
                fatalError("story not found")
            }
            pv?.story = currentStory
            return pv
        }
        return nil
    }
    func getProgressIndicatorView(with index: Int) -> IGSnapProgressIndicatorView? {
        let progressView = storyHeaderView.getProgressView
        return progressView.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first as? IGSnapProgressIndicatorView ?? nil
    }
    func adjustPreviousSnapProgressorsWidth(with index: Int) {
        fillupLastPlayedSnaps(index)
    }
    func deleteSnap() {
        let progressView = storyHeaderView.getProgressView
        clearLastPlayedSnaps(snapIndex)
        stopSnapProgressors(with: snapIndex)
        
        let snapCount = story?.snaps?.count ?? 0
        if let lastIndicatorView = getProgressIndicatorView(with: snapCount-1), let preLastIndicatorView = getProgressIndicatorView(with: snapCount-2) {
            
            lastIndicatorView.constraints.forEach { $0.isActive = false }
            
            preLastIndicatorView.rightConstraiant?.isActive = false
            preLastIndicatorView.rightConstraiant = progressView.igTrailingAnchor.constraint(equalTo: preLastIndicatorView.igTrailingAnchor, constant: 8)
            preLastIndicatorView.rightConstraiant?.isActive = true
        } else {
            debugPrint("No Snaps")
        }
        /**
         - If user is going to delete video snap, then we need to stop the player.
         - Remove the videoView/snapView from the scrollview subviews. Because once the snap got deleted, the next snap will be created on that same frame(x,y,width,height). If we didn't remove the videoView/snapView from scrollView subviews then it will create some wierd issues.
         */
        if story?.snaps?[snapIndex].type == .video {
            stopPlayer()
        }
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()
        
        /**
         Once we set isDeleted, snaps and snaps count will be reduced by one. So, instead of snapIndex+1, we need to pass snapIndex to willMoveToPreviousOrNextSnap. But the corresponding progressIndicator is not currently in active. Another possible way is we can always remove last presented progress indicator. So that snapIndex and tag will matches, so that progress indicator starts.
         */
        story?.snaps?[snapIndex].isDeleted = true
        direction = .forward
        for sIndex in 0..<snapIndex {
            if let holderView = self.getProgressIndicatorView(with: sIndex),
                let progressView = self.getProgressView(with: sIndex){
                progressView.widthConstraint?.isActive = false
                progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor, multiplier: 1.0)
                progressView.widthConstraint?.isActive = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.willMoveToPreviousOrNextSnap(n: strongSelf.snapIndex)
        }
        
        //Do the api call, when api request is success remove the snap using snap internal identifier from the nsuserdefaults.
    }
    
    //MARK: - Public functions
    public func willDisplayCellForZerothIndex(with sIndex: Int, handpickedSnapIndex: Int) {
        self.handpickedSnapIndex = handpickedSnapIndex
        story?.isCompletelyVisible = true
        willDisplayCell(with: handpickedSnapIndex)
    }
    public func willDisplayCell(with sIndex: Int) {
        //Todo:Make sure to move filling part and creating at one place
        //Clear the progressor subviews before the creating new set of progressors.
        storyHeaderView.clearTheProgressorSubviews()
        storyHeaderView.createSnapProgressors()
        fillUpMissingImageViews(sIndex)
        fillupLastPlayedSnaps(sIndex)
        snapIndex = sIndex
        handpickedSnapIndex = sIndex
        //Remove the previous observors
        NotificationCenter.default.removeObserver(self)
        
        // Add the observer to handle application from background to foreground
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    public func startSnapProgress(with sIndex: Int) {
        if let indicatorView = getProgressIndicatorView(with: sIndex),
            let pv = getProgressView(with: sIndex) {
            pv.start(with: 5.0, holderView: indicatorView, completion: { (identifier, snapIndex, isCancelledAbruptly) in
                if isCancelledAbruptly == false {
                    self.didCompleteProgress()
                }
            })
        }
    }
    public func pauseSnapProgressors(with sIndex: Int) {
        story?.isCompletelyVisible = false
        getProgressView(with: sIndex)?.pause()
    }
    public func stopSnapProgressors(with sIndex: Int) {
        getProgressView(with: sIndex)?.stop()
    }
    public func resetSnapProgressors(with sIndex: Int) {
        self.getProgressView(with: sIndex)?.reset()
    }
    public func pausePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.pause()
    }
    public func stopPlayer() {
        let videoView = getVideoView(with: videoSnapIndex)
        if videoView?.player?.timeControlStatus != .playing {
            getVideoView(with: videoSnapIndex)?.player?.replaceCurrentItem(with: nil)
        }
        videoView?.stop()
        //getVideoView(with: videoSnapIndex)?.player = nil
    }
    public func resumePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.play()
    }
    public func didEndDisplayingCell() {
        
    }
    public func resumePreviousSnapProgress(with sIndex: Int) {
        getProgressView(with: sIndex)?.resume()
    }
    public func pauseEntireSnap() {
        let v = getProgressView(with: snapIndex)
        let videoView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? IGPlayerView
        if videoView != nil {
            v?.pause()
            videoView?.pause()
        }else {
            v?.pause()
        }
    }
    public func resumeEntireSnap() {
        let v = getProgressView(with: snapIndex)
        let videoView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? IGPlayerView
        if videoView != nil {
            v?.resume()
            videoView?.play()
        }else {
            v?.resume()
        }
    }
    //Used the below function for image retry option
    public func retryRequest(view: UIView, with url: String) {
        if let v = view as? UIImageView {
            v.removeRetryButton()
            self.startRequest(snapView: v, with: url)
        }else if let v = view as? IGPlayerView {
            v.removeRetryButton()
            self.startPlayer(videoView: v, with: url)
        }
    }
    func updateFooter(){
        self.storyFooterView.updateUI(isFavouriteUpdated: true)
    }
    
}

//MARK: - Extension|StoryPreviewHeaderProtocol
extension IGStoryPreviewCell: StoryPreviewHeaderProtocol {
    func didTapCloseButton() {
        if let snap = story?.snaps?[snapIndex] {
            if snap.type == .video {
                stopPlayer()
            }
        }
        delegate?.dismiss()
    }
}

//MARK: - Extension|RetryBtnDelegate
extension IGStoryPreviewCell: RetryBtnDelegate {
    func retryButtonTapped() {
        self.retryRequest(view: retryBtn.superview!, with: retryBtn.contentURL!)
    }
}

//MARK: - Extension|IGPlayerObserverDelegate
extension IGStoryPreviewCell: IGPlayerObserver {
    
    func didStartPlaying() {
        if let videoView = getVideoView(with: snapIndex) {
            if videoView.error == nil && (story?.isCompletelyVisible)! == true {
                if let holderView = getProgressIndicatorView(with: snapIndex),
                    let progressView = getProgressView(with: snapIndex) {
                    progressView.story_identifier = self.story?.storyID
                    progressView.snapIndex = snapIndex
                    if let duration = videoView.currentItem?.asset.duration {
                        if Float(duration.value) > 0 {
                            progressView.start(with: duration.seconds, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                                if isCancelledAbruptly == false {
                                    self.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                    self.didCompleteProgress()
                                } else {
                                    self.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                }
                            })
                        }else {
                            debugPrint("Player error: Unable to play the video")
                        }
                    }
                }
            }
        }
    }
    func didFailed(withError error: String, for url: URL?) {
        debugPrint("Failed with error: \(error)")
        if let videoView = getVideoView(with: snapIndex), let videoURL = url {
            self.retryBtn = IGRetryLoaderButton(withURL: videoURL.absoluteString)
            self.retryBtn.translatesAutoresizingMaskIntoConstraints = false
            self.retryBtn.delegate = self
            self.isUserInteractionEnabled = true
            videoView.addSubview(self.retryBtn)
            NSLayoutConstraint.activate([
                self.retryBtn.igCenterXAnchor.constraint(equalTo: videoView.igCenterXAnchor),
                self.retryBtn.igCenterYAnchor.constraint(equalTo: videoView.igCenterYAnchor)
            ])
        }
    }
    func didCompletePlay() {
        //Video completed
    }
    
    func didTrack(progress: Float) {
        //Delegate already handled. If we just print progress, it will print the player current running time
    }
}

extension IGStoryPreviewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer is UISwipeGestureRecognizer) {
            return true
        }
        return false
    }
}
