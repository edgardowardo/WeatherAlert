//
//  WAAcknowledgementsViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 23/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import UIKit
import VTAcknowledgementsViewController

class WAAcknowledgementsViewController : VTAcknowledgementsViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ack = self.acknowledgements![indexPath.row]
        let ackController = WAAcknowledgementViewController(title: ack.title, text: ack.text)!
        self.navigationController?.pushViewController(ackController, animated: true)
    }
}

class WAAcknowledgementViewController : VTAcknowledgementViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
}