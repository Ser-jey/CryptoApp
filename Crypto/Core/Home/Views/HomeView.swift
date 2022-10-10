//
//  HomeView.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 31.08.2022.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var vm: HomeViewModel
    
    @State private var showPortfolio: Bool = false
    @State private var showPortfolioView: Bool = false
    @State private var showSettingsView: Bool = false
    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    
    var body: some View {
        ZStack {
            
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortfolioView) {
                    PortfolioView()
                        .environmentObject(vm)
                }
            VStack {
                header
                HomeStatsView(showPortfolio: $showPortfolio)
                SearchBarView(searchText: $vm.searchText)
                columnTitles
                
                if !showPortfolio {
                    allCoinsList
                        .animation(.linear(duration: 0.7), value: vm.searchText)
                        .transition(.move(edge: .leading))
                }
                if showPortfolio {
                    portfolioCoinsList
                        .transition(.move(edge: .trailing))
                }
                
                Spacer(minLength: 0)
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
            }
        }
        .background(
        NavigationLink(destination: DetailLoadingView(coin: $selectedCoin)
                        , isActive: $showDetailView,
                       label: {EmptyView()} )
        )
     
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        HomeView()
                .navigationBarHidden(true)
                .preferredColorScheme(.light)
        }
     //   .preferredColorScheme(.dark)
        .environmentObject(dev.homeVM)
    }
    
}

extension HomeView {
    
    private var header: some View {
        
        VStack {
            HStack {
                CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                    .animation(.none)
                    .onTapGesture {
                        if showPortfolio {
                            showPortfolioView = true
                        } else {
                            showSettingsView = true
                        }
                    }
                    .background(
                        CircleButtonAnimationView(animate: $showPortfolio)
                            .frame(width: 75, height: 75)
                        
                    )
                Spacer()
                Text(showPortfolio ? "Portfolio" : "Live prices")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.theme.accent)
                    .animation(.none)
                Spacer()
                CircleButtonView(iconName: "chevron.right")
                    .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))
                    .onTapGesture {
                        withAnimation {
                            if !showPortfolio {
                                showPortfolio = true }
                            else {
                                showPortfolio = false
                            }
                        }
                        
                    }
            }
            .padding([.top,.horizontal, .bottom])
            //Spacer()
        }
        
    }
    
    private var allCoinsList: some View {
        List {
            ForEach(vm.allCoins) { coin in
                
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .onTapGesture {
                        segue(coin: coin)
                    }
                
            }
            .listRowBackground(Color.theme.background)
        }
        .listStyle(.inset)
    }
    
    private var portfolioCoinsList: some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .onTapGesture {
                        segue(coin: coin)
                        
                    }
            }
            
        .listRowBackground(Color.theme.background)
    }
        .listStyle(.inset)
}
    
    private func segue(coin: CoinModel) {
        selectedCoin = coin
        showDetailView = true
    }
    
    private var columnTitles: some View {
        HStack {
            HStack {
                Text("Coin")
                
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .rank || vm.sortOption == .rankReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .rank ? 0 : 180))
            }
            .onTapGesture {
                withAnimation {
                    vm.sortOption = vm.sortOption == .rank ? .rankReversed : .rank
                }
            }
                Spacer()
                if showPortfolio {
                    HStack {
                        Text("Holdings")
                        Image(systemName: "chevron.down")
                            .opacity((vm.sortOption == .holdings || vm.sortOption == .holdingsReversed) ? 1.0 : 0.0)
                            .rotationEffect(Angle(degrees: vm.sortOption == .holdings ? 0 : 180))
                    }
                    .onTapGesture {
                        withAnimation {
                            vm.sortOption = vm.sortOption == .holdings ? .holdingsReversed : .holdings
                        }
                    }
                }
            
            HStack {
                Text("Price")
                    .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
                
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .price || vm.sortOption == .priceReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .price ? 0 : 180))
            }
            .onTapGesture {
                withAnimation {
                    vm.sortOption = vm.sortOption == .price ? .priceReversed : .price
                }
            }
                Button {
                    withAnimation(.linear(duration: 2.0)) {
                        vm.reloadData()
                    }
                } label: {
                        Image(systemName: "goforward")
                    }
                    .rotationEffect(Angle(degrees: vm.isLoading ? 360 : 0), anchor: .center)
                    
                
                
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .padding([.horizontal, .top])
    }
}
