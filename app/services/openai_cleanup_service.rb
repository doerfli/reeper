class OpenaiCleanupService
  def initialize
    api_key = Rails.application.credentials.openai_api_key
    raise "OpenAI API key not configured in Rails credentials" if api_key.blank?

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
