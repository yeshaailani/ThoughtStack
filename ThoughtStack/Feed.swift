

import UIKit
import Koloda
import pop
import TinyConstraints


/*
 Issues:
 
 1. Need to resize card and the views within based on whether images are included or not
 2. Need to connect front end to backend
 3. TW button on the top will take user to list of posts
 */

class Feed : UIViewController, KolodaViewDataSource, KolodaViewDelegate {
    
    
    var userId : String
    
    lazy var kolodaView : KolodaView = {
        let view = KolodaView()
        return view
    }()
    
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
        view.backgroundColor = .lightGray;
        return view;
    }()
    
    lazy var panel = UIStackView()
    
    fileprivate var dataSource : [Post] = {
        let posts = Utilities.singleton.getMockQuotes()
        return posts
    }()
        
    init(userId : String){
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.userId = ""
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.delegate = self
        kolodaView.dataSource = self
        
        setupNavigation()
        addViews()
        constrainViews()
    }
    
    func addViews(){
        
        panel = UIStackView(arrangedSubviews: [likeButton,skipButton])
        panel.axis = .horizontal
        panel.alignment = .fill
        
        let totalViews = [containerView,kolodaView,panel]
        
        for currView in totalViews {
            self.view.addSubview(currView)
        }
    }
    
    func constrainViews(){
        let frameWidth = view.frame.width, frameHeight = view.frame.height
        
        kolodaView.centerX(to: containerView)
        kolodaView.width(0.6 * frameWidth)
        kolodaView.height(0.6 * frameHeight)
        kolodaView.top(to: containerView,offset: 20)
        
        panel.centerX(to: containerView)
        panel.topToBottom(of: kolodaView,offset: 12)
        panel.height(70)
        panel.width(120)
        panel.padLeft(8)
        panel.padRight(8)
        
        
        containerView.edgesToSuperview()
        
    }
    
    func setupNavigation() {
        self.parent?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"wallet-outline")!, style: .plain, target: self, action: #selector(walletTapped))
        
        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"ic_undo")!, style: .plain, target: self, action: #selector(undoTapped))
        
        self.parent?.navigationItem.title = "Feed"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Checking for new posts?")
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
        return ExampleOverlayView(frame: view.frame)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        // called whenever a card is swiped?? might be useful
        print("Swiped card \(index) to \(direction.rawValue)")
    }
    
    // MARK: Delegate protocol
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return Card(frame: view.frame, post: dataSource[index])
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        // ran out of cards logic
        koloda.resetCurrentCardIndex()
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
    
        imageView.contentMode = .scaleAspectFill
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
