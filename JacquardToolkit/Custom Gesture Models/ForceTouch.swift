//
//  ForceTouch.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 4/15/19.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class ForceTouchInput : MLFeatureProvider {
    
    /// 15ThreadConductivityReadings as 675 element vector of doubles
    var _15ThreadConductivityReadings: MLMultiArray
    
    var featureNames: Set<String> {
        get {
            return ["15ThreadConductivityReadings"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "15ThreadConductivityReadings") {
            return MLFeatureValue(multiArray: _15ThreadConductivityReadings)
        }
        return nil
    }
    
    init(_15ThreadConductivityReadings: MLMultiArray) {
        self._15ThreadConductivityReadings = _15ThreadConductivityReadings
    }
}

/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class ForceTouchOutput : MLFeatureProvider {
    
    /// Source provided by CoreML
    
    private let provider : MLFeatureProvider
    
    
    /// Probability of each activity as dictionary of strings to doubles
    lazy var output: [String : Double] = {
        [unowned self] in return self.provider.featureValue(for: "output")!.dictionaryValue as! [String : Double]
        }()
    
    /// Labels of activity as string value
    lazy var classLabel: String = {
        [unowned self] in return self.provider.featureValue(for: "classLabel")!.stringValue
        }()
    
    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }
    
    init(output: [String : Double], classLabel: String) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["output" : MLFeatureValue(dictionary: output as [AnyHashable : NSNumber]), "classLabel" : MLFeatureValue(string: classLabel)])
    }
    
    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class ForceTouch {
    var model: MLModel
    
    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: ForceTouch.self)
        return bundle.url(forResource: "ForceTouch", withExtension:"mlmodelc")!
    }
    
    /**
     Construct a model with explicit path to mlmodelc file
     - parameters:
     - url: the file url of the model
     - throws: an NSError object that describes the problem
     */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }
    
    /// Construct a model that automatically loads the model from the app's bundle
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }
    
    /**
     Construct a model with configuration
     - parameters:
     - configuration: the desired model configuration
     - throws: an NSError object that describes the problem
     */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    
    /**
     Construct a model with explicit path to mlmodelc file and configuration
     - parameters:
     - url: the file url of the model
     - configuration: the desired model configuration
     - throws: an NSError object that describes the problem
     */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    init(contentsOf url: URL, configuration: MLModelConfiguration) throws {
        self.model = try MLModel(contentsOf: url, configuration: configuration)
    }
    
    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as ForceTouchInput
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as ForceTouchOutput
     */
    func prediction(input: ForceTouchInput) throws -> ForceTouchOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }
    
    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as ForceTouchInput
     - options: prediction options
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as ForceTouchOutput
     */
    func prediction(input: ForceTouchInput, options: MLPredictionOptions) throws -> ForceTouchOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return ForceTouchOutput(features: outFeatures)
    }
    
    /**
     Make a prediction using the convenience interface
     - parameters:
     - _15ThreadConductivityReadings as 675 element vector of doubles
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as ForceTouchOutput
     */
    func prediction(_15ThreadConductivityReadings: MLMultiArray) throws -> ForceTouchOutput {
        let input_ = ForceTouchInput(_15ThreadConductivityReadings: _15ThreadConductivityReadings)
        return try self.prediction(input: input_)
    }
    
    /**
     Make a batch prediction using the structured interface
     - parameters:
     - inputs: the inputs to the prediction as [ForceTouchInput]
     - options: prediction options
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as [ForceTouchOutput]
     */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    func predictions(inputs: [ForceTouchInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [ForceTouchOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [ForceTouchOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  ForceTouchOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
