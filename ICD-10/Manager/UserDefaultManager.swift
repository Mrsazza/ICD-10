//
//  UserDefaultManager.swift
//  ICD-10
//
//  Created by Sazza on 26/12/23.
//

import Foundation

class UserDefaultsManager: ObservableObject {
//    static let shared = UserDefaultsManager()
    let defaults = UserDefaults.standard
    @Published var medications: [Medication] = []
    func saveMedications(_ medications: [Medication]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(medications) {
            defaults.set(encoded, forKey: UserDefaultKey.medicationsKey)
        }
    }
    
    private func getMedications() -> [Medication]? {
        if let savedMedications = defaults.data(forKey: UserDefaultKey.medicationsKey) {
            let decoder = JSONDecoder()
            if let loadedMedications = try? decoder.decode([Medication].self, from: savedMedications) {
                return loadedMedications
            }
        }
        return nil
    }
    
    func populateMedications(){
        medications = getMedications() ?? []
    }
    
    func clearMedications() {
        defaults.removeObject(forKey: UserDefaultKey.medicationsKey)
    }
    
    func appendMedication(_ newMedication: Medication) {
            var currentMedications = getMedications() ?? [] // Retrieve existing medications or start with an empty array
            currentMedications.append(newMedication) // Append the new medication
            
            saveMedications(currentMedications) // Save the updated array back to UserDefaults
        }
    
    func updateMedication(_ medication: Medication) {
           var currentMedications = getMedications() ?? []
           
           if let index = currentMedications.firstIndex(where: { $0.id == medication.id }) {
               currentMedications[index] = medication
               saveMedications(currentMedications)
           }
       }
    
    func appendDrug(toMedicationId medicationId: String, newDrug: ConceptProperty) {
           var currentMedications = getMedications() ?? [] // Retrieve existing medications or start with an empty array
           
           if let index = currentMedications.firstIndex(where: { $0.id == medicationId }) {
               // Found the Medication with the specified ID
               var medicationToUpdate = currentMedications[index]
               medicationToUpdate.drugs.append(newDrug) // Append the new drug
               
               // Update the medication in the array
               currentMedications[index] = medicationToUpdate
               
               // Save the updated array back to UserDefaults
               saveMedications(currentMedications)
           }
       }
    
    func removeDrug(fromMedicationId medicationId: String, drugToRemove: ConceptProperty) {
           var currentMedications = getMedications() ?? []

           if let index = currentMedications.firstIndex(where: { $0.id == medicationId }) {
               var medicationToUpdate = currentMedications[index]
               medicationToUpdate.drugs.removeAll(where: { $0 == drugToRemove })

               // Update the medication in the array
               currentMedications[index] = medicationToUpdate

               // Save the updated array back to UserDefaults
               saveMedications(currentMedications)
           }
       }
}

enum UserDefaultKey {
    static let medicationsKey = "savedMedications"
}
