# LivePaper

Provides a ruby interface to the Live Paper service by HP for creating watermarked images, QR codes, and mobile-friendly shortened URLs.


## Installation

Add this line to your application's Gemfile:

    gem 'live_paper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install live_paper

## Register with the Live Paper Service

In order to obtain access credentials register here:  https://link.livepaperdeveloper.com

## Usage

### Authenticate

Live Paper gem requires an authentication hash with :id and :secret. Obtain your credentials from the registration link above.

```ruby
lp = LivePaper.auth id: "your client id", secret: "your client secret"
```


### Shortening URLs

```ruby
short_url = lp.shorten('http://www.google.com')
```


### Generating QR Codes

```ruby
qr_bytes = lp.qr_bytes('http://www.amazon.com')
 File.open("qr.png", "w") { |f| f.write(qr_bytes) }
```

> Note: Version 1 of the API only supports returning QR Code bytes. Version 2 may host publicly accessible QR images.

### Watermarking Images

```ruby
wm_bytes = lp.watermark_bytes("http://www.hp.com",
                              "https://www.google.com/images/srpr/logo11w.png")
File.open("watermark.jpg", "w") { |f| f.write(wm_bytes) }
```

> Note: Version 1 of the API only supports returning image bytes. Version 2 may host publicly accessible images.

## Contributing

1. Fork it ( https://github.com/IPGPTP/live_paper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
