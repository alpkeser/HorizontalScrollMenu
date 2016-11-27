//
//  HorizontalScrollMenuVC.swift
//  Draft
//
//  Created by Alp Keser on 11/26/16.
//  Copyright © 2016 Acropole. All rights reserved.
//

import UIKit

class HorizontalScrollMenuVC: UIViewController, UIScrollViewDelegate {
    
    //public variables
    var viewControllers: [UIViewController] = []
    var titles: [String] = []
    
    var initialViewControllerIndex = 1
    
    //IBOutlets
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var menuScrollView: UIScrollView!
    @IBOutlet weak var overlayScrollView: UIScrollView!
    
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var mainContentViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuViewWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var overlayViewWidthConstraint: NSLayoutConstraint!
    
    //Private
    private enum Scrolling{
        case none
        case main
        case overlay
    }
    
    private var scrolling: Scrolling = .none
    private var screenWidth = 0.0
    private var menuWidth: Double {
        get {
            return screenWidth / 2.0;
        }
    }
    private var initialOffset: CGPoint {
        get {
            let unitContentOffsetX = screenWidth
            let contentOffsetX = unitContentOffsetX * Double(initialViewControllerIndex) //ToDo: prevent initialVCIndex set as <= 0
            return CGPoint(x: contentOffsetX, y: 0.0)
        }
    }
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        screenWidth = Double(self.view.frame.width)
        setupViewControllers()
        setupTitles()
        configureOverlayView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureScrollViews()
    }
    
    private func setupViewControllers() {
        let vcCount = viewControllers.count
        let contentSize = screenWidth * Double(vcCount)
        mainContentViewWidthConstraint.constant = CGFloat(contentSize)
        
        var previousView = mainContentView
        for vc in viewControllers {
            let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: Double(mainContentView.frame.height)))
            containerView.translatesAutoresizingMaskIntoConstraints = false
            mainContentView.addSubview(containerView)
            var leadConstraint: NSLayoutConstraint
            if viewControllers.index(of: vc) == 0 {
                leadConstraint =  NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: mainContentView, attribute: .leading, multiplier: 1.0, constant: 0.0)
            } else {
                leadConstraint =  NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: previousView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            }
            let topConstraint =  NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: mainContentView, attribute: .top, multiplier: 1.0, constant: 0.0)
            let bottomConstraint =  NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: mainContentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let widthConstraint =  NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(screenWidth))
            mainContentView.addConstraints([leadConstraint, topConstraint,bottomConstraint, widthConstraint])
            embed(viewController: vc, intoView: containerView)
            previousView = containerView
        }
    }
    
    //MARK: - UI Setup
    private func setupTitles() {
        let titleCount = titles.count
        let contentSize = menuWidth * Double(titleCount)
        menuViewWidthConstraint.constant = CGFloat(contentSize)
        var count = 1.0;
        for title in titles {
            let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: CGFloat(menuWidth), height: 21.0))
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = title
            label.textAlignment = .center
            let centerYConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: menuView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            let labelCenterX = (menuWidth * count) - 8.0
            let centerXConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: menuView, attribute: .leadingMargin, multiplier: 1.0, constant: CGFloat(labelCenterX))
            menuView.addSubview(label)
            menuView.addConstraints([centerYConstraint, centerXConstraint])
            count+=1.0
        }
    }
    private func configureOverlayView() {
        let vcCount = viewControllers.count
        let contentSize = screenWidth * Double(vcCount)
        overlayViewWidthConstraint.constant = CGFloat(contentSize)
    }
    
    private func embed(viewController: UIViewController, intoView containerView: UIView) {
        addChildViewController(viewController)
        viewController.view.frame = containerView.frame
        containerView.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    private func configureScrollViews() {
        let initialOffset = self.initialOffset
        mainScrollView.contentOffset = initialOffset
        overlayScrollView.contentOffset = initialOffset
        menuScrollView.contentOffset = CGPoint(x: initialOffset.x * 0.5, y: initialOffset.y)
    }
    
    
    //MARK: - Scroll View Callbacks
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrolling == .main {
            var currentOffset = mainScrollView.contentOffset
            overlayScrollView.contentOffset = currentOffset
            currentOffset.x = currentOffset.x / 2.0
            self.menuScrollView.contentOffset = currentOffset
        } else if scrolling == .overlay {
            var currentOffset = overlayScrollView.contentOffset
            mainScrollView.contentOffset = currentOffset
            currentOffset.x = currentOffset.x / 2.0
            menuScrollView.contentOffset = currentOffset
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.mainScrollView {
            scrolling = .main
        } else if scrollView == overlayScrollView {
            scrolling = .overlay
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
