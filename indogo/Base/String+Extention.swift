//
//  String+Extention.swift
//  indogo
//
//  Created by mac on 2020/8/17.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

extension String {
    func utf8DecodedString()-> String {
         let data = self.data(using: .utf8)
         if let message = String(data: data!, encoding: .nonLossyASCII){
                return message
          }
          return ""
    }

    func utf8EncodedString()-> String {
         let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8)!
         return text
    }
}
