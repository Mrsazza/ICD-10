//
//  Extension.swift
//  ICD-10
//
//  Created by Sazza on 26/12/23.
//

import Foundation
import SwiftUI

extension View {
    func embedInNavigationView () -> some View {
        NavigationView {self}
    }
}
