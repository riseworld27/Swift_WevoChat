//
//  UserDataViewController.swift
//  commontech
//
//  Created by matata on 19/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import Alamofire
class UserDataViewController: UIViewController , UserDataCellDelegate{
    @IBOutlet weak var activity: UIActivityIndicatorView!
    //var arrrayMusic: [UserFacebookMusic] = []
    var arrrayMusic: [String] = []
    var page = 1
    func StartActivity()
    {
        activity.hidden = false
        activity.startAnimating()
    }
    func StopActivity()
    {
        activity.hidden = true
        activity.stopAnimating()
    }
    
    @IBAction func LoadMore(sender: AnyObject) {
        page++
        self.loadMusics()
    }
    @IBOutlet var tableViewMusic: UITableView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.StartActivity()

        loadMusics()
                tableViewMusic.dataSource = self
                tableViewMusic.delegate = self
               tableViewMusic.registerClass(UserDataCell.self, forCellReuseIdentifier: "MusicCell")
                tableViewMusic.separatorStyle = .None
                tableViewMusic.backgroundColor = UIColor.blackColor()
                tableViewMusic.rowHeight = 50;

    }
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableViewMusic.reloadData()
            self.StopActivity()
            
            return
        })
    }
    func loadMusics()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/"+UserId!+"/data/"+String(self.page)
        let headers = ["Authorization": defaults.stringForKey("guid")!]

        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
            print(response)

            //let resultDic : NSArray =  (response.result.value as? NSArray)!
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            let arrDic : NSArray =  (resultDic.valueForKey("data") as? NSArray)!

            for item in arrDic {
                if(item.valueForKey("title") === NSNull()){
                    
                }else{
                    self.arrrayMusic.append((item.valueForKey("title") as? String)!)

                }
                
            }
            self.do_table_refresh();
            
            
        }
        
    }
    func sinkOperation(item: String){
        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/"+UserId!+"/sink"
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        let parametersToSend = [
            "stringValue": (item as? AnyObject)!
        ]
        Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend, headers: headers).responseJSON { response in
            print(response)
        }
    }
    func floatOperation(item: String){
        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/"+UserId!+"/float"
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        let parametersToSend = [
            "stringValue": (item as? AnyObject)!
        ]
        Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend, headers: headers).responseJSON { response in
            print(response)
        }
    }
    //MARK: - UserDataCellDelegate
    func toDoItemSink(operationItem: String) {
        let index = (self.arrrayMusic as NSArray).indexOfObject(operationItem)
        if index == NSNotFound { return }
        self.sinkOperation(self.arrrayMusic[index])
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        self.arrrayMusic.removeAtIndex(index)
        
        // use the UITableView to animate the removal of this row
        tableViewMusic.beginUpdates()
        let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
        tableViewMusic.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Fade)
        tableViewMusic.endUpdates()
    }
    func toDoItemFloat(operationItem: String) {
        let index = (self.arrrayMusic as NSArray).indexOfObject(operationItem)
        if index == NSNotFound { return }
        self.floatOperation(self.arrrayMusic[index])

        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        self.arrrayMusic.removeAtIndex(index)
        
        // use the UITableView to animate the removal of this row
        tableViewMusic.beginUpdates()
        let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
        tableViewMusic.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Fade)
        tableViewMusic.endUpdates()
    }

}


//MARK: - UITableViewDataSource

extension UserDataViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return self.arrrayMusic.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {

        let CellIdentifier = "MusicCell"
        
//        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: CellIdentifier) as! InstagramCells
                let musicCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! UserDataCell
        
                let musicItem = self.arrrayMusic[indexPath.row]
                if var label = musicCell.lblName{
                    label.text = musicItem
                    label.textColor = UIColor.blackColor()
                }
        
        musicCell.selectionStyle = .None
        musicCell.delegate = self
        musicCell.operationItem = musicItem

        return musicCell
    }
    
}
//MARK: - UITableViewDelegate

extension UserDataViewController: UITableViewDelegate {
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }
//       func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // the cells you would like the actions to appear needs to be editable
//        return true
//    }
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        // you need to implement this method too or you can't swipe to display the actions
//    }
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
//    
//        let sink = UITableViewRowAction(style: .Normal, title: "Sink") { action, index in
//            print("sink button tapped")
//            print(indexPath.row)
//            print(self.arrrayMusic[indexPath.row])
//            self.sinkOperation(self.arrrayMusic[indexPath.row])
//            self.arrrayMusic.removeAtIndex(indexPath.row)
//            tableView.reloadData()
//        }
//        sink.backgroundColor = UIColor.redColor()
//        
//        let float = UITableViewRowAction(style: .Normal, title: "float") { action, index in
//            print("float button tapped")
//            print(indexPath.row)
//            
//            self.floatOperation(self.arrrayMusic[indexPath.row])
//
//            self.arrrayMusic.removeAtIndex(indexPath.row)
//            tableView.reloadData()
//        }
//        float.backgroundColor = UIColor.blueColor()
//        
//        
//        return [sink, float]
//
//
//
//    }
    func colorForIndex(index: Int) -> UIColor {
        let itemCount = self.arrrayMusic.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
            cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    // support for versions of iOS prior to iOS 8
    func tableView(tableView: UITableView, heightForRowAtIndexPath
        indexPath: NSIndexPath) -> CGFloat {
            return tableView.rowHeight;
    }
    
}
