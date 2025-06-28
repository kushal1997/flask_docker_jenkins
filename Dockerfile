FROM python:3.10-slim
WORKDIR /app
RUN pip install Flask
COPY app.py .
EXPOSE 3000
CMD ["python","app.py"]
