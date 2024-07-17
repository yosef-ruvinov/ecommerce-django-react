FROM python:3.9.6-alpine
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /code
COPY requirements.txt requirements.txt 
RUN pip install --upgrade pip
RUN apk add --update --no-cache gcc musl-dev libffi-dev openssl-dev
RUN pip install --upgrade defusedxml olefile Pillow
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
