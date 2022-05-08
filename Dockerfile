FROM python:3.9

WORKDIR /app

ADD requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt
# RUN pip install -vvv uvloop

ADD backend backend
ADD main.py .

ENV PORT=5000

CMD [uvicorn, main:app, --host, 0.0.0.0, --port, ]
