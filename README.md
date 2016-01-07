### 引言

Struct 是 Swift 新引入的一种数据结构，它可以用在各种简易的数据结构中，Swift 官方是强烈建议使用 Struct 而避免使用 Class 的。

但是， Struct 也有诸多不便，比如，不支持序列化和反序列化操作（即是将一个 Struct 实例转换为 NSData）， Struct 也不支持继承 Struct， Struct 只能遵从 Protocol。

Struct 有很多优点，其中最大的优点是其线程安全（使用 let 关键字）以及内存占用优化（无符号）。

### 思路

之前在简书看到几篇关于 Struct 序列化、反序列化的文章，总感觉使用起来有点别扭。

于是，今天从零开始研究了一下如何对 Struct 进行序列化。

我的思路如下：
1. 将 Struct 中的键值赋至一个 ```[String: AnyObject]``` 中 
2. 按照正常的方法，将这个```Dictionary``` 序列化
3. 使用反序列化后的 ```Dictionary``` 动态生成 Struct

### 例子
这是一个使用 SSCoding 的例子，使用方法和 NSCoding 十分类似。
```swift
import Foundation

struct SimpleStruct: SSCoding {
    
    let anInt: Int?
    
    init(anInt: Int) {
        self.anInt = anInt
    }
    
    init?(coder aDecoder: SSCoder) {
        guard let anInt = aDecoder.intValues["anInt"] else {
            return nil
        }
        self.anInt = anInt
    }
    
    func additionItems() -> (arrayItems: [String : [SSCoding]]?, dictionaryItems: [String : [String : SSCoding]]?, optionalItems: [String : AnyObject]?)? {
        return (nil, nil, ["anInt": anInt ?? NSNull()])
    }
    
}

func runSimpleSample() {
    
    let simple = SimpleStruct(anInt: 123)
    let data = NSKeyedArchiver.archivedDataWithRootStruct(simple)
    
    if let decodeSimple = NSKeyedUnarchiver.unarchiveStructWithData(data) as? SimpleStruct {
        print(decodeSimple.anInt)
    }
    
}
```

### SSCoding 的结构

SSCoding 包含以下的协议、结构体和 ```Helper``` 类

* ```SSCoding``` —— 这是一个协议，只有遵从这个协议的 Struct 才能被序列化
* ```SSCoder``` —— 这是一个结构体，它保存所有 Struct 的键值信息
* ```SSCodingHelper``` —— 这是一个 Helper 结构体，它负责将 Struct 的键值存储到 SSCoder，同时，也可以将 SSCoder 中的信息反射到 Struct
* ```NSKeyedArchiver、NSKeyedUnarchiver``` —— 我们为这两个类各添加一个方法，用于触发 Struct  的序列化、反序列化。

```swift
protocol SSCoding {
    
    init?(coder aDecoder: SSCoder)
    
    func additionItems() ->
        (arrayItems: [String: [SSCoding]]?,
        dictionaryItems:[String: [String: SSCoding]]?,
        optionalItems: [String: AnyObject]?)?
    
}
```

```swift
struct SSCoder {
    
    let values: [String: AnyObject]
    
    init(values: [String: AnyObject]) {
        self.values = values
    }

}
```

```swift
struct SSCodingHelper {
    
    static func encodedData(rootStruct: SSCoding) -> NSData 
    
    static func encodeDictionary(rootStruct: SSCoding) -> [String: AnyObject] 
    
    static func decodeDictionary(dict: [String: AnyObject]) -> SSCoding? 
    
}
```

这些代码可以在 GitHub 下载：https://github.com/PonyCui/SSCoding

### SSCoding 的工作原理
平时，我们使用 NSCoding 序列化 NSObject 的时候，会将必要的键值信息存储至 NSCoder 中。 SSCoding 与 NSCoding 思路一致。只是，这个存储的过程，在 NSCoder 中，是要显式声明的。而在 SSCoding 中，我们使用 Swift Mirror 黑魔法完成这件事情。
```swift
let mir = Mirror(reflecting: rootStruct)
for child in mir.children {
    if let label = child.label, let value = child.value as? SSCoding {
        dict[label] = encodeDictionary(value)
    }
    else if let label = child.label, let value = child.value as? AnyObject {
        dict[label] = value
    }
}
```

同时，考虑到一个 Struct 中可能包含有另外一个 Struct，所以，我们需要递归地调用 ```encodeDictionary``` 方法，直至所有的 Struct 都被序列化。
没有遵丛 SSCoding 协议的 Struct，又或是无法转换为```AnyObject``` 的对象，都不会被序列化。

接着，一个普通的 Dictionary 实例呈现在我们眼前，这个普通的 Dictionary 可以使用 ```NSKeyedArchiver.archivedDataWithRootObject``` 执行序列化操作。

### SSCoding 的反序列化
要将 NSData 转换为 Struct，难点在于，如何得知你拿到的 Key-Value 对应哪个 Struct。
因为我们无法使用类似 ```NSClassFromString()``` 的方法（Struct 根本不是 ```Class```），所以，我们必须在代码中显式声明一个 Key - Struct 的 Dictionary 去保存Type信息。
```swift
let SSCodingPrefix = "Default." // prefix 是为了避免冲突

var SSCodingDefines: [String: SSCoding.Type] = [
    "\(SSCodingPrefix)School": School.self,
    "\(SSCodingPrefix)Teacher": Teacher.self,
    "\(SSCodingPrefix)Honor": Honor.self,
    "\(SSCodingPrefix)SimpleStruct": SimpleStruct.self,
]
```
只有 ```SSCodingDefines``` 被声明的 Struct 才会被执行反序列化操作，这也避免了类似 NSCoding 中要反序化的类不存在而 Crash 的 Bug。

在序列化的 ```[String: AnyObject]``` 中，有一个默认键名为 ```_SSCodingType``` 的 Key-Value，Value 就是 ```SSCodingDefines``` 中的键名。

至此，我们很容易就得到了目标 Struct Type，因为 Struct 都遵从 SSCoding，所以，SSCodingHelper 可以调用 ```init?(coder aDecoder: SSCoder)``` 方法生成一个 Struct 实例。

### SSCoding 对 Array、Dictionary 的处理
Array 和 Dictionary 的泛型既好用亦讨厌，假如你有一个 Teacher 的 Struct，同时它遵从 SSCoding 协议，但是他并不能使用```let value = child.value as? [SSCoding]``` 去推断泛型，你必须使用 ```let value = child.value as? [Teacher]``` 完成这件事情。
对于 Dictionary 也是一样。
于是，我们为 SSCoding 协议添加了一个方法，```additionItems()```，Struct 通过实现这个方法，返回 SSCoding 一个已经转换好类型的数组、字典，就可以了。

### SSCoding 对 Optional 的处理
Optional 面临的问题，与泛型的问题类似。 你不能直接使用 ```as? Int``` 去判断一个值是否为 Int，你也不能使用 ```as? Int?```。
并且 Optional 值是不能转换成 AnyObject 的！
一个比较妥协的方法是，如果它存一个值，则在 addtionItems() 中返回这个值，如果这个值是 nil，则返回一个 NSNull() 的实例（或者干脆不返回）。

### 最后
最后，我们各添加了一个方法到 ```NSKeyedArchiver``` 和 ```NSKeyedUnarchiver```，至此，整个 SSCoding 就完成了。
实际上，这只是一个研究了半天的作品，希望能对你有所帮助。
如果你喜欢这篇研究性的作品，请点个赞吧！
