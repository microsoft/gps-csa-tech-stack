import os
import openai

def process_gpt(request):
  message = request.form['message']
  openai.api_key = "<your openai api key>"
  response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
      messages=[
        {"role": "system", "content": message},
        {"role": "user", "content": message}

    ],
  
   # prompt=message,
   max_tokens=4000,
   stream=True,
   temperature=0.3,
  )

  # Format the response text
  
  response_text = response.choices[0].message.content.strip()  # Remove leading and trailing whitespace
  response_text = response_text.replace("\n", "<br>")  # Replace newlines with line breaks
  # Return the formatted response text
  return response_text

