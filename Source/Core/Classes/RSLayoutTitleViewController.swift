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

class RSLayoutTitleViewController: UIViewController, StoreSubscriber, RSLayoutViewControllerProtocol {

    var store: Store<RSState>!
    var titleLayout: RSTitleLayout!
    var layout: RSLayout! {
        return self.titleLayout
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleLabel.text = self.titleLayout.title
        self.imageView.image = self.titleLayout.image
        self.button.setTitle(self.titleLayout.button.title, for: .normal)
        
        self.store.subscribe(self)
        
    }
    
    deinit {
        self.store.unsubscribe(self)
    }
    
    open func newState(state: RSState) {
        self.button.isEnabled = {
            
            guard let predicate = self.titleLayout.button.predicate else {
                return true
            }
            
            return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            
        }()
    }
    
    open func processAction(action: JSON) {
        RSActionManager.processAction(action: action, context: [:], store: self.store)
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        
        self.titleLayout.button.onTapActions.forEach { self.processAction(action: $0) }
        
    }
    
    open func layoutDidLoad() {
        
        self.layout.onLoadActions.forEach({ (action) in
            RSActionManager.processAction(action: action, context: ["layoutViewController":self], store: self.store)
        })
        
    }

}
