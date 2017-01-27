//
//  GroupsTableViewController.swift
//  commontech
//
//  Created by matata on 09/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import Alamofire
class GroupsTableViewController: UIViewController {
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
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
    
    @IBOutlet var tableViewGroup: UITableView!
    var valueToPass:String!
    var isViewMembersGroup:Bool!
    @IBAction func viewMembersGroup(sender: AnyObject) {
//        print(sender.tag)
//        print("tapped button")
//        let groupName = arrrayGroup[sender.tag]
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChooseUsersForGroup") as? ChooseUsersViewController
//        vc!.passedValue = self.arrrayGroup[sender.tag].GroupId
//        vc!.isViewMembersGroup = true
//
//        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
 
    var arrrayGroup: [Groups] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.StartActivity()
        loadGroups()
        tableViewGroup.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

    }
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableViewGroup.reloadData()
            self.StopActivity()

            return
        })
    }
    func loadGroups()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let headers = ["Authorization": defaults.stringForKey("guid")!]

        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/" + UserId! + "/groups"
        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!

            let totalItems : NSNumber = resultDic.valueForKey("totalItems") as! NSNumber
            if totalItems == 0
            {
                self.StopActivity()
                return
            }
            let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
            for item in resultArr {
                let group =  Groups(GroupName: (item.valueForKey("GroupName") as? String)!, GroupId: (item.valueForKey("GroupId") as? String)!, UserId: (item.valueForKey("OwnerUserId") as? String)!)!
                
                self.arrrayGroup.append(group)

            }
            self.do_table_refresh();


        }

    }


}
extension GroupsTableViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "DELETE") { (action , indexPath ) -> Void in
            self.editing = false
            print("DELETE button pressed")
            let itemGroup = self.arrrayGroup[indexPath.row]
            let defaults = NSUserDefaults.standardUserDefaults()

            
            let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/groups/" + itemGroup.GroupId
            let headers = ["Authorization": defaults.stringForKey("guid")!]

            Alamofire.request(.DELETE, postEndpoint, parameters: nil, headers: headers).responseJSON { response in
                print(response)
            }
            self.arrrayGroup.removeAtIndex(indexPath.row)
            
            self.do_table_refresh()
        }

        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "EDIT") { (action , indexPath) -> Void in
            self.editing = false
            print("EDIT button pressed")
            let itemGroup = self.arrrayGroup[indexPath.row]

            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcCreateGroup") as? CreateGroupController
            vc!.passedGroupId = itemGroup.GroupId
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        let viewAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "VIEW") { (action , indexPath) -> Void in
            self.editing = false
            print("VIEW button pressed")
            //let groupName = self.arrrayGroup[indexPath.row].GroupName
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChooseUsersForGroup") as? ChooseUsersViewController
            vc!.passedValue = self.arrrayGroup[indexPath.row].GroupId
            vc!.isViewMembersGroup = true
            
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        viewAction.backgroundColor = UIColor.blueColor()

        return [deleteAction, editAction, viewAction]
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return arrrayGroup.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "GroupsCell"
        let groupsCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! GroupsCell
        let groupC = self.arrrayGroup[indexPath.row]
        if let label = groupsCell.lblName{
            label.text = groupC.GroupName
        }
        if let btnView = groupsCell.viewMembersGroup{
            btnView.tag = indexPath.row

        }
        return groupsCell

    }
 
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let indexPath = tableView.indexPathForSelectedRow;

        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChooseUsersForGroup") as? ChooseUsersViewController
        vc!.passedValue = self.arrrayGroup[indexPath!.row].GroupId
        vc!.isViewMembersGroup = false

        self.navigationController?.pushViewController(vc!, animated: true)
  
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
//        if (segue.identifier == "idSegueChooseUsers") {
//            
//            // initialize new view controller and cast it as your view controller
//            let viewController = segue.destinationViewController as! ChooseUsersViewController
//            // your new view controller should have property that will store passed value
//            viewController.passedValue = self.valueToPass
//            viewController.isViewMembersGroup = false
//            
//        }
        
    }
}

