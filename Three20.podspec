# TODO CocoaPods needs a way to easily define overrides for each subspec.
overrides = Module.new do
  require 'set'
  
  # Give the spec the possibility to define the list of private headers.
  # They will go in a 'private' sub directory
  def private_header_files=(patterns)
    @private_header_files = Pod::Specification::pattern_list(patterns)
    @private_headers_set = nil
  end
  attr_reader :private_header_files
  
  # Returns all private header files of this pod
  # but relative to the project pods root.
  #
  # If the pattern is the path to a directory, the pattern will
  # automatically glob for header files.
  def expanded_private_header_files
    files = []
    (@private_header_files ||= []).each do |pattern|
      pattern = pod_destroot + pattern
      pattern = pattern + '*.h' if pattern.directory?
      pattern.glob.each do |file|
        files << file.relative_path_from(pod_destroot)
      end
    end
    files
  end
  
  # We want to put private headers in a 'private' sub directory
  def copy_header_mapping(from)
    @private_headers_set ||= Set.new expanded_private_header_files
    @private_headers_set.include?(from) ? File.join("private", from.basename) : from.basename
  end

end

Pod::Spec.new do |s|
  s.extend(overrides)
  s.name     = 'Three20'
  s.version  = '1.0.11'
  s.summary  = 'Three20 is an Objective-C library for iPhone developers.'
  s.homepage = 'http://three20.info/'
  s.author   = { }
  s.source   = { :git => 'git@github.com:jeanregisser/three20.git', :commit => '48180db6d0ffc8e3b3cbab507af447eb2894ded9' }
  s.platform = :ios
  
  s.source_files = 'src/Three20/{Sources,Headers}/*.{h,m}'
  s.dependency 'Three20/Core'
  s.dependency 'Three20/Network'
  s.dependency 'Three20/Style'
  s.dependency 'Three20/UICommon'
  s.dependency 'Three20/UINavigator'
  s.dependency 'Three20/UI'

  # Full name: Three20/Core
  s.subspec 'Core' do |cs|
    cs.extend(overrides)
    cs.source_files = 'src/Three20Core/{Sources,Headers}/*.{h,m}'
    cs.private_header_files = 'src/Three20Core/Headers/TTExtensionInfoPrivate.h'
    cs.header_dir = 'Three20Core'
    cs.resources    = 'src/Three20.bundle'
  end
  
  # Full name: Three20/Network
  s.subspec 'Network' do |ns|
    ns.extend(overrides)
    ns.source_files = 'src/Three20Network/{Sources,Headers}/*.{h,m}'
    ns.private_header_files = 'src/Three20Network/Headers/{TTRequestLoader,TTURLRequestQueueInternal}.h'
    ns.header_dir = 'Three20Network'
    ns.dependency 'Three20/Core'
  end
  
  # Full name: Three20/Style
  s.subspec 'Style' do |ss|
    ss.extend(overrides)
    ss.source_files = 'src/Three20Style/{Sources,Headers}/*.{h,m}'
    ss.private_header_files = 'src/Three20Style/Headers/{TTShapeInternal,TTStyledNodeInternal,TTStyleInternal}.h'
    ss.header_dir = 'Three20Style'
    ss.dependency 'Three20/Core'
    ss.dependency 'Three20/Network'
  end
  
  # Full name: Three20/UICommon
  s.subspec 'UICommon' do |ucs|
    ucs.extend(overrides)
    ucs.source_files = source_files = 'src/Three20UICommon/{Sources,Headers}/*.{h,m}'
    ucs.private_header_files = 'src/Three20UICommon/Headers/UIViewControllerGarbageCollection.h'
    ucs.header_dir = 'Three20UICommon'
    ucs.dependency 'Three20/Core'
    ucs.framework = 'UIKit', 'CoreGraphics'
  end
  
  # Full name: Three20/UINavigator
  s.subspec 'UINavigator' do |uns|
    uns.extend(overrides)
    uns.source_files = 'src/Three20UINavigator/{Sources,Headers}/*.{h,m}'
    uns.private_header_files = 'src/Three20UINavigator/Headers/{TTBaseNavigatorInternal,TTURLArguments,' \
                               'TTURLArgumentType,TTURLLiteral,TTURLPatternInternal,TTURLPatternText,' \
                               'TTURLSelector,TTURLWildcard,UIViewController+TTNavigatorGarbageCollection}.h'
    uns.header_dir = 'Three20UINavigator'
    uns.dependency 'Three20/Core'
    uns.dependency 'Three20/UICommon'
  end

  # Full name: Three20/UI
  s.subspec 'UI' do |us|
    us.extend(overrides)
    us.source_files = 'src/Three20UI/{Sources,Headers}/*.{h,m}'
    us.private_header_files = 'src/Three20UI/Headers/{TTButtonContent,TTImageLayer,TTImageViewInternal,' \
                              'TTLauncherHighlightView,TTLauncherScrollView,TTNavigatorWindow,' \
                              'TTSearchTextFieldInternal,TTTabBarInternal,TTTextEditorInternal,TTTextView}.h'
    us.header_dir = 'Three20UI'
    us.framework = 'QuartzCore'
    us.dependency 'Three20/Core'
    us.dependency 'Three20/Network'
    us.dependency 'Three20/Style'
    us.dependency 'Three20/UICommon'
    us.dependency 'Three20/UINavigator'
  end
  
end
