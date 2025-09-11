class OpenaiCleanupService
  def initialize
    # Try environment variable first, fallback to credentials for development
    api_key = ENV['OPENAI_API_KEY'] || Rails.application.credentials.openai_api_key
    raise "OpenAI API key not configured. Set OPENAI_API_KEY environment variable or add to Rails credentials" if api_key.blank?

    @client = OpenAI::Client.new(access_token: api_key)
  end

  def cleanup(text, prompt)
    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: prompt },
          { role: "user", content: text }
        ],
        max_tokens: 2000,
        temperature: 0.3
      }
    )

    response.dig("choices", 0, "message", "content")
  end
end
