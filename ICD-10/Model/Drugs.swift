//
//  Drugs.swift
//  SwiftUIApi
//
//  Created by Sazza on 14/7/22.
//

import Foundation

struct Drugs: Codable {
    let drugGroup: DrugGroup
}

// MARK: - DrugGroup
struct DrugGroup: Codable {
    let name: JSONNull?
    let conceptGroup: [ConceptGroup]?
}

// MARK: - ConceptGroup
struct ConceptGroup: Codable, Hashable {
    let tty: String
    let conceptProperties: [ConceptProperty]?
}

// MARK: - ConceptProperty
struct ConceptProperty: Codable, Hashable {
    let rxcui, name, synonym: String
    let tty: String
    let language: String
    let suppress: String
    let umlscui: String
}

//enum Language: String, Codable {
//    case eng = "ENG"
//}
//
//enum Suppress: String, Codable {
//    case n = "N"
//}
//
//enum TTY: String, Codable {
//    case bpck = "BPCK"
//    case gpck = "GPCK"
//    case sbd = "SBD"
//    case scd = "SCD"
//}

// MARK: - Encode/decode helpers

class JSONNull: Codable  {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
