# python:3.8-slim-buster is end-of-life: Debian buster left the mirrors, so
# `apt` fails inside it and Python 3.8 no longer receives security fixes.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

COPY . /app/

RUN useradd --create-home --uid 10001 appuser
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
