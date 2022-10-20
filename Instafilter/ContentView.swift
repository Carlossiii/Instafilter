//
//  ContentView.swift
//  Instafilter
//
//  Created by Carlos Vinicius on 17/10/22.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 5.0
    @State private var filterScale = 5.0
    @State private var filterSaturation = 5.0
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var showingFilterSheet = false
    
    @State private var currentFilter: CIFilter = CIFilter.gaussianBlur()
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity) { _ in applyProcessing() }
                        .disabled(currentFilter.inputKeys.contains(kCIInputIntensityKey) == false)
                    
                    Text("Radius")
                    Slider(value: $filterRadius, in: 0...200)
                        .onChange(of: filterRadius) { _ in applyProcessing() }
                        .disabled(currentFilter.inputKeys.contains(kCIInputRadiusKey) == false)
                }
                
                HStack {
                    Text("Scale")
                    Slider(value: $filterScale, in: 0...10)
                        .onChange(of: filterScale) { _ in applyProcessing() }
                        .disabled(currentFilter.inputKeys.contains(kCIInputScaleKey) == false)
                    
                    Text("Saturation")
                    Slider(value: $filterScale, in: 0...50)
                        .onChange(of: filterScale) { _ in applyProcessing() }
                        .disabled(currentFilter.inputKeys.contains(kCIInputSaturationKey) == false)
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter") {
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                        .disabled(inputImage == nil)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filte", isPresented: $showingFilterSheet) {
                Group {
                    Button("Bloom") { setFilter(CIFilter.bloom()) }
                    Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                    Button("Edges") { setFilter(CIFilter.edges()) }
                    Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                    Button("Noir") { setFilter(CIFilter.photoEffectNoir()) }
                    Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                    Button("Pointllize") { setFilter(CIFilter.pointillize()) }
                    Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                    Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                    Button("Vignette") { setFilter(CIFilter.vignette()) }
                }
                
                Group {
                    Button("Comic") { setFilter(CIFilter.comicEffect()) }
                    Button("Cancel", role: .cancel) { }
                }
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterScale, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputSaturationKey) { currentFilter.setValue(filterSaturation, forKey: kCIInputSaturationKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
