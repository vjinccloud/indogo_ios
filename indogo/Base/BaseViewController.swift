//
//  BaseViewController.swift
//  indogo
//
//  Created by mac on 2020/9/15.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    @objc private func closeKeyboardNow(notification: NSNotification){
        //do stuff using the userInfo property of the notification object
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.closeKeyboardNow),
            name: Notification.Name("closeKeyboard"),
            object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
