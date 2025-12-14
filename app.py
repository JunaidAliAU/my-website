from flask import Flask
import datetime

app = Flask(__name__)

@app.route('/')
def home():
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f'''
    <!DOCTYPE html>
    <html>
    <head>
        <title>My First CI/CD Website</title>
        <style>
            body {{ 
                font-family: Arial; 
                text-align: center; 
                padding: 50px; 
                background-color: #f0f8ff;
            }}
            h1 {{ color: #2c3e50; }}
            .box {{ 
                background: white; 
                padding: 30px; 
                border-radius: 10px; 
                box-shadow: 0 0 10px #ccc; 
                display: inline-block;
            }}
            .success {{ color: green; font-weight: bold; }}
        </style>
    </head>
    <body>
        <div class="box">
            <h1>✅ My First CI/CD Pipeline Project!</h1>
            <p>This website is auto-deployed from GitHub.</p>
            <p>Server Time: <strong>{current_time}</strong></p>
            <p class="success">Every commit will build a new Docker image and deploy to AWS!</p>
            <p>Powered by Flask | Docker | GitHub Actions | AWS | Terraform</p>
        </div>
    </body>
    </html>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
