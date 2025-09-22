# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY ai-boutique-assit/ ./ai-boutique-assit/

# Create a non-root user
RUN useradd --create-home --shell /bin/bash app && chown -R app:app /app
USER app

# Default microservice endpoints will be set by Kubernetes deployment
# These will be overridden by the K8s deployment to point to GKE services

# Expose port for ADK web server
EXPOSE 8000


# Default command - run the agent with web interface on all interfaces
CMD ["adk", "web", "--host", "0.0.0.0", "--port", "8000"]
