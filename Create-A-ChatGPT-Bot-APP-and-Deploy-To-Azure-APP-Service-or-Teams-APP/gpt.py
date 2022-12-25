import openai

def process_gpt(request):
  message = request.form['message']
  openai.api_key = "<YOUR_API_KEY>"
  response = openai.Completion.create(
    engine="text-davinci-003",
    prompt=message,
    max_tokens=1024,
    temperature=0.5,
  )

  # Format the response text
  response_text = response.choices[0].text.strip()  # Remove leading and trailing whitespace
  response_text = response_text.replace("\n", "<br>")  # Replace newlines with line breaks
  # Return the formatted response text
  return response_text

