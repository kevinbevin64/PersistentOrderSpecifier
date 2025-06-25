# PersistentOrderSpecifier

## Manual control over SwiftData models

### The motivation

The motivation behind this "package" is the instability of SwiftData's `@Query` macro, which provides a collection of SwiftData models via an array. However, without a specified `SortDescriptor`, this collection behaves more like a set. The `OrderSpecifiable` conformance of this package requires a `position` variable that specifies the position of elements in the array returned by `@Query` **as long as model objects are sorted by their OrderSpecifiable.position attribute**.  

### How to set up and use 

#### Add the `OrderSpecifiable` conformance to your SwiftData model and add the integer variable `position`. The default `shift(to:)` method is already provided.  

```
import SwiftData

@Model
class Student: OrderSpecifiable {
    var position: Int
    
    ...(other variables)
}
```

#### Add a parameter to your initializer(s) for either the position property (`Int`), or for the `OrderSpecifier` object.  

`Int` parameter;
```
init(position: Int) {
    self.position = position
}

// Call like so
let student1 = Student(myOrderSpecifier.nextPosition)
```

`OrderSpecifier` parameter:
```
init(orderSpecifier: Order) {
    self.position = orderSpecifier.nextPosition
}
```

