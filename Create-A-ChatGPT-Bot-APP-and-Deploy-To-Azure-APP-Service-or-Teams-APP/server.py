from flask import Flask, request
import gpt

app = Flask(__name__)

@app.route('/process_gpt', methods=['POST'])
def process_gpt():
  return gpt.process_gpt(request)

@app.route('/')
def index():
  return app.send_static_file('index.html')

if __name__ == '__main__':
  app.run()
