# Docker コンテナ上で OpenSiv3D for Web を自前ビルドする

Docker コンテナ上で OpenSiv3D for Web をビルドする。

https://github.com/nokotan/OpenSiv3D

## 開発環境

- Windows 11
- WSL2 (Ubuntu 22.04.2)
- Docker Desktop v4.20.1

## ビルド手順

Dockerfile:

```Dockerfile
FROM ubuntu:22.04
WORKDIR /work
RUN apt-get update \
  && apt-get install -y build-essential cmake git python3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
ENV HOST 0.0.0.0
EXPOSE 6931
```

docker-compose.yml:

```docker-compose.yml
version: '3'

services:
  app:
    container_name: OpenSiv3DWebBuild
    build: .
    command: bash
    volumes:
      - ./work:/work
    ports:
      - "6931:6931"
```

- Docker からのファイル操作の速度の関係で WSL2 のファイルシステム上で作業する
  - 参考: https://lazesoftware.com/ja/blog/230130/
- WSL2 の環境設定をする（Ubuntu で）
- 今回は `\\wsl.localhost\Ubuntu\home\<username>\OpenSiv3D_Web_Build` に上記 Dockerfile などを置き、同じディレクトリに `work` ディレクトリを作成し、そこを作業フォルダ（`/work` にマウントされる）として OpenSiv3D for Web のビルドを行うことにした
- Docker コンテナに入って作業。ビルド手順は https://siv3d.kamenokosoft.com/docs/ja/develop/build-siv3d-web/ のほか `ci_web.yml` を参考に

```shell
> docker-compose build
> docker-compose run --service-ports app bash
```

- emsdk のインストール
- 参考: https://qiita.com/terukazu/items/cdc3a4cf9afcae6f7f1b

```shell
$ git clone https://github.com/emscripten-core/emsdk.git
$ cd emsdk
$ ./emsdk install 3.1.20
$ ./emsdk activate 3.1.20
$ export PATH=$PATH:/work/emsdk:/work/emsdk/node/16.20.0_64bit/bin:/work/emsdk/upstream/emscripten
```

- OpenSiv3D をクローン
- boost 1.74.0 をダウンロードして配置
- サードパーティライブラリのビルド

```shell
$ cd /work/OpenSiv3D
$ embuilder.py build ogg vorbis
```

Siv3D のビルド

```shell
$ cd /work/OpenSiv3D/Web
$ mkdir Build
$ cd Build
$ emcmake cmake -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release ..
$ make -j4 install
```

Siv3D サンプルアプリのビルド

```shell
$ cd /work/OpenSiv3D/Web/App
$ mkdir Build
$ cd Build
$ emcmake cmake -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release ..
$ make -j4
```

サンプルアプリの実行（`http://<ipaddr>:6931/`）

```shell
$ cd /work/OpenSiv3D/Web/App
$ emrun --no_browser .
```
