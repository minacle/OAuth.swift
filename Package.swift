//
//  Package.swift
//  OAuth
//
//  Created by Sinoru on 2016. 12. 2..
//  Copyright © 2016 Sinoru. All rights reserved.

import PackageDescription

let package = Package(
    name: "OAuth",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/BlueCryptor.git", majorVersion: 0, minor: 8)
    ]
)
