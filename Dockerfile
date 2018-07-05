FROM google/cloud-sdk:alpine

RUN apk --update add jq py-pip && pip install --upgrade pip yasha

COPY loop.sh /

RUN chmod +x /loop.sh

CMD /loop.sh
