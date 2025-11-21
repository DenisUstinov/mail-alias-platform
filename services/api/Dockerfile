FROM python:3.13-slim

WORKDIR /app

RUN pip install --no-cache-dir fastapi uvicorn

RUN echo "from fastapi import FastAPI\n\
app = FastAPI()\n\
@app.get('/')\n\
def read_root():\n\
    return {'service': 'api', 'status': 'ok'}" > main.py

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
