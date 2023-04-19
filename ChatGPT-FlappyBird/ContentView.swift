//
//  ContentView.swift
//  ChatGPT-FlappyBird
//
//  Created by Derek Harne on 4/18/23.
//

import SwiftUI
import AppKit

struct ContentView: View {
    
    // Game Variables
    let gravity: CGFloat = 0.6
    let jumpHeight: CGFloat = -12
    let pipeSpeed: Double = 2.5
    let pipeSpacing: CGFloat = 200
    let pipeHeight: CGFloat = 320
    let pipeWidth: CGFloat = 52
    let birdSize: CGFloat = 40
    let screenSize = NSScreen.main?.frame.size ?? .zero
    
    @State private var birdPosition: CGPoint = CGPoint(x: 100, y: 200)
    @State private var birdVelocity: CGFloat = 0
    @State private var pipes: [Pipe] = []
    @State private var score: Int = 0
    @State private var gameOver: Bool = false
    
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background
            Image("background")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            // Pipes
            ForEach(pipes, id: \.id) { pipe in
                PipeView(pipe: pipe)
            }
            
            // Bird
            Image("bird")
                .resizable()
                .frame(width: birdSize, height: birdSize)
                .position(birdPosition)
                .rotationEffect(Angle(degrees: Double(birdVelocity * 3)))
                .animation(.default)
            
            // Score
            Text("\(score)")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.white)
                .position(x: screenSize.width / 2, y: 80)
            
            // Game Over Screen
            if gameOver {
                VStack {
                    Text("Game Over")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Score: \(score)")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                    
                    Button("Play Again") {
                        restartGame()
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
            }
        }
        .onTapGesture {
            if !gameOver {
                birdVelocity = jumpHeight
            } else {
                restartGame()
            }
        }
        .onReceive(timer) { _ in
            if !gameOver {
                movePipes()
                applyGravity()
                checkCollision()
            }
        }
    }
    
    func applyGravity() {
        birdVelocity += gravity
        birdPosition.y += birdVelocity
    }
    
    func movePipes() {
        for index in 0..<pipes.count {
            pipes[index].x -= pipeSpeed
            
            if pipes[index].x < -pipeWidth {
                pipes[index].x = screenSize.width
                pipes[index].y = CGFloat.random(in: (-pipeHeight-(pipeHeight / 2))..<0)
                score += 1
            }
        }
        
        if pipes.count < 3 {
            let screenSize = NSScreen.main?.frame.size ?? .zero
            let pipeHeight = CGFloat(200)
            let pipeWidth = CGFloat(50)
            let newPipe = Pipe(x: screenSize.width + pipeSpacing, y: CGFloat.random(in: (-pipeHeight-(pipeHeight / 2))..<0), width: pipeWidth, height: pipeHeight)
            pipes.append(newPipe)
        }
    }
    
    func checkCollision() {
        if birdPosition.y < 0 || birdPosition.y > screenSize.height {
            endGame()
        }
        

                }
    func endGame() {
        gameOver = true
    }

    func restartGame() {
        birdPosition = CGPoint(x: 100, y: 200)
        birdVelocity = 0
        pipes = []
        score = 0
        gameOver = false
    }
}

struct PipeView: View {
let pipe: Pipe
    var body: some View {
        let topPipe = Image("pipe")
            .resizable()
            .frame(width: pipe.width, height: pipe.height)
            .rotationEffect(.degrees(180))
        
        let bottomPipe = Image("pipe")
            .resizable()
            .frame(width: pipe.width, height: pipe.height)
        
        VStack {
            topPipe
                .frame(height: pipe.y)
            bottomPipe
          //      .frame(height: NSScreen.main.frame.height ?? - pipe.y)
        }
        //.frame(width: pipe.width, height: NSScreen.main.frame.height)
        //.position(x: pipe.x, y: NSScreen.main.frame.height / 2)
    }
}

struct Pipe {
let id = UUID()
var x: CGFloat
var y: CGFloat
var width: CGFloat
var height: CGFloat
}
