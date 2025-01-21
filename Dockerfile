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

