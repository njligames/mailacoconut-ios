//
//  TutorialViewController.swift
//  mailacoconut
//
//  Created by James Folk on 4/18/16.
//  Copyright © 2016 NJLIGames Ltd. All rights reserved.
//

import Foundation

class TutorialViewController: UIViewController
{
    @IBOutlet var scrollView: UIScrollView!
    override func viewDidLoad()
    {
        let pageCount:CGFloat = 3
        
//        let scrollView:UIScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 640, height: 1136))
        scrollView.backgroundColor = UIColor(red: 1, green: 1, blue: 0, alpha: 0.5)
        scrollView.isPagingEnabled = true
        
        scrollView.contentSize = CGSize(width: pageCount * scrollView.bounds.width, height: scrollView.bounds.height)
        
        var viewSize:CGRect = scrollView.bounds

        let imgView:UIImageView = UIImageView(frame: viewSize)
        imgView.image = UIImage(named: "Tutorial Page 1")
        scrollView.addSubview(imgView)
        
        viewSize = viewSize.offsetBy(dx: scrollView.bounds.size.width, dy: 0)
        
        let imgView2:UIImageView = UIImageView(frame: viewSize)
        imgView2.image = UIImage(named: "Tutorial Page 2")
        scrollView.addSubview(imgView2)
        
        viewSize = viewSize.offsetBy(dx: scrollView.bounds.size.width, dy: 0)
        
        let imgView3:UIImageView = UIImageView(frame: viewSize)
        imgView3.image = UIImage(named: "Tutorial Page 3")
        scrollView.addSubview(imgView3)
        
//        self.view.addSubview(scrollView)
        
        
        
//        var newViewSize:CGRect = scrollView.bounds
//        let numberOfImages = 3
//        var i = 0
//        
//        for(i = 0; i < numberOfImages; i += 1)
//        {
//            if i == 0
//            {
//                let imgView:UIImageView = UIImageView(frame: newViewSize)
//                let filePath:String = String(format: "Tutorial Page %d", i + 1)
//                imgView.image = UIImage(named: filePath)
//                scrollView.addSubview(imgView)
//            }
//            else
//            {
//                newViewSize = CGRectOffset(viewSize, scrollView.bounds.size.width, 0)
//                let imgView:UIImageView = UIImageView(frame: newViewSize)
//                let filePath:String = String(format: "Tutorial Page %d", i + 1)
//                imgView.image = UIImage(named: filePath)
//                scrollView.addSubview(imgView)
//            }
//        }
//        
//        self.view.addSubview(scrollView)
    }
}
