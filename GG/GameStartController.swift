import UIKit
import SpriteKit

class GameStartController: UIViewController {
    let backgroundImage = UIImage(named: "home-screen")
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = backgroundImage
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        //TODO: Change button size based on the phone
//        switch UIDevice().type {
//        case .iPhone4:
//            fallthrough
//        case .iPhone5:
//            print("No TouchID sensor")
//        case .iPhone5S:
//            fallthrough
//        case .iPhone6:
//            fallthrough
//        case .iPhone6plus:
//            fallthrough
//        case .iPhone6S:
//            fallthrough
//        case .iPhone6Splus:
//            print("Put your thumb on the " +
//                UIDevice().type.rawValue + " sensor thingy")
//        default:
//            print("I am not equipped to handle this device")
//        }
        
        let rate_image = UIImage(named: "rate_button") as UIImage?
        let rate_button = UIButton(type: UIButtonType.System) as UIButton
        rate_button.frame = CGRectMake(view.frame.size.width+60 - view.frame.size.width, view.frame.size.height-90, 130, 58)
        rate_button.setBackgroundImage(rate_image, forState: .Normal)
        //button.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        self.view.addSubview(rate_button)
        
        let start_image = UIImage(named: "start_button") as UIImage?
        let start_button = UIButton(type: UIButtonType.System) as UIButton
        start_button.frame = CGRectMake(view.frame.size.width/2-100, 270, 200, 90)
        start_button.setBackgroundImage(start_image, forState: .Normal)
        start_button.addTarget(self, action: "startGameButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(start_button)
        
        let score_image = UIImage(named: "score_button") as UIImage?
        let score_button = UIButton(type: UIButtonType.System) as UIButton
        score_button.frame = CGRectMake(view.frame.size.width-190, view.frame.size.height-90, 130, 58)
        score_button.setBackgroundImage(score_image, forState: .Normal)
        //button.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        self.view.addSubview(score_button)
    }
    
    func startGameButtonAction(sender:UIButton!) {
        dispatch_async(dispatch_get_main_queue(),{
            self.performSegueWithIdentifier("startGame", sender: self)
        })
        
        // would be nice to have a de
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
