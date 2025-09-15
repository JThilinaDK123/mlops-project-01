# # Use a lightweight Python image
# FROM python:slim

# # Set environment variables to prevent Python from writing .pyc files & Ensure Python output is not buffered
# ENV PYTHONDONTWRITEBYTECODE=1 \
#     PYTHONUNBUFFERED=1

# # Set the working directory
# WORKDIR /app

# # Install system dependencies required by LightGBM
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     libgomp1 \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# # Copy the application code
# COPY . .

# # Install the package in editable mode
# RUN pip install --no-cache-dir -e .

# # Train the model before running the application
# RUN python pipeline/training_pipeline.py

# # Expose the port that Flask will run on
# EXPOSE 5000

# # Command to run the app
# CMD ["python", "application.py"]


# Use a lightweight Python image
FROM python:slim

# Set environment variables to prevent Python from writing .pyc files & Ensure Python output is not buffered
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Install system dependencies required by LightGBM
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Accept service account key & project as build args
ARG GCP_KEY_FILE
ARG GCP_PROJECT

# Copy everything including service account key
COPY . .
COPY ${GCP_KEY_FILE} /app/${GCP_KEY_FILE}

# Set Google credentials so google-cloud-storage can authenticate
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/${GCP_KEY_FILE}
ENV GCP_PROJECT=${GCP_PROJECT}

# Install the package in editable mode
RUN pip install --no-cache-dir -e .

# Train the model before running the application
RUN python pipeline/training_pipeline.py

# Expose the port that Flask will run on
EXPOSE 5000

# Command to run the app
CMD ["python", "application.py"]
