FROM python:3.9

WORKDIR /app

ADD requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt
# RUN pip install -vvv uvloop

ADD backend backend
ADD main.py .

# these both do the same thing
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "$PORT"]
# CMD uvicorn main:app --host 0.0.0.0 --port $PORT
