//
//  Associations.swift
//  HS-Assesment
//
//  Created by Amit Thakur on 11/02/2025.
//

struct Results: Codable {
    let existingAssociations: [Association]?
    let newAssociations: [Association]?
}

struct Association: Codable, Equatable {
    let companyId: Int
    let contactId: Int
    let role: String
    var failureReason: String?
    
    var debugDescription: String {
        "Company: \(companyId), Contact: \(contactId), Role: \(role)"
    }
    
    static func == (lhs: Association, rhs: Association) -> Bool {
        lhs.companyId == rhs.companyId
        && lhs.contactId == rhs.contactId
        && lhs.role == rhs.role
    }
    
    var uniqueRole: String {
        "\(companyId)+\(role)"
    }
    
    var uniqueContact: String {
        "\(contactId)+\(companyId)"
    }
}


struct ValidatedResponse: Codable {
    let validAssociations: [Association]?
    let invalidAssociations: [Association]?
}
