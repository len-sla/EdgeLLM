## Ollama on Raspberry Pi 5 -> requests sent from jupyterlab ( in docker container)

The Ollama package was installed on a Raspberry Pi 5. After installation, a few smaller quantized models were downloaded, including two that will later be used for testing purposes.  

#### Important Note  

To make the models accessible from other computers and applications, the `ollama.service` file must be adjusted. Specifically, modify the `Environment` line as follows:  
Environment="OLLAMA_HOST=0.0.0.0:11434"

```
# /etc/systemd/system/ollama.service
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
ExecStart=/usr/local/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
```


Using the Models

You can interact with the models remotely via a POST request. Below is an example:
```
response = requests.post(url, json=payload, stream=True)
```
#### ![ Interactive Example](stable-code.ipynb)

An interactive example for asking questions is provided in the star-code.ipynb file. Since the Raspberry Pi requires some time to process requests, the stream=True option is used. This ensures the process's results are streamed and also saved to a Markdown file named output.md. In case of any hung up user could see that as well.


####  ![Classification Example ]( qwen.ipynb)

Another example demonstrates the use of a Pydantic class to frame responses for specific user needs. In this case, the task is to classify an SMS as spam or not spam and provide a chain of thought explaining the reasoning.

Example SMS
```
"Win the newest Harry Potter and the Order of the Phoenix (Book 5) reply HARRY, answer 5 questions - chance to be the first among readers!"
```

Pydantic Class Definition
```
from pydantic import BaseModel, Field
from typing import Optional, Literal

class SpamDetectorSmart(BaseModel):
    chain_of_thought: Optional[str] = Field(
        None, 
        description="Presenting a consequent way of reasoning to decide about the text"
    )
    label: Literal["spam", "not_spam"]
```
Payload for the Request
```
payload = {
    "model": "qwen2",
    "prompt": f"Classify the following SMS as spam or not_spam. Provide reasoning for the classification.\n\n{SMS}\n\nResponse format: {{\"label\": \"spam\", \"chain_of_thought\": \"[reasoning here]\"}}",
    "max_length": 150,
    "temperature": 0.0  # Low temperature for deterministic output
}

```

```
Final classification result:
Label: spam
Chain of Thought: The message is trying to entice the recipient by offering a prize (the newest Harry Potter book) in exchange for replying and answering questions. Such messages often have promotional elements and require action from the recipient, which are typical characteristics of spam.
```

Dockerfile for ollama ready environment to play with code and not polute original os:
```
# Use Python 3.11 for better compatibility
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt /tmp/requirements.txt

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt || \
    (echo "Retrying pip installation..." && sleep 5 && pip install --no-cache-dir -r /tmp/requirements.txt) && \
    pip install ollama && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expose JupyterLab port
EXPOSE 8888

# Default command
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
```
as well as requirements.txt

creating docker image and running:

```
docker build -t v_llm_jupyterlab .

docker run -it --rm --name v_llm_juplab -p 8888:8888 -v $(pwd):/app v_llm_jupyterlab
```
Summary

Using a Raspberry Pi with the Ollama package allows for small models to perform reasoning-based decisions. This approach is particularly useful in scenarios requiring reasoning and flexibility, enabling the use of small models to fulfill non-deterministic components of the code.



![](q2.gif)

If there is need to convert pdf to markdown file here is everything you need to quickly create docker image and then convert
![convert pdf to markdown](hawtopdf-to-md.md)
### If you want more info
lencz.sla@gmail.com
