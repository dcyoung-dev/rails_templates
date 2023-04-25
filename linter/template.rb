# frozen_string_literal: true

gem_group :development, :test do
  gem 'i18n-tasks'
  gem 'standardrb'
end

run 'bundle install'

run 'yarn add standard stylelint stylelint-config-standard-scss --dev'

file '.stylelintrc.json', <<~CODE
  {
    "extends": "stylelint-config-standard-scss"
  }
CODE

{
  fix_javascript: "\n    \"lint:javascript:fix\": \"yarn standard --fix\",",
  lint_javascript: "\n    \"lint:javascript\": \"yarn standard\",",
  fix_css: "\n    \"lint:css:fix\": \"yarn stylelint 'app/assets/stylesheets/**/*.scss' --fix\",",
  lint_css: "\n    \"lint:css\": \"yarn stylelint 'app/assets/stylesheets/**/*.scss'\",",
  fix: "\n    \"lint:fix\": \"yarn lint:css:fix && yarn lint:javascript:fix\",",
  lint: "\n    \"lint\": \"yarn lint:css && yarn lint:javascript\","
}.each_value do |script|
  inject_into_file('package.json', script, after: '  "scripts": {')
end

file 'bin/lint_fix', <<~CODE
  #!/usr/bin/env ruby
  # frozen_string_literal: true

  require 'fileutils'

  # path to your application root.
  APP_ROOT = File.expand_path('..', __dir__)

  def system!(*args)
    system(*args) || abort('== Command [] failed ==')
  end

  FileUtils.chdir APP_ROOT do
    puts '== Finding missing translations =='
    system 'i18n-tasks missing'

    puts '== Normalising translations =='
    system 'i18n-tasks normalize'

    puts '== Fixing Ruby =='
    system! 'standardrb --fix'

    puts '== Fixing JS =='
    system! 'yarn lint:javascript:fix'
  end
CODE

run 'chmod +x bin/lint_fix'

run 'cp $(i18n-tasks gem-path)/templates/config/i18n-tasks.yml config/'
