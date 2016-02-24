//
//  DetailViewController.swift
//  CData
//
//  Created by jhampac on 2/18/16.
//  Copyright © 2016 jhampac. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController
{
    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView()
    {
        // Update the user interface for the detail item.
        if let detail = self.detailItem as? Commit
        {
            if let label = self.detailDescriptionLabel
            {
                label.text = detail.message
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Commit 1/\(detail.author.commits.count)", style: .Plain, target: self, action: "showAuthorCommits")
            }
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

