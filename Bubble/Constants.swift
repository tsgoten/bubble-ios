//
//  Constants.swift
//  Bubble
//
//  Created by Tarang Srivastava on 6/17/19.
//  Copyright © 2019 Bubble. All rights reserved.
//

import Firebase

struct Constants {
    struct refs {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
    }
}
