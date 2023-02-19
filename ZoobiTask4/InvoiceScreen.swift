//
//  InvoiceScreen.swift
//  ZoobiTask4
//
//  Created by Theappmedia on 2/17/23.
//

import SwiftUI

struct InvoiceScreen: View {
    @FetchRequest(sortDescriptors: []) var fruits: FetchedResults<FruitModel>
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @State var paymentSuccessful = false
    @Binding var cartItems: [Fruit]
    
    var body: some View {
        VStack {
            ForEach(cartItems,id:\.id){ item in
                HStack {
                    Text("Fruit Name : ")
                        .fontWeight(.bold)
                    Text(item.name )
                    Spacer()
                    Text("Quantity : ")
                        .fontWeight(.bold)
                    Text("\(item.quantity)")
                }
            }
            .padding()
            Button {
                for item in cartItems{
                    let frt = fruits.first(where: {$0.id==item.id})
                    frt?.quantity -= Int32(item.quantity)
                    try?  moc.save()
                }
                cartItems.removeAll()
                paymentSuccessful = true
            } label: {
                Text("Pay")
                    .fontWeight(.bold)
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .cornerRadius(20)
            }
        }
        .navigationTitle("Cart")
        .alert(isPresented: $paymentSuccessful) {
            Alert(title: Text("Thank you!"),
                  message: Text("Your payment was successful."),
                  dismissButton: .default(Text("OK"), action: {
                    presentationMode.wrappedValue.dismiss()
                  }))
        }
    }
}
