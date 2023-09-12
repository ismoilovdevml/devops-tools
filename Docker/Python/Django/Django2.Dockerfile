# Use an official Python runtime as a parent image
FROM python:3.8-slim-buster as builder

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /usr/src/app

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libc6-dev python3-dev python3-setuptools \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

#-----------------------------------------------------
# Use a smaller parent image to create the final image

FROM python:3.8-slim-buster

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /usr/src/app

COPY --from=builder /usr/local /usr/local

COPY . .

RUN python manage.py collectstatic --noinput

# Make migrations and migrate the database.
# NOTE: Remove this step if you are not using Django's database functionality
RUN python manage.py migrate

# Create a user to run the application
RUN useradd -ms /bin/bash user
USER user

EXPOSE 8000

CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:8000"]
