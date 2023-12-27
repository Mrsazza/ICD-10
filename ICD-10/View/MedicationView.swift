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
            }
            .padding()
            Spacer()
        }
    }
}

struct DrugListView: View {
    @EnvironmentObject var userDefault: UserDefaultsManager
    @State var medication: Medication
    var body: some View {
        VStack(alignment: .leading){
            Text("List Of Drugs")
                .padding()
                .font(.headline)
            Divider()
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
        .navigationTitle("\(medication.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func deleteDrug(at offsets: IndexSet) {
        var updatedMedication = medication
        updatedMedication.drugs.remove(atOffsets: offsets)

        userDefault.updateMedication(updatedMedication)
        medication = updatedMedication
    }
}


#Preview {
    MedicationView()
}
