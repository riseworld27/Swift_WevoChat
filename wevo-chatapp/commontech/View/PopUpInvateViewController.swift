import UIKit
import QuartzCore
import Alamofire

@objc public class PopUpInvateViewController : UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var logoImg: UIImageView!
    var phoneNumber = ""

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        
        self.logoImg.layer.cornerRadius = self.logoImg.frame.size.width / 2
        self.logoImg.clipsToBounds = true
    }
    
    public func showInView(aView: UIView!, withImage image : UIImage!, withMessage message: String!, animated: Bool, withNumber phone: String!)
    {
        aView.addSubview(self.view)
        logoImg!.image = image
        messageLabel!.text = message
        self.phoneNumber = phone
        if animated
        {
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    @IBOutlet weak var invateFriend: UIButton!
    @IBAction func invateFriendBtn(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        let parametersToSend = [
            "phoneNumberToSend": (self.phoneNumber as? AnyObject)!,
            "nameToSend": (messageLabel!.text as? AnyObject)!,

            
        ]
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/invate"
        Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend, headers: headers).responseJSON { response in
            print(response)
        }
        self.removeAnimate()

    }
    
    @IBAction public func closePopup(sender: AnyObject) {
        self.removeAnimate()
    }
}
