//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Peter Hartnett on 1/5/22.
//

import SwiftUI

struct ContentView: View {
    //*************Properties********************
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var userScore = 0
    @State private var showingScore = false
    @State private var scoreTitle = ""
    
    @State private var playCount = 0
    
    @State private var gameOver = false
    
    
    @State private var animationSpinAmount = 0.0
    @State private var flipDownAmount = 0.0
    @State private var fadeWrongAnswer = false
    @State private var fadeOpacity = 1.0
    
    //Accessibility labels
    let labels = [
        "Estonia": "Flag with three horizontal stripes of equal size. Top stripe blue, middle stripe black, bottom stripe white",
        "France": "Flag with three vertical stripes of equal size. Left stripe blue, middle stripe white, right stripe red",
        "Germany": "Flag with three horizontal stripes of equal size. Top stripe black, middle stripe red, bottom stripe gold",
        "Ireland": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe orange",
        "Italy": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe red",
        "Nigeria": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe green",
        "Poland": "Flag with two horizontal stripes of equal size. Top stripe white, bottom stripe red",
        "Russia": "Flag with three horizontal stripes of equal size. Top stripe white, middle stripe blue, bottom stripe red",
        "Spain": "Flag with three horizontal stripes. Top thin stripe red, middle thick stripe gold with a crest on the left, bottom thin stripe red",
        "UK": "Flag with overlapping red and white crosses, both straight and diagonally, on a blue background",
        "US": "Flag with red and white stripes of equal size, with white stars on a blue background in the top-left corner"
    ]
    
    var winPercent: Double{
        return (Double(userScore) / 8.0)
    }
    
    //*********** Functions *************
    func flagTapped(_ number: Int){
        fadeWrongAnswer = true
        if number == correctAnswer{
            scoreTitle = "Correct"
            userScore += 1
            playCount += 1
        } else {
            scoreTitle = "Wrong, that is the flag of \(countries[number])"
            playCount += 1
        }
        
        if playCount < 8{
            showingScore = true
        } else {
            gameOver = true
        }
    }
    
    
    func askQuestion(){
        fadeOpacity = 1.0
        fadeWrongAnswer = false
        flipDownAmount = 0
        countries = countries.shuffled()
        correctAnswer = Int.random(in: 0...2)
    }
    
    func newGame(){
        askQuestion()
        playCount = 0
        userScore = 0
        
    }
    
    //******************** Flag View *****************
    //This view was made to replace the flag images that were handled inline before, learning from day 24
    struct FlagImage : View{
        var flag: String
        
        var body: some View{
            Image(flag)
                .renderingMode(.original)
                .clipShape(Capsule())
                .shadow(radius: 5)
            
            //should be able to add the animations here in some way
            //need to have a system that applies the animation to everything, and then a special animation that cancels out other animations and applies to the one that you clicked?
            
        }
    }
    
    
    
    //**************** Body View ****************
    var body: some View {
        
        
        
        ZStack{
            //            LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottomTrailing)
            //                .ignoresSafeArea()
            
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.25),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.26),
            ], center: .top, startRadius: 200, endRadius: 400)
            .ignoresSafeArea()
            
            VStack{
                Text("Guess the Flag")
                    .foregroundStyle(.white)
                    .font(.largeTitle.bold())
                
                VStack(spacing: 15){
                    Spacer()
                    
                    VStack{
                        Text("Tap the flag of")
                            .font(.subheadline)
                            .fontWeight(.heavy)
                            .foregroundStyle(Color.white)
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                    }
                    .accessibilityElement()
                    .accessibilityLabel("Tap the flag of \(countries[correctAnswer])")
                    VStack(spacing: 30){
                        ForEach(0..<3) { number in
                            
                            
                            Button {
                                
                                withAnimation(.easeOut(duration: 2)){
                                    animationSpinAmount += 360
                                    flipDownAmount += 90
                                }
                                
                                withAnimation(.easeOut(duration: 1)) {
                                    fadeOpacity = 0.25
                                }
                                
                                flagTapped(number)
                            } label: {
//                                This section was commented out and replaced with a separate view on day 24 to show how to use custom views
//                                Image(countries[number])
//                                    .renderingMode(.original)
//                                    .clipShape(Capsule())
//                                    .shadow(radius: 5)
                                FlagImage(flag: countries[number])
                                
                            }
                            //This label is using the above dictionary to give the description of the flags to a user.
                            .accessibilityLabel(labels[countries[number], default: "Unknown flag"])
                            .opacity(number != correctAnswer ? fadeOpacity : 1)
                            
                            .animation(.default, value: fadeWrongAnswer)
                            .rotation3DEffect(.degrees(number == correctAnswer ? animationSpinAmount : 0), axis: (x:0, y:1, z:0))
                            .rotation3DEffect(.degrees(number != correctAnswer ? flipDownAmount : 0), axis: (x:1, y:0, z:0))
                            
                        }
                        
                    }.frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Spacer()
                    Text("Score: \(userScore)")
                        .foregroundStyle(.white)
                        .font(.title.bold())
                    Spacer()
                }
                
                
            }.padding()
            
            
                .alert(scoreTitle, isPresented: $showingScore){
                    Button("Continue", action: askQuestion)
                } message: {
                    Text("Your score is \(userScore)")
                }
            
                .alert("Game Over", isPresented: $gameOver){
                    Button("New Game", action: newGame)
                    
                    
                    
                } message: {
                    Text("""
            Final score
            Right answers: \(userScore)
            Wrong answers: \(8 - userScore)
            Corect % : \(winPercent.formatted(.percent))
            """)
                }
            
            
            
        }
    }
    
    
    
    
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
        
    }
}
