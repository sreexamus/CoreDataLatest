//
//  ViewController.swift
//  CoreDataLatest
//
//  Created by Iragam Reddy, Sreekanth Reddy on 6/8/19.
//  Copyright © 2019 Iragam Reddy, Sreekanth Reddy. All rights reserved.
//

import UIKit
import CoreData

final class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var communities: [CommunityGroup]?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getPersonsInCommunity()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func getPersonsInCommunity() {
        
        do {
            let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: EnitityConstants.communityGroup)
            guard let communities = try CoreDataStack.shared.mainManagedObjectContext.fetch(fetchReq) as? [CommunityGroup] else { return }
            self.communities = communities
            print("the vc self.communities is \(self.communities)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch {
            print("error is \(error)")
        }
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return communities?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return communities?[section].person?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return communities?[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PersonTableViewCell
        let allPersons = communities?[indexPath.section].person?.allObjects
        guard let person = allPersons?[indexPath.row] as? Person else { return UITableViewCell() }
        cell.age.text = "Age: \(person.age)"
        cell.gender.text = "Gender: \(person.gender!)"
        cell.name.text = "Name: \(person.name!)"
        return cell
    }
}

