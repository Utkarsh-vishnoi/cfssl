#!/bin/bash

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
cp ca-server.pem sub_bundle
mkbundle -f sub_bundle.crt sub_bundle

# Generate OCSP Server Certificate
cfssl gencert -ca ca-server.pem -ca-key ca-server-key.pem -config config.json -profile="ocsp" ocsp-ca-csr.json | cfssljson -bare server-ocsp -

# Generate OCSP Certificate Bundle
mkdir ocsp-bundle
cp root_bundle/root.pem ocsp_bundle
cp server-ocsp.pem ocsp_bundle
mkbundle -f ocsp_bundle.crt ocsp_bundle

cfsssl serve -db-config=db-pg.json -ca-key=ca-server-key.pem -ca=ca-server.pem -config=config.json -responder=server-ocsp.pem -responder-key=server-ocsp-key.pem -ca-bundle root-bundle.crt -int-bundle sub-bundle.crt
