platform :ios, '13.5'

post_install do |pi|
  # https://github.com/CocoaPods/CocoaPods/issues/7314
  fix_deployment_target(pi)
  
  
end

def fix_deployment_target(pod_installer)
  if !pod_installer
    return
  end
  puts "Make the pods deployment target version the same as our target"
  
  project = pod_installer.pods_project
  deploymentMap = {}
  project.build_configurations.each do |config|
    deploymentMap[config.name] = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
  end
  # p deploymentMap
  
  project.targets.each do |t|
    puts "  #{t.name}"
    t.build_configurations.each do |config|
      
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      
      oldTarget = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
      newTarget = deploymentMap[config.name]
      if oldTarget == newTarget
        next
      end
      puts "    #{config.name} deployment target: #{oldTarget} => #{newTarget}"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = newTarget
    end
  end
  
  # Integration of licenses generation (see https://github.com/devxoul/Carte)
  pods_dir = File.dirname(pod_installer.pods_project.path)
  at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }
end


# ignore all warnings from all pods
inhibit_all_warnings!
use_frameworks!

target 'CoronaContact' do
  # Pods for CoronaContact
  pod 'SwiftLint'
  pod 'Resolver'
  pod 'Moya'
  pod 'SwiftRichString'
  pod 'Reusable'
  pod 'M13Checkbox'
  pod 'Carte'
  pod 'lottie-ios'
  pod 'SwiftyBeaver'
  pod 'SQLite.swift'
  pod 'SQLiteMigrationManager.swift'
  pod 'ZIPFoundation', '~> 0.9'
  
  target 'CoronaContactTests' do
    inherit! :search_paths
  end
end
