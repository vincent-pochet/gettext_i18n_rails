require 'gettext'

module GettextI18nRails
  module JsParser
    module_function

    def target?(file)
      File.extname(file) == ".js"
    end

    def parse(file, msgids = [])
      js = File.read(file)
      code = js.scan(/GetText.[sn]?_ *\(["'].*?["'](?: *, *["'].*?["'] *, *.*)?(?: *, *\{.*\})? *\)/).map { |s| s.gsub(/GetText\./, '') }
      GetText::RubyParser.parse_lines(file, code, msgids)
    end
  end
end

GetText::RGetText.add_parser(GettextI18nRails::JsParser)
