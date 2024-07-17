FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt upgrade -y

# ubuntu package install
RUN apt install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        libffi-dev \
        libssl-dev \
        libbz2-dev \
        python3-pip \
        python3-setuptools \
        wget \
        git \
        tzdata \
        libgl1-mesa-dev \
        zlib1g-dev \
        libncurses5-dev \
        libgdbm-dev \
        libnss3-dev \
        libreadline-dev \
        libffi-dev \
        libsqlite3-dev \
        libglib2.0-0

# # Update alternatives to use Python 3.10
# RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

WORKDIR /workspace

COPY ./requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

# 作業ディレクトリをLLaVAに変更
WORKDIR /workspace/LLaVA

# パッケージをインストール
RUN pip3 install --upgrade pip
# RUN if [ -f pyproject.toml ]; then pip3 install -e .; else echo "No setup.py or pyproject.toml found"; fi
# RUN pip3 install -e .
# # RUN if [ -f pyproject.toml ]; then pip3 install -e ".[train]"; else echo "No setup.py or pyproject.toml found"; fi
# RUN pip3 install -e ".[train]"
# # # RUN pip3 install flash-attn --no-build-isolation
# # # RUN pip3 uninstall  flash-attn
# # # RUN if [ -f pyproject.toml ]; then pip3 install -e ".[train]"; else echo "No setup.py or pyproject.toml found"; fi
# RUN pip3 install flash-attn --no-build-isolation --no-cache-dir

# # # LLaVAリポジトリの最新コードをプルしてアップグレード
# RUN git pull \
#     pip3 install -e .

# キャッシュを無効にして再インストール（必要に応じてコメントを外してください）
# RUN pip3 install flash-attn --no-build-isolation --no-cache-dir

# コンテナの起動時にbashを実行
CMD ["bash"]
