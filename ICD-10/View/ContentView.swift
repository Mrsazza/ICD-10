//
//  ContentView.swift
//  SwiftUIApi
//
//  Created by Sopnil Sohan on 12/6/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()
    var body: some View {
        VStack {
            HStack{
                TextField("Search Here", text: $vm.filter)
                Button(action: {
                    vm.fetchData()
                }, label: {
                    Text("Press")
                })
            }
            
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
                                            }
                                            Spacer()
                                            HStack{
                                                Text("Synonym:")
                                                Text(drug.synonym)
                                                    .padding()
                                            }
                                        }
                                        Divider()
                                            .padding(.all,10)
                                    }
                                }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
