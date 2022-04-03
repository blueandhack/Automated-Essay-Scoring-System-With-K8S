FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install build-essential -y
RUN apt-get install libxml-parser-perl wget git pip unzip pkg-config libpng-dev libfreetype6-dev freetype2-demos python3 python3-pip python3-tk -y
RUN mkdir -p /home/project/
WORKDIR /home/project/
RUN mkdir -p /tmp/
RUN wget --load-cookies /tmp/cookies.txt \
    "https://docs.google.com/uc?export=download&confirm=$(wget \
    --quiet --savecookies /tmp/cookies.txt --keep-session-cookies \
    --no-check-certificate 'https://drive.google.com/file/d/1RxfZOYyNvzvCf37_vABfJMkohAsEZKtH/' \
    -O- | sed -rn 's/.confirm=([0-9A-Za-z_]+)./\1\n/p')&id=1RxfZOYyNvzvCf37_vABfJMkohAsEZKtH" \
    -O rough.zip && rm -rf /tmp/cookies.txt
RUN wget https://s3.amazonaws.com/models.huggingface.co/bert/bert-large-uncased.tar.gz
RUN unzip rough.zip
RUN cpan install XML::Parser::PerlSAX
RUN cpan install XML::RegExp
RUN cpan install XML::DOM
WORKDIR /home/project/RELEASE-1.5.5
RUN ./runROUGE-test.pl
WORKDIR /home/project/
RUN git clone https://github.com/bheinzerling/pyrouge.git
WORKDIR /home/project/pyrouge
RUN pip install -e .
WORKDIR /home/project/
RUN git clone https://github.com/Quan25/flask-summary.git
RUN cd /home/project/
RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
RUN pip3 install flask pandas sklearn nltk gensim==3.8.3 pytorch-pretrained-bert matplotlib==3.0.1
RUN echo $'import nltk\nnltk.download("punkt")' > punktDownload.py
RUN python3 punktDownload.py
WORKDIR /home/project/flask-summary
RUN echo $'#!/bin/bash\nsed -i "s/\/home\/quan\/Downloads\/bert-large-uncased/\/home\/project\/bert-large-uncased.tar.gz/g" summarizer/BertParent.py' > replacePath.sh
RUN chmod +x replacePath.sh
RUN ./replacePath.sh
EXPOSE 5000
CMD ["python3", "app.py"]
