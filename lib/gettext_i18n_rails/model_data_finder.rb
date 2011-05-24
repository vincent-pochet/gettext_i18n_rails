module GettextI18nRails
  #Find and store model data
  def store_model_data(options)
    file = options[:to] || 'locale/model_data.rb'
    js_file = options[:to_js] || 'locale/model_data_js.rb'
    tables_file = options[:tables_file] || 'config/translated_tables.yml'

    tables = YAML::load(File.open(tables_file))
    message = "#DO NOT MODIFY! AUTOMATICALLY GENERATED FILE!"

    File.open(file, 'w') do |f|
      f.puts message
      ModelDataFinder.new.find(tables).each do |value|
        f.puts "_(\"#{value}\")"
      end
      f.puts message
    end

    File.open(js_file, 'w') do |f|
      f.puts message
      ModelDataFinder.new.find_for_js(tables).each do |value|
        f.puts "_(\"#{value}\")"
      end
      f.puts message
    end
  end

  class ModelDataFinder

    def find(tables)
      found = []

      connection = ActiveRecord::Base.connection
      connection.tables.each do |table_name|
        next unless translatable_table?(table_name, tables)
        if tables[table_name]['combinations']
          found.concat get_table_data(connection, table_name, tables[table_name]['columns'], tables[table_name]['combinations'])
        else
          found.concat get_table_data(connection, table_name, tables[table_name]['columns'])
        end
      end

      found
    end

    def find_for_js(tables)
      found = []

      connection = ActiveRecord::Base.connection
      connection.tables.each do |table_name|
        next unless translatable_table?(table_name, tables) and tables[table_name]['js']
        found.concat get_table_data(connection, table_name, tables[table_name]['columns'])
      end

      found
    end

    def get_table_data(connection, table_name, columns, combinations = [])
      found = []
      model = table_name.singularize.camelcase.constantize

      connection.columns(table_name).each do |column|
        next unless translatable_column?(column.name, columns)

        connection.select_values("SELECT #{column.name} FROM #{table_name}").each do |value|
          output = value.gsub(/"/, '\\"')
          found.push("#{model}|#{output}")
          combinations.each do |combination|
            found.push(combination.gsub('%{x}', output))
          end
        end
      end

      found
    end

    def translatable_table?(table_name, tables)
      return false unless tables
      tables.has_key?(table_name)
    end

    def translatable_column?(name, columns)
      return false unless columns
      columns.include?(name)
    end
  end
end
