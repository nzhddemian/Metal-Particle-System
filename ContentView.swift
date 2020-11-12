//
//  ContentView.swift
//  Particle
//
//  Created by Demian on 06.11.2020.
//  Copyright © 2020 Demian. All rights reserved.
//

import UIKit
import MetalKit
import ARKit
class ContentView: UIViewController{
    var session:ARSession!
    var render:Render!
    var mtlView=MTKView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        mtlView.frame = UIScreen.main.bounds
        render = Render(mtlView)
      
        self.view.addSubview(mtlView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
