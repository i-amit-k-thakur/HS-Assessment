//
//  ViewController.swift
//  HS-Assesment
//
//  Created by Amit Thakur on 11/02/2025.
//

import UIKit

class ViewController: UIViewController {

    var client: ClientProtocol?
    var results: Results?
    
    var invalidAssociations = [Association]()
    var undecidedAssociations = [Association]()
    var validAssociations = [Association]()
    
    var existingAssociationSummary = [String:Int]()
    var newAssociationSummary = [String:Int]()

    var existingCompanyRoleLimits = [String:Int]()
    var existingCompanyContactLimits = [String:Int]()

    var newCompanyRoleLimits = [String:Int]()
    var newCompanyContactLimits = [String:Int]()

    
    @IBOutlet var showButton: UIButton?
    @IBOutlet var messageLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        client = Client(service: NetworkService())
    }

    override func viewDidAppear(_ animated: Bool) {
        client?.fetchAssociations{[weak self] result in
            switch result {
            case .success(let fetchedResult):
                self?.results = fetchedResult
                DispatchQueue.main.async {
                    self?.showButton?.isHidden = false
                }
                
            case .failure(_):
                self?.results = nil
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Oops", message: "Something went wrong", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(okAction)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func checkAssociations() {
        for association in results?.newAssociations ?? [] {
            if results?.existingAssociations?.contains(association) == true {
                var thisAssociation = association
                thisAssociation.failureReason = "ALREADY_EXISTS"
                invalidAssociations.append(thisAssociation)
            } else {
                let companyRole = association.uniqueRole
                let companyContact = association.uniqueContact

                newAssociationSummary[companyRole] = (newAssociationSummary[companyRole] ?? 0) + 1
                newAssociationSummary[companyContact] = (newAssociationSummary[companyContact] ?? 0) + 1
                undecidedAssociations.append(association)
            }
        }
        
        for association in undecidedAssociations {
            let companyRole = association.uniqueRole
            let companyContact = association.uniqueContact
            
            if ((newAssociationSummary[companyRole] ?? 0) + (existingAssociationSummary[companyRole] ?? 0)) > 5 {
                var thisAssociation = association
                thisAssociation.failureReason = "WOULD_EXCEED_LIMIT"
                invalidAssociations.append(thisAssociation)
            } else if ((newAssociationSummary[companyContact] ?? 0) + (existingAssociationSummary[companyContact] ?? 0)) > 2 {
                var thisAssociation = association
                thisAssociation.failureReason = "WOULD_EXCEED_LIMIT"
                invalidAssociations.append(thisAssociation)
            } else {
                validAssociations.append(association)
            }
        }
    }
    
    func computeExistingAssociations() {
        for association in results?.existingAssociations ?? [] {
            let companyRole = association.uniqueRole
            let companyContact = association.uniqueContact

            existingAssociationSummary[companyRole] = (existingAssociationSummary[companyRole] ?? 0) + 1
            existingAssociationSummary[companyContact] = (existingAssociationSummary[companyContact] ?? 0) + 1
        }
    }
    
    @IBAction func validateData() {
        self.computeExistingAssociations()
        self.checkAssociations()

        
        var response: ValidatedResponse = ValidatedResponse(validAssociations: validAssociations, invalidAssociations: invalidAssociations)
        client?.sendValidatedResult(response: response) { [weak self] result in
            switch result {
            case .success(let fetchedResult):
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Wohoo", message: "Completed", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(okAction)
                    self?.present(alert, animated: true, completion: nil)
                }
                
            case .failure(_):
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Oops", message: "Something went wrong", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(okAction)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    
}

