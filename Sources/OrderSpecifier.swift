//
//  OrderSpecifier.swift
//  PersistentOrderSpecifier
//
//  Created by Kevin Chen on 6/25/25.
//

import SwiftData
import Foundation

/// Provides new position values. This model is intended to be used in conjunction with
/// OrderSpecifiable SwiftData models.
@Model
class OrderSpecifier {
    // The next position in line
    private var freshPosition: Int
    
    // The next position value for a new SwiftData OrderSpecifiable model.
    var nextPosition: Int {
        get {
            // Increment the underlying freshPosition var
            let result = freshPosition
            freshPosition += 1
            return result
        }
        set {
            freshPosition = newValue
        }
    }
    
    // Reset the nextPosition to 0
    func reset() {
        self.nextPosition = 0
    }
    
    init(_ position: Int = 0) {
        self.freshPosition = position
    }
}

/// Allows a SwiftData model to manage its own position in a collection of its type.
///
/// For example, a Student object may put itself at the front of a line of students by
/// shifting itself to position 0.
protocol OrderSpecifiable where Self: PersistentModel {
    var position: Int { get set }
    func shift(to position: Int)
}

extension OrderSpecifiable {
    /// Shift the specified model to a specified new position and models affected to their new
    /// positions.
    ///
    /// - Note: This is a default implementation and is not meant to be overriden.
    ///
    /// - Parameters:
    ///     - model: The model to reposition
    ///     - position: The new position of the model
    ///     - models: An array of (references to) the models moved to accomodate the rearrangement.
    ///               This needs to be grabbed before rearrangement, because directly using the
    ///               collection of models accessed with @Query may change the indices of models,
    ///               temporarily causing a mismatch between a model's index and its position value.
    ///
    func shift(to position: Int) {
        let currentPosition = self.position
        
        let descriptor = FetchDescriptor<Item>(
            // Allows items in the range (self.position, position] or [position, self.position),
            // whichever one is valid.
            predicate: #Predicate { item in
                (item.position < currentPosition && item.position >= position)
                || (item.position > currentPosition && item.position <= position)
            },
            // Sort by position in ascending order
            sortBy: [
                .init(\.position, order: .forward)
            ]
        )
        
        guard let models = try? self.modelContext?.fetch(descriptor) else { return }
        if self.position > position { // Moving the model left
            models.forEach { model in
                model.position += 1 // Move the others right
            }
            self.position = position
        } else if self.position < position { // Moving the model right
            models.forEach { model in
                model.position -= 1 // Move the others left
            }
            self.position = position
        } else { // The model is already in its desired position
            return
        }
    }
}

