//
//  Application.swift
//  TesserCube
//
//  Created by jk234ert on 2019/2/20.
//  Copyright © 2019 Sujitech. All rights reserved.
//

import Foundation
#if DEBUG
#if FLEX
import FLEX
#endif
#endif
import SwifterSwift
import IQKeyboardManagerSwift
import SVProgressHUD
import ConsolePrint

class Application: NSObject {
    
    static let instance = Application()
    
    class func applicationConfigInit(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        initLogger()
        initServices(application, launchOptions: launchOptions)
        
        initPersistentData()
        initUserDefaults()
        
        setupAppearance()
    }
    
    private class func initLogger() {
    }
    
    private class func initServices(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {

        UIApplication.shared.applicationSupportsShakeToEdit = true

        if SwifterSwift.isInDebuggingMode || SwifterSwift.isInTestFlight {
            #if FLEX
            FLEXManager.shared().showExplorer()
            #endif
        } else {
            
        }

        if let wordPredictor = WordSuggestionService.shared.wordPredictor, wordPredictor.needLoadNgramData {
            wordPredictor.load { error in
                consolePrint(error?.localizedDescription ?? "NGram realm setup success")
            }
        }

        IQKeyboardManager.shared.enable = true
    }
    
    private class func initPersistentData() {
//        TCDBManager.default?.test()
    }
    
    private class func initUserDefaults() {
        KeyboardPreference.accountName = "you get me!"

        // TODO: set tessercube armor header
//        DMSPGPArmoredHeader.commentHeaderContentForArmoredKey = "You can manage keys with https://tessercube.com"
//        DMSPGPArmoredHeader.commentHeaderContentForMessage = "Encrypted with https://tessercube.com"
        
    }
    
    private class func setupAppearance() {
        SVProgressHUD.setHapticsEnabled(true)
        SVProgressHUD.setMinimumSize(CGSize(width: 128, height: 96))
//        UINavigationBar.appearance().barTintColor = .purple
//        UINavigationBar.appearance().tintColor = .white
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        UISearchBar.appearance().tintColor = .white
//        UISearchBar.appearance().barTintColor = .white
    }
}
