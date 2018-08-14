#!/bin/bash

if [ ! -f root.pem ];then
	# Generate Root Certificate
	cd /certs && cfssl genkey -initca /opt/cfssl/ca-csr.json | cfssljson -bare root
	cd /opt/cfssl/

	# Generate Root Bundle
	mkdir root_bundle
	cp /certs/root.pem root_bundle
	rm -f root_bundle.crt
	mkbundle -f root_bundle.crt root_bundle

	# Generate Intermediate Certificate
	cfssl gencert -ca /certs/root.pem -ca-key /certs/root-key.pem -config config.json -profile="intermediate" server-ca-csr.json | cfssljson -bare ca-server -

	# Generate Intermediate Bundle
	mkdir int-bundle
	cp root_bundle/root.pem int_bundle
	cp ca-server.pem int_bundle
	mkbundle -f int_bundle.crt int_bundle

	# Generate OCSP Server Certificate
	cfssl gencert -ca ca-server.pem -ca-key ca-server-key.pem -config config.json -profile="ocsp" ocsp-ca-csr.json | cfssljson -bare server-ocsp -
fi
cfssl serve -db-config=db-config.json -ca-key=ca-server-key.pem -ca=ca-server.pem -config config.json -responder=server-ocsp.pem -responder-key=server-ocsp-key.pem -ca-bundle root_bundle.crt -int-bundle int_bundle.crt
