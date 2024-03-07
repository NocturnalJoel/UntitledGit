//
//  Application.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-11-21.
//

//  Created by Joël Lacoste-Therrien on 2023-10-25.
//

import SwiftUI
import UIKit

final class Application_utility {
    static var rootViewController : UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
}
