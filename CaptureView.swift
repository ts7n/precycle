import SwiftUI

struct CaptureView: View {
    @State private var showCamera: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showResults: Bool = false
    @State private var showSimulatorError: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType? = nil
    @State private var image: UIImage? = nil
    @State private var label: String = ""
    var mlService = MLService()
    var dataSource = RecyclabilityData()
    
    func runClassify() {
        mlService.classifyPic(image: self.image!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let classificationLabels = mlService.classificationLabel.components(separatedBy: "\\n")
            self.label = (classificationLabels[0].components(separatedBy: " = "))[0]
            self.showResults = true
            self.image = nil
        }
    }
    
    var body: some View {
        VStack {
            Text("Capture")
                .font(.title)
                .fontWeight(.bold)
            Text("Can't tell if something is recyclable? Take a picture of it and we'll tell you!")
                .multilineTextAlignment(.center)
            
            HStack {
                Button {
                    if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
                        self.sourceType = .camera
                        self.showCamera = true
                    } else {
                        self.showSimulatorError = true
                    }
                } label: {
                    Label("Camera", systemImage: "camera")
                    .foregroundColor(Color.blue)
                    .padding(.horizontal)
                }
                .popover(isPresented: self.$showSimulatorError) {
                    Text("This input method is not available.")
                        .padding()
                }
                
                Button {
                    self.sourceType = .photoLibrary
                    self.showImagePicker = true
                } label: {
                    Label("Photo Library", systemImage: "photo.on.rectangle.angled")
                        .foregroundColor(Color.orange)
                        .padding(.horizontal)
                }
            }
            .sheet(isPresented: $showCamera, content: {
                ImagePicker(sourceType: .camera, runClassify: self.runClassify, selectedImage: self.$image, showResults: self.$showResults)
                
            })
            .sheet(isPresented: $showImagePicker, content: {
                ImagePicker(sourceType: .photoLibrary, runClassify: self.runClassify, selectedImage: self.$image, showResults: self.$showResults)
            })
            .padding(.vertical)
            .sheet(isPresented: $showResults, content: {
                    VStack {
                        VStack {
                            Text("Results")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(self.label)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack {
                            if (dataSource.data[self.label]![0] as! Bool == true) {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(Color.green)
                                
                                Text("This item is recyclable!")
                                    .multilineTextAlignment(.center)
                            } else {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(Color.red)
                                
                                Text("This item is unfortunately not recyclable.")
                                    .multilineTextAlignment(.center)
                            }
                            
                            if (dataSource.data[self.label]![1] as! String? != nil) {
                                Section {
                                    Text("However, additional efforts/precautions might be required to recycle this item.")
                                        .multilineTextAlignment(.center)
                                    
                                    Link("Click here for a resource to learn how to properly and mindfully recycle this item.", destination: URL(string: dataSource.data[self.label]![1] as! String)!)
                                }
                                .padding(.top)
                            }
                        }
                        .padding()
                    }
                    .padding()
                })
            
            if self.image != nil {
                VStack {
                    Text("Processing Image...")
                        .foregroundColor(Color.gray)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .padding(.vertical)
            }
        }
        .padding()
    }
}
