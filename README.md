# guard-xcodebuild

guard-xcodebuild automatically and selectively runs your tests when your Xcode files are modified

## Installation

Add this line to your application's Gemfile:

    gem 'guard', '~> 2.0'
    gem 'guard-xcodebuild'

And then bundle it:

    $ bundle

Or install the gem:

    $ gem install guard-xcodebuild

## Dependency

- Ruby >2
- [xcodebuild](https://github.com/facebook/xcodebuild)
- Guard 2.x

## How to Use

1) Install xcodebuild with `brew install xcodebuild`
2) Create an `.xcodebuild-args` file in your project root passing the parameters relevant to your project. 
It's a simple JSON value where you can pass key value pairs. Here's an example:

```
{
  "workspace": "YourProject.xcworkspace",
  "scheme": "YourSchemeName",
  "configuration": "Debug",
  "sdk": "iphonesimulator",
  "destination": "'platform=iOS Simulator,name=iPhone 7 Plus'"
}
```

3) Configure your Guardfile

```ruby
directories %w(YourApp YourAppTests) \
.select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

guard 'xcodebuild' do
  watch(/(.*).(m|swift)/)
end
```

4) Run `bundle exec guard`

## Options
s
By default, xcodebuild find the folder for projects and find a target that look like test.
You can supply your target by using ```test_target``` option.

```ruby
guard 'xcodebuild', :test_target => 'YourAppTests' do
  watch(...)
end
```

By default, xcodebuild check all files under current folder for tests. You can specify a
specific folder, or array of folders, as test path.

```ruby
guard 'xcodebuild', :test_paths => 'YourAppTests' do
  watch(...)
end
```

```ruby
guard 'xcodebuild', :test_paths => ['YourAppUITests', 'YourAppTests'] do
  watch(...)
end
```

You can pass any of the standard xcodebuild CLI options using the ```:cli``` option.
Note that this will be append to any arguments specified in the .xcodebuild-args file

```ruby
guard 'xcodebuild', :cli => 'CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS=""' do
  watch(...)
end
```

You might specify the full path to the xcodebuild with ```:xcodebuild```  option:

```ruby
guard 'xcodebuild', :xcodebuild => '/usr/local/bin/xcodebuild' do
  watch(...)  
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request