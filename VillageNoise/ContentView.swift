//
//  ContentView.swift
//  VillageNoise
//
//  Created by Pieter Yoshua Natanael on 01/12/23.
//

import SwiftUI
import AVFoundation

struct LightGreenTheme {
    static let primaryColor = Color(red: 0.36, green: 0.75, blue: 0.54) // Define your light green color
    static let redColor = Color.red
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isPlaying = false
    @ObservedObject private var audioPlayerManager = AudioPlayerManager()

    let imageNames = ["drink1", "drink2", "drink3", "drink4", "drink5", "drink6"]
    let soundFiles = ["sound1", "sound2", "sound3", "sound4", "sound5","sound6" ]

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(0..<imageNames.count, id: \.self) { index in
                            Image(imageNames[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width)
                                .cornerRadius(30)
                                .id(index)
                        }
                    }
                }
                .content.offset(x: CGFloat(selectedTab) * -geometry.size.width)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let xOffset = value.translation.width
                            let page = xOffset > 0 ? selectedTab - 1 : selectedTab + 1
                            if page >= 0 && page < imageNames.count {
                                withAnimation {
                                    selectedTab = page
                                }
                            }
                        }
                )

                HStack {
                    if selectedTab > 0 {
                        Image(systemName: "arrow.left.circle.fill")
                            .onTapGesture {
                                withAnimation {
                                    selectedTab -= 1
                                }
                            }
                            .foregroundColor(LightGreenTheme.primaryColor)
                    } else {
                        Spacer()
                    }

                    Spacer()

                    if selectedTab < imageNames.count - 1 {
                        Image(systemName: "arrow.right.circle.fill")
                            .onTapGesture {
                                withAnimation {
                                    selectedTab += 1
                                }
                            }
                            .foregroundColor(LightGreenTheme.primaryColor)
                    } else {
                        Spacer()
                    }
                }
                .padding(20)
            }

            VStack {
                HStack(spacing: 6) {
                    ForEach(0..<imageNames.count, id: \.self) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(index == selectedTab ? LightGreenTheme.primaryColor : .gray)
                    }
                }
                .padding(.bottom, 20)
            }

            Button(action: {
                if isPlaying {
                    isPlaying = false
                    audioPlayerManager.stop()
                } else {
                    isPlaying = true
                    audioPlayerManager.play(soundFile: soundFiles[selectedTab])
                }
            }) {
                Text(isPlaying ? "Stop" : "Start")
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .background(isPlaying ? LightGreenTheme.redColor : Color.gray)
            .cornerRadius(15)
            .padding()

            Text("VillageNoise")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class AudioPlayerManager: ObservableObject {
    private var player: AVAudioPlayer?

    init() {}

    func play(soundFile: String) {
        guard let soundURL = Bundle.main.url(forResource: soundFile, withExtension: "mp3") else {
            fatalError("Sound file not found")
        }

        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
    }
}

