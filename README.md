# MLOps Project Setup with GCP, Jenkins, and Docker

This repository demonstrates the complete setup of an **end-to-end MLOps pipeline** using Google Cloud Platform (GCP), Docker, Jenkins, and MLflow for model tracking.

---

## Project Structure

```
Project_01/
│── artifacts/               # Stores intermediate artifacts
│── config/                  # Configuration files
│   ├── __init__.py
│   ├── config.yaml
│   ├── paths_config.py
│   ├── model_params.py
│── pipeline/                # Training and deployment pipelines
│   ├── __init__.py
│   ├── training_pipeline.py
│── src/                     # Source code for ingestion, preprocessing, training
│   ├── __init__.py
│   ├── logger.py
│   ├── custom_exception.py
│   ├── data_ingestion.py
│   ├── data_preprocessing.py
│   ├── model_training.py
│── utils/                   # Utility functions
│   ├── __init__.py
│   ├── common_functions.py
│── static/                  # Static files (if required for UI)
│── templates/               # HTML templates for user app
│── setup.py                 # Project management file
│── requirements.txt         # Python dependencies
│── Dockerfile               # Docker build file
│── Jenkinsfile              # Jenkins pipeline definition
```

---

## Project Setup

### 1. GCP Setup

* Create a **GCP account** and a new **project**.
* Create a **bucket** under the project (disable *Enforce public access prevention*).
* Upload your dataset (CSV file) into the bucket.

### 2. Virtual Environment Setup

```bash
python -m venv venv
source venv/bin/activate
```

Install dependencies:

```bash
pip install -e .
```

---

## Data Ingestion

1. Install **Google Cloud CLI** and authenticate:

   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-key.json
   ```
2. Add libraries:

   ```bash
   pip install scikit-learn google-cloud-storage
   ```
3. Create and assign roles for a **Service Account**:

   * `Storage Admin`
   * `Storage Object Viewer`

---

## Data Training

* Update `config.yaml` and `paths_config.py` with dataset paths.
* Add preprocessing logic in `data_preprocessing.py`.
* Train and track models using **MLflow**:

  ```bash
  python -m src.model_training
  mlflow ui
  ```

---

## Data & Code Versioning

* Store pipelines in `pipeline/training_pipeline.py`.
* Run training pipeline:

  ```bash
  python -m pipeline.training_pipeline
  ```
* Push code to GitHub (add `.gitignore`).

---

## CI/CD Deployment

### 1. Jenkins Setup with Docker

```bash
cd custom_jenkins/
docker build -t jenkins-dind .
docker run -d --name jenkins-dind --privileged \
  -p 8080:8080 -p 50000:50000 \
  -v //var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home jenkins-dind
```

* Access Jenkins at `http://localhost:8080`.
* Install suggested plugins.
* Create **admin user**.

Install dependencies inside Jenkins container:

```bash
docker exec -u root -it jenkins-dind bash
apt update -y
apt install -y python3 python3-pip python3-venv
```

### 2. GitHub Integration

* Generate a **GitHub token** (with `repo` and `admin:repo_hook`).
* Add credentials in Jenkins.
* Configure Jenkins job with *Pipeline script from SCM*.

### 3. Dockerization & GCR Push

* Add `Dockerfile` to project.

* Enable APIs in GCP:

  * Google Container Registry API
  * Artifact Registry API
  * Cloud Resource Manager API

* Configure Jenkins credentials with GCP Service Account JSON.

* Update `Jenkinsfile` to build & push image to GCR.

### 4. Deploy to Cloud Run

```bash
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member="serviceAccount:<SERVICE_ACCOUNT>" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member="serviceAccount:<SERVICE_ACCOUNT>" \
  --role="roles/iam.serviceAccountUser"
```

Trigger Jenkins build and deploy service to **Google Cloud Run**.

---

## Key Features

* End-to-end MLOps lifecycle with GCP.
* Automated pipelines using Jenkins.
* Model tracking via MLflow.
* CI/CD with Docker & Google Cloud Run.

---
