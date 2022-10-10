//
//  PortfolioView.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 12.09.2022.
//

import SwiftUI

struct PortfolioView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var vm: HomeViewModel
    @State private var selectedCoin: CoinModel? = nil
    @State private var quantityText:String = ""
    @State private var showCheckMarks: Bool = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0.0) {
                    SearchBarView(searchText: $vm.searchText)
                        .padding(.bottom)
                    ScrollCoin
                    if selectedCoin != nil  {
                       porfolioInputSection
                    }
                 
                }
            }
            .navigationTitle("Edit Portfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    XmarkButton(presentationMode: _presentationMode)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                   trailingNavBarButtons
                }
            }
            .onChange(of: vm.searchText) { newValue in
               // if newValue == "" {
                    selectedCoin = nil
              //  }
            }
        }
    }
    func updateSelectedCoins(coin: CoinModel) {
        selectedCoin = coin
        
        if let portfolioCoin = vm.portfolioCoins.first(where: {$0.id == coin.id}){
            guard  let amount = portfolioCoin.currentHoldings else { return }
            quantityText = amount.asNumberString()
        } else { quantityText = "" }
    }
    
    func exchangeValue<T>(_ nums: inout [T], _ a: Int, _ b: Int) {
        (nums[a], nums[b]) = (nums[b], nums[a])
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
            .environmentObject(dev.homeVM)
    }
}

extension PortfolioView {
    
    private var ScrollCoin: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(vm.searchText.isEmpty ? vm.portfolioCoins : vm.allCoins){ coin in
                   CoinLogoView(coin: coin)
                        .frame(width: 70)
                        .padding(4)
                        .onTapGesture {
                            withAnimation(.easeIn) {
                                updateSelectedCoins(coin: coin)
                            }
                        }
                        .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(lineWidth: 1.6, antialiased: false)
                            .foregroundColor((coin.id == selectedCoin?.id) ? Color.theme.green : Color.clear)
                        )
                }
            }.padding(.leading)
        }
    }
    
    
    private var porfolioInputSection: some View {
        
        VStack(spacing: 20) {
            HStack {
                Text("Current price of \(selectedCoin?.symbol.uppercased() ?? ""):")
                Spacer()
                Text("\(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")")
            }
            Divider()
                .offset(y: -14)
            HStack() {
                Text("Ammount holding:")
                    .lineLimit(1)
                Spacer()
                TextField("Ex: 1.4", text: $quantityText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 170, alignment: .trailing)
                    .keyboardType(.decimalPad)
            }
        Divider()
                .offset(y: -14)
        HStack {
            Text("Current value:")
            Spacer()
            Text("\(getCurrentValue().asCurrencyWith2Decimals())")
        }
            Divider()
                    .offset(y: -14)
        }
        .font(.headline)
        .padding()
        
    }
    
    private var trailingNavBarButtons: some View {
        
        HStack {
            Image(systemName: "checkmark")
                .opacity(showCheckMarks ? 1 : 0)
            Button {
                replace()
                saveButtinPressed()
            } label: {
                Text("SAVE")
            }
            .opacity((selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText) ) ? 1 : 0)

        }
        .font(.headline)
        
    }

    private func replace() {
        guard let _ = quantityText.first(where: {$0 == ","}) else {
            return
        }
        quantityText = quantityText.replacingOccurrences(of: ",", with: ".")
    }
    
    private func saveButtinPressed() {
        guard let selectedCoin = selectedCoin, let amount = Double(quantityText) else { return }
        
        //save
        vm.updatePortfolio(coin: selectedCoin, amount: amount)
        //show checkmarks
        withAnimation(.easeIn) {
            showCheckMarks = true
            removeSelectedCoin()
        }
        
        // hide keyboard
        UIApplication.shared.endEditing()
        
        // hide checkmarks
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeIn) {
            showCheckMarks = false
            }
        }
    }
    
    private func removeSelectedCoin() {
        selectedCoin = nil
        vm.searchText = ""
    }
    
    private func getCurrentValue() -> Double {
        if let quantity = Double(quantityText) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        return 0
    }
    
}

