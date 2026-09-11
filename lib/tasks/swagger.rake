namespace :swagger do
  desc "Validate swagger JSON file syntax"
  task validate: :environment do
    swagger_path = Rails.root.join("swagger", "v1", "swagger.json")
    unless File.exist?(swagger_path)
      puts "❌ Swagger file not found: #{swagger_path}"
      exit 1
    end

    begin
      JSON.parse(File.read(swagger_path))
      puts "✅ Swagger JSON is valid: #{swagger_path}"
    rescue JSON::ParserError => e
      puts "❌ Invalid JSON: #{e.message}"
      exit 1
    end
  end
end
