# encoding: utf-8
namespace :gettext do

  desc "copy template gettext_json.js file to public/javascripts/locale"
  task :install_js => :environment do
    file_name = "gettext_json.js"
    file = File.join(File.dirname(__FILE__), file_name)
    dir = File.join(RAILS_ROOT, 'public/javascripts/locale')
    if !File.exist? dir
      puts "Creating directory #{dir}"
      Dir.mkdir dir
    end

    new_file = File.join(dir, file_name)
    puts "Copy gettext_json.js to #{dir}"
    FileUtils.cp file, new_file

    after_generate
  end

  def after_generate
          puts <<-ALERT

                            ATTENTION !

In order to use the gettext_json library, add the following line in your layout :
    #{colorize("javascript_include_tag 'locale/gettext_json.js'")}

To generate the translations json file use the following rake task :
    #{colorize("rake gettext:json")}
or simply use the standard task
    #{colorize("rake gettext:pack")}
And then add the following line in your layout :
    #{colorize("javascript_include_tag 'locale/gettext_json_translations.js'")}

ALERT
  end

  def colorize(text)
    "\e[33m#{text}\e[0m"
  end
end
