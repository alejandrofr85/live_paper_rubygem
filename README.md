# LivePaper

Provides a ruby interface to the Live Paper service by HP for creating watermarked images, QR codes, and mobile-friendly shortened URLs.

[![Gem Version](https://badge.fury.io/rb/live_paper.svg)](http://badge.fury.io/rb/live_paper)


## Installation

Add this line to your application's Gemfile:

    gem 'live_paper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install live_paper

## Register with the Live Paper Service

In order to generate access credentials, register here:  https://www.linkcreationstudio.com

## Quick-Start Usage

### Authenticate

The live_paper gem requires authentication. Obtain your credentials from https://www.linkcreationstudio.com/api/libraries/ruby/

```ruby
lp = LivePaper.auth({id: "your client id", secret: "your client secret"})
```


### Shortening URLs

```ruby
short_url = lp.shorten('http://www.google.com')
```


### Generating QR Codes

```ruby
qr_bytes = lp.qr_bytes('http://www.amazon.com')
 File.open("qr.png", "wb") { |f| f.write(qr_bytes) }
```

### Watermarking Images

```ruby
wm_bytes = lp.watermark_bytes("http://www.hp.com",
                              "http://www.letsstartsmall.com/ITSE2313_WebAuthoring/images/unit3/jpg_example1.jpg")
File.open("watermark.jpg", "wb:UTF-8") { |f| f.write(wm_bytes.force_encoding("UTF-8")) }
```

> Note: Version 1 of the API only supports returning image bytes. Version 2 may host publicly accessible images.

## Usage

The gem supports full CRUD operations on the underlying objects. If you do not need to update or
delete previously created objects, see the quick-start section above.

### Underlying Objects

**Triggers** represent the object you want to put on a page: a short url, QR code, or watermarked image.
**Payoffs** are destinations, either the url of a webpage, or an interactive mobile experience.
**Links** join a Trigger to a Payoff.

### CRUD Example

```ruby
  lp = LivePaper.auth({id: "your client id", secret: "your client secret"})

  t=ShortTrigger.create(name: 'short trigger')
  p=Payoff.create(name: 'name', type: Payoff::TYPE[:WEB], url: "http://www.hp.com")
  l=Link.create(payoff_id: p.id, trigger_id: t.id, name: "link")
  @link_id=l.id
  @payoff_id=p.id
  @trigger_id=t.id
  t.short_url # returns url of the form http://hpgo.co/abc123
```

After creating, you will need to persist the link, payoff, and trigger IDs in some form of
permanent storage to later access the resources. The IDs are strings.

If you want to change the destination:

```ruby
  lp = LivePaper.auth({id: "your client id", secret: "your client secret"})

  p=Payoff.get(@payoff_id)
  p.url="http://shopping.hp.com"
  p.update
```

Still later, if you wanted to delete the resources:

```ruby
  lp = LivePaper.auth({id: "your client id", secret: "your client secret"})

  # delete link first, to avoid resource conflict
  l=Link.get(@link_id)
  l.delete

  t=Trigger.get(@trigger_id)
  t.delete

  p=Payoff.get(@payoff_id)
  p.delete
```

You can list existing resources with the list operation.

```ruby
  lp = LivePaper.auth({id: "your client id", secret: "your client secret"})

  @links=Link.list # returns array of Link objects

  @payoffs=Payoff.list # returns array of Payoff objects
```

### QR Code Example

```ruby
  t=QrTrigger.create(name: 'QR code trigger')
  p=Payoff.create(name: 'name', type: Payoff::TYPE[:WEB], url: "http://www.hp.com")
  l=Link.create(payoff_id: p.id, trigger_id: t.id, name: "link")
  t.download_qrcode # returns QR image bytes
```

### Watermarked Image Example

```ruby
  image = Image.upload "http://url/to_your_image"

  t=WmTrigger.create(name: 'watermark')
  p=Payoff.create(name: 'name', type: Payoff::TYPE[:WEB], url: dest)
  l=Link.create(payoff_id: p.id, trigger_id: t.id, name: "link")
  t.download_watermark(image, {strength: 10, resolution: 75})
```

Alternatively, you can upload an image from your local system by providing the path to the jpg file

```ruby
  image = Image.upload "/Users/mike/images/your_image.jpg"
```

### RichPayoff Example - Alternate for Watermarked or QR Code Payoff

```ruby
  rich_data = {
    "type":"content action layout",
    "version":1,
    "data":{
      "content":{
        "type":"image",
        "label":"Movember!",
        "data":{"URL":"http://static.movember.com/uploads/2014/profiles/ef4/ef48a53fb031669fe86e741164d56972-546b9b5c56e15-hero.jpg"}
      },
      "actions":[
        {
          "type":"webpage",
          "label":"Donate!",
          "icon":{"id":"533"},
          "data":{"URL":"http://MOBRO.CO/oamike"}
        },
        {
          "type":"share",
          "label":"Share!",
          "icon":{"id":"527"},
          "data":{"URL":"Help Mike get the prize of most donations on his team! MOBRO.CO/oamike"}
        }
      ]
    }
  }
  p=Payoff.create(name: 'name', type: Payoff::TYPE[:RICH], url: dest, data: rich_data)
  l=Link.create(payoff_id: p.id, trigger_id: t.id, name: "link")
  t.download_watermark
```

## Contributing

1. Fork it ( https://github.com/IPGPTP/live_paper_rubygem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
