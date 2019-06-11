//
//  AppDelegate.swift
//  CoreDataLatest
//
//  Created by Iragam Reddy, Sreekanth Reddy on 6/8/19.
//  Copyright © 2019 Iragam Reddy, Sreekanth Reddy. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if getCommunityDataCount() == 0 {
            fetchMockData()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func fetchMockData() {
        let privateManagerObjContext = CoreDataStack.shared.getPrivateManagedObjectContext()
        
        privateManagerObjContext.perform {
            
            let url = Bundle.main.url(forResource: "CommunityGroupMock", withExtension: "json")
            do
            {
                let data = try Data(contentsOf: url!)
                let communityDictionary = try (JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any])
                
                let communityData = communityDictionary["groups"] as! NSArray
                
                for comminity in communityData {
                    let singleComminityData = comminity as? [String: Any]
                    let groupId = singleComminityData?["groupId"] as? Int16
                    let groupName = singleComminityData?["name"] as? String
                    
                    
                    let communityGroup = NSEntityDescription.insertNewObject(forEntityName: EnitityConstants.communityGroup, into: privateManagerObjContext) as! CommunityGroup
                    communityGroup.name = groupName
                    communityGroup.groupId = groupId!
                    
                    let people = singleComminityData?["people"] as? [Any]
                    var persons = Set<Person>()
                    people?.forEach{ person in
                        
                        guard let personData = person as? [String: Any],
                            let name = personData["name"] as? String,
                            let gender = personData["gender"] as? String,
                            let age = personData["age"] as? Int16 else {
                                return }
                        let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: privateManagerObjContext) as! Person
                        person.name = name
                        person.age = age
                        person.community = communityGroup
                        person.gender = gender
                        persons.insert(person)
                    }
                    
                    
                    communityGroup.person = persons as NSSet
                    
                }
                
            } catch {
                print("error in fetching the data \(error)")
            }
            
            privateManagerObjContext.saveRecursively()
        }
    }
    
    private func getCommunityDataCount() -> Int {
        var communityCount = 0
        do {
            let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "CommunityGroup")
            communityCount = try CoreDataStack.shared.getPrivateManagedObjectContext().count(for: fetchReq)
            print("countCommunity... \(communityCount)")
        } catch {
            print("error is \(error)")
        }
        return communityCount
    }
}

