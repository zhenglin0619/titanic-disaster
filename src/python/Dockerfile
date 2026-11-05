FROM python:3.11

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY src/python/main.py ./src/python/main.py
COPY src/data/ ./src/data/

CMD ["python", "src/python/main.py"]
