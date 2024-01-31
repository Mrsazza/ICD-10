//
//  MedicationView.swift
//  ICD-10
//
//  Created by Sazza on 26/12/23.
//

import SwiftUI

struct MedicationView: View {
    @EnvironmentObject var userDefault: UserDefaultsManager
    @State private var showSheet: Bool = false
    @State private var showAlert: Bool = false
    @State var selectedMedication: Medication = Medication(name: "", drugs: [])
    var body: some View {
        VStack{
            if userDefault.medications.isEmpty{
                VStack{
                    Text("No Medication Found!")
                    Text("Add Medication First.")
                    Spacer()
                }
                    .padding()
            }
            ScrollView{
                ForEach(userDefault.medications, id: \.id){item in
                    VStack{
                        HStack{
                            NavigationLink {
                                DrugListView(medication: item)
                                    .environmentObject(userDefault)
                            } label: {
                                HStack{
                                    Text("\(item.name)")
                                    Spacer()
                                }
                                .padding()
                            }
                            NavigationLink {
                               EditMedicationView(medication: item)
                            } label: {
                                VStack{
                                    Image(systemName: "square.and.pencil.circle")
                                        .font(.title3)
                                }
                            }
                            
                            Button {
                                selectedMedication = item
                                showAlert.toggle()
                            } label: {
                                Image(systemName: "xmark.bin.circle")
                                    .foregroundStyle(.red)
                                    .font(.title3)
                            }

                        }
                        Divider()
                    }
                    .padding()
                }
                .onDelete { indexSet in
                    userDefault.medications.remove(atOffsets: indexSet)
                            // After removing the medication, save the updated medications to UserDefaults
                            userDefault.saveMedications(userDefault.medications)
                }
                .alert(isPresented: $showAlert){ () -> Alert in
                    Alert(title: Text("Warning!"), message: Text("Delete This Medication?"), primaryButton: .destructive(Text("Delete"), action: {
                        if let index = userDefault.medications.firstIndex(where: { $0.id == selectedMedication.id }) {
                            userDefault.medications.remove(at: index)
                            userDefault.saveMedications(userDefault.medications)
                        }
                    }), secondaryButton: .default(Text("Cancel")))
                }
            }
            .onAppear{
                userDefault.populateMedications()
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $showSheet, content: {
           AddMedicationView()
        })
        .navigationTitle("Medication")
        .navigationBarTitleDisplayMode(.large)
        .toolbar(content: {
            Button {
                showSheet.toggle()
            } label: {
                VStack{
                    Text("Add")
                }
            }
        })
        .embedInNavigationView()
    }
}

struct EditMedicationView: View {
    @EnvironmentObject var userDefault: UserDefaultsManager
    @Environment(\.dismiss) var dismiss
    @State var medication: Medication
    var body: some View {
        VStack{
            VStack{
                TextField("Enter Name", text: $medication.name)
                    .padding(.vertical)
                Button(action: {
                    userDefault.updateMedication(medication)
                    userDefault.populateMedications()
                    dismiss()
                }, label: {
                    Text("Save")
                })
                .buttonStyle(.bordered)
            }
            .padding()
            Spacer()
        }
        .navigationTitle("Edit Medication")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddMedicationView: View {
    @EnvironmentObject var userDefault: UserDefaultsManager
    @Environment(\.dismiss) var dismiss
    @State var medication: Medication = Medication(name: "", drugs: [])
    @EnvironmentObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool
    @State private var isSearching = false
    @State private var refreshedView = false
    var body: some View {
        VStack{
            ZStack{
                HStack{
                    Spacer()
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
                Text("Add Medication")
                    .font(.title3)
            }
            .padding()
            VStack{
                TextField("Enter Name", text: $medication.name)
                
                Button(action: {
                    userDefault.appendMedication(medication)
                    userDefault.populateMedications()
                    dismiss()
                }, label: {
                    Text("Save")
                })
                .buttonStyle(.bordered)
                if medication.name != ""{
                    SearchBar(vm: vm, isSearching: $isSearching,isTextFieldFocused: _isTextFieldFocused)
                    
                    if isSearching {
                        SearchResultsView(vm: vm, medication: $medication, isSearching: $isSearching, isTextFieldFocused: _isTextFieldFocused)
                            .onDisappear {
                                userDefault.populateMedications()
                            }
                    } else {
                        MedicationList(refreshedView:refreshedView , medication: $medication)
                            .onAppear{
                                userDefault.populateMedications()
                            }
                    }
                }
            }
            .padding()
            Spacer()
        }
    }
}

struct DrugListView: View {
    @EnvironmentObject var userDefault: UserDefaultsManager
    @State var medication: Medication
    
    @EnvironmentObject var vm: ViewModel
    @State private var showSheet: Bool = false
    @State private var selectedDrug: ConceptProperty?
    @State private var isSearching = false
    @State private var refreshedView = false
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading){
            SearchBar(vm: vm, isSearching: $isSearching,isTextFieldFocused: _isTextFieldFocused)
            if isSearching {
                SearchResultsView(vm: vm, medication: $medication, isSearching: $isSearching, isTextFieldFocused: _isTextFieldFocused)
                    .onDisappear {
                        userDefault.populateMedications()
                    }
            } else {
                MedicationList(refreshedView: refreshedView, medication: $medication)
                    .onAppear{
                        userDefault.populateMedications()
                    }
            }
        }
        .onChange(of: userDefault.medications){newValue in
            refreshedView.toggle()
        }
        .navigationTitle("\(medication.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
//    private var medicationList: some View{
//        VStack{
//            Text("List Of Drugs")
//                .padding()
//                .font(.headline)
//            Divider()
//            if refreshedView{
//                List{
//                    ForEach(medication.drugs, id: \.self) { drug in
//                        Text("\(drug.name)")
//                    }
//                    .onDelete { index in
//                        deleteDrug(at: index)
//                    }
//                    
//                }
//                .listStyle(.plain)
//                .toolbar(content: {
//                    EditButton()
//                })
//            } else{
//                List{
//                    ForEach(medication.drugs, id: \.self) { drug in
//                        Text("\(drug.name)")
//                    }
//                    .onDelete { index in
//                        deleteDrug(at: index)
//                    }
//                    
//                }
//                .listStyle(.plain)
//                .toolbar(content: {
//                    EditButton()
//                })
//            }
//        }
//    }
//    
//    func deleteDrug(at offsets: IndexSet) {
//        var updatedMedication = medication
//        updatedMedication.drugs.remove(atOffsets: offsets)
//
//        userDefault.updateMedication(updatedMedication)
//        medication = updatedMedication
//    }
}

struct MedicationList: View {
    @EnvironmentObject var userDefault: UserDefaultsManager
    @State var refreshedView:Bool
    @Binding var medication: Medication
    var body: some View {
        VStack{
            Text("List Of Drugs")
                .padding()
                .font(.headline)
            Divider()
            if refreshedView{
                List{
                    ForEach(medication.drugs, id: \.self) { drug in
                        Text("\(drug.name)")
                    }
                    .onDelete { index in
                        deleteDrug(at: index)
                    }
                    
                }
                .listStyle(.plain)
                .toolbar(content: {
                    EditButton()
                })
            } else{
                List{
                    ForEach(medication.drugs, id: \.self) { drug in
                        Text("\(drug.name)")
                    }
                    .onDelete { index in
                        deleteDrug(at: index)
                    }
                    
                }
                .listStyle(.plain)
                .toolbar(content: {
                    EditButton()
                })
            }
        }
    }
    
    func deleteDrug(at offsets: IndexSet) {
        var updatedMedication = medication
        updatedMedication.drugs.remove(atOffsets: offsets)

        userDefault.updateMedication(updatedMedication)
        medication = updatedMedication
    }
}

struct SearchBar: View {
    @ObservedObject var vm: ViewModel
    @Binding var isSearching: Bool
    @State var filter: String = ""
    @FocusState var isTextFieldFocused: Bool
    var body: some View {
        HStack {
            TextField("Search Drug Here", text: $filter)
                .focused($isTextFieldFocused)
                .onChange(of: isTextFieldFocused) { isFocused in
                    if isFocused {
                        // began editing...
                        isSearching = true
                    } else {
                        // ended editing...
                        isSearching = false
                    }
                }
                .onSubmit {
                    vm.fetchData(filter: filter)
                }
            .onChange(of: filter) { newValue in
                vm.fetchData(filter: filter)
            }
            Button(action: {
                vm.fetchData(filter: filter)
            }, label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                }
            })
            if isTextFieldFocused{
                Button {
                    isTextFieldFocused = false
                } label: {
                    Image(systemName: "xmark")
                }

            }
        }
        .padding()
    }
}

struct SearchResultsView: View {
    @EnvironmentObject var userDefault: UserDefaultsManager
    @ObservedObject var vm: ViewModel
    @Binding var medication: Medication
    @Binding var isSearching: Bool
    @FocusState var isTextFieldFocused: Bool
    var body: some View {
        VStack{
            ScrollView {
                if vm.drugs != nil {
                    if (vm.drugs!.drugGroup.conceptGroup == nil) {
                        Text("No Result Found")
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            if vm.drugs != nil && vm.drugs?.drugGroup.conceptGroup != nil {
                                ForEach (((vm.drugs?.drugGroup.conceptGroup)!), id:\.self){ item in
                                    if item.conceptProperties != nil {
                                        ForEach(item.conceptProperties!, id: \.self){ drug in
                                            VStack(alignment:.leading){
                                                Button {
                                                    addDrug(newDrug: drug)
//                                                    userDefault.appendDrug(toMedicationId: medication.id, newDrug: drug)
//                                                    userDefault.populateMedications()
//                                                    isSearching = false
                                                   isTextFieldFocused = false
                                                } label: {
                                                    HStack{
                                                        Text("Name:")
                                                        Text(drug.name)
                                                            .padding()
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
    }
    
    func addDrug(newDrug: ConceptProperty) {
        var updatedMedication = medication
        updatedMedication.drugs.append(newDrug)

        userDefault.updateMedication(updatedMedication)
        medication = updatedMedication
    }
}


#Preview {
    MedicationView()
}
