

import UIKit
import Koloda
import pop
import TinyConstraints


/*
 crashed @ feed
 */

class Feed : UIViewController, KolodaViewDataSource, KolodaViewDelegate {
    
    
    var userId : String
    var spinner = SpinnerViewController()
    var lastPostCount = 0
    var kolodaView : KolodaView
    
    lazy var likeButton : UIButton = {
        
        let button = UIButton(image: UIImage(named:"ic_like")!, tintColor: .white, target: self, action: #selector(likePost))
        
        return button
    }()
    
    lazy var skipButton : UIButton = {
        
        let button = UIButton(image: UIImage(named:"ic_skip")!, tintColor: .white, target: self, action: #selector(skipPost))
        
        return button
    }()
    
    lazy var containerView : UIView = {
        let view = UIView();
        view.backgroundColor = .red;
        return view;
    }()
    
    lazy var panel = UIStackView()
    
    lazy var emptyPostInfo = UIView()
    
    fileprivate var dataSource = [Post]()
        
    init(userId : String){
        // refactor this if possible
        self.userId = userId
        self.kolodaView = KolodaView() // maybe send size here?
        super.init(nibName: nil, bundle: nil)
    }
    
    
    func tearDownSpinner(){
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
    }
    
    func setUpSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    
    required init?(coder: NSCoder) {
        self.userId = ""
        self.kolodaView = KolodaView() // maybe send size here?
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSpinner()
        self.checkPostCount() // setup datasource first
        self.kolodaView.delegate = self
        self.kolodaView.dataSource = self
        
        self.addViews()
        self.constrainViews()
        setupNavigation()
        
    }
    
    
    func checkPostCount() {
        
        print("Checking for new posts?")
        FirebaseService.shared.getTotalPostCount(completion: { totalPostCount,error in
            
            if error != nil || totalPostCount == nil{
                print("Didnt get total post count!")
                return
            }
            
            if totalPostCount! != self.lastPostCount {
                self.setUpSpinner()
                self.lastPostCount = totalPostCount!
                print("Loading up posts from backend... New count: \(self.lastPostCount)")
                
                FirebaseService.shared.getUserFeed(userId: self.userId, completion: {posts,error in
                    
                    if error != nil {
                        print("Didnt get feed!",error?.localizedDescription)
                        return
                    }
                        
                    
                    if posts == nil || posts?.count ?? 0 == 0 {
                        // no posts left
                        
                        self.noMorePostsLeft()
                        self.tearDownSpinner()
                        return
                    }
                    
                    self.dataSource = posts!
                    print("Loaded datasource with \(self.dataSource.count ) cards")
                    self.kolodaView.reloadData()
                    self.tearDownSpinner()
                    self.panel.isHidden = false
                    
                    print("All data sent!")
                })
            }
        })
    
    }
    
    func noMorePostsLeft(){
        kolodaView.isHidden = true
        self.panel.isHidden = true
        
        self.view.addSubview(emptyPostInfo)
        
        self.emptyPostInfo.centerInSuperview()
        self.emptyPostInfo.size(.init(width: 200, height: 200))
        
        let emptyPostText = UILabel(text: "There are no more posts to show", font: .boldSystemFont(ofSize: 16), textColor: .white, textAlignment: .center, numberOfLines: 1)
        
        self.emptyPostInfo.addSubview(emptyPostText)
        emptyPostText.center(in: emptyPostInfo)
        
        
    }
    
    func addViews(){
        
        panel = UIStackView(arrangedSubviews: [likeButton,skipButton])
        panel.axis = .horizontal
        panel.alignment = .fill
        panel.isHidden = true
        
        let totalViews = [containerView,kolodaView,panel]
        
        for currView in totalViews {
            self.view.addSubview(currView)
        }
    }
    
    func constrainViews(){
        let frameWidth = view.frame.width, frameHeight = view.frame.height
        
        
        containerView.edgesToSuperview()
        kolodaView.centerX(to: containerView)
        kolodaView.height(0.7 * frameHeight)
        kolodaView.width(0.9 * frameWidth)
        kolodaView.top(to: containerView,offset: 72)
        
        panel.centerX(to: containerView)
        panel.topToBottom(of: kolodaView,offset: 12)
        panel.height(70)
        panel.width(120)
        panel.padLeft(8)
        panel.padRight(8)
        
        
    }
    
    func setupNavigation() {
        self.parent?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"wallet-outline")!, style: .plain, target: self, action: #selector(walletTapped))
        
        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"ic_undo")!, style: .plain, target: self, action: #selector(undoTapped))
        
        self.parent?.navigationItem.title = "Feed"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Checking for new posts?")
        // method here will ensure feed is upto date
        self.checkPostCount()
        setupNavigation()
    }
    
    @objc func walletTapped(){
        self.parent?.navigationController?.pushViewController(ThoughtWallet(userId: self.userId), animated: true)
    }
    
    @objc func likePost() {
        print("simul right swipe")
        kolodaView.swipe(.right)
    }
    
    @objc func skipPost() {
        print("simul left swipe")
        kolodaView.swipe(.left)
    }
    
    @objc func undoTapped() {
        print("undo simul")
        
        let lastCard = kolodaView.currentCardIndex - 1 > -1 ? kolodaView.currentCardIndex - 1 : 0;
        
        if lastCard < 0 || lastCard >= dataSource.count {
            print("Index out of bounds")
            return
        }
        
        
        FirebaseService.shared.userHitUndo(userId: userId, postId: dataSource[lastCard].postID)
        kolodaView.revertAction()
    }
    
    // MARK: Datasource protocol
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return dataSource.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .moderate
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        // show specific card at this index probably resize card if it contains images
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        // setup a uiview to show an image for left and right swipes
        return ExampleOverlayView(frame: kolodaView.frame)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        // called whenever a card is swiped?? might be useful
        let postId = dataSource[index].postID ?? "invalid"
        print("Card \(index) swiped \(direction) with pid \(postId)")
        
        switch direction {
        case .left:
            FirebaseService.shared.userDislikedPost(userId: self.userId, postId:postId)
        case .right:
            FirebaseService.shared.userLikedPost(userId: self.userId, postId:postId)
        default:
            print("Invalid swipe")
        }
        
        print("Swiped card \(index) to \(direction.rawValue)")
    }
    
    // MARK: Delegate protocol
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        print("Attempting to load card at index \(index) out of \(dataSource.count)")
        let card = Card(frame: view.frame, post: dataSource[index])
        return card
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        // ran out of cards logic
        self.noMorePostsLeft()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        // select a certain card
        print("Tapped card \(index)")
    }
    
}

private let overlayRightImageName = "yesOverlayImage"
private let overlayLeftImageName = "noOverlayImage"

class ExampleOverlayView: OverlayView {
    
    // these images are meant to be shown when swept left/right accordingly.
    
   lazy var overlayImageView: UIImageView = {
        [self] in
        
        var imageView = UIImageView(frame: self.bounds) // since this was supposed to be an outlet you must add one somehow and link it here.
    
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        
        return imageView
        }()
    
    
    override init(frame : CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                overlayImageView.image = nil
            }
        }
    }

}
