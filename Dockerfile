# Use a lightweight Python image
FROM python:slim

# Set environment variables to prevent Python from writing .pyc files
# and ensure logs are flushed directly
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies required by LightGBM (and cleanup)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . .

# Install Python dependencies (package in editable mode)
RUN pip install --no-cache-dir -e .

# Expose Flask port
EXPOSE 5000

# Default command -> run the Flask app
CMD ["python", "application.py"]
