//
//  RSLayoutTitleViewController.swift
//  Pods
//
//  Created by James Kizer on 7/6/17.
//
//

import UIKit
import ReSwift
import Gloss
import ResearchSuiteExtensions

class RSLayoutTitleViewController: UIViewController, StoreSubscriber, RSLayoutViewControllerProtocol {

    var store: Store<RSState>!
    var titleLayout: RSTitleLayout!
    var layout: RSLayout! {
        return self.titleLayout
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: RSBorderedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleLabel.text = self.titleLayout.title
        self.imageView.image = self.titleLayout.image
        if let button = self.titleLayout.button {
            self.button.isHidden = false
            self.button.setTitle(button.title, for: .normal)
        }
        else {
            self.button.isHidden = true
        }
        
        
        self.store.subscribe(self)
        
    }
    
    deinit {
        self.store.unsubscribe(self)
    }
    
    open func newState(state: RSState) {
        
        guard let button = self.titleLayout.button else {
            return
        }
        
        self.button.isEnabled = {
            
            guard let predicate = button.predicate else {
                return true
            }
            
            return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            
        }()
    }
    
    open func processAction(action: JSON) {
        RSActionManager.processAction(action: action, context: [:], store: self.store)
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        
        guard let button = self.titleLayout.button else {
            return
        }
        
        button.onTapActions.forEach { self.processAction(action: $0) }
        
    }
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: self.store)
        })
        
    }

}
