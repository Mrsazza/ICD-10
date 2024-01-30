//
//  ApiViewModel.swift
//  SwiftUIApi
//
//  Created by Sopnil Sohan on 12/6/22.
//

import SwiftUI

class ViewModel: ObservableObject {
    @Published var drugs: Drugs?
//    @Published var filter: String = ""
    func fetchData(filter: String) {
        guard let url = URL(string: "https://rxnav.nlm.nih.gov/REST/Prescribe/drugs.json?name=\(filter)") else {
            print("URL Error")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            //Convert to JSON
            do {
                let drugs = try JSONDecoder().decode(Drugs.self, from: data)
                DispatchQueue.main.async {
                    self?.drugs = drugs
                    print(drugs)
                }
            }
            catch {
                print(error.localizedDescription)
                print("error")
            }
        }
        task.resume()
    }
}
