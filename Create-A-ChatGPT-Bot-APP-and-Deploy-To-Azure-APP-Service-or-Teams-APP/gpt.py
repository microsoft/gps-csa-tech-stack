import openai
openai.api_type = "azure"
#替换您的Openai API Key endpoint
openai.api_base = "<Your Openai API Key endpoint>"
openai.api_version = "2022-12-01"
#替换您的Openai API Key 
openai.api_key = "<Your Openai API Key>"


# defining a function to create the prompt from the system message and the messages
def create_prompt(system_message, messages):
    prompt = system_message
    message_template = "\n<|im_start|>{}\n{}\n<|im_end|>"
    for message in messages:
        prompt += message_template.format(message['sender'], message['text'])
    prompt += "\n<|im_start|>assistant\n"
    return prompt
# defining the system message
system_message_template = "<|im_start|>system\n{}\n<|im_end|>"
system_message = system_message_template.format("You are an AI assistant that helps people find information.")
# creating a list of messages to track the conversation

def process_gpt(request):
  message = request.form['message']
  messages = [{"sender": "user", "text": message}]

  response = openai.Completion.create(
    #替换您的Openai API模型部署名字，在Azure Portal中openai“模型部署”中可以找到
    engine="<Your Openai Model deployment name>",
    prompt= create_prompt(system_message, messages),
    temperature=0.7,
    max_tokens=4000,
    top_p=0.95,
    frequency_penalty=0,
    presence_penalty=0,
    stop=["<|im_end|>"])

    # Format the response text
    
  response_text = response['choices'][0]['text']
    # Remove leading and trailing whitespace
  response_text = response_text.replace("\n", "<br>")  # Replace newlines with line breaks
    # Return the formatted response text
  return response_text
