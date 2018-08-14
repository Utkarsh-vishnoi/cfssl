FROM cfssl/cfssl:latest

RUN apt update

RUN apt install jq -y

RUN go get -u bitbucket.org/liamstask/goose/cmd/goose

RUN goose -path $GOPATH/src/github.com/cloudflare/cfssl/certdb/sqlite -env production up

RUN mv certstore_production.db certs.db

EXPOSE 8888

ADD files/ /opt/cfssl/

ADD cfssl.sh /

RUN chmod +x /cfssl.sh

ENTRYPOINT["/cfssl.sh"]