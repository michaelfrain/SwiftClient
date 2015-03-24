//
//  ServerControllerViewController.swift
//  VideoServer
//
//  Created by Michael Frain on 3/23/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

import UIKit

class ServerController: UIViewController {
    @IBOutlet weak var switchServerActive: UISwitch!
    @IBOutlet weak var labelServerStatus: UILabel!
    
    let server = HTTPServer()
    let globalError = NSErrorPointer()
    let currentAddress = AddressHelper.getIPAddress(true)

    override func viewDidLoad() {
        super.viewDidLoad()
        server.setPort(8080)
        server.setDocumentRoot(AddressHelper.documentsDirectory())
        server.setConnectionClass(ServerConnection.self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let alert = UIAlertController(title: "Note!", message: "I recommend setting your auto-lock preference to \"NEVER\", as this server CANNOT run in the background. Visit Settings > General > Auto-Lock to change this setting.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
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

    @IBAction func serverSwitched(sender: UISwitch!) {
        if sender.on {
            if server.start(globalError) {
                labelServerStatus.text = "Current server status: Active with address \(currentAddress):\(server.listeningPort())"
            } else {
                labelServerStatus.text = "Current server status: Could not start server"
            }
        } else {
            server.stop()
            labelServerStatus.text = "Current server status: Server stopped"
        }
    }
}
