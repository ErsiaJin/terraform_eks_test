# 파이썬 이미지를 기반으로 함
FROM python:3.7-slim

# Docker 이미지 내부에서 RUN, CMD, ENTRYPOINT의 명령이 실행될 디렉토리를 설정 (작업 폴더 설정)
WORKDIR /app

# 현재 디렉터리에 있는 파일들을 이미지 내부 /app 디렉터리에 복사함
COPY . /app

# requirements.txt 파일을 기반으로 파이썬 패키지들을 실행함
RUN pip install -r requirements.txt

# 80포트를 외부로 노출함
EXPOSE 80

# 환경변수를 설정함
ENV NAME World

# 쉘을 사용하지 않고 컨테이너가 시작되었을 때 아래 명령을 실행함 'python app.py'가 실행
CMD ["python", "app.py"]