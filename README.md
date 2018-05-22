# ImageExtended

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Quick Start

### How to use

Import compiled library to your class:

    import ImageExtended

### Image Load

You can specify a download url as a URL or String type:
```
public func image(stringOrURL source: Any,
                  placeholderType: PlaceholderType? = nil,
                  brokenImagePlaceholder: UIImage? = nil,
                  completion: ImageDownloaderCompletion? = nil)
```

For example:

    imageView.image(stringOrURL: "YOUR_URL")

Also you can set the placeholder image while its loading from the web:

    imageView.image(stringOrURL: "YOUR_URL",
                    placeholderType: .image(UIImage(named: "PLACEHOLDER_IMAGE")))

or activity indicator:

    imageView.image(stringOrURL: "YOUR_URL",
                    placeholderType: .activityIndicator(.infinit))
    
There are two modes of behavior in activity indicator view: `infinit` and `progress`.

    public enum IndicatorType {
        case infinit
        case progress
    }

Also there is a possibility to set image that will show if your download process is broken for some reason:
```
imageView.image(stringOrURL: "YOUR_URL",
                placeholderType: .activityIndicator(.infinit)
                brokenImagePlaceholder: UIImage(named: "BROKEN_PLACEHOLDER"))
```

In `progress` mode indicator change length of its stroke depending on the current download progress.

Also its possible to receive completion handler after finishing its download process:

    imageView.image(stringOrURL: "YOUR_URL",
                    placeholderType: .image(UIImage(named: "PLACEHOLDER_IMAGE")))
    { (imageInstance, error) in
    
    }

### Tint pictogram

This method work on single colors without fading, mainly for svg images. Method returns tinted image. For example:

    let image = UIImage(named: "TRAGET_IMAGE").tintPictogram(with: UIColor.blue)


## Red Line

Don't forget  to add the following lines to your `.plist` file:

- `NSAppTransportSecurity` as a Dictionary and...
- `NSAllowsArbitraryLoads` setted to true as key-value attribute of its dictionary 
