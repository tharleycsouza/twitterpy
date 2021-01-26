# Dockerfile

# FROM directive instructing base image to build upon
FROM python:3.7-buster

# set environment varibles
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# set work directory
WORKDIR /usr/src/twitterpy
RUN pip install --upgrade pip
RUN pip install pipenv
COPY ./Pipfile /usr/src/twitterpy/Pipfile
RUN pipenv install --skip-lock --system

# copy project
COPY ./app/local_settings.py /etc/twitterpy/local_settings.py
COPY . /usr/src/twitterpy
