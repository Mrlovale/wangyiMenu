//
//  ViewController.swift
//  仿网易菜单
//
//  Created by 赵大红 on 16/4/3.
//  Copyright © 2016年 赵大红. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIScrollViewDelegate,NewsViewControllerDelegate {

    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var titleScrollView: UIScrollView!
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    // 记录偏移量
    private var lastPosition: CGFloat = 0
    // 记录标题是否在动画
    private var isAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        // 添加子控制器
        addChildViewControllers()
        // 设置标题栏
        setupTitleScrollView()
        // 设置内容
        scrollViewDidEndScrollingAnimation(contentScrollView)
    }

    /// 添加子控制器
    private func addChildViewControllers() {
        let titles = ["热点","娱乐","体育","科技","民生","财经","汽车","时尚"]
        for title in titles {
            let newsVc = NewsViewController()
            newsVc.title = title
            newsVc.newsDelegate = self
            addChildViewController(newsVc)
        }
        contentScrollView.contentSize = CGSize(width: contentW() * CGFloat(childViewControllers.count), height: contentH())
        contentScrollView.delegate = self
    }
    
    /// 设置标题栏
    private func setupTitleScrollView() {
        let height = titleH()
        let width = titleW()
        titleScrollView.contentSize = CGSize(width: width * CGFloat(childViewControllers.count), height: 0)
        
        for i in 0..<childViewControllers.count {
            let label = TitleLabel(frame: CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height))
            label.text = childViewControllers[i].title
            label.tag = i
            let tap = UITapGestureRecognizer(target: self, action: "titleClick:")
            label.addGestureRecognizer(tap)
            titleScrollView.addSubview(label)
            if (i == 0) { // 最前面的label
                label.scale = 1.0;
            }
        }
        
    }
    
    /// 设置内容
    private func setupContentScrollView() {
        contentScrollView.contentSize = CGSize(width: contentW() * CGFloat(childViewControllers.count), height: contentH())
        let vc = childViewControllers.first
        vc?.view.frame = CGRect(x: 0, y: 0, width: contentW(), height: contentH())
        contentScrollView.addSubview((vc?.view)!)
        contentScrollView.delegate = self
    }
    
    /// 点击标题
    func titleClick(gesture: UIGestureRecognizer) {
        let label = gesture.view as! UILabel
        let tag = CGFloat(label.tag)
        
        contentScrollView.setContentOffset(CGPoint(x: tag * contentW(), y: 0), animated: true)
        
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / contentW())
        
        // 让对应的顶部标题居中显示
        let label = titleScrollView.subviews[index]
        var titleOffset = titleScrollView.contentOffset
        titleOffset.x = label.center.x - contentW() * 0.5
        // 左边超出处理
        if titleOffset.x < 0 {
            titleOffset.x = 0
        }
        // 右边超出处理
        let maxTitleOffsetX = titleScrollView.contentSize.width - contentW();
        if titleOffset.x > maxTitleOffsetX {
            titleOffset.x = maxTitleOffsetX
        }
        titleScrollView.setContentOffset(titleOffset, animated: true)
        
        // 让其他label回到最初的状态
        for titleLabel in titleScrollView.subviews {
            if titleLabel != label {
                (titleLabel as! TitleLabel).scale = 0.0
            }
        }
        
        let vc = childViewControllers[index]
        // 如果该view已经加载过，就不需要再次加载
        if vc.isViewLoaded() {return}
        
        vc.view.frame = CGRect(x: CGFloat(index) * contentW(), y: 0, width: contentW(), height: contentH())
        contentScrollView.addSubview(vc.view)
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        scrollViewDidEndScrollingAnimation(contentScrollView)
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scale = scrollView.contentOffset.x / scrollView.frame.width
        if scale < 0 || scale > CGFloat(titleScrollView.subviews.count) {return}
        
        // 获取左边的label
        let leftIndex = Int(scale)
        let leftLabel = titleScrollView.subviews[leftIndex] as! TitleLabel
        
        // 获取右边的label
        let rightIndex = leftIndex + 1
        let rightLabel = (rightIndex == titleScrollView.subviews.count) ? TitleLabel() : titleScrollView.subviews[rightIndex] as! TitleLabel
        
        // 右边比例
        let rightScale = scale - CGFloat(leftIndex)
        // 左边比例
        let leftScale = 1 - rightScale
        
        // 设置label的比例
        leftLabel.scale = leftScale
        rightLabel.scale = rightScale
    }
    
    // MARK:- NewsViewControllerDelegate
    func newsScrollViewDidScroll(scrollView: UIScrollView)
    {
        let currentPosition = scrollView.contentOffset.y
        print(currentPosition)
        if currentPosition <= 0 {
            showOrHideTitleScrollView(true)
        }
        else if currentPosition - lastPosition > 40{ // 上滑
            lastPosition = currentPosition
            showOrHideTitleScrollView(false)
        }
        else if lastPosition - currentPosition > 40 { // 下滑
            lastPosition = currentPosition
            showOrHideTitleScrollView(true)
        }
    }
    
    // show = true显示 show = false隐藏
    private func showOrHideTitleScrollView(show: Bool) {
        if isAnimating {return}
        isAnimating = true
        titleTopConstraint.constant = show ? 0 : -44
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                self.isAnimating = false
        }
    }
    
    //MARK:- 获取contentScrollView跟titleScrollView的宽高
    private func contentW() -> CGFloat {
        return contentScrollView.bounds.width
    }
    private func contentH() -> CGFloat {
        return contentScrollView.bounds.height
    }
    private func titleH() -> CGFloat {
        return titleScrollView.bounds.height
    }
    private func titleW() -> CGFloat {
        return 80
    }
    

}


let Red:CGFloat = 0.4
let Green = 0.6
let Blue = 0.7
class TitleLabel: UILabel {
    var scale: CGFloat? {
        didSet {
            //      R G B
            // 默认：0.4 0.6 0.7
            // 红色：1   0   0
            let red = Red + (1 - Red) * scale!
            let green = CGFloat(Green) + CGFloat(0 - Green) * scale!
            let blue = CGFloat(Blue) + CGFloat(0 - Blue) * scale!
            textColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            
            let transformScale = 1 + 0.3 * scale! // [1, 1.3]
            transform = CGAffineTransformMakeScale(transformScale, transformScale)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = NSTextAlignment.Center
        font = UIFont.systemFontOfSize(14.0)
        userInteractionEnabled = true
        backgroundColor = UIColor.lightTextColor()
        textColor = UIColor(red: CGFloat(Red), green:CGFloat(Green), blue: CGFloat(Blue), alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

