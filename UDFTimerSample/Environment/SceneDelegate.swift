//
//  SceneDelegate.swift
//  UDFTimerSample
//
//  Created by Stanly Shiyanovskiy on 03.10.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let store = Store()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let root = TimerViewController()
        window.rootViewController = root
        self.window = window
        window.makeKeyAndVisible()
        
        connect(root)
    }
    
    private func connect(_ viewController: TimerViewController) {
        let viewControllerOperator = TimerViewControllerOperator(
            render: CommandWith { props in
                viewController.props = props
            }.dispatched(on: .main), store: store)
        
        let observer = Observer(handle: viewControllerOperator.process(state:))
        
        store.observe(with: observer)
    }
}

