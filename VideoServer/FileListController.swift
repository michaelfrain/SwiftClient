//
//  FileListController.swift
//  VideoServer
//
//  Created by Michael Frain on 3/23/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

import UIKit

class FileListController: UIViewController {
    var localhostArray: Array<NSURL> {
        let localhost = NSURL(string: AddressHelper.documentsDirectory())
        let manager = NSFileManager.defaultManager()
        let fileList = manager.contentsOfDirectoryAtURL(localhost!, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, error: nil)
        return fileList as Array<NSURL>
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FileListController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = localhostArray.count
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileCell") as UITableViewCell
        let url = localhostArray[indexPath.row]
        cell.textLabel!.text = url.path
        return cell
    }
    
}
