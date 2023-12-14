FROM python:3.9

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /code

COPY requirements.txt /code/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /code/

RUN python manage.py makemigrations
RUN python manage.py migrate

RUN mkdir -p /code/staticfiles

RUN python manage.py collectstatic --noinput --clear

EXPOSE 9000

CMD ["python", "manage.py", "runserver", "0.0.0.0:9000"]