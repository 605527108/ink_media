//
//  AppDelegate.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/5/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var hasMovieFile: Bool = false
    var hasMusicFile: Bool = false
    var hasCartoonFile: Bool = false
    var connectToIPv6: Bool = false
    var highResolution: Bool = false
    var connectToNKU: Bool = false
    var backgroundSessionCompletionHandler: (() -> Void)?
//    let tintColor =  UIColor(red: 242/255, green: 71/255, blue: 63/255, alpha: 1)
    let tintColor =  UIColor(red: 248/255, green: 0/255, blue: 0/255, alpha: 1)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        customizeAppearance()
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let containerViewController = ContainerViewController()
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()
        checkConnectStatusToIPv6()
        checkConnectStatusToNKU()
        checkMovieFile()
        checkMusicFile()
        checkCartoonFile()
        return true
    }
    
    func checkDeviceType()
    {
        if max(UIScreen.mainScreen().bounds.size.height,UIScreen.mainScreen().bounds.size.width) >= 667
        {
            highResolution = true
        }
        else
        {
            highResolution = false
        }
        print(highResolution)

    }
    func checkConnectStatusToNKU()
    {
        let testURL = NSURL(string: "http://movie.nku.cn")
        let request = NSMutableURLRequest(URL: testURL!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 3)
        let URLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: URLSessionConfiguration, delegate: nil, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if(error != nil)
            {
                print(error?.localizedDescription)
                self.connectToNKU = false
            }
            else
            {
                let HTTPURLResponse = response as! NSHTTPURLResponse
                if(HTTPURLResponse.statusCode != 200)
                {
                    print(HTTPURLResponse.statusCode)
                }
                else
                {
                    print("connectToNKU")
                    self.connectToNKU = true
                }
            }
        }
        task.resume()
    }
    func checkConnectStatusToIPv6()
    {
        let IPv6TestURL = NSURL(string: "http://tv.byr.cn/mobile/")
        let request = NSMutableURLRequest(URL: IPv6TestURL!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 3)
        let URLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: URLSessionConfiguration, delegate: nil, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if(error != nil)
            {
                print(error?.localizedDescription)
                self.connectToIPv6 = false
            }
            else
            {
                let HTTPURLResponse = response as! NSHTTPURLResponse
                if(HTTPURLResponse.statusCode != 200)
                {
                    print(HTTPURLResponse)
                }
                else
                {
                    self.connectToIPv6 = true
                }
            }
        }
        task.resume()
    }
    
    func checkMovieFile()
    {
        managedObjectContext.performBlockAndWait { [weak weakSelf = self] in
            let request = NSFetchRequest(entityName: "MovieFile")
            request.predicate = nil
            if ((try? self.managedObjectContext.executeFetchRequest(request))?.first as? MovieFile) == nil
            {
                weakSelf?.hasMovieFile = false
                print("No movieFile")
            }
            else
            {
                weakSelf?.hasMovieFile = true
            }
        }
    }
    
    func checkCartoonFile()
    {
        managedObjectContext.performBlockAndWait { [weak weakSelf = self] in
            let request = NSFetchRequest(entityName: "CartoonFile")
            request.predicate = nil
            if ((try? self.managedObjectContext.executeFetchRequest(request))?.first as? CartoonFile) == nil
            {
                weakSelf?.hasCartoonFile = false
                print("No cartoonFile")
            }
            else
            {
                weakSelf?.hasCartoonFile = true
            }
        }
    }
    
    func checkMusicFile()
    {
        managedObjectContext.performBlockAndWait { [weak weakSelf = self] in
            let request = NSFetchRequest(entityName: "MusicFile")
            request.predicate = nil
            if ((try? self.managedObjectContext.executeFetchRequest(request))?.first as? MusicFile) == nil
            {
                weakSelf?.hasMusicFile = false
                print("No musicFile")
            }
            else
            {
                weakSelf?.hasMusicFile = true
            }
        }
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "iNankai.bbb" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    private func customizeAppearance() {
        window?.tintColor = tintColor
        UISearchBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
}
