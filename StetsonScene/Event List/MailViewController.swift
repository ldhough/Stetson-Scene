//
//  MailViewController.swift
//  StetsonScene
//
//  Created by Lannie Hough on 2/24/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

/*class MailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    var emailTitle:String
    var messageBody:String
    var toEventOrganizer:[String]
    @IBAction func launchEmail(sender: AnyObject) {
        let mc:MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toEventOrganizer)
        self.present(mc, animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("mail cancelled")
        case .saved:
            print("mail saved")
        case .sent:
            print("mail sent")
        case .failed:
            print("Mail sent failure: \(error?.localizedDescription ?? "Unknown")")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
}*/
