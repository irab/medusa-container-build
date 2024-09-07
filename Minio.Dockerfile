FROM minio/minio:RELEASE.2024-08-29T01-40-52Z-cpuv1

EXPOSE 10000
EXPOSE 10001

COPY ./minio.sh .
ENTRYPOINT [ "/bin/bash", "minio.sh" ]