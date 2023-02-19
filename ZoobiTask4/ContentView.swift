//
//  ContentView.swift
//  ZoobiTask4
//
//  Created by Theappmedia on 2/17/23.
//

import SwiftUI

struct ContentView: View {
    @FetchRequest(sortDescriptors: []) var fruits: FetchedResults<FruitModel>
    @Environment(\.managedObjectContext) var moc
    @AppStorage("isDataNotDownloded") var isDataNotDownloded: Bool = true
    @State var id = 1
    @State var cartArray:[Fruit] = []
    var body: some View {
        VStack{
            if !isDataNotDownloded{
                ScrollView{
                    ForEach(fruits,id:\.id){fruit in
                        
                        let isAddedToCart = cartArray.contains(where: { $0.id == fruit.id })
                        let backgroundColor = isAddedToCart ? Color.green : Color.white
                        
                        let isQuantityExceeded = (cartArray.first(where: { $0.id == fruit.id })?.quantity ?? 0) >= fruit.quantity
                        let quantityBackgroundColor = isQuantityExceeded ? Color.red : backgroundColor
                        
                        HStack{
                            VStack(alignment:.leading){
                                HStack{
                                    Text("Fruit Name : ")
                                        .fontWeight(.bold)
                                    Text(fruit.name ?? "")
                                }
                                HStack{
                                    Text("Fruit Price : ")
                                        .fontWeight(.bold)
                                    Text(fruit.priceunit ?? "")
                                    Text(fruit.price ?? "")
                                }
                            }
                            Spacer()
                            if fruit.quantity<1{
                                Text("Out of Stock")
                            }else{
                                Button {
                                    if !isQuantityExceeded{
                                        if let index = cartArray.firstIndex(where: { $0.id == fruit.id }) {
                                            cartArray[index].quantity += 1
                                        } else {
                                            cartArray.append(Fruit(id: fruit.id!, name: fruit.name!, quantity: 1, price: fruit.price!, priceunit: fruit.priceunit!))
                                        }
                                    }
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.green)
                                }
                                .background(Circle()
                                                .fill(Color.white))
                                Button {
                                    if let index = cartArray.firstIndex(where: { $0.id == fruit.id }) {
                                        if cartArray[index].quantity > 1 {
                                            cartArray[index].quantity -= 1
                                        } else {
                                            cartArray.remove(at: index)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.green)
                                }
                                .background(Circle()
                                                .fill(Color.white))
                                .padding()
                            }
                        }
                        .padding(.horizontal)
                        .background(quantityBackgroundColor)
                        Divider()
                            .frame(width: UIScreen.main.bounds.width-30, height: 2)
                    }
                }
            }else{
                ProgressView()
            }
            Spacer()
            HStack{
                NavigationLink(destination: InvoiceScreen(cartItems: $cartArray)) {
                    if cartArray.isEmpty{
                        EmptyView()
                    }else{
                        Image(systemName: "cart.fill")
                            .font(.title)
                            .frame(width: UIScreen.main.bounds.width*0.6, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .overlay(Text("\(cartArray.count)")
                                        .foregroundColor(.red)
                                        .padding(6)
                                        .background(Color.green)
                                        .clipShape(Circle())
                                        .padding(.trailing)
                                        .frame(width: UIScreen.main.bounds.width*0.6, height: 50, alignment: .trailing))
                            
                    }
                }
            }
        }
        .navigationTitle("Fruits")
        .onAppear {
            if isDataNotDownloded{
                loadData { dataDownloaded in
                    if dataDownloaded{
                        isDataNotDownloded = false
                    }
                }
            }
        }
    }
    func loadData(completion:@escaping (Bool) -> Void) {
        var id = 1
        if let url = URL(string: "https://raw.githubusercontent.com/zoobibackups/fruitjosn_data/main/fruit.json") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode([Fruit].self, from: data)
                        DispatchQueue.main.async {
                            for fruit in decodedResponse{
                                let fruitMod = FruitModel(context: moc)
                                print(fruit)
                                fruitMod.id = String(id)
                                fruitMod.name = fruit.name
                                fruitMod.quantity = Int32(fruit.quantity)
                                fruitMod.price = fruit.price
                                fruitMod.priceunit = fruit.priceunit
                                id+=1
                                try? moc.save()
                            }
                            completion(true)
                        }
                    } catch let jsonError as NSError {
                        print("JSON decode failed: \(jsonError.localizedDescription)")
                    }
                    return
                }
                
            }.resume()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
