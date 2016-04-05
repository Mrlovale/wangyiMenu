//
//  NewsViewController.swift
//  仿网易菜单
//
//  Created by 赵大红 on 16/4/3.
//  Copyright © 2016年 赵大红. All rights reserved.
//

import UIKit

protocol NewsViewControllerDelegate: NSObjectProtocol {
    func newsScrollViewDidScroll(scrollView: UIScrollView)
}

let ID = "identifier"
class NewsViewController: UITableViewController {
    weak var newsDelegate: NewsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 40
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(ID)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: ID)
        }
        
        cell?.textLabel?.text = "-----\(title!)"
        
        return cell!
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        newsDelegate?.newsScrollViewDidScroll(scrollView)
    }
    
}
