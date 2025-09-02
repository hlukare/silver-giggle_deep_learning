FROM python:3.10-slim

# System deps for OpenCV + video
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg libgl1 libglib2.0-0 \
 && rm -rf /var/lib/apt/lists/*

# App dir
WORKDIR /app

# Copy dependency list and install (build cache friendly)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . .

# If model is remote, uncomment to download on build or at runtime
# RUN python scripts/download_model.py

# Render provides $PORT env var; expose for local
EXPOSE 8000

# Gunicorn: single worker + threads = safer for TF/NumPy
# Render will set PORT; default to 8000 locally
ENV PYTHONUNBUFFERED=1
CMD ["sh", "-c", "gunicorn -w 1 -k gthread -t 120 -b 0.0.0.0:${PORT:-8000} app:app"]
