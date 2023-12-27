//
//  HomeView.swift
//  ICD-10
//
//  Created by Sazza on 26/12/23.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var vm: ViewModel
    @State private var showSheet: Bool = false
    @State private var selectedDrug: ConceptProperty?
    var body: some View {
        VStack {
            HStack{
                TextField("Search Here", text: $vm.filter)
                    .onSubmit {
                        vm.fetchData()
                    }
                Button(action: {
                    vm.fetchData()
                }, label: {
                    HStack{
                        Image(systemName: "magnifyingglass")
                    }
                })
            }
            .padding()
            Divider()
            ScrollView {
                if vm.drugs != nil {
                    if (vm.drugs!.drugGroup.conceptGroup == nil) {
                        Text("No Result Found")
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            if vm.drugs != nil && vm.drugs?.drugGroup.conceptGroup != nil {
                                ForEach (((vm.drugs?.drugGroup.conceptGroup)!), id:\.self){ item in
                                    if item.conceptProperties != nil {
                                    ForEach(item.conceptProperties!, id: \.self){ drug in
                                        VStack(alignment:.leading){
                                            HStack{
                                                Text("Name:")
                                                Text(drug.name)
                                                    .padding()
                                                Spacer()
                                                NavigationLink {
                                                    AddDrugToMedicationView(drug: drug)
                                                } label: {
                                                    Image(systemName: "doc.badge.plus")
                                                }
                                            }
//                                            Spacer()
//                                            HStack{
//                                                Text("Synonym:")
//                                                Text(drug.synonym)
//                                                    .padding()
//                                            }
                                        }
                                        Divider()
                                            .padding(.all,10)
                                    }
                                }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
//        .sheet(isPresented: $showSheet, content: {
//            AddDrugToMedicationView( drug: selectedDrug)
//        })
        .navigationTitle("Search Drugs")
        .navigationBarTitleDisplayMode(.large)
        .embedInNavigationView()
    }
}

struct AddDrugToMedicationView: View {
    @EnvironmentObject var userDefault: UserDefaultsManager
    @State var drug: ConceptProperty
    @State private var refreshView: Bool = true
    var body: some View {
        VStack{
            ScrollView{
                if userDefault.medications.isEmpty{
                    VStack{
                        Text("No Medication Found!")
                        Text("Add Medication First.")
                    }
                    .padding()
                }
                VStack{
                    ForEach(userDefault.medications, id: \.id){item in
                        Button {
                            userDefault.appendDrug(toMedicationId: item.id, newDrug: drug)
                            userDefault.populateMedications()
                            
                        } label: {
                            HStack{
                                Text("\(item.name)")
                                Spacer()
                                if refreshView{
                                    Image(systemName: "checkmark.circle")
                                        .foregroundStyle(.green)
                                        .opacity(item.drugs.contains(drug) ? 1 : 0)
                                } else {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundStyle(.green)
                                        .opacity(item.drugs.contains(drug) ? 1 : 0)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: item.drugs.count) { newValue in
                            refreshView.toggle()
                        }
                        Divider()
                    }
                }
                .onAppear{
                    userDefault.populateMedications()
                }
            }
        }
        .navigationTitle("Select Medication")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HomeView()
}
