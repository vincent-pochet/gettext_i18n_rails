module GettextI18nRails
  # Find and write all translation into a json javascript file accessible
  # for the javascript gettext implementation
  def store_json_translations(options)
    translations = {}
    file = options[:to] || 'public/javascripts/locale/gettext_json_translations.js'
    locale_path = options[:locale_path] || 'locale'

    js_messages = find_javascript_translations
    js_messages.concat(find_extra_translations(options[:extra_translations]))
    js_messages.concat(find_extra_translations(options[:model_data]))

    # extract translation from po files
    Dir.glob("#{locale_path}/*/") do |folder|
      lang = File.basename(folder)
      translations[lang] = {}

      Dir.glob(File.join(folder, '*.po')) do |file|
        code = File.read(file)

        code.scan(/^(msgid ".*?"\n(?:(?:msgid_plural ".*?"\n)|(?:msgstr ".*?")))\n/m).each do |block|
          if /^msgid_plural "(.*?)"$/m.match(block[0])
            msg = /^msgid "(.*?)"\nmsgid_plural "(.*?)"\nmsgstr\[0\] "(.*?)"\nmsgstr\[1\] "(.*?)"$/m.match(block[0])

            unless msg[1].empty? or msg[2].empty?
              message_to_add = "id:#{msg[1]}:plural:#{msg[2]}"
              if js_messages.include?(message_to_add)
                translations[lang][message_to_add] = [msg[3].gsub(/["\n]/, ''), msg[4].gsub(/["\n]/, '')]
              end
            end
          else
            msg = /^msgid "(.*?)"\nmsgstr "(.*?)"$/m.match(block[0])
            unless msg[1].empty? or not js_messages.include?(msg[1])
              translations[lang][msg[1]] = msg[2].gsub(/["\n]/, '') unless msg[2].empty?
            end
          end
        end
      end
    end
    write_json_translations(file, translations)
  end

  #Find translation into javascripts files
  def find_javascript_translations
    javascripts_to_translate = Dir.glob("public/javascripts/**/*.js")
    js_messages = []

    Dir.glob(javascripts_to_translate) do |file|
      code = File.read(file)
      code.scan(/GetText.[sn]?_ *\(["'](.*?)["'](?: *, *["'](.*?)["'] *, *.*)?(?: *, *\{.*\})? *\)/).each do |msgs|
        unless msgs[0].empty?
          if msgs[1].nil?
            js_messages.push(msgs[0])
          else
            js_messages.push("id:#{msgs[0]}:plural:#{msgs[1]}")
          end
        end
      end
    end
    return js_messages
  end

  def find_extra_translations(file)
    js_messages = []
    return js_messages unless file
    
    code = File.read(file)
    return js_messages unless code
    code.scan(/[sn]?_ *\(["'](.*?)["'](?: *, *["'](.*?)["'] *, *.*)?(?: *, *\{.*\})? *\)/).each do |msgs|
      unless msgs[0].empty?
        if msgs[1].nil?
          js_messages.push(msgs[0])
        else
          js_messages.push("id:#{msgs[0]}:plural:#{msgs[1]}")
        end
      end
    end
    js_messages
  end

  def write_json_translations(file, translations)
    File.open(file, 'w') do |f|
      f.write 'GetText.translations = '
      f.write translations.to_json
      f.write ";"
    end
  end
  
end
