FROM mcr.microsoft.com/azure-cli:2.9.1
LABEL maintainer="Andy Anisimov <andy@dazlab.io>"

ADD run.sh run.sh

RUN apk add --update --no-cache postgresql-client coreutils libc6-compat && \
	wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
	tar -xf azcopy_v10.tar.gz --strip-components=1 && \
	chmod +x azcopy && \
	rm azcopy_v10.tar.gz

CMD ["sh", "run.sh"]
