//
//  Medication.swift
//  ICD-10
//
//  Created by Sazza on 26/12/23.
//

import Foundation

struct Medication: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var drugs: [ConceptProperty]
}
